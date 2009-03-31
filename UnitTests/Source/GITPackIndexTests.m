//
//  GITPackIndex.m
//  CocoaGit
//
//  Created by Geoffrey Garside on 26/11/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import "GITPackIndexTests.h"
#import "GITPackFile.h"

@interface GITPackIndex (IndexV2PrivateMethods)
- (NSRange)rangeOfPackChecksum;
- (NSRange)rangeOfExtendedOffsetTable;
@end

@implementation GITPackIndexTests
@synthesize versionOne;
@synthesize versionTwo;

- (void)setUp
{
    [super setUp];
    // Need to make a version 1 index file
    //self.versionTwo = [[GITPackIndex alloc] initWithPath:DOT_GIT@"objects/pack/pack-709b858145841a007ab0c53e130630fd1eecea6f.idx"];
    GITPackFile *packfile = [GITPackFile packFileWithPath:DELTA_REF_PACK];
    self.versionTwo = [packfile index];
}
- (void)tearDown
{
    self.versionOne = nil;
    self.versionTwo = nil;
    [super tearDown];
}
- (void)testVersionOneVersionShouldBe1
{
    //GHAssertEquals([versionOne version], (NSUInteger)1, nil);
}
- (void)testVersionTwoVersionShouldBe2
{
    GHAssertEquals([versionTwo version], (NSUInteger)2, nil);
}
- (void)testNumberOfObjectsInVersionTwo
{
    GHAssertEquals([versionTwo numberOfObjects], (NSUInteger)1797, nil);
}
- (void)testOffsetOfObjectInVersionTwo
{
    off_t offset = [versionTwo packOffsetForSha1:@"cec49e51b154fbd982c3f023dcbde80c5687ce57"];
    GHAssertEquals(offset, (off_t)146843, nil);

    GHAssertEquals([versionTwo packOffsetForSha1:@"cafebabe0d485f3cfd5fd9cc62491341067f0c59"], (off_t)NSNotFound, nil);
}
- (void)testHasObjectWithSha1InVersionTwo
{
    GHAssertTrue([versionTwo hasObjectWithSha1:@"cec49e51b154fbd982c3f023dcbde80c5687ce57"], nil);
    GHAssertFalse([versionTwo hasObjectWithSha1:@"cafebabe0d485f3cfd5fd9cc62491341067f0c59"], nil);
}
- (void)testChecksumStringInVersionTwo
{
    GHAssertEqualObjects([versionTwo checksumString], @"b6d850ef7f93d134b3b13fab027c2b4a86aa4368", nil);
}
- (void)testPackChecksumStringInVersionTwo
{
    GHAssertEqualObjects([versionTwo packChecksumString], @"30c9a070ff5dcb64b5fd20337e3793407ecbfe66", nil);
}
- (void)testChecksumDoesVerify
{
    GHAssertTrue([versionTwo verifyChecksum], nil);     // We assume the file is well formed so we're checking our verification process here
}

- (void) testOffsetForSha1
{
    NSDictionary *packInfo = [GITTestHelper packedObjectInfo];
    NSArray *objectKeys = [NSArray arrayWithObjects:@"firstObject",@"lastNormalObject",@"penultimateObject",@"lastObject",nil];
    for (NSString *key in objectKeys) {
        NSDictionary *o = [packInfo valueForKey:key];
        NSNumber *expectedOffset = [o valueForKey:@"offset"];
        GHAssertEquals((off_t)[expectedOffset unsignedLongLongValue],
                       [versionTwo packOffsetForSha1:[o valueForKey:@"sha1"]], nil);
    }
}

- (void) testBaseOffsetBeforeFirstObject
{
    NSDictionary *packInfo = [GITTestHelper packedObjectInfo];
    NSDictionary *o = [packInfo valueForKey:@"firstObject"];
    NSNumber *offset = [o valueForKey:@"offset"];
    GHAssertEquals((off_t)[offset unsignedLongLongValue],
                   (off_t)[versionTwo baseOffsetWithOffset:0], nil);
}

- (void) testBaseOffsetOfFirstObject
{
    NSDictionary *packInfo = [GITTestHelper packedObjectInfo];
    NSDictionary *o = [packInfo valueForKey:@"firstObject"];
    NSNumber *offset = [o valueForKey:@"offset"];
    GHAssertEquals((off_t)[offset unsignedLongLongValue],
                   (off_t)[versionTwo baseOffsetWithOffset:([offset unsignedLongLongValue]+1)], nil); 
}

- (void) testBaseOffsetOfPenultimateObject
{
    NSDictionary *packInfo = [GITTestHelper packedObjectInfo];
    NSDictionary *o = [packInfo valueForKey:@"penultimateObject"];
    NSNumber *offset = [o valueForKey:@"offset"];
    GHAssertEquals((off_t)[offset unsignedLongLongValue],
                   (off_t)[versionTwo baseOffsetWithOffset:([offset unsignedLongLongValue]+1)], nil); 
}

- (void) testBaseOffsetOfLastObject
{
    NSDictionary *packInfo = [GITTestHelper packedObjectInfo];
    NSDictionary *o = [packInfo valueForKey:@"lastObject"];
    NSNumber *offset = [o valueForKey:@"offset"];
    GHAssertEquals((off_t)[offset unsignedLongLongValue],
                   (off_t)[versionTwo baseOffsetWithOffset:([offset unsignedLongLongValue]+1)], nil); 
}

- (void) testNextOffsetOfPenultimateObject
{
    NSDictionary *packInfo = [GITTestHelper packedObjectInfo];
    NSDictionary *o = [packInfo valueForKey:@"penultimateObject"];
    NSNumber *offset = [o valueForKey:@"offset"];
    NSNumber *lastOffset = [[packInfo valueForKey:@"lastObject"] valueForKey:@"offset"];
    GHAssertEquals((off_t)[lastOffset unsignedLongLongValue],
                   (off_t)[versionTwo nextOffsetWithOffset:[offset unsignedLongLongValue]], nil);       
}

- (void) testNextOffsetOfLastObject
{
    NSDictionary *packInfo = [GITTestHelper packedObjectInfo];
    NSDictionary *o = [packInfo valueForKey:@"lastObject"];
    NSNumber *offset = [o valueForKey:@"offset"];
    GHAssertEquals((off_t)-1,
                   (off_t)[versionTwo nextOffsetWithOffset:[offset unsignedLongLongValue]], nil);                       
}

@end
