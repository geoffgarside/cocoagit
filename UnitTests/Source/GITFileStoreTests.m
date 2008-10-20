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
    self.store = [[GITFileStore alloc] initWithRoot:@"./.git"];
}
- (void)tearDown
{
    self.store = nil;
    [super tearDown];
}
- (void)testStoreRootIsCorrect
{
    STAssertEqualObjects(store.objectsDir, @"./.git/objects", nil);
}
- (void)testExpandHashIntoFilePath
{
    NSString * path = [store stringWithPathToObject:@"421b03c7c48b987452a05f02b1bdf73fff93f3b9"];
    STAssertEqualObjects(path, @"./.git/objects/42/1b03c7c48b987452a05f02b1bdf73fff93f3b9", nil);
}
- (void)testDataWithContentsOfObject
{
    NSString * sha = @"421b03c7c48b987452a05f02b1bdf73fff93f3b9";
    NSString * str = @"blob 233\0//\n//  GITBlob.h\n//  CocoaGit\n//\n//  Created by Geoffrey Garside on 29/06/2008.\n//  Copyright 2008 ManicPanda.com. All rights reserved.\n//\n\n#import <Cocoa/Cocoa.h>\n#import \"GITObject.h\"\n\n@interface GITBlob : GITObject {\n    \n}\n\n@end\n";
    NSData * data  = [NSData dataWithData:[str dataUsingEncoding:NSASCIIStringEncoding]];
    
    NSData * raw   = [store dataWithContentsOfObject:sha];
    STAssertEqualObjects(raw, data, nil);
}
@end
