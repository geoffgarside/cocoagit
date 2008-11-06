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
- (NSUInteger)numberOfObjectsWithFirstByte:(char)byte
{
    return [self rangeOfObjectsWithFirstByte:byte].length;
}
- (NSRange)rangeOfObjectsWithFirstByte:(char)byte
{
    NSUInteger thisFanout, prevFanout = 0;
    thisFanout = [[[self offsets] objectAtIndex:byte] unsignedIntegerValue];
    if (byte != 0x0)
        prevFanout = [[[self offsets] objectAtIndex:byte - 1] unsignedIntegerValue];
    return NSMakeRange(prevFanout, thisFanout - prevFanout);
}

@end
