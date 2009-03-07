//
//  GITCombinedStoreTests.h
//  CocoaGit
//
//  Created by Geoffrey Garside on 27/12/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import "GITTestHelper.h"

@class GITCombinedStore;
@interface GITCombinedStoreTests : GHTestCase {
    GITCombinedStore * store;
}

@property(readwrite,retain) GITCombinedStore * store;

@end
