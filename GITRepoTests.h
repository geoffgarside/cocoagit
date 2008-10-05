//
//  GITRepoTests.h
//  CocoaGit
//
//  Created by Geoffrey Garside on 05/10/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

@class GITRepo;
@interface GITRepoTests : SenTestCase {
    GITRepo * testRepo;
    
    // Test data
    NSString * blobSHA1;
    NSString * blobPath;
}

@property(readwrite,retain) GITRepo * testRepo;
@property(readwrite,copy)  NSString * blobSHA1;
@property(readwrite,copy)  NSString * blobPath;

- (void)testRepoCanDetermineObjectPathFromHash;
- (void)testRepoCanGetDataContentsFromHash;
- (void)testRepoCanExtractTypeSizeAndData;
@end
