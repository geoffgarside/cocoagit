//
//  GITPackIndexVersion1.m
//  CocoaGit
//
//  Created by Geoffrey Garside on 04/11/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import "GITPackIndexVersion1.h"
#import "GITUtilityBelt.h"
#import "NSData+Hashing.h"

static const NSUInteger kGITPackIndexFanOutSize  = 4;          //!< bytes
static const NSUInteger kGITPackIndexFanOutCount = 256;
static const NSUInteger kGITPackIndexFanOutEnd   = 4 * 256;    //!< Update when either of the two above change
static const NSUInteger kGITPackIndexEntrySize   = 24;         //!< bytes

/*! \cond */
@interface GITPackIndexVersion1 ()
- (NSArray*)loadOffsets;
- (NSRange)rangeOfPackChecksum;
- (NSRange)rangeOfChecksum;
@end
/*! \endcond */

@implementation GITPackIndexVersion1
@synthesize path;
@synthesize data;
- (id)initWithPath:(NSString*)thePath
{
    if (self = [super init])
    {
        NSError * err;
        self.path = thePath;
        self.data = [NSData dataWithContentsOfFile:thePath
                                           options:NSUncachedRead
                                             error:&err];
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
    return 1;
}
- (NSArray*)offsets
{
    if (!offsets)
        offsets = [[self loadOffsets] retain];
    return offsets;
}
- (NSArray*)loadOffsets
{
    uint8_t buf[4];
    NSUInteger i, lastCount, thisCount;
    NSMutableArray * _offsets = [NSMutableArray arrayWithCapacity:256];

    lastCount = thisCount = 0;
    for (i = 0; i < kGITPackIndexFanOutCount; i++)
    {
        [self.data getBytes:buf range:NSMakeRange(i * kGITPackIndexFanOutSize, kGITPackIndexFanOutSize)];
        thisCount = integerFromBytes(buf, kGITPackIndexFanOutSize);

        if (lastCount > thisCount)
        {
            NSString * reason = [NSString stringWithFormat:@"Index: %@ : Invalid fanout %lu -> %lu for entry %d",
                                 [self.path lastPathComponent], lastCount, thisCount, i];
            NSException * ex  = [NSException exceptionWithName:@"GITPackIndexCorrupted"
                                                        reason:reason
                                                      userInfo:nil];
            @throw ex;
        }

        [_offsets addObject:[NSNumber numberWithUnsignedInteger:thisCount]];
        lastCount = thisCount;
    }
    return _offsets;
}
- (NSUInteger)packOffsetForSha1:(NSString*)sha1
{
    uint8_t byte;
    NSData * packedSha1 = packSHA1(sha1);
    [packedSha1 getBytes:&byte length:1];

    NSRange rangeOfShas = [self rangeOfObjectsWithFirstByte:byte];
    if (rangeOfShas.length > 0)
    {
        uint8_t buf[4];

        NSUInteger location = kGITPackIndexFanOutEnd +
        (kGITPackIndexEntrySize * rangeOfShas.location);
        NSUInteger finish   = location +
        (kGITPackIndexEntrySize * rangeOfShas.length);

        for (location; location < finish; location += kGITPackIndexEntrySize)
        {
            memset(buf, 0x0, 4);
            [self.data getBytes:buf range:NSMakeRange(location, 4)];
            NSUInteger offset = integerFromBytes(buf, 4);

            NSData * foundSha1 = [self.data subdataWithRange:NSMakeRange(location + 4, 20)];

            if ([foundSha1 isEqualToData:packedSha1])
                return offset;
        }
    }

    // If its found the SHA1 then it will have returned by now.
    // Otherwise the SHA1 is not in this PACK file, so we should
    // raise an error.
    NSString * reason = [NSString stringWithFormat:@"SHA1 %@ is not known in this Index file %@",
                         sha1, [[self path] lastPathComponent]];
    NSException * ex  = [NSException exceptionWithName:@"GITPackIndexUnknownSHA1"
                                                reason:reason
                                              userInfo:nil];
    @throw ex;
}
- (NSData*)packChecksum
{
    return [self.data subdataWithRange:[self rangeOfPackChecksum]];
}
- (NSString*)packChecksumString
{
    return unpackSHA1FromData([self packChecksum]);
}
- (NSData*)checksum
{
    return [self.data subdataWithRange:[self rangeOfChecksum]];
}
- (NSString*)checksumString
{
    return unpackSHA1FromData([self checksum]);
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
