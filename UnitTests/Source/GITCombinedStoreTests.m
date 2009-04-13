//
//  GITCombinedStoreTests.m
//  CocoaGit
//
//  Created by Geoffrey Garside on 27/12/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import "GITCombinedStoreTests.h"
#import "GITCombinedStore.h"
#import "GITFileStore.h"
#import "GITPackStore.h"

@implementation GITCombinedStoreTests
@synthesize store;

- (void)setUp
{
    [super setUp];
    self.store = [[[GITCombinedStore alloc] init] autorelease];
}
- (void)tearDown
{
    self.store = nil;
    [super tearDown];
}
- (void)testAddStore
{
    NSError * error = nil;
    GITFileStore * fileStore = [GITFileStore storeWithRoot:DOT_GIT error:&error];
    GHAssertNotNil(fileStore, nil); GHAssertNil(error, nil);

    GHAssertEquals([store.stores count], (NSUInteger)0, @"Should have no stores");
    [store addStore:fileStore];
    GHAssertEquals([store.stores count], (NSUInteger)1, @"Should have one store");
}
- (void)testAddStoreWithPriority
{
    NSError * error = nil;

    GITFileStore * fileStore = [GITFileStore storeWithRoot:DOT_GIT error:&error];
    GHAssertNotNil(fileStore, nil); GHAssertNil(error, nil);

    GITPackStore * packStore = [GITPackStore storeWithRoot:DOT_GIT error:&error];
    GHAssertNotNil(packStore, nil); GHAssertNil(error, nil);

    GHAssertEquals([store.stores count], (NSUInteger)0, @"Should have no stores");
    [store addStore:packStore];
    GHAssertEquals([store.stores count], (NSUInteger)1, @"Should have one store");
    GHAssertEqualObjects([store.stores objectAtIndex:0], packStore, @"Should have packStore at position 0");

    [store addStore:fileStore priority:GITHighPriority];
    GHAssertEquals([store.stores count], (NSUInteger)2, @"Should have one store");
    GHAssertEqualObjects([store.stores objectAtIndex:0], fileStore, @"Should have fileStore at position 0");
    GHAssertEqualObjects([store.stores objectAtIndex:1], packStore, @"Should have packStore at position 1");
}
- (void)testAddStores
{
    NSError * error = nil;
    
    GITFileStore * fileStore = [GITFileStore storeWithRoot:DOT_GIT error:&error];
    GHAssertNotNil(fileStore, nil); GHAssertNil(error, nil);
    
    GITPackStore * packStore = [GITPackStore storeWithRoot:DOT_GIT error:&error];
    GHAssertNotNil(packStore, nil); GHAssertNil(error, nil);

    GHAssertEquals([store.stores count], (NSUInteger)0, @"Should have no stores");
    [store addStores:fileStore, packStore, nil];

    GHAssertEquals([store.stores count], (NSUInteger)2, @"Should have one store");
    GHAssertEqualObjects([store.stores objectAtIndex:0], fileStore, @"Should have fileStore at position 0");
    GHAssertEqualObjects([store.stores objectAtIndex:1], packStore, @"Should have packStore at position 1");
}
- (void)testShouldFindObjectFromFileStore
{
    NSError * error = nil;
    NSData * raw; GITObjectType type;
    NSString * sha1 = @"87f974580d485f3cfd5fd9cc62491341067f0c59";

    [store addStore:[GITFileStore storeWithRoot:DOT_GIT error:&error] priority:GITHighPriority];
    GHAssertNil(error, @"Should be nil after initializing GITFileStore");

    BOOL result = [store loadObjectWithSha1:sha1 intoData:&raw type:&type error:&error];
    GHAssertTrue(result, @"No Error Occurred");
    GHAssertNil(error, @"No Error Occurred");
    GHAssertNotNil(raw, @"Data was retrieved");
}
- (void)testShouldFindObjectFromPackStore
{
    NSError * error = nil;
    NSData * raw; GITObjectType type;
    NSString * sha1 = @"226e91f3b4cca13890325f5d33ec050beca99f89";
    
    [store addStore:[GITPackStore storeWithRoot:DOT_GIT error:&error] priority:GITHighPriority];
    GHAssertNil(error, @"Should be nil after initializing GITPackStore");
    
    BOOL result = [store loadObjectWithSha1:sha1 intoData:&raw type:&type error:&error];
    GHAssertTrue(result, @"No Error Occurred");
    GHAssertNil(error, @"No Error Occurred");
    GHAssertNotNil(raw, @"Data was retrieved");
}
- (void)testShouldFindObjectFromFileAndPackStore
{
    NSError * error = nil;

    GITFileStore * fileStore = [GITFileStore storeWithRoot:DOT_GIT error:&error];
    GHAssertNotNil(fileStore, nil); GHAssertNil(error, nil);

    GITPackStore * packStore = [GITPackStore storeWithRoot:DOT_GIT error:&error];
    GHAssertNotNil(packStore, nil); GHAssertNil(error, nil);

    [store addStores:fileStore, packStore, nil];

    NSData * raw = nil; GITObjectType type;
    NSString * sha1File = @"87f974580d485f3cfd5fd9cc62491341067f0c59",
             * sha1Pack = @"226e91f3b4cca13890325f5d33ec050beca99f89";

    BOOL result = [store loadObjectWithSha1:sha1File intoData:&raw type:&type error:&error];
    GHAssertTrue(result, @"No Error Occurred");
    GHAssertNil(error, @"No Error Occurred");
    GHAssertNotNil(raw, @"Data was retrieved");

    raw = nil;
    result = [store loadObjectWithSha1:sha1Pack intoData:&raw type:&type error:&error];
    GHAssertTrue(result, @"No Error Occurred");
    GHAssertNil(error, @"No Error Occurred");
    GHAssertNotNil(raw, @"Data was retrieved");
}
@end
