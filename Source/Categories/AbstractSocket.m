//
// AbstractSocket.m
//
// SmallSockets Library (http://smallsockets.sourceforge.net/)
//
// Copyright (C) 2001 Steven Frank (stevenf@panic.com)
//
// This software is provided 'as-is', without any express or implied 
// warranty. In no event will the authors be held liable for any damages 
// arising from the use of this software.
//
// Permission is granted to anyone to use this software for any purpose, 
// including commercial applications, and to alter it and redistribute it 
// freely, subject to the following restrictions:
//
//     1. The origin of this software must not be misrepresented; you must 
//        not claim that you wrote the original software. If you use this 
//        software in a product, an acknowledgment in the product 
//        documentation (and/or about box) would be appreciated but is not 
//        required.
//
//     2. Altered source versions must be plainly marked as such, and must
//        not be misrepresented as being the original software.
//
//     3. This notice may not be removed or altered from any source 
//        distribution.
//        
 
#import "AbstractSocket.h"

#import <fcntl.h>
#import <netdb.h>
#import <netinet/in.h>
#import <sys/socket.h>
#import <sys/time.h>
#import <sys/types.h>
#import <arpa/inet.h>
#import <unistd.h>


@implementation AbstractSocket

- (id)init
//
// Designated initializer
//
{    
    if ( ![super init] )
		return nil;

    connected = NO;
    listening = NO;
    readBuffer = NULL;
    readBufferSize = SOCKET_DEFAULT_READ_BUFFER_SIZE;
    remoteHostName = NULL;
    remotePort = SOCKET_INVALID_PORT;

    // Create socket

    if ( (socketfd = socket(AF_INET, SOCK_STREAM, 0)) < 0 )
        [NSException raise:SOCKET_EX_CANT_CREATE_SOCKET 
                        format:SOCKET_EX_CANT_CREATE_SOCKET_F, strerror(errno)];

    [self allocReadBuffer];
    
    return self;
}


- (void)dealloc
//
// Do not call this method directly!  Use retain & release.
//
{
    [self close];

    if ( readBuffer )
    {
        free(readBuffer);
        readBuffer = NULL;
    }
    
    [super dealloc];
}


- (void)acceptConnection
//
// Accept a connection on this socket, if it is listening.  May block if
// no connections are pending.  The existing listening socket will be destroyed, and
// replaced with the socket that is connected to the remote host.
//
// If you want to keep the listening socket around, try acceptConnectionAndKeepListening
//
{
    struct sockaddr_in acceptAddr;
    int socketfd2 = SOCKET_INVALID_DESCRIPTOR;
    int addrSize = sizeof(acceptAddr);
  
    // Socket must be created, not connected, and listening
    
    if ( socketfd == SOCKET_INVALID_DESCRIPTOR )
        [NSException raise:SOCKET_EX_BAD_SOCKET_DESCRIPTOR 
                        format:SOCKET_EX_BAD_SOCKET_DESCRIPTOR];

    if ( connected )
        [NSException raise:SOCKET_EX_ALREADY_CONNECTED 
                        format:SOCKET_EX_ALREADY_CONNECTED];

    if ( !listening )
        [NSException raise:SOCKET_EX_NOT_LISTENING 
                        format:SOCKET_EX_NOT_LISTENING];
   
    // Accept a remote connection.  Raise on failure
    
    socketfd2 = accept(socketfd, (struct sockaddr*)&acceptAddr, &addrSize);
    
    if ( socketfd2 < 0 )
        [NSException raise:SOCKET_EX_ACCEPT_FAILED 
                        format:SOCKET_EX_ACCEPT_FAILED_F, strerror(errno)];
    
    // Replace existing socket descriptor with newly obtained one
    
    [self close];

    remotePort = acceptAddr.sin_port;
    remoteHostName = [[AbstractSocket dottedIPFromAddress:&acceptAddr.sin_addr] retain];
    
    socketfd = socketfd2;
    connected = YES;
    listening = NO;
}


- (void)allocReadBuffer
//
// Internal utility function.  You should not call this from client code.
//
{
    // Allocate readBuffer
    
    if ( readBuffer == NULL )
    {
        readBuffer = malloc(readBufferSize);
        if ( readBuffer == NULL )
            [NSException raise:SOCKET_EX_MALLOC_FAILED format:SOCKET_EX_MALLOC_FAILED];
    }
}


