//
//  GITBlob.m
//  CocoaGit
//
//  Created by Geoffrey Garside on 05/08/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import "GITBlob.h"
#import "GITRepo.h"

#import "NSData+Searching.h"

@interface GITBlob ()
@property(readwrite,retain) GITRepo * repo;
@property(readwrite,copy) NSString * sha1;
@property(readwrite,assign) NSUInteger size;
@property(readwrite,copy) NSData * data;
@end

@implementation GITBlob
@synthesize repo;
@synthesize sha1;
@synthesize size;
@synthesize data;

- (id)initWithHash:(NSString*)hash
           andData:(NSData*)data
          fromRepo:(GITRepo*)repo
{
    if (self = [super init])
    {
        self.repo = repo;
        self.sha1 = hash;
        self.size = [data length];
        self.data = data;
    }
    return self;
}
- (void)dealloc
{
    self.repo = nil;
    self.sha1 = nil;
    self.size = nil;
    self.data = nil;
    [super dealloc];
}
- (BOOL)canBeRepresentedAsString
{
    if ([self.data rangeOfNullTerminatedBytesFrom:0].location != NSNotFound)
        return YES;
    return NO;
}
- (NSString*)stringValue    //!< Implicitly retained by the sender
{
    NSString * v = [[NSString alloc] initWithData:self.data
                                         encoding:NSASCIIStringEncoding];
    return [[v autorelease] retain];
}

@end
