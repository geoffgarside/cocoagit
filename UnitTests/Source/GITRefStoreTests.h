//
//  GITRefStoreTests.h
//  CocoaGit
//
//  Created by Brian Chapados on 4/6/09.
//  Copyright 2009 Brian Chapados. All rights reserved.
//

#import "GITTestHelper.h"

@class GITRefStore, GITRef;

@interface GITRefStoreTests : GHTestCase {
    GITRefStore *store;
}
@property(readwrite,retain) GITRefStore *store;


@end