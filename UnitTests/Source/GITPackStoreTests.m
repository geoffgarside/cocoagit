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
    self.store = [GITPackStore storeWithRoot:DOT_GIT];
}
- (void)tearDown
{
    self.store = nil;
    [super tearDown];
}

- (void)testStoreRootIsCorrect
{
    GHAssertEqualObjects(store.packsDir, DOT_GIT @"objects/pack", nil);
}
- (void)testLoadObjectWithSha1
{
    NSData * raw; GITObjectType type;
    NSString * sha = @"226e91f3b4cca13890325f5d33ec050beca99f89";
    NSString * str = @"#!/usr/bin/env ruby\n\nputs \"hello world!\"\n\nputs \"goodbye world.\"\n";

    NSData * data  = [str dataUsingEncoding:NSASCIIStringEncoding];
    BOOL result = [store loadObjectWithSha1:sha intoData:&raw type:&type error:NULL];

    GHAssertTrue(result, nil);
    GHAssertEquals(type, GITObjectTypeBlob, nil);
    GHAssertEquals([raw length], [data length], nil);
    GHAssertEqualObjects(raw, data, nil);
}
- (void)testObjectNotFoundError
{
    NSError *error = nil;   // We get a segfault if this is not preset to nil.
    NSData *raw; GITObjectType type;
    BOOL result = [store loadObjectWithSha1:@"cafebabe0d485f3cfd5fd9cc62491341067f0c59" intoData:&raw type:&type error:&error];

    GHAssertFalse(result, @"Object should not be found");
    GHAssertNotNil(error, @"Should not be nil");
    GHAssertEquals(GITErrorObjectNotFound, [error code], @"Should have correct error code");
}
@end
