//
//  GITTag.h
//  CocoaGit
//
//  Created by Geoffrey Garside on 05/08/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GITObject.h"

@class GITRepo, GITCommit, GITActor;
@interface GITTag : NSObject <GITObject>
{
    GITRepo  * repo;
    NSString * name;
    NSString * sha1;
    NSUInteger size;
    
    // At such time as Tags can reference objects
    // other than commits we'll change this.
    GITCommit * commit;
    GITActor  * tagger;
    
    NSDate * taggedAt;
    NSTimeZone * taggedTz;
    
    NSString * message;
}

@property(readonly,copy) NSString * name;
@property(readonly,copy) NSString * sha1;
@property(readonly,assign) NSUInteger size;
@property(readonly,copy) GITCommit * commit;
@property(readonly,copy) GITActor * tagger;
@property(readonly,copy) NSDate * taggedAt;
@property(readonly,copy) NSTimeZone * taggedTz;
@property(readonly,copy) NSString * message;

@end
