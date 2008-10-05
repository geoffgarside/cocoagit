//
//  GITBlobTests.h
//  CocoaGit
//
//  Created by Geoffrey Garside on 05/10/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

@class GITRepo;
@interface GITBlobTests : SenTestCase {
    GITRepo * repo;
    NSString * blobSHA1;
}

@property(readwrite,retain) GITRepo * repo;
@property(readwrite,copy)  NSString * blobSHA1;

- (void)testInitWithHashDataAndRepo;

@end
