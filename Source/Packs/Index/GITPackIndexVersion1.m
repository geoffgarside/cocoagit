//
//  GITPackIndexVersion1.m
//  CocoaGit
//
//  Created by Geoffrey Garside on 04/11/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import "GITPackIndexVersion1.h"
#import "GITPackReverseIndex.h"
#import "GITUtilityBelt.h"
#import "NSData+Hashing.h"
#import "GITErrors.h"

static const NSUInteger kGITPackIndexFanOutSize  = 4;          //!< bytes
static const NSUInteger kGITPackIndexFanOutCount = 256;
static const NSUInteger kGITPackIndexFanOutEnd   = 4 * 256;    //!< Update when either of the two above change
static const NSUInteger kGITPackIndexEntrySize   = 24;         //!< bytes

typedef struct packIndexEntry {
    uint32_t offset;
    uint8_t sha1[20];
} packIndexEntry;

/*! \cond */
@interface GITPackIndexVersion1 ()
- (NSArray*)loadOffsetsWithError:(NSError**)error;
- (NSRange)rangeOfPackChecksum;
- (NSRange)rangeOfChecksum;
- (packIndexEntry *) packEntryWithIndex:(NSUInteger)i;
@end
/*! \endcond */

@implementation GITPackIndexVersion1
@synthesize path;
@synthesize data;
- (id)initWithPath:(NSString*)thePath error:(NSError**)outError
{
    if (self = [super init])
    {
        self.path = thePath;
        self.data = [NSData dataWithContentsOfFile:thePath
                                           options:NSMappedRead
                                             error:outError];
        if (! [self verifyChecksum]) {
            NSString * errDesc = NSLocalizedString(@"PACK Index file checksum failed", @"GITErrorPackIndexChecksumMismatch");
            GITErrorWithInfo(outError, GITErrorPackIndexChecksumMismatch, errDesc, NSLocalizedDescriptionKey, thePath, NSFilePathErrorKey, nil);
            [self release];
            return nil;
        }
    }
    return self;
}

- (void)dealloc
{
    self.path = nil;
    self.data = nil;
    [offsets release], offsets = nil;
    [revIndex release], revIndex = nil;
    [super dealloc];
}

- (GITPackReverseIndex *)revIndex;
{
    if (! revIndex) {
        revIndex = [[GITPackReverseIndex alloc] initWithPackIndex:self];
    }
    return revIndex;
}

- (id)copyWithZone:(NSZone *)zone
{
    if (NSShouldRetainWithZone(self, zone))
        return [self retain];
    else
        return [super copyWithZone:zone];
}
- (NSUInteger)version
{
    return 1;
}
- (NSArray*)offsets
{
    if (!offsets)
        offsets = [[self loadOffsetsWithError:NULL] copy];
    return offsets;
}
- (NSArray*)loadOffsetsWithError:(NSError**)error
{
    uint32_t value;
    NSUInteger i, lastCount, thisCount;
    NSMutableArray * _offsets = [NSMutableArray arrayWithCapacity:256];

    lastCount = thisCount = 0;
    for (i = 0; i < kGITPackIndexFanOutCount; i++)
    {
        [self.data getBytes:&value range:NSMakeRange(i * kGITPackIndexFanOutSize, kGITPackIndexFanOutSize)];
        thisCount = CFSwapInt32BigToHost(value);

        if (lastCount > thisCount)
        {
            NSString * format = NSLocalizedString(@"Index: %@ : Invalid fanout %lu -> %lu for entry %d", @"GITErrorPackIndexCorrupted");
            NSString * reason = [NSString stringWithFormat:format, [self.path lastPathComponent], lastCount, thisCount, i];
            GITError(error, GITErrorPackIndexCorrupted, reason);
            return nil;
        }

        [_offsets addObject:[NSNumber numberWithUnsignedInteger:thisCount]];
        lastCount = thisCount;
    }
    return _offsets;
}
- (off_t) packOffsetForSha1:(NSString*)sha1
{
    return [self packOffsetForSha1:sha1 error:NULL];
}
- (off_t) packOffsetForSha1:(NSString*)sha1 error:(NSError**)error
{
    uint8_t byte;
    NSData * packedSha1 = packSHA1(sha1);
    [packedSha1 getBytes:&byte length:1];

    NSRange rangeOfShas = [self rangeOfObjectsWithFirstByte:byte];
    if (rangeOfShas.length > 0)
    {
        NSUInteger location = kGITPackIndexFanOutEnd +
        (kGITPackIndexEntrySize * rangeOfShas.location);
        NSUInteger finish   = location +
        (kGITPackIndexEntrySize * rangeOfShas.length);

        packIndexEntry entry;
        for (location; location < finish; location += kGITPackIndexEntrySize)
        {
            [self.data getBytes:&entry range:NSMakeRange(location, kGITPackIndexEntrySize)];
            NSData *entrySha1 = [NSData dataWithBytes:entry.sha1 length:20];            
            off_t offset = CFSwapInt32BigToHost(entry.offset);
            if ( [entrySha1 isEqual:packedSha1] )
                return offset;
        }
    }

    // If its found the SHA1 then it will have returned by now.
    // Otherwise the SHA1 is not in this PACK file, so we should
    // raise an error.
    NSString * errorFormat = NSLocalizedString(@"Object %@ is not in index file",@"GITErrorObjectNotFound");
    NSString * errorDesc = [NSString stringWithFormat:errorFormat, sha1];
    GITError(error, GITErrorObjectNotFound, errorDesc);
    return NSNotFound;
}

