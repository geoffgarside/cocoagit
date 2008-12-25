//
//  GITPackIndex.m
//  CocoaGit
//
//  Created by Geoffrey Garside on 04/11/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import "GITPackIndex.h"
#import "GITUtilityBelt.h"

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
    return [self initWithPath:thePath error:NULL];
}
- (id)initWithPath:(NSString*)thePath error:(NSError**)outError
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
- (NSData*)checksum
{
    [self doesNotRecognizeSelector: _cmd];
    return nil;
}
- (NSData*)packChecksum
{
    [self doesNotRecognizeSelector: _cmd];
    return nil;
}
- (NSString*)checksumString
{
    return unpackSHA1FromData([self checksum]);
}
- (NSString*)packChecksumString
{
    return unpackSHA1FromData([self packChecksum]);
}
- (BOOL)verifyChecksum
{
    [self doesNotRecognizeSelector: _cmd];
    return NO;
}
- (NSUInteger)packOffsetForSha1:(NSString *)sha1
{
    return [self packOffsetForSha1:sha1 error:NULL];
}
- (NSUInteger)packOffsetForSha1:(NSString *)sha1 error:(NSError **)error
{
    [self doesNotRecognizeSelector: _cmd];
    return 0;
}
#pragma mark -
#pragma mark Derived Methods
- (NSUInteger)numberOfObjects
{
    return [[[self offsets] lastObject] unsignedIntegerValue];
}
- (NSUInteger)numberOfObjectsWithFirstByte:(uint8_t)byte
{
    return [self rangeOfObjectsWithFirstByte:byte].length;
}
- (NSRange)rangeOfObjectsWithFirstByte:(uint8_t)byte
{
    NSUInteger thisFanout, prevFanout = 0;
    thisFanout = [[[self offsets] objectAtIndex:byte] unsignedIntegerValue];
    if (byte != 0x0)
        prevFanout = [[[self offsets] objectAtIndex:byte - 1] unsignedIntegerValue];
    return NSMakeRange(prevFanout, thisFanout - prevFanout);
}
- (BOOL)hasObjectWithSha1:(NSString*)sha1
{
    if ([self packOffsetForSha1:sha1] > 0)
        return YES;
    return NO;
}

@end
