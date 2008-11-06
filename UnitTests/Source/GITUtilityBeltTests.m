//
//  GITUtilityBeltTests.m
//  CocoaGit
//
//  Created by Geoffrey Garside on 06/10/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import "GITUtilityBeltTests.h"
#import "GITUtilityBelt.h"

@implementation GITUtilityBeltTests
@synthesize unpackedSHA1;
@synthesize packedSHA1Data;
@synthesize packedSHA1String;

- (void)setUp
{
    [super setUp];
    self.unpackedSHA1 = @"bed4001738fa8dad666d669867afaf9f2c2b8c6a";
    self.packedSHA1Data = [NSData dataWithBytes:"\276\324\000\0278\372\215\255fmf\230g\257\257\237,+\214j" length:20];
    self.packedSHA1String = [[NSString alloc] initWithData:self.packedSHA1Data encoding:NSASCIIStringEncoding];
}
- (void)tearDown
{
    self.unpackedSHA1 = nil;
    self.packedSHA1Data = nil;
    self.packedSHA1String = nil;
    [super tearDown];
}
- (void)testPackedSHA1String
{
    STAssertEquals([packedSHA1String length], (NSUInteger)20, nil);
}
- (void)testShouldPackSHA1FromString
{
    NSData * packed = packSHA1(unpackedSHA1);
    STAssertEquals([packed length], (NSUInteger)20, nil);
    STAssertEqualObjects(packed, packedSHA1Data, nil);
}
- (void)testShouldUnpackSHA1FromString
{
    NSString * sha1 = unpackSHA1FromString(packedSHA1String);
    STAssertEqualObjects(sha1, unpackedSHA1, nil);
}
- (void)testShouldConvertBinaryToInteger
{   // Contents similar to PACK File version
    uint8_t bytes[4] = { 0x0, 0x0, 0x0, 0x2 };
    NSUInteger val = integerFromBytes(bytes, 4);
    STAssertEquals(val, (NSUInteger)2, nil);
}
- (void)testShouldConvertBinaryToInteger2
{
    uint8_t bytes[] = { 0x0, 0x0, 0x0, 0xFE };
    NSUInteger val = integerFromBytes(bytes, 4);
    STAssertEquals(val, (NSUInteger)254, nil);
}
@end
