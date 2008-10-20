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
}

@property(readwrite,retain) GITRepo   * repo;
@property(readwrite,retain) GITCommit * commit;
@property(readwrite,copy)   NSString  * commitSHA1;

- (void)testIsNotNil;
- (void)testSha1MatchesInitialSha1;
- (void)testAuthorIsNotNil;
- (void)testAuthoredIsNotNil;
- (void)testCommitterIsNotNil;
- (void)testCommittedIsNotNil;

@end
