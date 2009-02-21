//
//  SSHChannel.m
//  SSHSession
//
//  Created by Brian Chapados on 2/6/09.
//  Copyright 2009 Brian Chapados. All rights reserved.
//

#import "SSHChannel.h"
#import "SSHError.h"
#import "MutableDataBufferExtension.h"
#import "NSData+HexDump.h"
#import "libssh2_priv.h"

const NSUInteger SSHChannelDefaultReadBufferSize = 4096;

@interface SSHChannel ()
- (CFIndex) _readData:(NSMutableData *)data;
- (void) allocReadBuffer;
- (void) deallocReadBuffer;
- (void) clearChannelError;
@end

@implementation SSHChannel

- (id) initWithSession:(LIBSSH2_SESSION *)sshSession;
{
    LIBSSH2_CHANNEL *sshChannel = libssh2_channel_open_session(sshSession);
    if (sshChannel == NULL)
        return nil;
    
    return [self initWithChannel:sshChannel];
}

- (id) initWithChannel:(LIBSSH2_CHANNEL *)sshChannel;
{
    if (! [super init])
        return nil;

    channel = sshChannel;
    
    readBufferSize = SSHChannelDefaultReadBufferSize;
    [self allocReadBuffer];
    
    buffer = [NSMutableData new];
    
    return self;
}

- (void) dealloc;
{
    [self close];
    [buffer release], buffer = nil;
    [self clearChannelError];
    [self deallocReadBuffer];
    [super dealloc];
}

- (void) finalize;
{
    [self close];
    [self deallocReadBuffer];
    [super finalize];
}

- (void) allocReadBuffer;
{
    if ( readBuffer == NULL ) {
        readBuffer = malloc(readBufferSize);
        NSAssert(readBuffer != NULL, @"Could not allocate internal READ buffer");
    }
}

- (void) deallocReadBuffer;
{
    if ( readBuffer != NULL ) {
        free(readBuffer);
        readBuffer = NULL;
    }
}

- (BOOL) isConnected;
{
    return (channel != NULL && libssh2_channel_eof(channel) == 0);
}

- (void) close;
{
    if (channel) {
        libssh2_channel_close(channel);
        libssh2_channel_free(channel);
        channel = NULL;
    }
}

- (BOOL) execCommand:(NSString *)command;
{
    int status;
    [self clearChannelError];

    while ((status = libssh2_channel_exec(channel,[command UTF8String])) == LIBSSH2_ERROR_EAGAIN);
    
    if (status < 0) {
        NSString *errorDescription = libssh2ErrorDescription(channel->session, @"Exec Command: '%@' failed.");
        SSHErrorWithDescription(&channelError, SSHErrorChannel, errorDescription, command);
        return NO;
    }
    return YES;
}

- (CFIndex) _readData:(NSMutableData *)data;
{
    NSAssert(data != nil, @"Invalid READ buffer");
    
    CFIndex count = 0;
    count = libssh2_channel_read(channel, (char *)readBuffer, readBufferSize);
    
    [self clearChannelError];
    if (count > 0) {    
        [data appendBytes:readBuffer length:count];
    } else if (count == 0) {
        [self close];
    } else if (count < 0) {
        if (count == LIBSSH2_ERROR_EAGAIN) {
            count = 0;
        } else {
            SSHErrorWithDescription(&channelError, SSHErrorChannel, libssh2ErrorDescription(channel->session, @"Error reading data."));
        }
    }
    
    return count;
}

- (NSData *) buffer;
{
    return [[buffer copy] autorelease];
}

- (NSMutableData *) readData:(CFIndex)n;
{
    while ([buffer length] < n) {
        int len;
        len = [self _readData:buffer];
        
        if (len == 0) 
			return nil; // socket closed or nonblocking socket && not enough data
    }
    
    return [buffer getBytes:n];
}

- (NSMutableData*) readDataUpToData:(NSData*)d;
{
    while (! [buffer containsData:d]) {
        int len;
        len = [self _readData:buffer];
		
        if (len == 0) 
			return nil; // socket closed or nonblocking socket && not enough data   
    }
    
    return [buffer getBytesUpToData:d];
}

- (NSMutableData*) readDataUpToString:(NSString*)s;
{
    return [self readDataUpToData:[s dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void) writeData:(NSData *)data;
{
    // send a private copy of the data
    NSData *d = [data copy];
    const char* buf = [d bytes];    
    CFIndex len = [data length];
    CFIndex sent;
    
    [self clearChannelError];
    while (len > 0) {
        /* write data in a loop until we (would) block */
        while ((sent = libssh2_channel_write(channel, buf, len)) == LIBSSH2_ERROR_EAGAIN);
        if (sent < 0) {
            SSHErrorWithDescription(&channelError, SSHErrorChannel, libssh2ErrorDescription(channel->session, @"Error writing data."));
            [d release];
            return;
        }
        buf += sent;
        len -= sent;
    }
    [d release];
}

- (void) sendEOF;
{
    while (libssh2_channel_send_eof(channel) == LIBSSH2_ERROR_EAGAIN);
}

- (void) clearChannelError;
{
    [channelError release], channelError = nil;
}

- (NSError *) channelError;
{
    if (! channelError)
        return nil;
    
    return [[channelError copy] autorelease];
}

@end
