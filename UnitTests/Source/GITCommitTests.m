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
    self.repo = [[[GITRepo alloc] initWithRoot:DOT_GIT bare:YES] autorelease];
    self.firstCommitSha1 = @"f7e7e7d240ccdae143b064aa7467eb2fa91aa8a5";
    self.commitSHA1 = @"2bb318d2c722b344f6fae8ec274d0c7df9020544";
    self.commit = [repo commitWithSha1:commitSHA1 error:NULL];
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
    GHAssertNotNil(commit, nil);
    GHAssertNotNil(firstCommit, nil);
}
- (void)testSha1MatchesInitialSha1
{
    GHAssertEqualObjects(commit.sha1, commitSHA1, nil);
    GHAssertEqualObjects(firstCommit.sha1, firstCommitSha1, nil);
}
- (void)testAuthorIsNotNil
{
    GHAssertNotNil(commit.author, nil);
    GHAssertNotNil(firstCommit.author, nil);
}
- (void)testAuthoredIsNotNil
{
    GHAssertNotNil(commit.authored, nil);
    GHAssertNotNil(firstCommit.authored, nil);
}
- (void)testCommitterIsNotNil
{
    GHAssertNotNil(commit.committer, nil);
    GHAssertNotNil(firstCommit.committer, nil);
}
- (void)testCommittedIsNotNil
{
    GHAssertNotNil(commit.committed, nil);
    GHAssertNotNil(firstCommit.committed, nil);
}
- (void)testIsFirstCommit
{
    GHAssertFalse([commit isFirstCommit], nil);
    GHAssertTrue([firstCommit isFirstCommit], nil);
}

- (void)testRawContent
{
    NSData *theData;
    GITObjectType theType;
    [self.repo loadObjectWithSha1:self.commitSHA1 intoData:&theData type:&theType error:NULL];
    GHAssertEqualObjects([self.commit rawContent], theData, nil);
}

- (void)testRawData
{
    NSData *rawData = [self.repo dataWithContentsOfObject:self.commitSHA1];
    GHAssertEqualObjects([self.commit rawData], rawData, nil);
}
@end
