//
//  GITTag.m
//  CocoaGit
//
//  Created by Geoffrey Garside on 05/08/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import "GITTag.h"
#import "GITRepo+Protected.h"
#import "GITActor.h"
#import "GITCommit.h"
#import "GITDateTime.h"

@interface GITTag ()
@property(readwrite,retain) GITRepo * repo;
@property(readwrite,copy) NSString * name;
@property(readwrite,copy) NSString * sha1;
@property(readwrite,assign) NSUInteger size;
@property(readwrite,copy) GITCommit * commit;
@property(readwrite,copy) GITActor * tagger;
@property(readwrite,copy) GITDateTime * tagged;
@property(readwrite,copy) NSString * message;

- (void)extractFieldsFromData:(NSData*)data;

@end

@implementation GITTag
@synthesize repo;
@synthesize name;
@synthesize sha1;
@synthesize size;
@synthesize commit;
@synthesize tagger;
@synthesize tagged;
@synthesize message;

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
    self.name = nil;
    self.sha1 = nil;
    self.size = nil;
    self.commit = nil;
    self.tagger = nil;
    self.tagged = nil;
    self.message = nil;
    
    [super dealloc];
}
- (id)copyWithZone:(NSZone*)zone
{
    GITTag * tag    = [[GITTag allocWithZone:zone] init];
    tag.repo        = self.repo;
    tag.sha1        = self.sha1;
    tag.name        = self.name;
    tag.size        = self.size;
    tag.commit      = self.commit;
    tag.tagger      = self.tagger;
    tag.tagged      = self.tagged;
    tag.message     = self.message;
    
    return tag;
}
- (void)extractFieldsFromData:(NSData*)data
{
    NSString  * dataStr = [[NSString alloc] initWithData:data 
                                                encoding:NSASCIIStringEncoding];
    NSScanner * scanner = [NSScanner scannerWithString:dataStr];
    
    static NSString * NewLine = @"\n";
    NSString * taggedCommit,
             * taggedType,      //!< Should be @"commit"
             * tagName,
             * taggerName,
             * taggerEmail,
             * taggerTimezone,
             * msg;
     NSTimeInterval taggerTimestamp;
    
    if ([scanner scanString:@"object" intoString:NULL] &&
        [scanner scanUpToString:NewLine intoString:&taggedCommit] &&
        [scanner scanString:@"type" intoString:NULL] &&
        [scanner scanUpToString:NewLine intoString:&taggedType] &&
        [taggedType isEqualToString:kGITCommitType])
    {
        self.commit = [self.repo commitWithHash:taggedCommit];
    }
    
    if ([scanner scanString:@"tag" intoString:NULL] &&
        [scanner scanUpToString:NewLine intoString:&tagName])
    {
        self.name = tagName;
    }
    
    if ([scanner scanString:@"tagger" intoString:NULL] &&
        [scanner scanUpToString:@"<" intoString:&taggerName] &&
        [scanner scanUpToString:@">" intoString:&taggerEmail] &&
        [scanner scanDouble:&taggerTimestamp] &&
        [scanner scanUpToString:NewLine intoString:&taggerTimezone])
    {
        self.tagger = [[GITActor alloc] initWithName:taggerName andEmail:taggerEmail];
        self.tagged = [[GITDateTime alloc] initWithTimestamp:taggerTimestamp
                                              timeZoneOffset:taggerTimezone];
    }
        
    self.message = [dataStr substringFromIndex:[scanner scanLocation]];
}
- (NSString*)description
{
    return [NSString stringWithFormat:@"Tag: %@ <%@>",
                                        self.name, self.sha1];
}

@end
