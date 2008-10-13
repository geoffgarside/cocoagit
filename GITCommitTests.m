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
#import "GITRepo.h"
#import "NSData+Compression.h"

@implementation GITCommitTests
@synthesize repo;
@synthesize commit;
@synthesize commitSHA1;
@synthesize rawCommitSize;

- (void)setUp
{
    [super setUp];
    self.repo = [[GITRepo alloc] initWithRoot:@"."];
    self.commitSHA1 = @"bc1f8741941e3a8136f40cb9b99a492171686214";
    self.commit = [[GITCommit alloc] initWithHash:commitSHA1 andData:[self rawCommitData] fromRepo:repo];
}
- (void)tearDown
{
    self.repo = nil;
    self.commitSHA1 = nil;
    self.rawCommitSize = 0;
    [super tearDown];
}
- (NSData*)rawCommitData
{
    NSString * objectType;
    NSUInteger objectSize;
    NSData * objectData;
    
    NSData * rawCommit = [[NSData dataWithContentsOfFile:[repo objectPathFromHash:commitSHA1]] zlibInflate];
    
    [repo extractFromData:rawCommit
                     type:&objectType 
                     size:&objectSize
                  andData:&objectData];
    
    self.rawCommitSize = objectSize;
    return objectData;
}

- (void)testIsNotNil
{
    STAssertNotNil(commit, nil);
}
- (void)testSha1MatchesInitialSha1
{
    STAssertEqualObjects(commit.sha1, commitSHA1, nil);
}
- (void)testSizeMatchesRawSize
{
    STAssertEquals(commit.size, rawCommitSize, @"Sizes should be equal");
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
