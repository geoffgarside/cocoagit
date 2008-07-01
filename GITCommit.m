//
//  GITCommit.m
//  CocoaGit
//
//  Created by Geoffrey Garside on 01/07/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import "GITCommit.h"
#import "GITTree.h"
#import "GITUser.h"

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
- (void)setAuthor:(GITUser*)user withDate:(NSCalendarDate*)theDate
{
    self.author = user;
    self.authoredAt = theDate;
}
- (void)setCommitter:(GITUser*)user withDate:(NSCalendarDate*)theDate
{
    self.committer = user;
    self.committedAt = theDate;
}
- (NSString*)formattedUser:(GITUser*)theUser withDate:(NSCalendarDate*)theDate
{
    return [NSString stringWithFormat:@"%@ %d %@", theUser,
            [theDate timeIntervalSince1970], [theDate descriptionWithCalendarFormat:@"%z"]];
}
- (NSString*)objectType
{
    return kGITObjectCommitType;
}

@end
