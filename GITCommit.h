//
//  GITCommit.h
//  CocoaGit
//
//  Created by Geoffrey Garside on 01/07/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GITObject.h"

extern const NSString *kGITObjectCommitType;

@class GITTree, GITActor;

@interface GITCommit : GITObject {
    GITCommit * parent;
    GITTree * tree;
    
    GITActor * author;
    GITActor * committer;
    
    NSCalendarDate * authoredAt;
    NSCalendarDate * committedAt;
    
    NSString * message;
}

#pragma mark -
#pragma mark Properties
@property(retain) GITCommit * parent;
@property(retain) GITTree * tree;

@property(retain) GITActor * author;
@property(retain) GITActor * committer;
@property(retain) NSCalendarDate * authoredAt;
@property(retain) NSCalendarDate * committedAt;

@property(retain) NSString * message;

#pragma mark -
#pragma mark Instance Methods
- (void)setAuthor:(GITActor*)actor withDate:(NSCalendarDate*)theDate;
- (void)setCommitter:(GITActor*)actor withDate:(NSCalendarDate*)theDate;
- (NSString*)formattedActor:(GITActor*)actor withDate:(NSCalendarDate*)theDate;

- (NSString*)objectType;

@end
