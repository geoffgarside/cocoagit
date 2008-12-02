//
//  GITPackFileTests.h
//  CocoaGit
//
//  Created by Geoffrey Garside on 02/12/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import "GITTestHelper.h"
#import "GITPackFile.h"

@interface GITPackFileTests : SenTestCase {
    GITPackFile * versionTwo;
}

@property(readwrite,retain) GITPackFile * versionTwo;

@end
