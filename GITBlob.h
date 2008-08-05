//
//  GITBlob.h
//  CocoaGit
//
//  Created by Geoffrey Garside on 05/08/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class GITRepo;
@protocol GITObject;
@interface GITBlob : NSObject <GITObject>
{
    GITRepo  * repo;
    NSString * sha1;
    NSUInteger size;
    NSData   * data;
}

@property(readonly,copy) NSString * sha1;
@property(readonly,assign) NSUInteger size;
@property(readonly,copy) NSData * data;

- (BOOL)canBeRepresentedAsString;
- (NSString*)stringValue;

@end
