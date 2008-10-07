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
#import "GITRepo+Protected.h"
#import "NSData+Compression.h"

@implementation GITCommitTests
@synthesize repo;
@synthesize commitSHA1;
@synthesize rawCommitSize;

- (void)setUp
{
    [super setUp];
    self.repo = [[GITRepo alloc] initWithRoot:@"."];
    self.commitSHA1 = @"bc1f8741941e3a8136f40cb9b99a492171686214";
}
- (void)tearDown
{
    self.repo = nil;
    self.commitSHA1 = nil;
    self.rawCommitSize = 0;
    [super tearDown];
}
-(NSData*)rawCommitData
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

- (void)testInitWithHashDataAndRepo
{
    GITCommit * commit = [[GITCommit alloc] initWithHash:commitSHA1 andData:[self rawCommitData] fromRepo:repo];
    STAssertNotNil(commit, @"Commit should be created");
    STAssertEqualObjects(commit.sha1, commitSHA1, @"SHA1 hashes should be equal");
    STAssertEquals(commit.size, rawCommitSize, @"Sizes should be equal");
}

@end
