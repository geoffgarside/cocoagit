//
//  GITTree.m
//  CocoaGit
//
//  Created by Geoffrey Garside on 29/06/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import "GITTree.h"

static const char hexchars[] = "0123456789abcdef";

@interface GITTree (Private)

- (NSData*)packSHA1:(NSString*)unpackedSHA1;
- (NSString*)unpackSHA1FromString:(NSString*)packedSHA1;
- (NSString*)unpackSHA1FromData:(NSData*)packedSHA1;

@end


@implementation GITTree

@end

@implementation GITTree (Private)

- (NSData*)packSHA1:(NSString*)unpackedSHA1
{
    unsigned int highBits, lowBits, bits;
    NSMutableData *packedSHA1 = [NSMutableData dataWithCapacity:20];
    for (int i = 0; i < [unpackedSHA1 length]; i++)
    {
        if (i % 2 == 0) {
            highBits = (strchr(hexchars, [unpackedSHA1 characterAtIndex:i]) - hexchars) << 4;
        } else {
            lowBits = strchr(hexchars, [unpackedSHA1 characterAtIndex:i]) - hexchars;
            bits = (highBits | lowBits);
            [packedSHA1 appendBytes:&bits length:1];
        }
    }
    return packedSHA1;
}
- (NSString*)unpackSHA1FromString:(NSString*)packedSHA1
{
    NSMutableString *unpackedSHA1 = [NSMutableString stringWithCapacity:40];
    for(int i = 0; i < 20; i++)
    {
        unsigned int bits = [packedSHA1 characterAtIndex:i];
        [unpackedSHA1 appendFormat:@"%c", hexchars[bits >> 4]];
        [unpackedSHA1 appendFormat:@"%c", hexchars[bits & 0xf]];
    }
    return unpackedSHA1;
}
- (NSString*)unpackSHA1FromData:(NSData*)packedSHA1
{
    NSMutableString *unpackedSHA1 = [NSMutableString stringWithCapacity:40];
    for(int i = 0; i < 20; i++)
    {
        unsigned int bits;
        [packedSHA1 getBytes:&bits range:NSMakeRange(i, 1)];
        [unpackedSHA1 appendFormat:@"%c", hexchars[bits >> 4]];
        [unpackedSHA1 appendFormat:@"%c", hexchars[bits & 0xf]];
    }
    return unpackedSHA1;
}

@end

