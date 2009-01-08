//
// Socket.m
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

#import <sys/types.h>
#import <sys/socket.h>
#import <netinet/in.h>

#import "Socket.h"

@implementation Socket

+ (Socket*)socket
//
// Creates a Socket for you, and returns it.  
// The new Socket will be autoreleased, so be sure to retain it if you
// need to keep it around.
//
// Note: Sockets are blocking by default.
//
{
    return [[[Socket alloc] init] autorelease];
}


- (Socket*)acceptConnectionAndKeepListening
//
// Accept a connection on this socket, if it is listening.  May block if
// no connections are pending.  
//
// This variant of acceptConnection will return the connection to the remote host
// to you as a new Socket.  Meanwhile, this existing Socket will continue to 
// listen for connections.
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
    
    return [[[Socket alloc] initWithFD:socketfd2 remoteAddress:&acceptAddr] autorelease];
}

@end
