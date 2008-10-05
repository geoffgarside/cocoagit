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
#import "NSTimeZone+Offset.h"

@interface GITCommit ()
@property(readwrite,copy) GITRepo * repo;
@property(readwrite,copy) NSString * sha1;
@property(readwrite,assign) NSUInteger size;
@property(readwrite,copy) GITTree * tree;
@property(readwrite,copy) GITCommit * parent;
@property(readwrite,copy) GITActor * author;
@property(readwrite,copy) GITActor * committer;
@property(readwrite,copy) NSDate * authoredAt;
@property(readwrite,copy) NSDate * committedAt;
@property(readwrite,copy) NSTimeZone * authoredTz;
@property(readwrite,copy) NSTimeZone * committedTz;

- (void)extractFieldsFromData:(NSData*)data;

@end

@implementation GITCommit

@synthesize repo;
@synthesize sha1;
@synthesize size;
@synthesize tree;
@synthesize parent;
@synthesize author;
@synthesize committer;
@synthesize authoredAt;
@synthesize committedAt;
@synthesize authoredTz;
@synthesize committedTz;

- (id)initWithHash:(NSString*)hash
           andData:(NSData*)data
          fromRepo:(GITRepo*)repo
{
    if (self = [super init])
    {
        self.repo = repo;
        self.sha1 = hash;
        self.size = [data length];
        
        [self extractFieldsFromData:data];
    }
    return self;
}
- (void)dealloc
{
    self.repo = nil;
    self.sha1 = nil;
    self.size = 0;
    self.tree = nil;
    self.parent = nil;
    self.author = nil;
    self.committer = nil;
    self.authoredAt = nil;
    self.committedAt = nil;
    self.authoredTz = nil;
    self.committedTz = nil;
    
    [super dealloc];
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
             * committerTimezone,
             * msg;
    NSTimeInterval authorTimestamp,
                   committerTimestamp;
     
    if ([scanner scanString:@"tree" intoString:NULL] &&
        [scanner scanUpToString:NewLine intoString:&commitTree])
    {
        self.tree = [self.repo treeWithHash:commitTree];
    }
    
    if ([scanner scanString:@"parent" intoString:NULL] &&
        [scanner scanUpToString:NewLine intoString:&commitParent])
    {
        self.parent = [self.repo commitWithHash:commitParent];
    }
    
    if ([scanner scanString:@"author" intoString:NULL] &&
        [scanner scanUpToString:@"<" intoString:&authorName] &&
        [scanner scanUpToString:@">" intoString:&authorEmail] &&
        [scanner scanDouble:&authorTimestamp] &&
        [scanner scanUpToString:NewLine intoString:&authorTimezone])
    {
        self.author = [[GITActor alloc] initWithName:authorName andEmail:authorEmail];
        self.authoredAt = [NSDate dateWithTimeIntervalSince1970:authorTimestamp];
        self.authoredTz = [NSTimeZone timeZoneWithStringOffset:authorTimezone];
    }
    
    if ([scanner scanString:@"committer" intoString:NULL] &&
        [scanner scanUpToString:@"<" intoString:&committerName] &&
        [scanner scanUpToString:@">" intoString:&committerEmail] &&
        [scanner scanDouble:&committerTimestamp] &&
        [scanner scanUpToString:NewLine intoString:&committerTimezone])
    {
        self.committer = [[GITActor alloc] initWithName:committerName andEmail:committerEmail];
        self.committedAt = [NSDate dateWithTimeIntervalSince1970:committerTimestamp];
        self.committedTz = [NSTimeZone timeZoneWithStringOffset:committerTimezone];
    }
        
    self.message = [[scanner string] substringFromIndex:[scanner scanLocation]];
}
- (NSString*)description
{
    return [NSString stringWithFormat:@"Commit <%@>", self.sha1];
}

@end
