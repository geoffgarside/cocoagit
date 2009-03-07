//
//  GITBlobTests.h
//  CocoaGit
//
//  Created by Geoffrey Garside on 05/10/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import "GITTestHelper.h"

@class GITRepo, GITBlob;
@interface GITBlobTests : GHTestCase {
    GITRepo * repo;
    GITBlob * blob;
    NSString * blobSHA1;
}

@property(readwrite,retain) GITRepo * repo;
@property(readwrite,retain) GITBlob * blob;
@property(readwrite,copy)  NSString * blobSHA1;

- (void)testShouldNotBeNil;
- (void)testSha1HashesAreEqual;

@end
