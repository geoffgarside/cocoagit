//
//  GITTreeEntry.h
//  CocoaGit
//
//  Created by Geoffrey Garside on 06/07/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class GITObject;

@interface GITTreeEntry : NSObject {
    NSString * name;
    NSString * sha1;
    NSUInteger mode;
    
    GITObject *object;
}

@property(retain) NSString * name;
@property(retain) NSString * sha1;
@property(assign) NSUInteger mode;
@property(readonly) GITObject * object;

@end
