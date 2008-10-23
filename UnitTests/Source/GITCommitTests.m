//
//  GITCommitTests.m
//  CocoaGit
//
//  Created by Geoffrey Garside on 05/10/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import "GITCommitTests.h"
#import "GITCommit.h"
#import "GITRepo.h"

@implementation GITCommitTests
@synthesize repo;
@synthesize commit;
@synthesize commitSHA1;

- (void)setUp
{
    [super setUp];
    self.repo = [[GITRepo alloc] initWithRoot:TEST_REPO_PATH];
    self.commitSHA1 = @"f7e7e7d240ccdae143b064aa7467eb2fa91aa8a5";
    self.commit = [repo commitWithSha1:commitSHA1];
}
- (void)tearDown
{
    self.repo = nil;
    self.commitSHA1 = nil;
    self.commit = nil;
    [super tearDown];
}
- (void)testIsNotNil
{
    STAssertNotNil(commit, nil);
}
- (void)testSha1MatchesInitialSha1
{
    STAssertEqualObjects(commit.sha1, commitSHA1, nil);
}
- (void)testAuthorIsNotNil
{
    STAssertNotNil(commit.author, nil);
}
- (void)testAuthoredIsNotNil
{
    STAssertNotNil(commit.authored, nil);
}
- (void)testCommitterIsNotNil
{
    STAssertNotNil(commit.committer, nil);
}
- (void)testCommittedIsNotNil
{
    STAssertNotNil(commit.committed, nil);
}

@end
