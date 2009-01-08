//
//  GITClient.h
//  CocoaGit
//
//  Created by Scott Chacon on 1/3/09.
//  Copyright 2009 GitHub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Socket.h"

@interface GITClient : NSObject {
	Socket*	 	socket;
}

@property(retain, readwrite) Socket *socket;	

- (BOOL) clone:(NSString *) url;
- (void) sendPacket:(NSString *)dataWrite;
- (void) writeServer:(NSString *)dataWrite;
- (void) writeServerLength:(NSUInteger)length;

@end
