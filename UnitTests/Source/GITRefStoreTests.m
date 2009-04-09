//
//  GITRefStoreTests.m
//  CocoaGit
//
//  Created by Brian Chapados on 4/6/09.
//  Copyright 2009 Brian Chapados. All rights reserved.
//

#import "GITRefStoreTests.h"
#import "GITRefStore.h"
#import "GITRepo.h"
#import "GITRef.h"
#import "GITUtilityBelt.h"

#define DOT_GIT_REFS TEST_RESOURCES_PATH @"dot_git_refs/"
#define DOT_GIT_REFS_FIXTURES TEST_FIXTURES_PATH @"refFixtures.plist" 

@implementation GITRefStoreTests

static NSDictionary *fixtures;

@synthesize store;

- (void) dealloc
{
    [fixtures release], fixtures = nil;
    [super dealloc];
}

- (void)setUp
{
    [super setUp];
    GITRepo *repo = [[[GITRepo alloc] initWithRoot:DOT_GIT_REFS bare:YES] autorelease];
    self.store = [[[GITRefStore alloc] initWithRepo:repo error:NULL] autorelease];
}

- (void)tearDown
{
    self.store = nil;
    [super tearDown];
}

- (NSDictionary *) fixtures
{
    if ( !fixtures )
        fixtures = [[NSDictionary alloc] initWithContentsOfFile:DOT_GIT_REFS_FIXTURES];
    return fixtures;
}

- (NSDictionary *) heads { return [[self fixtures] objectForKey:@"heads"]; }
- (NSDictionary *) remotes { return [[self fixtures] objectForKey:@"remotes"]; }
- (NSDictionary *) tags { return [[self fixtures] objectForKey:@"tags"]; }

- (void) testResolveSymbolicRef
{
    GITRef *rawHeadRef = [GITRef refWithContentsOfFile:DOT_GIT_REFS @"HEAD"];
    GITRef *headRef = [store refByResolvingSymbolicRef:rawHeadRef];
    NSString *headSha1 = [[self heads] valueForKey:[rawHeadRef linkName]];
    GHAssertEqualObjects([headRef sha1], headSha1, nil);
}

- (void) testLooseRefWithName
{
    GITRef *ref = [store refWithName:@"refs/heads/facepalm"];
    NSString *refSha1 = [[self heads] valueForKey:@"refs/heads/facepalm"];
    GHAssertEqualObjects([ref sha1], refSha1, nil);
}

- (void) testPackedRefWithName
{
    GITRef *ref = [store refWithName:@"refs/heads/origin/master"];
    NSString *refSha1 = [[self heads] valueForKey:@"refs/heads/origin/master"];
    GHAssertEqualObjects([ref sha1], refSha1, nil);
}

- (void) testRefStoreReturnsCopiedRefs
{
    NSArray *heads = [store heads];
    GITRef *firstHead = [heads objectAtIndex:0];
    [firstHead setSha1:@"BLAH"];
    GITRef *firstHeadFromStore = [[store heads] objectAtIndex:0];
    GHAssertNotEqualObjects([firstHead sha1], [firstHeadFromStore sha1], nil);
}

- (void) testHeads
{
    NSMutableDictionary *heads = [NSMutableDictionary dictionary];
    for (GITRef *r in [store heads]) {
        [heads setValue:[r sha1] forKey:[r name]];
    }
    NSDictionary *expectedHeads = [self heads];
    GHAssertEqualObjects(heads, expectedHeads, nil);
}

- (void) testRemotes
{
    NSMutableDictionary *remotes = [NSMutableDictionary dictionary];
    for (GITRef *r in [store remotes]) {
        [remotes setValue:[r sha1] forKey:[r name]];
    }
    NSDictionary *expectedRemotes = [self remotes];
    GHAssertEqualObjects(remotes, expectedRemotes, nil);
}

- (void) testTags
{
    NSMutableDictionary *tags = [NSMutableDictionary dictionary];
    for (GITRef *r in [store tags]) {
        [tags setValue:[r sha1] forKey:[r name]];
    }
    NSDictionary *expectedTags = [self tags];
    GHAssertEqualObjects(tags, expectedTags, nil);
}
@end
