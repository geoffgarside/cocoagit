//
//  GITObjectStore.m
//  CocoaGit
//
//  Created by Geoffrey Garside on 09/10/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import "GITObjectStore.h"


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
@end
