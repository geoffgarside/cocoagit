//
// BufferedSocket.h
// BufferedSocket
//
// Created by Rainer Kupke (rkupke@gmx.de) on Thu Jul 26 2001.
// Copyright (c) 2001 Rainer Kupke.
//
// Additional modifications by Steven Frank (stevenf@panic.com)
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


/*
 * The Socket class must be supplied with an NSMutableData object
 * on each read and appends the data that was read from the 
 * BSD-socket, but will often return with more or less data than
 * the caller requires. This forces the programmer to keep track of 
 * additional data that is read.
 *
 * The BufferedSocket class internally buffers the data read from 
 * the Socket and implements messages that can
 * a) read a specified amount of data
 * b) read data until a secified pattern is found
 *
 */

#import "Socket.h"

@interface BufferedSocket : Socket 
{
    NSMutableData* buffer;
}

// Convenience constructor

+ (BufferedSocket*)bufferedSocket;

// Designated initializer

- (id)init;

// Destructor

- (void)dealloc;

// Receiving connections

- (BufferedSocket*)acceptConnectionAndKeepListening;

// Reading and writing data

- (NSMutableData*)readData: (int)n;
- (NSMutableData*)readDataUpToData:(NSData*) d;
- (NSMutableData*)readDataUpToString:(NSString*) s;

@end
