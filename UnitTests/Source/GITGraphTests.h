//
//  GITGraphTests.h
//  CocoaGit
//
//  Created by chapbr on 4/23/09.
//  Copyright 2009 Brian Chapados. All rights reserved.
//

#import "GITTestHelper.h"

@class GITRepo, GITGraph;
@interface GITGraphTests : GHTestCase {
    GITRepo *repo;
    GITGraph *graph;
}
@property(readwrite,retain) GITRepo *repo;
@property(readwrite,retain) GITGraph *graph;

@end
