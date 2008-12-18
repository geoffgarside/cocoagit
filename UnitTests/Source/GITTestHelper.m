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

@end