- (void)bindTo:(u_int32_t)address port:(unsigned short)port
//
// Bind an address to this socket.  You normally do not need to
// call this method.  See listenOnPort instead.
//
{
    struct sockaddr_in localAddr;
    int on = 1;

    // Set a flag so that this address can be re-used immediately after the connection
    // closes.  (TCP normally imposes a delay before an address can be re-used.)
    
    if ( setsockopt(socketfd, SOL_SOCKET, SO_REUSEADDR, (void*)&on, sizeof(on)) < 0 )
        [NSException raise:SOCKET_EX_SETSOCKOPT_FAILED 
                        format:SOCKET_EX_SETSOCKOPT_FAILED_F, strerror(errno)];

    // Bind the address to the socket

    localAddr.sin_family      = AF_INET;
    localAddr.sin_addr.s_addr = htonl(address);
    localAddr.sin_port        = htons(port);

    if ( bind(socketfd, (struct sockaddr*)&localAddr, sizeof(localAddr)) < 0 )
	[NSException raise:SOCKET_EX_BIND_FAILED 
                        format:SOCKET_EX_BIND_FAILED_F, strerror(errno)];
}


- (void)close
//
// Closes the socket.  You generally do not need to call this, as the socket
// will be automatically closed when it is released.
//
{
    if ( socketfd != SOCKET_INVALID_DESCRIPTOR )
    {
        close(socketfd);
        socketfd = SOCKET_INVALID_DESCRIPTOR;
    }
    
    if ( remoteHostName != NULL )
    {
        [remoteHostName release];
        remoteHostName = NULL;
    }

    connected = NO;
    listening = NO;
    remotePort = SOCKET_INVALID_PORT;
}


- (void)connectToHostName:(NSString*)hostName port:(unsigned short)port
//
// Connect the socket to the host specified by hostName, on the requested port.
//
{
    struct hostent* remoteHost;
    struct sockaddr_in remoteAddr;

    // Socket must be created, and not already connected

    if ( socketfd == SOCKET_INVALID_DESCRIPTOR )
        [NSException raise:SOCKET_EX_BAD_SOCKET_DESCRIPTOR 
                        format:SOCKET_EX_BAD_SOCKET_DESCRIPTOR];
    
    if ( connected )
        [NSException raise:SOCKET_EX_ALREADY_CONNECTED 
                        format:SOCKET_EX_ALREADY_CONNECTED];
    
    // Look up host 
    
    if ( (remoteHost = gethostbyname([hostName cString])) == NULL )
        [NSException raise:SOCKET_EX_HOST_NOT_FOUND 
                        format:SOCKET_EX_HOST_NOT_FOUND_F, strerror(errno)];
    
    // Copy host address and port into socket address structure
    
    bzero((char*)&remoteAddr, sizeof(remoteAddr));
    remoteAddr.sin_family = AF_INET;
    bcopy((char*)remoteHost->h_addr, (char*)&remoteAddr.sin_addr.s_addr, remoteHost->h_length);
    remoteAddr.sin_port = htons(port);

    // Request connection, raise on failure
    
    if ( (connect(socketfd, (struct sockaddr*)&remoteAddr, sizeof(remoteAddr)) < 0) )
        [NSException raise:SOCKET_EX_CONNECT_FAILED 
                        format:SOCKET_EX_CONNECT_FAILED_F, strerror(errno)];

    // Note successful connection
    
    remoteHostName = [[NSString alloc] initWithString:hostName];
    remotePort = port;

    connected = YES;
}


+ (NSString*)dottedIPFromAddress:(struct in_addr*)address;
//
// Utility function that returns a dotted IP address string from a
// 32-bit network address
//
{
    return [NSString stringWithCString:inet_ntoa(*address)];
}


