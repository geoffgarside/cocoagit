//
//  GITCommit.h
//  CocoaGit
//
//  Created by Geoffrey Garside on 05/08/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class GITRepo, GITTree, GITActor;
@protocol GITObject;
@interface GITCommit : NSObject <GITObject>
{
    GITRepo  * repo;
    NSString * sha1;
    NSUInteger size;
    GITTree  * tree;
    
    GITCommit * parent;
    GITActor  * author;
    GITActor  * committer;
    
    NSDate * authoredAt;
    NSDate * committedAt;
    
    NSTimeZone * authoredTz;
    NSTimeZone * committedTz;
    
    NSString * message;
}

@property(readonly,copy) NSString * sha1;
@property(readonly,assign) NSUInteger size;
@property(readonly,copy) GITTree * tree;
@property(readonly,copy) GITCommit * parent;
@property(readonly,copy) GITActor * author;
@property(readonly,copy) GITActor * committer;
@property(readonly,copy) NSDate * authoredAt;
@property(readonly,copy) NSDate * committedAt;
@property(readonly,copy) NSTimeZone * authoredTz;
@property(readonly,copy) NSTimeZone * committedTz;

@end
