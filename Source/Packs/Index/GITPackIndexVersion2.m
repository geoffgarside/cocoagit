//
//  GITPackIndexVersion2.m
//  CocoaGit
//
//  Created by Geoffrey Garside on 04/11/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import "GITPackIndexVersion2.h"
#import "GITUtilityBelt.h"
#import "NSData+Hashing.h"
#import "GITErrors.h"

#define EXTENDED_OFFSET_FLAG (1 << 31)

static const NSRange kGITPackIndexSignature             = {0, 4};
static const NSRange kGITPackIndexVersion               = {4, 4};

static const NSRange kGITPackIndexFanout                = {8, 256 * 4};
static const NSUInteger kGITPackIndexFanoutSize         = 4;
static const NSUInteger kGITPackIndexFanoutCount        = 256;

static const NSUInteger kGITPackIndexSHASize            = 20;
static const NSUInteger kGITPackIndexCRCSize            = 4;
static const NSUInteger kGITPackIndexOffsetSize         = 4;
static const NSUInteger kGITPackIndexExtendedOffsetSize = 8;

/*! \cond */
@interface GITPackIndexVersion2 ()
- (NSArray*)loadOffsetsWithError:(NSError**)error;
- (NSRange)rangeOfSignature;
- (NSRange)rangeOfVersion;
- (NSRange)rangeOfFanoutTable;
- (NSRange)rangeOfSHATable;
- (NSRange)rangeOfCRCTable;
- (NSRange)rangeOfOffsetTable;
- (NSRange)rangeOfExtendedOffsetTable;
- (NSRange)rangeOfPackChecksum;
- (NSRange)rangeOfChecksum;
- (NSUInteger)packOffsetWithIndex:(NSUInteger)i;
@end
/*! \endcond */

@implementation GITPackIndexVersion2
@synthesize path;
@synthesize data;

- (id)initWithPath:(NSString*)thePath error:(NSError**)outError
{
    if (self = [super init])
    {
        self.path = thePath;
        self.data = [NSData dataWithContentsOfFile:thePath
                                           options:NSUncachedRead
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
    [super dealloc];
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
    return 2;
}
- (NSArray*)offsets
{
    if (!offsets)
        offsets = [[self loadOffsetsWithError:NULL] retain];
    return offsets;
}
- (NSArray*)loadOffsetsWithError:(NSError**)error
{
    uint32_t value;
    NSUInteger i, lastCount, thisCount;
    NSMutableArray * _offsets = [NSMutableArray arrayWithCapacity:256];

    lastCount = thisCount = 0;
    for (i = 0; i < kGITPackIndexFanoutCount; i++)
    {
        NSRange range = NSMakeRange(i * kGITPackIndexFanoutSize +
            [self rangeOfFanoutTable].location, kGITPackIndexFanoutSize);
        [self.data getBytes:&value range:range];
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
// The sha1 to offset mapping in v2 Index files works like this
//  - the fanout table tells you where in the main entry table you can find SHA's with a specific first byte
//  - the main sha1 list table gives you a sorted list of SHA1's in the Index and Pack file. The array index
//    of the SHA1 in this table equates to the array index of the pack offset in the offsets table.
- (NSUInteger)packOffsetForSha1:(NSString*)sha1
{
    return [self packOffsetForSha1:sha1 error:NULL];
}
- (NSUInteger)packOffsetForSha1:(NSString*)sha1 error:(NSError**)error
{
    uint8_t byte;
    NSData * packedSha1 = packSHA1(sha1);
    [packedSha1 getBytes:&byte length:1];

    NSRange rangeOfShas = [self rangeOfObjectsWithFirstByte:byte];
    if (rangeOfShas.length > 0)
    {
        NSUInteger i;
        NSUInteger location = [self rangeOfSHATable].location +
            (kGITPackIndexSHASize * rangeOfShas.location);
        NSUInteger finish   = location +
            (kGITPackIndexSHASize * rangeOfShas.length);

        for (i = 0; location < finish; i++, location += kGITPackIndexSHASize)
        {
            NSData * foundSha1 = [self.data subdataWithRange:NSMakeRange(location, 20)];

            if ([foundSha1 isEqualToData:packedSha1])
                return [self packOffsetWithIndex:i + rangeOfShas.location];
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
- (NSRange)rangeOfSignature
{
    return kGITPackIndexSignature;
}
- (NSRange)rangeOfVersion
{
    return kGITPackIndexVersion;
}
- (NSRange)rangeOfFanoutTable
{
    return kGITPackIndexFanout;
}
- (NSRange)rangeOfSHATable
{
    NSUInteger endOfFanout = [self rangeOfFanoutTable].location + [self rangeOfFanoutTable].length;
    return NSMakeRange(endOfFanout, kGITPackIndexSHASize * [self numberOfObjects]);
}
- (NSRange)rangeOfCRCTable
{
    NSUInteger endOfSHATable = [self rangeOfSHATable].location + [self rangeOfSHATable].length;
    return NSMakeRange(endOfSHATable, kGITPackIndexCRCSize * [self numberOfObjects]);
}
- (NSRange)rangeOfOffsetTable
{
    NSUInteger endOfCRCTable = [self rangeOfCRCTable].location + [self rangeOfCRCTable].length;
    return NSMakeRange(endOfCRCTable, kGITPackIndexOffsetSize * [self numberOfObjects]);
}
- (NSRange)rangeOfExtendedOffsetTable
{
    NSUInteger endOfOffsetTable = [self rangeOfOffsetTable].location + [self rangeOfOffsetTable].length;
    return NSMakeRange(endOfOffsetTable, endOfOffsetTable - [self.data length] - 40);    //!< Not sure what the length value should be here.
}
- (NSRange)rangeOfPackChecksum
{
    return NSMakeRange([self.data length] - 40, 20);
}
- (NSRange)rangeOfChecksum
{
    return NSMakeRange([self.data length] - 20, 20);
}
- (NSUInteger)packOffsetWithIndex:(NSUInteger)i
{
    NSRange offsetsRange = [self rangeOfOffsetTable];
    NSUInteger positionFromStart = i * kGITPackIndexOffsetSize;

    if (positionFromStart < offsetsRange.length)
    {
        uint32_t value;
        [self.data getBytes:&value range:NSMakeRange(offsetsRange.location + positionFromStart, kGITPackIndexOffsetSize)];

        value = CFSwapInt32BigToHost(value);
        if ((value & EXTENDED_OFFSET_FLAG) == 0)
            return value;
        else
        {
            value = (value | ~EXTENDED_OFFSET_FLAG);
            // Now get the correct offset from the extended offset table
            NSLog(@"Value (%lu) extended offset range { %lu, %lu }", value,
                  [self rangeOfExtendedOffsetTable].location, [self rangeOfExtendedOffsetTable].length);
        }
    }
    return 0;
}
@end
