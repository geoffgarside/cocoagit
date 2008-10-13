//
//  GITRepo.m
//  CocoaGit
//
//  Created by Geoffrey Garside on 05/08/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import "GITRepo.h"
#import "GITFileStore.h"

#import "GITBranch.h"

#import "GITObject.h"
#import "GITCommit.h"
#import "GITBlob.h"
#import "GITTree.h"
#import "GITTag.h"

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
    return [self.store dataWithContentsOfObject:hash];
}
- (GITObject*)objectWithSha1:(NSString*)sha1
{
    NSString * type; NSUInteger size; NSData * data;

    [self.store extractFromObject:sha1 type:&type size:&size data:&data];
    if ([data length] == size)
    {
        if ([type isEqualToString:@"blob"])
            return [[GITBlob alloc] initWithSha1:sha1 data:data repo:self];
        else if ([type isEqualToString:@"tree"])
            return [[GITTree alloc] initWithSha1:sha1 data:data repo:self];
        else if ([type isEqualToString:@"commit"])
            return [[GITCommit alloc] initWithSha1:sha1 data:data repo:self];
        else if ([type isEqualToString:@"tag"])
            return [[GITTag alloc] initWithSha1:sha1 data:data repo:self];
    }

    return nil;
}
- (GITCommit*)commitWithSha1:(NSString*)sha1
{
    NSString * type; NSUInteger size; NSData * data;

    [self.store extractFromObject:sha1 type:&type size:&size data:&data];
    if ([type isEqualToString:@"commit"] && [data length] == size)
        return [[GITCommit alloc] initWithSha1:sha1 data:data repo:self];
    else
        return nil;
}
- (GITBlob*)blobWithSha1:(NSString*)sha1
{
    NSString * type; NSUInteger size; NSData * data;

    [self.store extractFromObject:sha1 type:&type size:&size data:&data];
    if ([type isEqualToString:@"blob"] && [data length] == size)
        return [[GITBlob alloc] initWithSha1:sha1 data:data repo:self];
    else
        return nil;
}
- (GITTree*)treeWithSha1:(NSString*)sha1
{
    NSString * type; NSUInteger size; NSData * data;

    [self.store extractFromObject:sha1 type:&type size:&size data:&data];
    if ([type isEqualToString:@"tree"] && [data length] == size)
        return [[GITTree alloc] initWithSha1:sha1 data:data repo:self];
    else
        return nil;
}
- (GITTag*)tagWithSha1:(NSString*)sha1
{
    NSString * type; NSUInteger size; NSData * data;

    [self.store extractFromObject:sha1 type:&type size:&size data:&data];
    if ([type isEqualToString:@"tree"] && [data length] == size)
        return [[GITTag alloc] initWithSha1:sha1 data:data repo:self];
    else
        return nil;
}
@end
