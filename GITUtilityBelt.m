//
//  GITUtilityBelt.m
//  CocoaGit
//
//  Created by Geoffrey Garside on 12/08/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import "GITUtilityBelt.h"

const NSUInteger kGITPackedSha1Length   = 20;
const NSUInteger kGITUnpackedSha1Length = 40;

static const char hexchars[] = "0123456789abcdef";

NSData *
packSHA1(NSString * unpackedSHA1)
{
    unsigned int highBits, lowBits, bits;
    NSMutableData *packedSHA1 = [NSMutableData dataWithCapacity:kGITPackedSha1Length];
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

NSString *
unpackSHA1FromString(NSString * packedSHA1)
{
    unsigned int bits;
    NSMutableString *unpackedSHA1 = [NSMutableString stringWithCapacity:kGITUnpackedSha1Length];
    for(int i = 0; i < kGITPackedSha1Length; i++)
    {
        bits = [packedSHA1 characterAtIndex:i];
        [unpackedSHA1 appendFormat:@"%c", hexchars[bits >> 4]];
        [unpackedSHA1 appendFormat:@"%c", hexchars[bits & 0xf]];
    }
    return unpackedSHA1;
}

NSString *
unpackSHA1FromData(NSData * packedSHA1)
{
    unsigned int bits;
    NSMutableString *unpackedSHA1 = [NSMutableString stringWithCapacity:kGITUnpackedSha1Length];
    for(int i = 0; i < kGITPackedSha1Length; i++)
    {
        [packedSHA1 getBytes:&bits range:NSMakeRange(i, 1)];
        [unpackedSHA1 appendFormat:@"%c", hexchars[bits >> 4]];
        [unpackedSHA1 appendFormat:@"%c", hexchars[bits & 0xf]];
    }
    return unpackedSHA1;
}

NSUInteger
integerFromBytes(unichar * bytes, NSUInteger length)
{
    NSUInteger i, value = 0;
    for (i = 0; i <= length; i++)
        value = (value << 8) | bytes[i];
    return value;
}
