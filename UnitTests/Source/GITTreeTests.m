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
    self.repo = [[[GITRepo alloc] initWithRoot:DOT_GIT bare:YES] autorelease];
    self.treeSHA1 = @"a9ecfd8989d7c427c5564cf918b264261866ce01";
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
    GHAssertNotNil(tree, nil);
}
- (void)testShouldHaveCorrectSHA
{
    GHAssertEqualObjects(tree.sha1, treeSHA1, nil);
}
- (void)testTreeEntryLoading
{
    GHAssertNotNil(tree.entries, @"Should not be nil");
    GHAssertEquals([tree.entries count], (NSUInteger)1, @"Should have 1 entry");
}

- (void)testRawContent
{
    NSData *theData;
    GITObjectType theType;
    [self.repo loadObjectWithSha1:self.treeSHA1 intoData:&theData type:&theType error:NULL];
    GHAssertEqualObjects([self.tree rawContent], theData, nil);
}

- (void)testRawData
{
    NSData *rawData = [self.repo dataWithContentsOfObject:self.treeSHA1];
    GHAssertEqualObjects([self.tree rawData], rawData, nil);
}
@end
