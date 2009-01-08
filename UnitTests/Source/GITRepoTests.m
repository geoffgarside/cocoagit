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
    self.repo = [[GITRepo alloc] initWithRoot:DOT_GIT bare:YES];
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
- (void)testRepoIsBare
{
    STAssertTrue([repo isBare], nil);
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

- (void)testObjectNotFoundError
{
    NSError *error = nil;
    GITObject *o = [repo objectWithSha1:@"0123456789012345678901234567890123456789"
                                  error:&error];
    STAssertNil(o, nil);
    STAssertEquals(GITErrorObjectNotFound, [error code], nil);
}
@end
