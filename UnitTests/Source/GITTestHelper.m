//
//  GITTestHelper.m
//  CocoaGit
//
//  Created by Brian Chapados on 12/15/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import "GITTestHelper.h"

@interface GITTestHelper ()
+ (NSString *) tmpWorkingDir;
@end

@implementation GITTestHelper

+ (NSString *) tmpWorkingDir;
{
    NSString *tmpWorkingDir;
    // generate a unique string
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    NSString *uString = (NSString *)CFUUIDCreateString(NULL, uuid);
    CFRelease(uuid);
    
    NSString *tempDir = NSTemporaryDirectory();
    if (tempDir != nil)
        tmpWorkingDir = [tempDir stringByAppendingPathComponent:uString];
    
    [uString release];
    return tmpWorkingDir;
}

+ (NSString *) createTempRepoWithDotGitDir:(NSString *)clonePath;
{
    NSString *tmpDir = [self tmpWorkingDir];
    NSString *sourceRepoPath = [TEST_RESOURCES_PATH stringByAppendingPathComponent:clonePath];
    NSFileManager *fm = [NSFileManager defaultManager];
    
    NSError *error;
    BOOL success = ([fm createDirectoryAtPath:tmpDir withIntermediateDirectories:YES attributes:nil error:&error] && [fm copyItemAtPath:sourceRepoPath toPath:tmpDir error:&error]);
    
    // crash here if we could not copy the files.
    NSAssert1(success, @"Could not create temp repo.\n%@", [error localizedDescription]);
    
    return [tmpDir stringByAppendingPathComponent:clonePath];
}

+ (BOOL) removeTempRepoAtPath:(NSString *)aPath;
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error;
    // crash immediately if we don't succeed.
    NSAssert1([fm removeItemAtPath:aPath error:&error], @"Could not delete temp repo.\n%@", [error localizedDescription]);
    return YES;
}

+ (NSDictionary *)packedObjects;
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            @"e83483aee3acd1ed7e268f524feaccefc20dd9e7", @"raw_blob",
            @"dad7275d1d9c17b81ffab9a61cfd48c940aaf994", @"deltified_blob",
            @"da26259c7057cedc6552071f1fc51b430e01fab4", @"deltified_blob_xo",
            @"d00160399d71034078fd8ea531a6739f321b369b", @"raw_tree",
            @"dc493b818cbbf489bf5e6dfa793fc991df4fc078", @"deltified_tree",
            @"fac337c337d0dc53a61360daad8f18b632066460", @"deltified_tree_xo",
            @"8c9db88c17479d4663658fd9321e095ea2c4a690", @"last_normal_object", // offset = 299902
            @"5cf8773ba4c007845873e3d8b23d406652a1f8c4", @"penultimate_object", // offset = 332809
            @"a01ba8491691058a072cbb4b12acce1d54801e22", @"last_object", nil];  // offset = 332902
}
@end