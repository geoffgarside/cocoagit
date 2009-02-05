//
//  NSData+Patching.m
//  CocoaGit
//
//  Created by Geoffrey Garside on 01/02/2009.
//  Copyright 2009 ManicPanda.com. All rights reserved.
//

#import "NSData+Patching.h"


@implementation NSData (Patching)

- (void)patchDeltaHeader:(NSData*)deltaData size:(unsigned long*)size position:(unsigned long*)position
{
    int shift = 0;
    unsigned char c;
    *size = 0;
    
    do {
        [deltaData getBytes:&c range:NSMakeRange(*position, 1)];
        *position += 1;
        
        *size |= ((c & 0x7f) << shift);
        shift += 7;
    } while ( (c & 0x80) != 0 );
}

- (NSData*)dataByPatchingWithDelta:(NSData*)deltaData
{
    unsigned long sourceSize, destSize, position = 0;
    unsigned long cp_off, cp_size;
    unsigned char c, d;
    
    int bufLength = 1000;
    
    [self patchDeltaHeader:deltaData size:&sourceSize position:&position];
    [self patchDeltaHeader:deltaData size:&destSize position:&position];
    
    NSMutableData *buffer = [[NSMutableData alloc] initWithCapacity:bufLength];
    NSMutableData *destination = [NSMutableData dataWithCapacity:destSize];
    
    while (position < [deltaData length]) {
        [deltaData getBytes:&c range:NSMakeRange(position, 1)];
        
        ++position;
        if ( (c & 0x80) != 0 ) {
            --position;
            cp_off = cp_size = 0;
            
            if ( 0 != (c & 0x01) ) {
                [deltaData getBytes:&d range:NSMakeRange(++position, 1)];
                cp_off = d;
            }
            if ( 0 != (c & 0x02) ) {
                [deltaData getBytes:&d range:NSMakeRange(++position, 1)];
                cp_off |= d << 8;
            }
            if ( 0 != (c & 0x04) ) {
                [deltaData getBytes:&d range:NSMakeRange(++position, 1)];
                cp_off |= d << 16;
            }
            if ( 0 != (c & 0x08) ) {
                [deltaData getBytes:&d range:NSMakeRange(++position, 1)];
                cp_off |= d << 24;
            }
            if ( 0 != (c & 0x10) ) {
                [deltaData getBytes:&d range:NSMakeRange(++position, 1)];
                cp_off |= d;
            }
            if ( 0 != (c & 0x20) ) {
                [deltaData getBytes:&d range:NSMakeRange(++position, 1)];
                cp_off |= d << 8;
            }
            if ( 0 != (c & 0x40) ) {
                [deltaData getBytes:&d range:NSMakeRange(++position, 1)];
                cp_off |= d << 16;
            }
            
            if (cp_size == 0)
                cp_size = 0x10000;
            
            ++position;
            
            if (cp_size > bufLength) {
                bufLength = cp_size + 1;
                [buffer setLength:bufLength];
            }
            
            [self getBytes:[buffer mutableBytes] range:NSMakeRange(cp_off, cp_size)];
            [destination appendBytes:[buffer bytes] length:cp_size];
        } else if ( c != 0 ) {
            if ( c > destSize )
                break;
            
            [deltaData getBytes:[buffer mutableBytes] range:NSMakeRange(position, c)];
            [destination appendBytes:[buffer bytes] length:c];
            position += c;
            destSize -= c;
        } else {
            // invalid delta data
        }
    }
    
    [buffer release];
    return [[destination copy] autorelease];
}

@end
