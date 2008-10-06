//
//  GITTreeTests.m
//  CocoaGit
//
//  Created by Geoffrey Garside on 05/10/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import "GITTreeTests.h"
#import "GITTree.h"
#import "GITRepo.h"
#import "GITRepo+Protected.h"
#import "NSData+Compression.h"

@implementation GITTreeTests
@synthesize repo;
@synthesize treeSHA1;
@synthesize rawObjectSize;

- (void)setUp
{
    [super setUp];
    self.repo = [[GITRepo alloc] initWithRoot:@"."];
    self.treeSHA1 = @"d813a4972d16d95c6b9dcfa41dfc4ea2150e6dcc";
}
- (void)tearDown
{
    self.repo = nil;
    self.treeSHA1 = nil;
    [super tearDown];
}
- (NSData*)rawTreeData
{
    NSString * objectType;
    NSUInteger objectSize;
    NSData * objectData;
    
    NSData * rawTree = [[NSData dataWithContentsOfFile:[repo objectPathFromHash:treeSHA1]] zlibInflate];
    
    [repo extractFromData:rawTree
                     type:&objectType 
                     size:&objectSize
                  andData:&objectData];
    
    self.rawObjectSize = objectSize;
    return objectData;
}

- (void)testInitWithHashDataAndRepo
{
    GITTree * tree = [[GITTree alloc] initWithHash:treeSHA1 andData:[self rawTreeData] fromRepo:repo];
    STAssertNotNil(tree, @"Tree should not be nil");
    STAssertEquals(tree.size, self.rawObjectSize, @"Size should be parsed properly");
    STAssertEqualObjects(tree.sha1, treeSHA1, @"SHA1 hashes should be equal");
}

- (void)testTreeEntryLoading
{
    GITTree * tree = [[GITTree alloc] initWithHash:treeSHA1 andData:[self rawTreeData] fromRepo:repo];
    STAssertNotNil(tree.entries, @"Should not be nil");
    STAssertEquals([tree.entries count], (NSUInteger)16, @"Should have 16 entries");
}

@end
