//
//  GITFileStoreTests.h
//  CocoaGit
//
//  Created by Geoffrey Garside on 13/10/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

@class GITFileStore;
@interface GITFileStoreTests : SenTestCase {
    GITFileStore * store;
}

@property(readwrite,retain) GITFileStore * store;

- (void)testStoreRootIsCorrect;
- (void)testExpandHashIntoFilePath;
- (void)testDataWithContentsOfObject;
@end
