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
    self.repo = [[GITRepo alloc] initWithRoot:DOT_GIT bare:YES];
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
    GHAssertNotNil(blob, @"Blob should be created");
}

- (void)testSha1HashesAreEqual
{
    GHAssertEqualObjects(blob.sha1, blobSHA1, @"SHA1 hashes should be equal");
}

- (void)testRawContent
{
    NSData *theData;
    GITObjectType theType;
    [self.repo loadObjectWithSha1:self.blobSHA1 intoData:&theData type:&theType error:NULL];
    GHAssertEqualObjects([self.blob rawContent], theData, nil);
}

- (void)testRawData
{
    NSData *rawData = [self.repo dataWithContentsOfObject:self.blobSHA1];
    GHAssertEqualObjects([self.blob rawData], rawData, nil);
}

@end
