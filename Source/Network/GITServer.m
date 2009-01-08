//
//  GITServer.m
//  CocoaGit
//
//  Created by Scott Chacon on 1/4/09.
//  Copyright 2009 GitHub. All rights reserved.
//

#import "GITServer.h"
#import "GITServerHandler.h"
#import "GITRepo.h"

@implementation GITServer

@synthesize workingDir;

- (BOOL) shouldExit {
	return false;
}

- (oneway void) startListening:(NSString *) gitStartDir {
	uint16_t port = 9418;
	
	workingDir = gitStartDir;
	
	tcpServer = [[TCPServer alloc] init];
	NSError *error = nil;
	[tcpServer setPort: port];
	[tcpServer setDelegate: self];
	if (![tcpServer start:&error] ) {
		NSLog(@"Error starting server: %@", error);
	} else {
		NSLog(@"Starting server on port %d", [tcpServer port]);
	}	
}

- (void)TCPServer:(TCPServer *)server didReceiveConnectionFromAddress:(NSData *)addr inputStream:(NSInputStream *)inStream outputStream:(NSOutputStream *)outStream {
	NSLog(@"New connection received...");
		
	NSLog(@"gitdir:%@", workingDir);
	
	[outStream open];
	[inStream  open];
	
	GITRepo* git = [GITRepo alloc];
	GITServerHandler *obsh = [[GITServerHandler alloc] init];
	
	NSLog(@"INIT WITH GIT:  %@ : %@ : %@ : %@ : %@", obsh, git, workingDir, inStream, outStream);
	[obsh initWithGit:git gitPath:workingDir input:inStream output:outStream];	

	[outStream close];
	[inStream  close];
}

@end
