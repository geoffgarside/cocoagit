//
//  GITPackIndexVersion1.m
//  CocoaGit
//
//  Created by Geoffrey Garside on 04/11/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import "GITPackIndexVersion1.h"
#import "GITUtilityBelt.h"

static const NSUInteger kGITPackIndexFanOutSize  = 4;          //!< bytes
static const NSUInteger kGITPackIndexFanOutCount = 256;
static const NSUInteger kGITPackIndexFanOutEnd   = 4 * 256;    //!< Update when either of the two above change
static const NSUInteger kGITPackIndexEntrySize   = 24;         //!< bytes

/*! \cond */
@interface GITPackIndexVersion1 ()
- (NSArray*)loadOffsets;
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
    char buf[4];
    NSUInteger i, lastCount, thisCount;
    NSMutableArray * _offsets = [NSMutableArray arrayWithCapacity:256];

    lastCount = thisCount = 0;

    // The Fanout table
    // The fanout table consists of 256 entries. These
    // entries correspond to the first byte of an object
    // sha1. The value at each entry is the number of
    // object sha1's in the corresponding PACK file
    // in which the first byte is less than or equal
    // to the entry index. This also applies to the
    // list of SHA1 entries in the IDX file as well.
    // The value of each entry should be greater than
    // or equal to the previous value, if it is not
    // then the index file is corrupt.
    // At the moment I am not sure if the fan out
    // entry index corresponds to the compressed or
    // uncompressed SHA1 hash value.
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
    NSRange range = [self rangeOfObjectsWithFirstByte:[sha1 characterAtIndex:0]];
    if (range.length > 0)
    {
        unsigned char buf[20];

        NSUInteger location = kGITPackIndexFanOutEnd +
        (kGITPackIndexEntrySize * range.location);
        NSUInteger finish   = location +
        (kGITPackIndexEntrySize * range.length);

        for (location; location < finish; location += kGITPackIndexEntrySize)
        {
            memset(buf, 0x0, 20);
            [self.data getBytes:buf range:NSMakeRange(location, 4)];
            NSUInteger offset = integerFromBytes(buf, 4);

            memset(buf, 0x0, 20);
            [self.data getBytes:buf range:NSMakeRange(location + 4, 20)];
            NSString * packedSha1 = [[NSString alloc] initWithBytes:buf
                                                             length:20
                                                           encoding:NSASCIIStringEncoding];
            NSString * name = unpackSHA1FromString(packedSha1);

            if ([name isEqualToString:sha1])
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
@end
