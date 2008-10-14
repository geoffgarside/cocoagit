//
//  GITTreeEntryTests.h
//  CocoaGit
//
//  Created by Geoffrey Garside on 06/10/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

@class GITRepo, GITTree;
@interface GITTreeEntryTests : SenTestCase {
    GITRepo * repo;
    GITTree * tree;
    NSUInteger entryMode;
    NSString * entryName;
    NSString * entrySHA1;
    NSString * entryLine;
}

@property(readwrite,retain) GITRepo * repo;
@property(readwrite,retain) GITTree * tree;
@property(readwrite,assign) NSUInteger entryMode;
@property(readwrite,copy) NSString * entryName;
@property(readwrite,copy) NSString * entrySHA1;
@property(readwrite,copy) NSString * entryLine;

- (void)testShouldParseEntryLine;
- (void)testShouldInitWithModeNameAndHash;
- (void)testShouldInitWithModeStringNameAndHash;

@end