- (off_t)baseOffsetWithOffset:(off_t)offset;
{
    return (off_t)[[self revIndex] baseOffsetWithOffset:offset];
}

- (off_t)nextOffsetWithOffset:(off_t)offset;
{
    return (off_t)[[self revIndex] nextOffsetWithOffset:offset];
}

- (NSData *)packedSha1WithIndex:(NSUInteger)i;
{
    packIndexEntry *entry = [self packEntryWithIndex:i];
    if ( entry->offset == NSNotFound )
        return nil;
    NSData *packedSha1 = [NSData dataWithBytes:(const uint8_t *)entry->sha1 length:20];
    return packedSha1;
}

- (NSString *)sha1WithOffset:(off_t)offset;
{
    NSUInteger index = [[self revIndex] indexWithOffset:offset];
    return unpackSHA1FromData([self packedSha1WithIndex:index]);
}

- (off_t) packOffsetWithIndex:(NSUInteger)i;
{
    packIndexEntry *entry = [self packEntryWithIndex:i];
    if ( entry->offset == NSNotFound )
        return NSNotFound;
    off_t offset = CFSwapInt32BigToHost(entry->offset);
    return offset;
}

- (packIndexEntry *) packEntryWithIndex:(NSUInteger)i;
{
    NSRange offsetsRange = NSMakeRange(kGITPackIndexFanOutEnd,
                                       [self rangeOfPackChecksum].location - kGITPackIndexFanOutEnd);    
    NSUInteger positionFromStart = i * kGITPackIndexEntrySize;
    
    packIndexEntry entry, *e = &entry;
    if (positionFromStart < offsetsRange.length) {
        [self.data getBytes:e
         range:NSMakeRange(offsetsRange.location + positionFromStart, kGITPackIndexEntrySize)];
        return e;
    }
    entry.offset = NSNotFound;
    return e;
}

- (NSData*)packChecksum
{
    return [self.data subdataWithRange:[self rangeOfPackChecksum]];
}
- (NSData*)checksum
{
    return [self.data subdataWithRange:[self rangeOfChecksum]];
}
- (BOOL)verifyChecksum
{
    NSData * checkData = [[self.data subdataWithRange:NSMakeRange(0, [self.data length] - 20)] sha1Digest];
    return [checkData isEqualToData:[self checksum]];
}
- (NSRange)rangeOfPackChecksum
{
    return NSMakeRange([self.data length] - 40, 20);
}
- (NSRange)rangeOfChecksum
{
    return NSMakeRange([self.data length] - 20, 20);
}
@end
