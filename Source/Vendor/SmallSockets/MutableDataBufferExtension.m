//
// MutableDataBufferExtension.m
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

#import "MutableDataBufferExtension.h"


@implementation NSMutableData ( BufferExtension )

- (NSMutableData*)getBytes:(int)n
{
    char* bytes;
    int len;
    NSMutableData* result;
    
    // get length of data in object
    len = [self length];
    
    // sanity check raises exception if trying to delete more data than available in object
    if ( n > len)
    {
        [NSException raise:BUFFEREDSOCKET_EX_NOT_ENOUGH_DATA 
					format:@"trying to get %d bytes, only %d bytes in data object", n, len];
    }
    
    // get pointer to data in object
    bytes = [self mutableBytes];
    
    // copy requested amount of data to result
    result = [NSMutableData dataWithBytes:bytes length:n];
    
    // copy data from end of buffer to beginning
    memmove(bytes, bytes + n, len - n);
    
    // truncate buffer
    [self setLength:len - n];
    
    return result;
}


- (NSMutableData*)getBytesUpToData:(NSData*)d
{
    int len;
    
    if ( (len = [self indexOfData:d]) == -1 )
    {
        [NSException raise:BUFFEREDSOCKET_EX_PATTERN_NOT_FOUND 
					format:@"NSMutableData object dos not contain the requested pattern"];
    }

    len += [d length];
    
    return [self getBytes:len];
}


- (NSMutableData*)getBytesUpToString:(NSString*)s
{
    NSData* d;
    
    d = [s dataUsingEncoding:NSUTF8StringEncoding];
    
    return [self getBytesUpToData:d];
}


- (int)indexOfData:(NSData*)d
{
    const char* res;
    
    res = [self findPattern:[d bytes] length:[d length] 
					inBuffer:[self bytes] length:[self length]];
    
    if ( !res )
		return -1;
    
    return res - (const char*)[self bytes];
}


- (int)indexOfString:(NSString*)s
{
    const char* cs;
    NSData* d;
    
    cs = [s cStringUsingEncoding:[NSString defaultCStringEncoding]];
    d = [NSData dataWithBytes:cs length:strlen(cs)];
    
    return [self indexOfData:d];
}


// check if of d/s are in the reciever

- (BOOL)containsData:(NSData*)d
{
    return ([self indexOfData:d] != -1);
}


- (BOOL) containsString: (NSString*) s
{
	return ([self indexOfString:s] != -1);
}


// for internal use only

- (char*)findPattern:(const char*)pattern length:(int)plen 
			inBuffer:(const char*)buf length:(int)blen
{
    char* location;
    int restLen;
    
    // look for first byte of data in buffer
    location = memchr(buf, *pattern, blen);
    if ( !location ) 
		return NULL;
    
    // check if enough data follows to fit pattern into buffer
    restLen = blen - (location - buf);
    if ( restLen < plen ) 
		return NULL;
    
    // check if location is beginning of pattern
    if ( 0 == memcmp(pattern, location, plen) ) 
		return location;
    
    // find pattern in remaining buffer
    location++;
    restLen--;
    
    // check if remaining buffer is large enough for pattern
    if ( restLen < plen ) 
		return NULL;
    
    return [self findPattern:pattern length:plen 
						inBuffer:location length:restLen];
}

@end
