//
//  GITPackIndex.m
//  CocoaGit
//
//  Created by Geoffrey Garside on 04/11/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import "GITPackIndex.h"

@implementation GITPackIndex
#pragma mark -
#pragma mark Class Cluster Alloc Methods
+ (id)alloc
{
    if ([self isEqual:[GITPackIndex class]])
        return [GITPlaceholderPackIndex alloc];
    else return [super alloc];
}
+ (id)allocWithZone:(NSZone*)zone
{
    if ([self isEqual:[GITPackIndex class]])
        return [GITPlaceholderPackIndex allocWithZone:zone];
    else return [super allocWithZone:zone];
}
- (id)copyWithZone:(NSZone*)zone
{
    return self;
}

#pragma mark -
#pragma mark Primitive Methods
- (id)initWithPath:(NSString*)thePath
{
    [self doesNotRecognizeSelector: _cmd];
    [self release];
    return nil;
}
- (NSUInteger)version
{
    return 0;
}
- (NSArray*)offsets
{
    [self doesNotRecognizeSelector: _cmd];
    return nil;
}

#pragma mark -
#pragma mark Derived Methods
- (NSUInteger)numberOfObjects
{
    return [[[self offsets] lastObject] unsignedIntegerValue];
}
// TODO: Refactor this into wherever it should go
// - (NSUInteger)offsetForSha1:(NSString*)sha1
// {
//     unichar firstByte = [sha1 characterAtIndex:0];
//     NSUInteger thisFanout, prevFanout = 0;
//     
//     // prevFanout = number of objects with firstByte less than that of sha1
//     // thisFanout = number of objects with firstByte less than or equal to that of sha1
//     // fanoutDiff = number of objects with firstByte equal to that of sha1
//     thisFanout = [[[self offsets] objectAtIndex:firstByte] unsignedIntegerValue];
//     if (firstByte != 0x0)
//         prevFanout = [[[self offsets] objectAtIndex:firstByte - 1] unsignedIntegerValue];
//     
//     // There are entries to examine
//     if (thisFanout > prevFanout)
//     {
//         NSUInteger i;
//         char buf[20];
//         
//         NSUInteger startLocation = kGITPackIndexFanOutEnd +
//         (kGITPackIndexEntrySize * prevFanout);
//         NSUInteger endLocation   = kGITPackIndexFanOutEnd +
//         (kGITPackIndexEntrySize * thisFanout);
//         
//         for (i = startLocation; i < endLocation; i += kGITPackIndexEntrySize)
//         {
//             memset(buf, 0x0, 20);
//             [self.idxData getBytes:buf range:NSMakeRange(i, 4)];
//             NSUInteger offset = integerFromBytes(buf, 4);
//             
//             memset(buf, 0x0, 20);
//             [[self data] getBytes:buf range:NSMakeRange(i + 4, 20)];
//             NSString * packedSha1 = [[NSString alloc] initWithBytes:buf
//                                                              length:20
//                                                            encoding:NSASCIIStringEncoding];
//             NSString * name = unpackSHA1FromString(packedSha1);
//             
//             if ([name isEqualToString:sha1])
//                 return offset;
//         }
//     }
//     
//     // If its found the SHA1 then it will have returned by now.
//     // Otherwise the SHA1 is not in this PACK file, so we should
//     // raise an error.
//     NSString * reason = [NSString stringWithFormat:@"SHA1 %@ is not known in this Index file %@",
//                          sha1, [[self path] lastPathComponent]];
//     NSException * ex  = [NSException exceptionWithName:@"GITPackIndexUnknownSHA1"
//                                                 reason:reason
//                                               userInfo:nil];
//     @throw ex;
// }

@end
