//
//  GITClient.m
//  CocoaGit
//
//  Created by Scott Chacon on 1/3/09.
//  Copyright 2009 GitHub. All rights reserved.
//

#import "GITClient.h"


@implementation GITClient

/*
- (void) connectToURL:(NSURL *) gitURL;
{		
	// typical git:// url =  git://<host>/path/to/repo.git
	if ([[gitURL scheme] isEqualToString:@"git"]) {
		NSHost *host = [NSHost hostWithName:[gitURL host]];
		NSUInteger port = [gitURL port] || DEFAULT_GIT_PORT;
		//NSString *repoPath = [gitURL path];
		//NSString *repoName = [repoPath lastPathComponent];
		
		// *** not available for iPhone ***
		// need to use CFStream or switch to SmallSockets...
		// for now quick and dirty - this will change anyway
		NSInputStream *sin;
		NSOutputStream *sout;
		[NSStream getStreamsToHost:host
							  port:port 
					   inputStream:&sin 
					  outputStream:&sout];
		[self setInStream:sin];
		[self setOutStream:sout];
	} else if ([gitURL isFileURL]) {
		// Not sure that this will work properly...
		NSString *path = [gitURL path];
		[self setInStream:[NSInputStream inputStreamWithFileAtPath:path]];
		[self setOutStream:[NSOutputStream outputStreamToFileAtPath:path append:YES]];
	}
	
	if (inStream && outStream)
		[self handleRequest];
}
*/

@end
