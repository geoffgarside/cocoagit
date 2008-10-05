//
//  GITRepoTests.m
//  CocoaGit
//
//  Created by Geoffrey Garside on 05/10/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import "GITRepoTests.h"
#import "GITRepo.h"
#import "GITRepo+Protected.h"

#import "NSData+Compression.h"

@implementation GITRepoTests
@synthesize testRepo;
@synthesize blobSHA1;
@synthesize blobPath;

- (void)setUp
{
    [super setUp];
    self.testRepo = [[GITRepo alloc] initWithRoot:@"."];
    self.blobSHA1 = @"421b03c7c48b987452a05f02b1bdf73fff93f3b9";
    self.blobPath = @"./.git/objects/42/1b03c7c48b987452a05f02b1bdf73fff93f3b9";
}
- (void)tearDown
{
    self.testRepo = nil;
    self.blobSHA1 = nil;
    self.blobPath = nil;
    [super tearDown];
}

#pragma mark -
#pragma mark Protected Methods
- (void)testRepoCanDetermineObjectPathFromHash
{
    NSString * objectPath = [testRepo objectPathFromHash:blobSHA1];
    STAssertEqualObjects(objectPath, blobPath, @"Object path was not determined");
}
- (void)testRepoCanGetDataContentsFromHash
{
    NSData * expectedData = [[NSData dataWithContentsOfFile:blobPath] zlibInflate];
    
    NSData * objectData = [testRepo dataWithContentsOfHash:blobSHA1];
    STAssertEqualObjects(objectData, expectedData, @"Extracted data should match");
}
- (void)testRepoCanExtractTypeSizeAndData
{
    NSString * dataString = @"//\n//  GITBlob.h\n//  CocoaGit\n//\n//  Created by Geoffrey Garside on 29/06/2008.\n//  Copyright 2008 ManicPanda.com. All rights reserved.\n//\n\n#import <Cocoa/Cocoa.h>\n#import \"GITObject.h\"\n\n@interface GITBlob : GITObject {\n    \n}\n\n@end\n";
    NSData * expectedData = [NSData dataWithData:[dataString dataUsingEncoding:NSASCIIStringEncoding]];
    
    NSString * objectType;
    NSUInteger objectSize;
    NSData * objectData;
    
    [testRepo extractFromData:[testRepo dataWithContentsOfHash:blobSHA1]
                         type:&objectType
                         size:&objectSize
                      andData:&objectData];
    
    STAssertEqualObjects(objectType, @"blob", @"Object should be a blob");
    STAssertEquals(objectSize, (NSUInteger)233, @"Object should be 233 bytes in size");
    STAssertEqualObjects(objectData, expectedData, @"Data should be contents of the file");
}

@end
