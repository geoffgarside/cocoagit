//
//  GITObjectStore.m
//  CocoaGit
//
//  Created by Geoffrey Garside on 09/10/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import "GITObjectStore.h"
#import "NSData+Searching.h"

@implementation GITObjectStore
- (id)initWithRoot:(NSString*)root
{
    [self doesNotRecognizeSelector:_cmd];
    [self release];
    return nil;
}
- (NSData*)dataWithContentsOfObject:(NSString*)sha1
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}
- (BOOL)extractFromObject:(NSString*)sha1 type:(NSString**)type
                     size:(NSUInteger*)size data:(NSData**)data
{
    NSData * raw  = [self dataWithContentsOfObject:sha1];
    NSRange range = [raw rangeOfNullTerminatedBytesFrom:0];
    NSData * meta = [raw subdataWithRange:range];
    *data = [raw subdataFromIndex:range.length + 1];

    NSString * metaStr = [[NSString alloc] initWithData:meta
                                               encoding:NSASCIIStringEncoding];
    NSUInteger indexOfSpace = [metaStr rangeOfString:@" "].location;

    *type = [metaStr substringToIndex:indexOfSpace];
    *size = (NSUInteger)[[metaStr substringFromIndex:indexOfSpace + 1] integerValue];

    if (data && type && size)
        return YES;
    return NO;
}
@end
