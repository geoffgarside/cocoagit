//
//  GITCommit.m
//  CocoaGit
//
//  Created by Geoffrey Garside on 05/08/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import "GITCommit.h"
#import "GITRepo.h"
#import "GITTree.h"
#import "GITActor.h"
#import "GITDateTime.h"

NSString * const kGITObjectCommitName = @"commit";

/*! \cond
 Make properties readwrite so we can use
 them within the class.
*/
@interface GITCommit ()
@property(readwrite,copy) GITTree * tree;
@property(readwrite,copy) GITCommit * parent;
@property(readwrite,copy) GITActor * author;
@property(readwrite,copy) GITActor * committer;
@property(readwrite,copy) GITDateTime * authored;
@property(readwrite,copy) GITDateTime * committed;
@property(readwrite,copy) NSString * message;

- (void)extractFieldsFromData:(NSData*)data;

@end
/*! \endcond */

@implementation GITCommit
@synthesize tree;
@synthesize parent;
@synthesize author;
@synthesize committer;
@synthesize authored;
@synthesize committed;
@synthesize message;

+ (NSString*)typeName
{
    return kGITObjectCommitName;
}
- (id)initWithSha1:(NSString*)newSha1 data:(NSData*)raw repo:(GITRepo*)theRepo
{
    if (self = [super initType:kGITObjectCommitName sha1:newSha1
                          size:[raw length] repo:theRepo])
    {
        [self extractFieldsFromData:raw];
    }
    return self;
}
- (void)dealloc
{
    self.tree = nil;
    self.parent = nil;
    self.author = nil;
    self.committer = nil;
    self.authored = nil;
    self.committed = nil;
    
    [super dealloc];
}
- (id)copyWithZone:(NSZone*)zone
{
    GITCommit * commit  = (GITCommit*)[super copyWithZone:zone];
    commit.tree         = self.tree;
    commit.parent       = self.parent;
    commit.author       = self.author;
    commit.committer    = self.committer;
    commit.authored     = self.authored;
    commit.committed    = self.committed;
    
    return commit;
}
- (void)extractFieldsFromData:(NSData*)data
{
    NSString  * dataStr = [[NSString alloc] initWithData:data 
                                                encoding:NSASCIIStringEncoding];
    NSScanner * scanner = [NSScanner scannerWithString:dataStr];
    
    static NSString * NewLine = @"\n";
    NSString * commitTree,
             * commitParent,
             * authorName,
             * authorEmail,
             * authorTimezone,
             * committerName,
             * committerEmail,
             * committerTimezone;

    NSTimeInterval authorTimestamp,
                   committerTimestamp;
     
    if ([scanner scanString:@"tree" intoString:NULL] &&
        [scanner scanUpToString:NewLine intoString:&commitTree])
    {
        self.tree = [self.repo treeWithSha1:commitTree];
    }
    
    if ([scanner scanString:@"parent" intoString:NULL] &&
        [scanner scanUpToString:NewLine intoString:&commitParent])
    {
        self.parent = [self.repo commitWithSha1:commitParent];
    }
    
    if ([scanner scanString:@"author" intoString:NULL] &&
        [scanner scanUpToString:@"<" intoString:&authorName] &&
        [scanner scanString:@"<" intoString:NULL] &&
        [scanner scanUpToString:@">" intoString:&authorEmail] &&
        [scanner scanString:@">" intoString:NULL] &&
        [scanner scanDouble:&authorTimestamp] &&
        [scanner scanUpToString:NewLine intoString:&authorTimezone])
    {
        self.author = [[GITActor alloc] initWithName:authorName andEmail:authorEmail];
        self.authored = [[GITDateTime alloc] initWithTimestamp:authorTimestamp
                                                timeZoneOffset:authorTimezone];
    }
    
    if ([scanner scanString:@"committer" intoString:NULL] &&
        [scanner scanUpToString:@"<" intoString:&committerName] &&
        [scanner scanString:@"<" intoString:NULL] &&
        [scanner scanUpToString:@">" intoString:&committerEmail] &&
        [scanner scanString:@">" intoString:NULL] &&
        [scanner scanDouble:&committerTimestamp] &&
        [scanner scanUpToString:NewLine intoString:&committerTimezone])
    {
        self.committer = [[GITActor alloc] initWithName:committerName andEmail:committerEmail];
        self.committed = [[GITDateTime alloc] initWithTimestamp:committerTimestamp
                                                 timeZoneOffset:committerTimezone];
    }
        
    self.message = [[scanner string] substringFromIndex:[scanner scanLocation]];
}
- (NSString*)description
{
    return [NSString stringWithFormat:@"Commit <%@>", self.sha1];
}
- (NSData*)rawContent
{
    return [[NSString stringWithFormat:@"tree %@\nparent %@\nauthor %@ %@\ncommitter %@ %@\n%@",
             self.tree.sha1, self.parent.sha1, self.author, self.authored,
             self.committer, self.committed, self.message] dataUsingEncoding:NSASCIIStringEncoding];
}

@end
