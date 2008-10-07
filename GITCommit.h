//
//  GITCommit.h
//  CocoaGit
//
//  Created by Geoffrey Garside on 05/08/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GITObject.h"

@class GITRepo, GITTree, GITActor, GITDateTime;
@interface GITCommit : NSObject <GITObject>
{
    GITRepo  * repo;
    NSString * sha1;
    NSUInteger size;
    GITTree  * tree;
    
    GITCommit * parent;
    GITActor  * author;
    GITActor  * committer;
    
    GITDateTime * authored;
    GITDateTime * committed;
    
    NSString * message;
}

@property(readonly,copy) NSString * sha1;
@property(readonly,assign) NSUInteger size;
@property(readonly,copy) GITTree * tree;
@property(readonly,copy) GITCommit * parent;
@property(readonly,copy) GITActor * author;
@property(readonly,copy) GITActor * committer;
@property(readonly,copy) GITDateTime * authored;
@property(readonly,copy) GITDateTime * committed;
@property(readonly,copy) NSString * message;

@end
