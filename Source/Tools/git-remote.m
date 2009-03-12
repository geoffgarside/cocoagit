//
//  git-remote.m
//  CocoaGit
//
//  Created by Scott Chacon on 1/6/09.
//  Copyright 2009 GitHub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GITClient.h"

int
main (int argc, const char *argv[]) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSProcessInfo *info = [NSProcessInfo processInfo];
    NSArray *args = [info arguments];

    if ([args count] != 2 ) {
        printf("You have to provide a git:// url\n");
        exit(0);
    }

    NSString *url = [args objectAtIndex: 1];
    GITClient *client = [[GITClient alloc] init];
    [client clone: url];

    [pool drain];
    return 0;
}