- (id)initWithFD:(int)fd remoteAddress:(struct sockaddr_in*)remoteAddress 
//
// Inits a Socket with an existing, connected socket file descriptor.  This is really
// only intended for internal use (see -acceptConnectionAndKeepListening) 
//
{
    if ( ![super init] )
	return nil;

    connected = YES;
    listening = NO;
    readBuffer = NULL;
    readBufferSize = SOCKET_DEFAULT_READ_BUFFER_SIZE;
    remoteHostName = [[AbstractSocket dottedIPFromAddress:&remoteAddress->sin_addr] retain];
    remotePort = remoteAddress->sin_port;
    socketfd = fd;    

    [self allocReadBuffer];

    return self;
}


- (BOOL)isConnected
//
// Returns whether the socket is connected
//
{
    return connected;
}


- (BOOL)isReadable
//
// Returns whether or not data is available at the Socket for reading
//
{
    int count;
    fd_set readfds;
    struct timeval timeout;
    
    // Socket must be created and connected
    
    if ( socketfd == SOCKET_INVALID_DESCRIPTOR )
        [NSException raise:SOCKET_EX_BAD_SOCKET_DESCRIPTOR 
                        format:SOCKET_EX_BAD_SOCKET_DESCRIPTOR];

    if ( !connected )
        [NSException raise:SOCKET_EX_NOT_CONNECTED 
                        format:SOCKET_EX_NOT_CONNECTED];

    // Create a file descriptor set for just this socket

    FD_ZERO(&readfds);
    FD_SET(socketfd, &readfds);
   
    // Create a timeout of zero (don't wait)
   
    timeout.tv_sec = 0;
    timeout.tv_usec = 0;
 
    // Check socket for data
 
    count = select(socketfd + 1, &readfds, NULL, NULL, &timeout);
    
    // Return value of less than 0 indicates error

    if ( count < 0 )
        [NSException raise:SOCKET_EX_SELECT_FAILED 
                        format:SOCKET_EX_SELECT_FAILED_F, strerror(errno)];
    
    // select() returns number of descriptors that matched, so 1 == has data, 0 == no data
    
    return (count == 1);
}


- (BOOL)isWritable
//
// Returns whether or not the Socket can be written to
//
{
    int count;
    fd_set writefds;
    struct timeval timeout;
    
    // Socket must be created and connected
    
    if ( socketfd == SOCKET_INVALID_DESCRIPTOR )
        [NSException raise:SOCKET_EX_BAD_SOCKET_DESCRIPTOR 
                        format:SOCKET_EX_BAD_SOCKET_DESCRIPTOR];

    if ( !connected )
        [NSException raise:SOCKET_EX_NOT_CONNECTED 
                        format:SOCKET_EX_NOT_CONNECTED];

    // Create a file descriptor set for just this socket

    FD_ZERO(&writefds);
    FD_SET(socketfd, &writefds);
   
    // Create a timeout of zero (don't wait)
   
    timeout.tv_sec = 0;
    timeout.tv_usec = 0;
 
    // Check socket for data
 
    count = select(socketfd + 1, NULL, &writefds, NULL, &timeout);
    
    // Return value of less than 0 indicates error

    if ( count < 0 )
        [NSException raise:SOCKET_EX_SELECT_FAILED 
                        format:SOCKET_EX_SELECT_FAILED_F, strerror(errno)];
    
    // select() returns number of descriptors that matched, so 1 == write OK
    
    return (count == 1);
}


- (void)listenOnPort:(unsigned short)port
//
// Start the socket listening on the given local port number
//
{
    [self listenOnPort:port maxPendingConnections:SOCKET_MAX_PENDING_CONNECTIONS];
}


- (void)listenOnPort:(unsigned short)port maxPendingConnections:(unsigned int)maxPendingConnections
//
// Start the socket listening on the given local port number,
// with the given maximum number of pending connections.
//
{
    [self bindTo:INADDR_ANY port:port];

    if ( listen(socketfd, maxPendingConnections) < 0 )
        [NSException raise:SOCKET_EX_LISTEN_FAILED 
                        format:SOCKET_EX_LISTEN_FAILED_F, strerror(errno)];
        
    listening = YES;
}


- (unsigned int)readBufferSize
//
// Returns this Socket's readBuffer size
//
{
    return readBufferSize;
}


