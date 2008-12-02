//
//  GITPackIndex.h
//  CocoaGit
//
//  Created by Geoffrey Garside on 26/11/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import "GITTestHelper.h"
#import "GITPackIndex.h"

@interface GITPackIndexTests : SenTestCase {
    GITPackIndex * versionOne;
    GITPackIndex * versionTwo;
}

@property(readwrite,retain) GITPackIndex * versionOne;
@property(readwrite,retain) GITPackIndex * versionTwo;

@end
