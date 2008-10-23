//
//  GITRepoTests.m
//  CocoaGit
//
//  Created by Geoffrey Garside on 05/10/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import "GITRepoTests.h"
#import "GITRepo.h"

@implementation GITRepoTests
@synthesize repo;

- (void)setUp
{
    [super setUp];
    self.repo = [[GITRepo alloc] initWithRoot:TEST_REPO_PATH];
}
- (void)tearDown
{
    self.repo = nil;
    [super tearDown];
}
- (void)testIsNotNil
{
    STAssertNotNil(repo, nil);
}
- (void)testRootHasDotGitSuffix
{
    STAssertTrue([repo.root hasSuffix:@".git"], nil);
}
- (void)testShouldLoadDataForHash
{
	NSString * sha = @"87f974580d485f3cfd5fd9cc62491341067f0c59";
	NSString * str = @"hello world!\n\ngoodbye world.\n";
    NSData * data  = [NSData dataWithData:[str dataUsingEncoding:NSASCIIStringEncoding]];
    
    NSData * raw = [repo dataWithContentsOfObject:sha type:@"blob"];
    STAssertNotNil(raw, nil);
    STAssertEqualObjects(data, raw, nil);
}
@end
