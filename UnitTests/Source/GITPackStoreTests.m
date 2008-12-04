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
- (void)testDataWithContentsOfObject
{
    NSString * sha = @"226e91f3b4cca13890325f5d33ec050beca99f89";
    NSString * str = @"blob 64\x00#!/usr/bin/env ruby\n\nputs \"hello world!\"\n\nputs \"goodbye world.\"";

    NSData * data  = [str dataUsingEncoding:NSASCIIStringEncoding];
    NSData * raw   = [store dataWithContentsOfObject:sha];

    NSLog(@"raw as str:\n%@", [[NSString alloc] initWithData:raw encoding:NSASCIIStringEncoding]);

    STAssertEquals([raw length], [data length], nil);
    STAssertEqualObjects(raw, data, nil);
}

@end
