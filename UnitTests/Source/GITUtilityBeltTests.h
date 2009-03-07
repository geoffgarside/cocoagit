//
//  GITUtilityBeltTests.h
//  CocoaGit
//
//  Created by Geoffrey Garside on 06/10/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import "GITTestHelper.h"


@interface GITUtilityBeltTests : GHTestCase {
    NSString * unpackedSHA1;
    NSData   * packedSHA1Data;
    NSString * packedSHA1String;
}

@property(readwrite,copy) NSString * unpackedSHA1;
@property(readwrite,copy) NSData   * packedSHA1Data;
@property(readwrite,copy) NSString * packedSHA1String;

- (void)testPackedSHA1String;
- (void)testShouldPackSHA1FromString;
- (void)testShouldUnpackSHA1FromString;
- (void)testShouldUnpackSHA1FromData;
- (void)testShouldConvertBinaryToInteger;

@end
