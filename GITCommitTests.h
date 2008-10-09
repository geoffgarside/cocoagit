//
//  GITCommitTests.h
//  CocoaGit
//
//  Created by Geoffrey Garside on 05/10/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

@class GITRepo, GITCommit;
@interface GITCommitTests : SenTestCase {
    GITRepo   * repo;
    GITCommit * commit;
    NSString  * commitSHA1;
    NSUInteger rawCommitSize;
}

@property(readwrite,retain) GITRepo   * repo;
@property(readwrite,retain) GITCommit * commit;
@property(readwrite,copy)   NSString  * commitSHA1;
@property(readwrite,assign) NSUInteger rawCommitSize;

- (void)testIsNotNil;
- (void)testSha1MatchesInitialSha1;
- (void)testSizeMatchesRawSize;
- (void)testAuthorIsNotNil;

#pragma mark -
#pragma mark Helpers
- (NSData*)rawCommitData;

@end
