//
//  GITCommit.m
//  CocoaGit
//
//  Created by Geoffrey Garside on 01/07/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import "GITCommit.h"
#import "GITTree.h"
#import "GITActor.h"

const NSString *kGITObjectCommitType = @"commit";

@implementation GITCommit

#pragma mark -
#pragma mark Properties
@synthesize parent;
@synthesize tree;
@synthesize author;
@synthesize committer;
@synthesize authoredAt;
@synthesize committedAt;
@synthesize message;

#pragma mark -
#pragma mark Instance Methods
- (void)setAuthor:(GITActor*)actor withDate:(NSCalendarDate*)theDate
{
    self.author = actor;
    self.authoredAt = theDate;
}
- (void)setCommitter:(GITActor*)actor withDate:(NSCalendarDate*)theDate
{
    self.committer = actor;
    self.committedAt = theDate;
}
- (NSString*)formattedUser:(GITActor*)actor withDate:(NSCalendarDate*)date
{
    return [NSString stringWithFormat:@"%@ %d %@", actor,
            [date timeIntervalSince1970], [date descriptionWithCalendarFormat:@"%z"]];
}
- (NSString*)objectType
{
    return kGITObjectCommitType;
}

@end
