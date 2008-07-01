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

@class GITTree, GITUser

@interface GITCommit : GITObject {
    GITCommit * parent;
    GITTree * tree;
    
    GITUser * author;
    GITUser * committer;
    
    NSCalendarDate * authoredAt;
    NSCalendarDate * committedAt;
    
    NSString * message;
}

#pragma mark -
#pragma mark Properties
@property(retain) GITCommit * parent;
@property(retain) GITTree * tree;

@property(retain) GITUser * author;
@property(retain) GITUser * committer;
@property(retain) NSCalendarDate * authoredAt;
@property(retain) NSCalendarDate * committedAt;

@property(retain) NSString * message;

#pragma mark -
#pragma mark Instance Methods
- (void)setAuthor:(GITUser*)user withDate:(NSCalendarDate*)theDate;
- (void)setCommitter:(GITUser*)user withDate:(NSCalendarDate*)theDate;
- (NSString*)formattedUser:(GITUser*)theUser withDate:(NSCalendarDate*)theDate;

@end
