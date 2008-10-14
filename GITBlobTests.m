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
    self.repo = [[GITRepo alloc] initWithRoot:@"."];
    self.blobSHA1 = @"421b03c7c48b987452a05f02b1bdf73fff93f3b9";
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
