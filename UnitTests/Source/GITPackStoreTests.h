//
//  GITPackStoreTests.h
//  CocoaGit
//
//  Created by Geoffrey Garside on 02/12/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import "GITTestHelper.h"

@class GITPackStore;
@interface GITPackStoreTests : SenTestCase {
    GITPackStore * store;
}

@property(readwrite,retain) GITPackStore * store;

- (void)testStoreRootIsCorrect;
- (void)testDataWithContentsOfObject;

@end
