//
//  GITFileStoreTests.m
//  CocoaGit
//
//  Created by Geoffrey Garside on 13/10/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import "GITFileStoreTests.h"
#import "GITFileStore.h"

@implementation GITFileStoreTests
@synthesize store;

- (void)setUp
{
    [super setUp];
    self.store = [GITFileStore storeWithRoot:DOT_GIT];
}
- (void)tearDown
{
    self.store = nil;
    [super tearDown];
}
- (void)testStoreRootIsCorrect
{
    GHAssertEqualObjects(store.objectsDir, DOT_GIT@"objects", nil);
}
- (void)testExpandHashIntoFilePath
{
    NSString * path = [store stringWithPathToObject:@"87f974580d485f3cfd5fd9cc62491341067f0c59"];
    GHAssertEqualObjects(path, DOT_GIT@"objects/87/f974580d485f3cfd5fd9cc62491341067f0c59", nil);
}
- (void)testDataWithContentsOfObject
{
    NSString * sha = @"87f974580d485f3cfd5fd9cc62491341067f0c59";
	NSString * str = @"blob 29\x00hello world!\n\ngoodbye world.\n";

	NSData * data  = [NSData dataWithData:[str dataUsingEncoding:NSASCIIStringEncoding]];
    
    NSData * raw   = [store dataWithContentsOfObject:sha];
	GHAssertEqualObjects(raw, data, nil);
}
- (void)testLoadObjectWithSha1
{
    NSData * raw; GITObjectType type;
    NSString * sha = @"87f974580d485f3cfd5fd9cc62491341067f0c59";
    NSString * str = @"hello world!\n\ngoodbye world.\n";

    NSData * data  = [NSData dataWithData:[str dataUsingEncoding:NSASCIIStringEncoding]];
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
