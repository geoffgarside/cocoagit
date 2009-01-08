//
//  GITServer.h
//  CocoaGit
//
//  Created by Scott Chacon on 1/4/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TCPServer.h"

@class GITServer;

@interface GITServer : NSObject {
	TCPServer *tcpServer;
	NSString *workingDir;
	
	unsigned short listen_port;
}

@property(copy, readwrite) NSString *workingDir;

- (BOOL) shouldExit;
- (oneway void) startListening:(NSString *) gitStartDir;

@end
