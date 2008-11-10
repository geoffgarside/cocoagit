//
//  GITPackFile.m
//  CocoaGit
//
//  Created by Geoffrey Garside on 05/08/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import "GITPackFile.h"

@implementation GITPackFile
#pragma mark -
#pragma mark Class Cluster Alloc Methods
+ (id)alloc
{
    if ([self isEqual:[GITPackFile class]])
        return [GITPlaceholderPackFile alloc];
    else return [super alloc];
}
+ (id)allocWithZone:(NSZone*)zone
{
    if ([self isEqual:[GITPackFile class]])
        return [GITPlaceholderPackFile allocWithZone:zone];
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
- (NSData*)objectAtOffset:(NSUInteger)offset
{
    [self doesNotRecognizeSelector: _cmd];
    return nil;
}

#pragma mark -
#pragma mark Derived Methods

@end
