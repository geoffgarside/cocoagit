//
//  GITTreeEntryTests.m
//  CocoaGit
//
//  Created by Geoffrey Garside on 06/10/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import "GITTreeEntryTests.h"
#import "GITTreeEntry.h"
#import "GITRepo.h"

@implementation GITTreeEntryTests
@synthesize repo;
@synthesize tree;
@synthesize entryMode;
@synthesize entryName;
@synthesize entrySHA1;
@synthesize entryLine;

- (void)setUp
{
    [super setUp];
    self.repo = [[GITRepo alloc] initWithRoot:@"."];
    self.tree = [repo treeWithSha1:@"d813a4972d16d95c6b9dcfa41dfc4ea2150e6dcc"];
    
    self.entryMode = 100644;
    self.entryName = @".gitignore";
    self.entrySHA1 = @"bed4001738fa8dad666d669867afaf9f2c2b8c6a";

    // length (38) = mode (6) + name (10) + sha1 (20) + 1 space + 1 null
    NSData * entryData = [NSData dataWithBytes:"100644 .gitignore\000\276\324\000\0278\372\215\255fmf\230g\257\257\237,+\214j" length:38];
    self.entryLine = [[NSString alloc] initWithData:entryData encoding:NSASCIIStringEncoding];
}
- (void)tearDown
{
    self.repo = nil;
    self.entryMode = 0;
    self.entryName = nil;
    self.entrySHA1 = nil;
    self.entryLine = nil;
    [super tearDown];
}

- (void)testShouldParseEntryLine
{
    GITTreeEntry * entry = [[GITTreeEntry alloc] initWithTreeLine:entryLine parent:tree];
    STAssertNotNil(entry, @"TreeEntry should not be nil");
    STAssertEquals(entry.mode, entryMode, @"Mode should be parsed properly");
    STAssertEqualObjects(entry.name, entryName, @"Name should be parsed properly");
    STAssertEqualObjects(entry.sha1, entrySHA1, @"SHA1 should be parsed properly");
}
- (void)testShouldInitWithModeNameAndHash
{
    GITTreeEntry * entry = [[GITTreeEntry alloc] initWithMode:entryMode name:entryName
                                                         sha1:entrySHA1 parent:tree];
    STAssertNotNil(entry, @"TreeEntry should not be nil");
    STAssertEquals(entry.mode, entryMode, @"Mode should be parsed properly");
    STAssertEqualObjects(entry.name, entryName, @"Name should be parsed properly");
    STAssertEqualObjects(entry.sha1, entrySHA1, @"SHA1 should be parsed properly");
}
- (void)testShouldInitWithModeStringNameAndHash
{
    NSString * entryModeStr = [NSString stringWithFormat:@"%ld", entryMode];
    GITTreeEntry * entry = [[GITTreeEntry alloc] initWithModeString:entryModeStr name:entryName
                                                               sha1:entrySHA1 parent:tree];
    STAssertNotNil(entry, @"TreeEntry should not be nil");
    STAssertEquals(entry.mode, entryMode, @"Mode (%@) should be parsed properly", entryModeStr);
    STAssertEqualObjects(entry.name, entryName, @"Name should be parsed properly");
    STAssertEqualObjects(entry.sha1, entrySHA1, @"SHA1 should be parsed properly");
}

@end
