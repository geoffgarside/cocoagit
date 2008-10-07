//
//  GITCommitTests.h
//  CocoaGit
//
//  Created by Geoffrey Garside on 05/10/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

@class GITRepo;
@interface GITCommitTests : SenTestCase {
    GITRepo * repo;
    NSString * commitSHA1;
    NSUInteger rawCommitSize;
}

@property(readwrite,retain) GITRepo * repo;
@property(readwrite,copy)  NSString * commitSHA1;
@property(readwrite,assign) NSUInteger rawCommitSize;

- (void)testInitWithHashDataAndRepo;

@end
