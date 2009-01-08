//
//  GITPackFileTests.m
//  CocoaGit
//
//  Created by Geoffrey Garside on 02/12/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import "GITPackFileTests.h"

@implementation GITPackFileTests
@synthesize versionTwo;

- (void)setUp
{
    [super setUp];
    self.versionTwo = [[GITPackFile alloc] initWithPath:DOT_GIT @"objects/pack/pack-709b858145841a007ab0c53e130630fd1eecea6f.pack"];
}
- (void)tearDown
{
    self.versionTwo = nil;
    [super tearDown];
}
- (void)testVersionTwoIsNotNil
{
    STAssertNotNil(versionTwo, nil);
}
- (void)testVersionInVersionTwo
{
    STAssertEquals([versionTwo version], (NSUInteger)2, nil);
}
- (void)testChecksumInVersionTwo
{
    STAssertEqualObjects([versionTwo checksumString], @"ac9654dde94bdb31dd50a50d20fe26c2c5cda925", nil);
}
- (void)testChecksumVerifiesInVersionTwo
{
    STAssertTrue([versionTwo verifyChecksum], nil);
}
- (void)testNumberOfObjectsInVersionTwo
{
    STAssertEquals([versionTwo numberOfObjects], (NSUInteger)15, nil);
}
- (void)testHasObjectWithSha1InVersionTwo
{
    STAssertTrue([versionTwo hasObjectWithSha1:@"226e91f3b4cca13890325f5d33ec050beca99f89"], nil);
    STAssertFalse([versionTwo hasObjectWithSha1:@"cafebabe0d485f3cfd5fd9cc62491341067f0c59"], nil);
}
- (void)testDataForObjectWithSha1InVersionTwo
{
    NSData * data = [versionTwo dataForObjectWithSha1:@"226e91f3b4cca13890325f5d33ec050beca99f89"];
    NSString * dataStr = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    STAssertNotNil(dataStr, @"The string contents of the data block should not be nil");
}
// TODO: Add more test of the data contents and sizes

@end
