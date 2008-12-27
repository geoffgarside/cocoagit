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
    self.store = [[GITCombinedStore alloc] init];
}
- (void)tearDown
{
    self.store = nil;
    [super tearDown];
}
- (void)testAddStore
{
    NSError * error = nil;
    GITFileStore * fileStore = [[GITFileStore alloc] initWithRoot:DOT_GIT error:&error];
    STAssertNotNil(fileStore, nil); STAssertNil(error, nil);

    STAssertEquals([store.stores count], (NSUInteger)0, @"Should have no stores");
    [store addStore:fileStore];
    STAssertEquals([store.stores count], (NSUInteger)1, @"Should have one store");
}
- (void)testAddStoreWithPriority
{
    NSError * error = nil;

    GITFileStore * fileStore = [[GITFileStore alloc] initWithRoot:DOT_GIT error:&error];
    STAssertNotNil(fileStore, nil); STAssertNil(error, nil);

    GITPackStore * packStore = [[GITPackStore alloc] initWithRoot:DOT_GIT error:&error];
    STAssertNotNil(packStore, nil); STAssertNil(error, nil);

    STAssertEquals([store.stores count], (NSUInteger)0, @"Should have no stores");
    [store addStore:packStore];
    STAssertEquals([store.stores count], (NSUInteger)1, @"Should have one store");
    STAssertEqualObjects([store.stores objectAtIndex:0], packStore, @"Should have packStore at position 0");

    [store addStore:fileStore priority:GITHighPriority];
    STAssertEquals([store.stores count], (NSUInteger)2, @"Should have one store");
    STAssertEqualObjects([store.stores objectAtIndex:0], fileStore, @"Should have fileStore at position 0");
    STAssertEqualObjects([store.stores objectAtIndex:1], packStore, @"Should have packStore at position 1");
}
- (void)testAddStores
{
    NSError * error = nil;
    
    GITFileStore * fileStore = [[GITFileStore alloc] initWithRoot:DOT_GIT error:&error];
    STAssertNotNil(fileStore, nil); STAssertNil(error, nil);
    
    GITPackStore * packStore = [[GITPackStore alloc] initWithRoot:DOT_GIT error:&error];
    STAssertNotNil(packStore, nil); STAssertNil(error, nil);

    STAssertEquals([store.stores count], (NSUInteger)0, @"Should have no stores");
    [store addStores:fileStore, packStore, nil];

    STAssertEquals([store.stores count], (NSUInteger)2, @"Should have one store");
    STAssertEqualObjects([store.stores objectAtIndex:0], fileStore, @"Should have fileStore at position 0");
    STAssertEqualObjects([store.stores objectAtIndex:1], packStore, @"Should have packStore at position 1");
}
- (void)testShouldFindObjectFromFileStore
{
    NSError * error = nil;
    NSData * raw; GITObjectType type;
    NSString * sha1 = @"87f974580d485f3cfd5fd9cc62491341067f0c59";

    [store addStore:[[GITFileStore alloc] initWithRoot:DOT_GIT error:&error] priority:GITHighPriority];
    STAssertNil(error, @"Should be nil after initializing GITFileStore");

    BOOL result = [store loadObjectWithSha1:sha1 intoData:&raw type:&type error:&error];
    STAssertTrue(result, @"No Error Occurred");
    STAssertNil(error, @"No Error Occurred");
    STAssertNotNil(raw, @"Data was retrieved");
}
- (void)testShouldFindObjectFromPackStore
{
    NSError * error = nil;
    NSData * raw; GITObjectType type;
    NSString * sha1 = @"226e91f3b4cca13890325f5d33ec050beca99f89";
    
    [store addStore:[[GITPackStore alloc] initWithRoot:DOT_GIT error:&error] priority:GITHighPriority];
    STAssertNil(error, @"Should be nil after initializing GITPackStore");
    
    BOOL result = [store loadObjectWithSha1:sha1 intoData:&raw type:&type error:&error];
    STAssertTrue(result, @"No Error Occurred");
    STAssertNil(error, @"No Error Occurred");
    STAssertNotNil(raw, @"Data was retrieved");
}
@end
