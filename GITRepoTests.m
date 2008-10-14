//
//  GITRepoTests.m
//  CocoaGit
//
//  Created by Geoffrey Garside on 05/10/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import "GITRepoTests.h"
#import "GITRepo.h"

@implementation GITRepoTests
@synthesize repo;

- (void)setUp
{
    [super setUp];
    self.repo = [[GITRepo alloc] initWithRoot:@"."];
}
- (void)tearDown
{
    self.repo = nil;
    [super tearDown];
}
- (void)testIsNotNil
{
    STAssertNotNil(repo, nil);
}
- (void)testRootHasDotGitSuffix
{
    STAssertTrue([repo.root hasSuffix:@".git"], nil);
}
- (void)testShouldLoadDataForHash
{
    NSString * sha = @"421b03c7c48b987452a05f02b1bdf73fff93f3b9";
    NSString * str = @"//\n//  GITBlob.h\n//  CocoaGit\n//\n//  Created by Geoffrey Garside on 29/06/2008.\n//  Copyright 2008 ManicPanda.com. All rights reserved.\n//\n\n#import <Cocoa/Cocoa.h>\n#import \"GITObject.h\"\n\n@interface GITBlob : GITObject {\n    \n}\n\n@end\n";
    NSData * data  = [NSData dataWithData:[str dataUsingEncoding:NSASCIIStringEncoding]];
    
    NSData * raw = [repo dataWithContentsOfObject:sha type:@"blob"];
    STAssertNotNil(raw, nil);
    STAssertEqualObjects(data, raw, nil);
}
@end
