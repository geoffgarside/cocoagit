//
//  GITPackIndex.m
//  CocoaGit
//
//  Created by Geoffrey Garside on 26/11/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import "GITPackIndexTests.h"

@implementation GITPackIndexTests
@synthesize versionOne;
@synthesize versionTwo;

- (void)setUp
{
    [super setUp];
    // Need to make a version 1 index file
    self.versionTwo = [[GITPackIndex alloc] initWithPath:DOT_GIT@"objects/pack/pack-709b858145841a007ab0c53e130630fd1eecea6f.idx"];
}
- (void)tearDown
{
    self.versionOne = nil;
    self.versionTwo = nil;
    [super tearDown];
}
- (void)testVersionOneVersionShouldBe1
{
    //STAssertEquals([versionOne version], (NSUInteger)1, nil);
}
- (void)testVersionTwoVersionShouldBe2
{
    STAssertEquals([versionTwo version], (NSUInteger)2, nil);
}
- (void)testNumberOfObjectsInVersionTwo
{
    STAssertEquals([versionTwo numberOfObjects], (NSUInteger)15, nil);
}
- (void)testOffsetOfObjectInVersionTwo
{
    NSUInteger offset = [versionTwo packOffsetForSha1:@"226e91f3b4cca13890325f5d33ec050beca99f89"];
    STAssertEquals(offset, (NSUInteger)1032, nil);

    STAssertEquals([versionTwo packOffsetForSha1:@"cafebabe0d485f3cfd5fd9cc62491341067f0c59"], (NSUInteger)NSNotFound, nil);
}
- (void)testHasObjectWithSha1InVersionTwo
{
    STAssertTrue([versionTwo hasObjectWithSha1:@"226e91f3b4cca13890325f5d33ec050beca99f89"], nil);
    STAssertFalse([versionTwo hasObjectWithSha1:@"cafebabe0d485f3cfd5fd9cc62491341067f0c59"], nil);
}
- (void)testChecksumStringInVersionTwo
{
    STAssertEqualObjects([versionTwo checksumString], @"d9b99e4efbd35769156692b946511b028b3ede83", nil);
}
- (void)testPackChecksumStringInVersionTwo
{
    STAssertEqualObjects([versionTwo packChecksumString], @"ac9654dde94bdb31dd50a50d20fe26c2c5cda925", nil);
}
- (void)testChecksumDoesVerify
{
    STAssertTrue([versionTwo verifyChecksum], nil);     // We assume the file is well formed so we're checking our verification process here
}
@end
