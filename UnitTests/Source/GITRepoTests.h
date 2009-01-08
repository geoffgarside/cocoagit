//
//  GITRepoTests.h
//  CocoaGit
//
//  Created by Geoffrey Garside on 05/10/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import "GITTestHelper.h"

@class GITRepo;
@interface GITRepoTests : SenTestCase {
    GITRepo * repo;
}

@property(readwrite,retain) GITRepo * repo;

- (void)testIsNotNil;
- (void)testRepoIsBare;
- (void)testShouldLoadDataForHash;

@end
