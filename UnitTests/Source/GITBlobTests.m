//
//  GITBlobTests.m
//  CocoaGit
//
//  Created by Geoffrey Garside on 05/10/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import "GITBlobTests.h"
#import "GITRepo.h"
#import "GITBlob.h"

@implementation GITBlobTests
@synthesize repo;
@synthesize blob;
@synthesize blobSHA1;

- (void)setUp
{
    [super setUp];
    self.repo = [[GITRepo alloc] initWithRoot:TEST_REPO_PATH];
	NSLog(@"repo = %@, root = %@", self.repo, self.repo.root);
    self.blobSHA1 = @"87f974580d485f3cfd5fd9cc62491341067f0c59";
    self.blob = [repo blobWithSha1:blobSHA1];
}
- (void)tearDown
{
    self.repo = nil;
    self.blobSHA1 = nil;
    self.blob = nil;
    [super tearDown];
}

- (void)testShouldNotBeNil
{
    STAssertNotNil(blob, @"Blob should be created");
}
- (void)testSha1HashesAreEqual
{
    STAssertEqualObjects(blob.sha1, blobSHA1, @"SHA1 hashes should be equal");
}

@end