- (int)readData:(NSMutableData*)data
//
// Append any available data from the socket to the supplied buffer.
// Returns number of bytes received.  (May be 0)
//
{
    ssize_t count;
 
	// data must not be null ptr
	
	if ( data == NULL )
		[NSException raise:SOCKET_EX_INVALID_BUFFER 
						format:SOCKET_EX_INVALID_BUFFER];
 
    // Socket must be created and connected
    
    if ( socketfd == SOCKET_INVALID_DESCRIPTOR )
        [NSException raise:SOCKET_EX_BAD_SOCKET_DESCRIPTOR 
                        format:SOCKET_EX_BAD_SOCKET_DESCRIPTOR];

    if ( !connected )
        [NSException raise:SOCKET_EX_NOT_CONNECTED 
                        format:SOCKET_EX_NOT_CONNECTED];
    
    // Request a read of as much as we can.  Should return immediately if no data.
   
    count = recv(socketfd, readBuffer, readBufferSize, 0);
    
    if ( count > 0 )
    {
        // Got some data, append it to user's buffer

        [data appendBytes:readBuffer length:count];
    }
    else if ( count == 0 )
    {
        // Other side has disconnected, so close down our socket

        [self close];
    }
    else if ( count < 0 )
    {
        // recv() returned an error. 
                
        if ( errno == EAGAIN )
        {
            // No data available to read (and socket is non-blocking)
            count = 0;
        }
        else
            [NSException raise:SOCKET_EX_RECV_FAILED 
                            format:SOCKET_EX_RECV_FAILED_F, strerror(errno)];
    }
    
    return count;
}


- (NSString*)remoteHostName
//
// Returns the remote hostname that the socket is connected to,
// or NULL if the socket is not connected.
//
{
    return remoteHostName;
}


- (unsigned short)remotePort
//
// Returns the remote port number that the socket is connected to, 
// or 0 if not connected.
//
{
    return remotePort;
}


- (void)setBlocking:(BOOL)shouldBlock
//
// Switch the socket to blocking or non-blocking mode
//
{
    int flags;
    int result;
    
    flags = fcntl(socketfd, F_GETFL, 0);

    if ( flags < 0 )
        [NSException raise:SOCKET_EX_FCNTL_FAILED 
                        format:SOCKET_EX_FCNTL_FAILED_F, strerror(errno)];

    if ( shouldBlock )
    {
        // Set it to blocking...
        result = fcntl(socketfd, F_SETFL, flags & ~O_NONBLOCK );
    }
    else
    {
        // Set it to non-blocking...
        result = fcntl(socketfd, F_SETFL, flags | O_NONBLOCK);
    }

    if ( result < 0 )
        [NSException raise:SOCKET_EX_FCNTL_FAILED 
                        format:SOCKET_EX_FCNTL_FAILED_F, strerror(errno)];
}


- (void)setReadBufferSize:(unsigned int)size
//
// Change the size of the read buffer at runtime
//
{
    readBufferSize = size;
	
    if ( readBuffer ) 
    {
        free(readBuffer);
        readBuffer = NULL;
    }
    
    [self allocReadBuffer];
}


- (void)writeData:(NSData*)data
//
// Writes the given data to the socket
//
{
    const char* bytes = [data bytes];    
    int len = [data length];
    int sent;
    
    // Socket must be created and connected
    
    if ( socketfd == SOCKET_INVALID_DESCRIPTOR )
        [NSException raise:SOCKET_EX_BAD_SOCKET_DESCRIPTOR 
                        format:SOCKET_EX_BAD_SOCKET_DESCRIPTOR];

    if ( !connected )
        [NSException raise:SOCKET_EX_NOT_CONNECTED 
                        format:SOCKET_EX_NOT_CONNECTED];
    
    // Send the data
    
    while ( len > 0 )
    {
        sent = send(socketfd, bytes, len, 0);
        
        if ( sent < 0 )
            [NSException raise:SOCKET_EX_SEND_FAILED 
                            format:SOCKET_EX_SEND_FAILED_F, strerror(errno)];    
        
        bytes += sent;
        len -= sent;
    }
}


- (void)writeString:(NSString*)string
//
// Writes the given string to the socket
//
{
    if ( [string length] > 0 ) 
        [self writeData:[string dataUsingEncoding:NSUTF8StringEncoding]]; 
}


@end

