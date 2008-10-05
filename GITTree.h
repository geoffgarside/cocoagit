//
//  GITTree.h
//  CocoaGit
//
//  Created by Geoffrey Garside on 05/08/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GITObject.h"

@class GITRepo;
@interface GITTree : NSObject <GITObject>
{
    GITRepo  * repo;
    NSString * sha1;
    NSUInteger size;
    NSArray  * entries;
}

@property(readonly,copy) NSString * sha1;
@property(readonly,assign) NSUInteger size;
@property(readonly,copy) NSArray * entries;

@end
