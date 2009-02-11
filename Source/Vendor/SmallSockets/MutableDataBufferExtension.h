//
// MutableDataBufferExtension.h
// BufferedSocket
//
// Created by Rainer Kupke (rkupke@gmx.de) on Wed Jul 18 2001.
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
 * This category extends the class NSMutableData to make it 
 * easier to use instances of NSMutableData as a FIFO buffer
 *
 * it contains messages for testing if an instance contains a 
 * specific byte sequence and for taking a prefix of the data
 * out of the buffer
 *
 */
 
#import <Foundation/Foundation.h>

// Exceptions raised by this category

#define BUFFEREDSOCKET_EX_NOT_ENOUGH_DATA   @"not enough data"
#define BUFFEREDSOCKET_EX_PATTERN_NOT_FOUND @"pattern not found"

@interface NSMutableData ( BufferExtension )

// Get the first n bytes from reciever and remove them from reciever
// will raise exception BUFFEREDSOCKET_EX_NOT_ENOUGH_DATA when 
// requesting more data than available

- (NSMutableData*)getBytes:(int)n; 

// Return prefix of reciever including the first occurrence of given data sequence
// Removes prefix including pattern from reciever
// Will raise exception BUFFEREDSOCKET_EX_PATTERN_NOT_FOUND when 
// pattern is not found inside the data

- (NSMutableData*)getBytesUpToData:(NSData*)d;
- (NSMutableData*)getBytesUpToString:(NSString*)s;

// Returns the index of the given data sequence in the reciever or -1

- (int)indexOfData:(NSData*)d; 
- (int)indexOfString:(NSString*)s;

// Check if the given data or string is in the reciever

- (BOOL)containsData:(NSData*)d; 
- (BOOL)containsString:(NSString*)s;

// For internal use

- (char*)findPattern:(const char*)pattern length:(int)len 
					inBuffer:(const char*)buf length:(int)len;

@end
