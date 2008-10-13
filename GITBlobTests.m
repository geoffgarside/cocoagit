//
//  GITBlobTests.m
//  CocoaGit
//
//  Created by Geoffrey Garside on 05/10/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import "GITBlobTests.h"
#import "GITRepo.h"
#import "GITRepo.h"

#import "GITBlob.h"

#import "NSData+Compression.h"

@implementation GITBlobTests
@synthesize repo;
@synthesize blobSHA1;

- (void)setUp
{
    [super setUp];
    self.repo = [[GITRepo alloc] initWithRoot:@"."];
    self.blobSHA1 = @"421b03c7c48b987452a05f02b1bdf73fff93f3b9";
}
- (void)tearDown
{
    self.repo = nil;
    self.blobSHA1 = nil;
    [super tearDown];
}

- (void)testInitWithHashDataAndRepo
{
    NSString * objectType;
    NSUInteger objectSize;
    NSData * objectData;
    
    NSData * rawBlob = [[NSData dataWithContentsOfFile:[repo objectPathFromHash:blobSHA1]] zlibInflate];
    
    [repo extractFromData:rawBlob
                     type:&objectType 
                     size:&objectSize
                  andData:&objectData];
    
    GITBlob * blob = [[GITBlob alloc] initWithHash:blobSHA1 andData:objectData fromRepo:repo];
    STAssertNotNil(blob, @"Blob should be created");
    STAssertEqualObjects(blob.sha1, blobSHA1, @"SHA1 hashes should be equal");
    STAssertEquals(blob.size, objectSize, @"Sizes should be equal");
}

@end
