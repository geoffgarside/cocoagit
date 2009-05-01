//
//  GITRepoTests.m
//  CocoaGit
//
//  Created by Geoffrey Garside on 05/10/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import "GITRepoTests.h"
#import "GITRepo.h"
#import "GITErrors.h"

@implementation GITRepoTests
@synthesize repo;

- (void)setUp
{
    [super setUp];
    self.repo = [[[GITRepo alloc] initWithRoot:DOT_GIT bare:YES] autorelease];
}
- (void)tearDown
{
    self.repo = nil;
    [super tearDown];
}
- (void)testIsNotNil
{
    GHAssertNotNil(repo, nil);
}
- (void)testRepoIsBare
{
    GHAssertTrue([repo isBare], nil);
}
- (void)testShouldLoadDataForHash
{
	NSString * sha = @"87f974580d485f3cfd5fd9cc62491341067f0c59";
	NSString * str = @"hello world!\n\ngoodbye world.\n";
    NSData * data  = [NSData dataWithData:[str dataUsingEncoding:NSASCIIStringEncoding]];
    
    NSData * raw = [repo dataWithContentsOfObject:sha type:@"blob"];
    GHAssertNotNil(raw, nil);
    GHAssertEqualObjects(data, raw, nil);
}

- (void)testBranchesInRepo
{
    NSArray *branches = [repo branches];
    GHAssertTrue([branches count] == 7, @"Repo should have 7 branches");
    NSArray *names = [branches valueForKey:@"name"];
    GHAssertTrue([names containsObject:@"refs/heads/ruby"], @"There should be a 'ruby' branch");
    GHAssertTrue([names containsObject:@"refs/heads/master"], @"There should be a 'master' branch");
}

- (void)testObjectNotFoundError
{
    NSError *error = nil;
    GITObject *o = [repo objectWithSha1:@"0123456789012345678901234567890123456789"
                                  error:&error];
    GHAssertNil(o, nil);
    GHAssertEquals(GITErrorObjectNotFound, [error code], nil);
}
@end
