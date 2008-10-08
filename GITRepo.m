//
//  GITRepo.m
//  CocoaGit
//
//  Created by Geoffrey Garside on 05/08/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import "GITRepo.h"
#import "GITRepo+Protected.h"

#import "NSData+Hashing.h"
#import "NSData+Searching.h"
#import "NSData+Compression.h"

#import "GITBranch.h"

#import "GITObject.h"
#import "GITCommit.h"
#import "GITBlob.h"
#import "GITTree.h"
#import "GITTag.h"

@interface GITRepo ()
@property(readwrite,copy) NSString * root;
@property(readwrite,copy) NSString * desc;
@end

@implementation GITRepo

@synthesize root;
@synthesize desc;

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
    }
    return self;
}
- (id)copyWithZone:(NSZone*)zone
{
    return [[GITRepo allocWithZone:zone] initWithRoot:self.root];
}
- (NSString*)objectPathFromHash:(NSString*)hash
{
    NSString * dir = [self.root stringByAppendingPathComponent:@"objects"];
    NSString * ref = [NSString stringWithFormat:@"%@/%@",
        [hash substringToIndex:2], [hash substringFromIndex:2]];
    
    return [dir stringByAppendingPathComponent:ref];
}
- (NSData*)dataWithContentsOfHash:(NSString*)hash
{
    NSString * objectPath = [self objectPathFromHash:hash];
    return [[NSData dataWithContentsOfFile:objectPath] zlibInflate];
}
- (void)extractFromData:(NSData*)data
                   type:(NSString**)theType
                   size:(NSUInteger*)theSize
                andData:(NSData**)theData
{
    NSRange range = [data rangeOfNullTerminatedBytesFrom:0];
    NSData * meta = [data subdataWithRange:range];
    *theData = [data subdataFromIndex:range.length + 1];
    
    NSString * metaStr = [[NSString alloc] initWithData:meta
                                               encoding:NSASCIIStringEncoding];
    NSUInteger indexOfSpace = [metaStr rangeOfString:@" "].location;
    
    *theType = [metaStr substringToIndex:indexOfSpace];
    *theSize = (NSUInteger)[[metaStr substringFromIndex:indexOfSpace + 1] integerValue];
}
- (id)objectWithHash:(NSString*)hash
{
    NSString * objectType;
    NSUInteger objectSize;
    NSData * objectData;

    [self extractFromData:[self dataWithContentsOfHash:hash]
                     type:&objectType
                     size:&objectSize
                  andData:&objectData];

    if ([objectType isEqualToString:@"blob"])
        return [[GITBlob alloc] initWithHash:hash andData:objectData fromRepo:self];
    else if ([objectType isEqualToString:@"tree"])
        return [[GITTree alloc] initWithHash:hash andData:objectData fromRepo:self];
    else if ([objectType isEqualToString:@"commit"])
        return [[GITCommit alloc] initWithHash:hash andData:objectData fromRepo:self];
    else if ([objectType isEqualToString:@"tag"])
        return [[GITTag alloc] initWithHash:hash andData:objectData fromRepo:self];
    else
        return nil;
}
- (GITBlob*)blobWithHash:(NSString*)hash
{
    NSString * objectType;
    NSUInteger objectSize;
    NSData * objectData;

    [self extractFromData:[self dataWithContentsOfHash:hash]
                     type:&objectType
                     size:&objectSize
                  andData:&objectData];
    if ([objectType isEqualToString:@"blob"])
        return [[GITBlob alloc] initWithHash:hash andData:objectData fromRepo:self];
    else
        return nil;
}
- (GITTree*)treeWithHash:(NSString*)hash
{
    NSString * objectType;
    NSUInteger objectSize;
    NSData * objectData;

    [self extractFromData:[self dataWithContentsOfHash:hash]
                     type:&objectType
                     size:&objectSize
                  andData:&objectData];
    if ([objectType isEqualToString:@"tree"])
        return [[GITTree alloc] initWithHash:hash andData:objectData fromRepo:self];
    else
        return nil;
}
- (GITCommit*)commitWithHash:(NSString*)hash
{
    NSString * objectType;
    NSUInteger objectSize;
    NSData * objectData;

    [self extractFromData:[self dataWithContentsOfHash:hash]
                     type:&objectType
                     size:&objectSize
                  andData:&objectData];
    if ([objectType isEqualToString:@"commit"])
        return [[GITCommit alloc] initWithHash:hash andData:objectData fromRepo:self];
    else
        return nil;
}
- (GITTag*)tagWithHash:(NSString*)hash
{
    NSString * objectType;
    NSUInteger objectSize;
    NSData * objectData;

    [self extractFromData:[self dataWithContentsOfHash:hash]
                     type:&objectType
                     size:&objectSize
                  andData:&objectData];
    if ([objectType isEqualToString:@"tag"])
        return [[GITTag alloc] initWithHash:hash andData:objectData fromRepo:self];
    else
        return nil;
}
@end
