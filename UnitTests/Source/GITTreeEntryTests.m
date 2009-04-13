//
//  GITTreeEntryTests.m
//  CocoaGit
//
//  Created by Geoffrey Garside on 06/10/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import "GITTestHelper.h"
#import "GITUtilityBelt.h"
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
	self.repo = [[[GITRepo alloc] initWithRoot:DOT_GIT bare:YES] autorelease];
    self.tree = [repo treeWithSha1:@"a9ecfd8989d7c427c5564cf918b264261866ce01"];
	    
    self.entryMode = 100644;
    self.entryName = @"index.html";
    self.entrySHA1 = @"b8ea533af44f544877babe0aaabc1d7f3ed2593f";

	NSData *packedEntrySha1 = packSHA1(self.entrySHA1);
	NSString *entryHeader = [NSString stringWithFormat:@"%d %@\x00", self.entryMode, self.entryName, nil];

	NSMutableData *entryData = [[[entryHeader dataUsingEncoding:NSASCIIStringEncoding] mutableCopy] autorelease];
	[entryData appendData:packedEntrySha1];

    self.entryLine = [[[NSString alloc] initWithData:entryData encoding:NSASCIIStringEncoding] autorelease];
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
    GHAssertNotNil(entry, @"TreeEntry should not be nil");
    GHAssertEquals(entry.mode, entryMode, @"Mode should be parsed properly");
    GHAssertEqualObjects(entry.name, entryName, @"Name should be parsed properly");
    GHAssertEqualObjects(entry.sha1, entrySHA1, @"SHA1 should be parsed properly");
    [entry release];
}
- (void)testShouldInitWithModeNameAndHash
{
    GITTreeEntry * entry = [[GITTreeEntry alloc] initWithMode:entryMode name:entryName
                                                         sha1:entrySHA1 parent:tree];
    GHAssertNotNil(entry, @"TreeEntry should not be nil");
    GHAssertEquals(entry.mode, entryMode, @"Mode should be parsed properly");
    GHAssertEqualObjects(entry.name, entryName, @"Name should be parsed properly");
    GHAssertEqualObjects(entry.sha1, entrySHA1, @"SHA1 should be parsed properly");
    [entry release];
}
- (void)testShouldInitWithModeStringNameAndHash
{
    NSString * entryModeStr = [NSString stringWithFormat:@"%ld", entryMode];
    GITTreeEntry * entry = [[GITTreeEntry alloc] initWithModeString:entryModeStr name:entryName
                                                               sha1:entrySHA1 parent:tree];
    GHAssertNotNil(entry, @"TreeEntry should not be nil");
    GHAssertEquals(entry.mode, entryMode, @"Mode (%@) should be parsed properly", entryModeStr);
    GHAssertEqualObjects(entry.name, entryName, @"Name should be parsed properly");
    GHAssertEqualObjects(entry.sha1, entrySHA1, @"SHA1 should be parsed properly");
    [entry release];
}

@end
