//
//  GITTreeTests.h
//  CocoaGit
//
//  Created by Geoffrey Garside on 05/10/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

@class GITRepo, GITTree;
@interface GITTreeTests : SenTestCase {
    GITRepo * repo;
    GITTree * tree;
    NSString * treeSHA1;
    NSUInteger rawObjectSize;
}

@property(readwrite,retain) GITRepo * repo;
@property(readwrite,retain) GITTree * tree;
@property(readwrite,copy)  NSString * treeSHA1;
@property(readwrite,assign) NSUInteger rawObjectSize;

- (void)testShouldNotBeNil;
- (void)testShouldHaveCorrectSHA;
- (void)testTreeEntryLoading;

@end
