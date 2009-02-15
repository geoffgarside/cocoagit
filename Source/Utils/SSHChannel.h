//
//  SSHChannel.h
//  SSHSession
//
//  Created by Brian Chapados on 2/6/09.
//  Copyright 2009 Brian Chapados. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "libssh2.h"

extern const NSUInteger SSHChannelDefaultReadBufferSize;

@interface SSHChannel : NSObject {
    LIBSSH2_CHANNEL *channel;
        
    CFIndex readBufferSize;
    void *readBuffer;
    
    NSMutableData *buffer;
    NSError **channelError;
}

- (id) initWithSession:(LIBSSH2_SESSION *)sshSession;
- (id) initWithChannel:(LIBSSH2_CHANNEL *)sshChannel;
//- (void) openShell;

- (BOOL) execCommand:(NSString *)command;
- (NSMutableData *) readData:(CFIndex)n;
- (NSMutableData *) readDataUpToData:(NSData *)d;
- (NSMutableData *) readDataUpToString:(NSString *)s;
- (void) writeData:(NSData *)data;
- (void) sendEOF; // send channel EOF
- (void) close;

- (BOOL) isConnected;

// error accessor
- (NSError *)channelError;

// read-only copy of buffer
- (NSData *) buffer;

@end
