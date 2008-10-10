//
//  GITTree.m
//  CocoaGit
//
//  Created by Geoffrey Garside on 05/08/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import "GITTree.h"
#import "GITRepo+Protected.h"
#import "GITObject.h"
#import "GITTreeEntry.h"

@interface GITTree ()
@property(readwrite,retain) GITRepo * repo;
@property(readwrite,copy) NSString * sha1;
@property(readwrite,assign) NSUInteger size;
@property(readwrite,copy) NSArray * entries;

- (void)extractEntriesFromData:(NSData*)data;

@end

@implementation GITTree
@synthesize repo;
@synthesize sha1;
@synthesize size;
@synthesize entries;

- (id)initWithHash:(NSString*)hash
           andData:(NSData*)treeData
          fromRepo:(GITRepo*)parentRepo
{
    if (self = [super init])
    {
        self.repo = parentRepo;
        self.sha1 = hash;
        self.size = [treeData length];
        
        [self extractEntriesFromData:treeData];
    }
    return self;
}
- (void)dealloc
{
    self.repo = nil;
    self.sha1 = nil;
    self.size = 0;
    self.entries = nil;
    [super dealloc];
}
- (id)copyWithZone:(NSZone*)zone
{
    GITTree * tree  = [[GITTree allocWithZone:zone] init];
    tree.repo       = self.repo;
    tree.sha1       = self.sha1;
    tree.size       = self.size;
    tree.entries    = self.entries;
    
    return tree;
}
- (void)extractEntriesFromData:(NSData*)data
{
    NSString  * dataStr = [[NSString alloc] initWithData:data 
                                                encoding:NSASCIIStringEncoding];

    NSMutableArray *treeEntries = [NSMutableArray arrayWithCapacity:2];
    unsigned entryStart = 0;

    do {
        NSRange searchRange = NSMakeRange(entryStart, [dataStr length] - entryStart);
        NSUInteger entrySha1Start = [dataStr rangeOfString:@"\0" 
                                                   options:0
                                                     range:searchRange].location;

        NSRange entryRange = NSMakeRange(entryStart, 
            entrySha1Start - entryStart + kGITPackedSha1Length + 1);
        
        NSString * treeLine = [dataStr substringWithRange:entryRange];
        GITTreeEntry * entry = [[GITTreeEntry alloc] initWithTreeLine:treeLine repo:self.repo];
        [treeEntries addObject:entry];

        entryStart = entryRange.location + entryRange.length;
    } while(entryStart < [dataStr length]);
    
    self.entries = treeEntries;
}
- (NSData*)rawData
{
    NSString * treeString = [NSString stringWithFormat:@"tree %lu"];
    return [treeString dataUsingEncoding:NSASCIIStringEncoding];
}

@end
