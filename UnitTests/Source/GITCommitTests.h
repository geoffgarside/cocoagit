//
//  GITCommitTests.h
//  CocoaGit
//
//  Created by Geoffrey Garside on 05/10/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import "GITTestHelper.h"

@class GITRepo, GITCommit;
@interface GITCommitTests : GHTestCase {
    GITRepo   * repo;
    GITCommit * commit;
    NSString  * commitSHA1;
    GITCommit * firstCommit;
    NSString  * firstCommitSha1;
}

@property(readwrite,retain) GITRepo   * repo;
@property(readwrite,retain) GITCommit * commit;
@property(readwrite,copy)   NSString  * commitSHA1;
@property(readwrite,retain) GITCommit * firstCommit;
@property(readwrite,copy)   NSString  * firstCommitSha1;

- (void)testIsNotNil;
- (void)testSha1MatchesInitialSha1;
- (void)testAuthorIsNotNil;
- (void)testAuthoredIsNotNil;
- (void)testCommitterIsNotNil;
- (void)testCommittedIsNotNil;

@end
