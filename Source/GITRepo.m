//
//  GITRepo.m
//  CocoaGit
//
//  Created by Geoffrey Garside on 05/08/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import "GITRepo.h"
#import "GITFileStore.h"
#import "GITObject.h"
#import "GITCommit.h"
#import "GITBlob.h"
#import "GITTree.h"
#import "GITTag.h"

#import "NSData+Searching.h"

/*! \cond
 Make properties readwrite so we can use
 them within the class.
*/
@interface GITRepo ()
@property(readwrite,copy) NSString * root;
@property(readwrite,copy) NSString * desc;
@property(readwrite,retain) GITObjectStore * store;
@end
/*! \endcond */

@implementation GITRepo
@synthesize root;
@synthesize desc;
@synthesize store;

- (id)initWithRoot:(NSString*)repoRoot
{
    return [self initWithRoot:repoRoot bare:NO];
}
- (id)initWithRoot:(NSString*)repoRoot bare:(BOOL)isBare
{
    if (self = [super init])
    {
        if ([repoRoot hasSuffix:@".git"])
            self.root = repoRoot;
        else
        {
            if (isBare)
                self.root = repoRoot; //[repoRoot stringByAppendingPathExtension:@".git"];
            else
                self.root = [repoRoot stringByAppendingPathComponent:@".git"];
        }
        
        NSString * descFile = [self.root stringByAppendingPathComponent:@"description"];
        self.desc = [NSString stringWithContentsOfFile:descFile];

        self.store = [[GITFileStore alloc] initWithRoot:self.root];
    }
    return self;
}
- (id)copyWithZone:(NSZone*)zone
{
    return [[GITRepo allocWithZone:zone] initWithRoot:self.root];
}

#pragma mark -
#pragma mark Internal Methods
- (NSData*)dataWithContentsOfObject:(NSString*)sha1
{
    NSData * data = [self.store dataWithContentsOfObject:sha1];
    NSRange range = [data rangeOfNullTerminatedBytesFrom:0];
    return [data subdataFromIndex:range.length + 1];
}
- (NSData*)dataWithContentsOfObject:(NSString*)sha1 type:(NSString*)expectedType
{
    NSString * type; NSUInteger size; NSData * data;

    [self.store extractFromObject:sha1 type:&type size:&size data:&data];
    if ([expectedType isEqualToString:type] && [data length] == size)
        return data;
    return nil;
}
- (GITObject*)objectWithSha1:(NSString*)sha1
{
    NSString * type; NSUInteger size; NSData * data;

    [self.store extractFromObject:sha1 type:&type size:&size data:&data];
    if ([data length] == size)
    {
        if ([type isEqualToString:kGITObjectBlobName])
            return [[GITBlob alloc] initWithSha1:sha1 data:data repo:self];
        else if ([type isEqualToString:kGITObjectTreeName])
            return [[GITTree alloc] initWithSha1:sha1 data:data repo:self];
        else if ([type isEqualToString:kGITObjectCommitName])
            return [[GITCommit alloc] initWithSha1:sha1 data:data repo:self];
        else if ([type isEqualToString:kGITObjectTagName])
            return [[GITTag alloc] initWithSha1:sha1 data:data repo:self];
    }

    return nil;
}
- (GITCommit*)commitWithSha1:(NSString*)sha1
{
    NSData * data = [self dataWithContentsOfObject:sha1 type:@"commit"];
    if (data)
        return [[GITCommit alloc] initWithSha1:sha1 data:data repo:self];
    else
        return nil;
}
- (GITBlob*)blobWithSha1:(NSString*)sha1
{
    NSData * data = [self dataWithContentsOfObject:sha1 type:@"blob"];
    if (data)
        return [[GITBlob alloc] initWithSha1:sha1 data:data repo:self];
    else
        return nil;
}
- (GITTree*)treeWithSha1:(NSString*)sha1
{
    NSData * data = [self dataWithContentsOfObject:sha1 type:@"tree"];
    if (data)
        return [[GITTree alloc] initWithSha1:sha1 data:data repo:self];
    else
        return nil;
}
- (GITTag*)tagWithSha1:(NSString*)sha1
{
    NSData * data = [self dataWithContentsOfObject:sha1 type:@"tag"];
    if (data)
        return [[GITTag alloc] initWithSha1:sha1 data:data repo:self];
    else
        return nil;
}
@end
