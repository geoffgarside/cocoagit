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
@synthesize firstCommit;
@synthesize firstCommitSha1;

- (void)setUp
{
    [super setUp];
    self.repo = [[GITRepo alloc] initWithRoot:TEST_REPO_PATH];
    self.commitSHA1 = @"f7e7e7d240ccdae143b064aa7467eb2fa91aa8a5";
    self.commit = [repo commitWithSha1:commitSHA1 error:NULL];
    self.firstCommitSha1 = @"2bb318d2c722b344f6fae8ec274d0c7df9020544";
    self.firstCommit = [repo commitWithSha1:firstCommitSha1 error:NULL];
}
- (void)tearDown
{
    self.repo = nil;
    self.commitSHA1 = nil;
    self.commit = nil;
    self.firstCommitSha1 = nil;
    self.firstCommit = nil;
    [super tearDown];
}
- (void)testIsNotNil
{
    STAssertNotNil(commit, nil);
    STAssertNotNil(firstCommit, nil);
}
- (void)testSha1MatchesInitialSha1
{
    STAssertEqualObjects(commit.sha1, commitSHA1, nil);
    STAssertEqualObjects(firstCommit.sha1, firstCommitSha1, nil);
}
- (void)testAuthorIsNotNil
{
    STAssertNotNil(commit.author, nil);
    STAssertNotNil(firstCommit.author, nil);
}
- (void)testAuthoredIsNotNil
{
    STAssertNotNil(commit.authored, nil);
    STAssertNotNil(firstCommit.authored, nil);
}
- (void)testCommitterIsNotNil
{
    STAssertNotNil(commit.committer, nil);
    STAssertNotNil(firstCommit.committer, nil);
}
- (void)testCommittedIsNotNil
{
    STAssertNotNil(commit.committed, nil);
    STAssertNotNil(firstCommit.committed, nil);
}

@end
