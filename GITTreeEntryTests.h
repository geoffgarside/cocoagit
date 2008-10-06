//
//  GITTreeEntryTests.h
//  CocoaGit
//
//  Created by Geoffrey Garside on 06/10/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>


@interface GITTreeEntryTests : SenTestCase {
    NSUInteger entryMode;
    NSString * entryName;
    NSString * entrySHA1;
    NSString * entryLine;
}

@property(readwrite,assign) NSUInteger entryMode;
@property(readwrite,copy) NSString * entryName;
@property(readwrite,copy) NSString * entrySHA1;
@property(readwrite,copy) NSString * entryLine;

- (void)testShouldParseEntryLine;
- (void)testShouldInitWithModeNameAndHash;
- (void)testShouldInitWithModeStringNameAndHash;

@end
