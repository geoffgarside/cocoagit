//
//  GITPackIndexVersion2.m
//  CocoaGit
//
//  Created by Geoffrey Garside on 04/11/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import "GITPackIndexVersion2.h"
#import "GITUtilityBelt.h"

static const NSUInteger kGITPackIndexFanOutSize  = 4;          //!< bytes
static const NSUInteger kGITPackIndexFanOutCount = 256;
static const NSUInteger kGITPackIndexFanOutStart = 2 * 4;      //!< Starts 2*Size entries in
static const NSUInteger kGITPackIndexFanOutEnd   = 4 * 256;    //!< Update when either of the two above change
static const NSUInteger kGITPackIndexEntrySize   = 24;         //!< bytes

/*! \cond */
@interface GITPackIndexVersion2 ()
- (NSArray*)loadOffsets;
@end
/*! \endcond */

@implementation GITPackIndexVersion2
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
    return 2;
}
- (NSArray*)offsets
{
    if (!offsets)
        offsets = [[self loadOffsets] retain];
    return offsets;
}
- (NSArray*)loadOffsets
{
    unsigned char buf[4];
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
        [self.data getBytes:buf range:NSMakeRange((i * kGITPackIndexFanOutSize) + kGITPackIndexFanOutStart, kGITPackIndexFanOutSize)];
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
@end
