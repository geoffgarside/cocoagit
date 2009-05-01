//
//  GITGraphTests.m
//  CocoaGit
//
//  Created by chapbr on 4/23/09.
//  Copyright 2009 Brian Chapados. All rights reserved.
//

#import "GITGraphTests.h"
#import "GITGraph.h"
#import "GITNode.h"
#import "GITRepo.h"

#define DOT_GIT_REVLIST_FIXTURES TEST_FIXTURES_PATH @"revListFixtures.plist" 

@implementation GITGraphTests
@synthesize repo, graph;

static NSString *testBranch = @"revwalk-test";
static NSDictionary *fixtures;

- (void)setUp
{
    [super setUp];
    self.repo = [[[GITRepo alloc] initWithRoot:DOT_GIT bare:YES] autorelease];
    self.graph = [[[GITGraph alloc] init] autorelease];
    [self.graph buildGraphWithStartingCommit:[self.repo commitWithBranchName:testBranch]];
}

- (void)tearDown
{
    self.repo = nil;
    self.graph = nil;
    if (fixtures)
        [fixtures release], fixtures = nil;
    [super tearDown];
}

- (NSDictionary *) fixtures
{
    if ( !fixtures )
        fixtures = [[NSDictionary alloc] initWithContentsOfFile:DOT_GIT_REVLIST_FIXTURES];
    return fixtures;
}

- (void) testNodeOutEdges
{
    GHAssertEquals([graph countOfNodes], (NSUInteger)15, nil);
}

// command: 'git-rev-list revwalk-test'
- (void) testNodesSortedByDate
{
    NSArray *nodes = [graph nodesSortedByDate];
    NSArray *commitShas = [nodes valueForKey:@"key"];
    NSArray *expectedShas = [[self fixtures] valueForKey:@"default"];
    GHAssertEqualObjects(commitShas, expectedShas, nil);
}

// command: 'git-rev-list --topo-order revwalk-test'
- (void) testNodesSortedByTopology
{
    NSArray *nodes = [graph nodesSortedByTopology:YES];
    NSArray *commitShas = [nodes valueForKey:@"key"];
    NSArray *expectedShas = [[self fixtures] valueForKey:@"topo"];
    GHAssertEqualObjects(commitShas, expectedShas, nil);
}

// command: 'git-rev-list --date-order revwalk-test'
- (void) testNodesSortedTopologicallyByDate
{
    NSArray *nodes = [graph nodesSortedByTopology:NO];
    NSArray *commitShas = [nodes valueForKey:@"key"];
    NSArray *expectedShas = [[self fixtures] valueForKey:@"date"];
    GHAssertEqualObjects(commitShas, expectedShas, nil);
}

@end