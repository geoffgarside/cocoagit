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
    self.packedSHA1String = [[[NSString alloc] initWithData:self.packedSHA1Data encoding:NSASCIIStringEncoding] autorelease];
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
    GHAssertEquals([packedSHA1String length], (NSUInteger)20, nil);
}

- (void)testShouldPackSHA1FromString
{
    NSData * packed = packSHA1(unpackedSHA1);
    GHAssertEquals([packed length], (NSUInteger)20, nil);
    GHAssertEqualObjects(packed, packedSHA1Data, nil);
}

- (void)testPackSHA1FromBytes
{
    NSData * packed = packSHA1FromBytes("bed4001738fa8dad666d669867afaf9f2c2b8c6a");
    GHAssertEquals([packed length], (NSUInteger)20, nil);
    GHAssertEqualObjects(packed, packedSHA1Data, nil);
}

- (void)testUnpackedSHA1StringEncoding
{
    NSString *unpackedCString = [[[NSString alloc] initWithCString:"bed4001738fa8dad666d669867afaf9f2c2b8c6a" encoding:NSASCIIStringEncoding] autorelease];
    GHAssertEqualObjects(self.unpackedSHA1,
                         unpackedCString, nil);
    GHAssertEqualObjects([self.unpackedSHA1 dataUsingEncoding:NSASCIIStringEncoding],
                         [unpackedCString dataUsingEncoding:NSASCIIStringEncoding], nil);
}

- (void)testStringEncodingSanityCheck
{
    NSString *test = @"test";
    NSData *testData = [test dataUsingEncoding:NSASCIIStringEncoding];
    NSString *testWithData = [[[NSString alloc] initWithData:testData encoding:NSASCIIStringEncoding] autorelease];
    GHAssertEqualObjects(test, testWithData, nil);
}

- (void)testPackedSHA1StringLatin1Encoding
{
    NSString *sha1 = @"0123456789abcdef0123456789abcdef01234567";
    NSData *packedData = packSHA1(sha1);
    NSString *packedString = [[[NSString alloc] initWithData:packedData encoding:NSASCIIStringEncoding] autorelease];
    NSData *packedStringData = [packedString dataUsingEncoding:NSISOLatin1StringEncoding];
    NSData *packedStringAsciiData = [packedString dataUsingEncoding:NSASCIIStringEncoding];
    GHAssertEqualObjects(packedData, packedStringData, nil);
    GHAssertNotEqualObjects(packedData, packedStringAsciiData, nil);
}

- (NSString *)packedStringEncoding
{
    NSData *packed = packSHA1(self.unpackedSHA1);
    NSString *asciiPacked = [[NSString alloc] initWithData:packed encoding:NSASCIIStringEncoding];
    NSStringEncoding *encodings = (NSStringEncoding *)[NSString availableStringEncodings];
    NSString *packedStringEncoding = nil;
    NSData *data;
    while (*encodings) {
        data = [asciiPacked dataUsingEncoding:*encodings];
        if ([data isEqual:packed]) {
            packedStringEncoding = [NSString localizedNameOfStringEncoding:*encodings];
            break;
        }
        encodings++;
    }
    return packedStringEncoding;
}

- (void)testShouldUnpackSHA1FromString
{
    NSString * sha1 = unpackSHA1FromString(packedSHA1String);
    GHAssertEqualObjects(sha1, unpackedSHA1, nil);
}
- (void)testShouldUnpackSHA1FromData
{
    NSString * sha1 = unpackSHA1FromData(packedSHA1Data);
    GHAssertEqualObjects(sha1, unpackedSHA1, nil);
}
- (void)testShouldConvertBinaryToInteger
{   // Contents similar to PACK File version
    uint8_t bytes[4] = { 0x0, 0x0, 0x0, 0x2 };
    NSUInteger val = integerFromBytes(bytes, 4);
    GHAssertEquals(val, (NSUInteger)2, nil);
}
- (void)testShouldConvertBinaryToInteger2
{
    uint8_t bytes[] = { 0x0, 0x0, 0x0, 0xFE };
    NSUInteger val = integerFromBytes(bytes, 4);
    GHAssertEquals(val, (NSUInteger)254, nil);
}
@end
