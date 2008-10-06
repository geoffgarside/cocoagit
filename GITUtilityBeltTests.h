//
//  GITUtilityBeltTests.h
//  CocoaGit
//
//  Created by Geoffrey Garside on 06/10/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>


@interface GITUtilityBeltTests : SenTestCase {
    NSString * unpackedSHA1;
    NSData   * packedSHA1Data;
    NSString * packedSHA1String;
}

@property(readwrite,copy) NSString * unpackedSHA1;
@property(readwrite,copy) NSData   * packedSHA1Data;
@property(readwrite,copy) NSString * packedSHA1String;

- (void)testShouldUnpackSHA1FromString;

@end
