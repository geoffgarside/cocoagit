#import <Foundation/Foundation.h>
#import <GHUnit/GHUnit.h>
//#import <SenTestingKit/SenTestingKit.h>

#define COCOAGIT_REPO @"."
#define TEST_RESOURCES_PATH @"../../UnitTests/Resources/"

#define DOT_GIT TEST_RESOURCES_PATH @"dot_git/"
#define DELTA_REF_PACK TEST_RESOURCES_PATH @"packs/cg-0.2.5-deltaref-be5a15ac583f7ed1e431f03bd444bbde6511e57c.pack"
#define DELTA_OFS_PACK TEST_RESOURCES_PATH @"packs/cg-0.2.5-deltaofs-be5a15ac583f7ed1e431f03bd444bbde6511e57c.pack"

@interface GITTestHelper : NSObject
{}
+ (NSString *) createTempRepoWithDotGitDir:(NSString *)clonePath;
+ (BOOL) removeTempRepoAtPath:(NSString *)aPath;
+ (NSDictionary *)packedObjects;
@end