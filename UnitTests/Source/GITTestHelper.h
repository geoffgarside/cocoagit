#import <Foundation/Foundation.h>
#import <SenTestingKit/SenTestingKit.h>

#define COCOAGIT_REPO @"."
#define TEST_RESOURCES_PATH @"UnitTests/Resources/"

#define DOT_GIT TEST_RESOURCES_PATH @"dot_git/"

@interface GITTestHelper : NSObject
{}
+ (NSString *) createTempRepoWithDotGitDir:(NSString *)clonePath;
+ (BOOL) removeTempRepoAtPath:(NSString *)aPath;
@end