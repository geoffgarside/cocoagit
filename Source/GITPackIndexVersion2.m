//
//  GITPackIndexVersion2.m
//  CocoaGit
//
//  Created by Geoffrey Garside on 04/11/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import "GITPackIndexVersion2.h"
#import "GITUtilityBelt.h"

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
- (NSArray*)loadOffsets;
- (NSRange)rangeOfSignature;
- (NSRange)rangeOfVersion;
- (NSRange)rangeOfFanoutTable;
- (NSRange)rangeOfSHATable;
- (NSRange)rangeOfCRCTable;
- (NSRange)rangeOfOffsetTable;
- (NSRange)rangeOfExtendedOffsetTable;
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
    uint8_t buf[4];
    NSUInteger i, lastCount, thisCount;
    NSMutableArray * _offsets = [NSMutableArray arrayWithCapacity:256];

    lastCount = thisCount = 0;
    for (i = 0; i < kGITPackIndexFanoutCount; i++)
    {
        NSRange range = NSMakeRange(i * kGITPackIndexFanoutSize +
            [self rangeOfFanoutTable].location, kGITPackIndexFanoutSize);
        [self.data getBytes:buf range:range];
        thisCount = integerFromBytes(buf, kGITPackIndexFanoutSize);

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
    return NSMakeRange(endOfOffsetTable, 0);    //!< Not sure what the length value should be here.
}
@end
