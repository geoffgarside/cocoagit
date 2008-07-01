//
//  GITTag.m
//  CocoaGit
//
//  Created by Geoffrey Garside on 01/07/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import "GITTag.h"

const NSString *kGITObjectTagType = @"tag";

@implementation GITTag

#pragma mark -
#pragma mark Properties
@synthesize ref;
@synthesize type;
@synthesize name;
@synthesize tagger;
@synthesize taggedAt;

#pragma mark -
#pragma mark Instance Methods
- (NSString*)objectType
{
    return kGITObjectTagType;
}

@end
