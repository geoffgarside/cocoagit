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
#import "GITRepo.h"
#import "NSData+Compression.h"

@implementation GITTreeTests
@synthesize repo;
@synthesize tree;
@synthesize treeSHA1;
@synthesize rawObjectSize;

- (void)setUp
{
    [super setUp];
    self.repo = [[GITRepo alloc] initWithRoot:@"."];
    self.treeSHA1 = @"d813a4972d16d95c6b9dcfa41dfc4ea2150e6dcc";
    self.tree = [repo treeWithSha1:treeSHA1];
}
- (void)tearDown
{
    self.repo = nil;
    self.treeSHA1 = nil;
    self.tree = nil;
    [super tearDown];
}
- (void)testShouldNotBeNil
{
    STAssertNotNil(tree, nil);
}
- (void)testShouldHaveCorrectSHA
{
    STAssertEqualObjects(tree.sha1, treeSHA1, nil);
}
- (void)testTreeEntryLoading
{
    STAssertNotNil(tree.entries, @"Should not be nil");
    STAssertEquals([tree.entries count], (NSUInteger)16, @"Should have 16 entries");
}

@end
