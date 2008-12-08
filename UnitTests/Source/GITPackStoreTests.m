//
//  GITPackStoreTests.m
//  CocoaGit
//
//  Created by Geoffrey Garside on 02/12/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import "GITPackStoreTests.h"
#import "GITPackStore.h"

@implementation GITPackStoreTests
@synthesize store;

- (void)setUp
{
    [super setUp];
    self.store = [[GITPackStore alloc] initWithRoot:TEST_REPO_ROOT@"/.git"];
}
- (void)tearDown
{
    self.store = nil;
    [super tearDown];
}

- (void)testStoreRootIsCorrect
{
    STAssertEqualObjects(store.packsDir, TEST_REPO_ROOT@"/.git/objects/pack", nil);
}
- (void)testLoadObjectWithSha1
{
    NSData * raw; GITObjectType type;
    NSString * sha = @"226e91f3b4cca13890325f5d33ec050beca99f89";
    NSString * str = @"#!/usr/bin/env ruby\n\nputs \"hello world!\"\n\nputs \"goodbye world.\"\n";

    NSData * data  = [str dataUsingEncoding:NSASCIIStringEncoding];
    BOOL result = [store loadObjectWithSha1:sha intoData:&raw type:&type error:NULL];

    STAssertTrue(result, nil);
    STAssertEquals(type, GITObjectTypeBlob, nil);
    STAssertEquals([raw length], [data length], nil);
    STAssertEqualObjects(raw, data, nil);
}

@end
