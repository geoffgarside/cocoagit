//
//  NSData+Hashing.m
//  CocoaGit
//
//  Created by Geoffrey Garside on 29/06/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//
//  Methods extracted from source given at
//  http://www.cocoadev.com/index.pl?NSDataCategory
//

#import "NSData+Hashing.h"
#include <openssl/sha.h>

@implementation NSData (Hashing)

#pragma mark -
#pragma mark Hashing macros
#define HEComputeDigest(method)                                         \
    method##_CTX ctx;                                                   \
    unsigned char digest[method##_DIGEST_LENGTH];                       \
    method##_Init(&ctx);                                                \
    method##_Update(&ctx, [self bytes], [self length]);                 \
    method##_Final(digest, &ctx);

#define HEComputeDigestNSData(method)                                   \
    HEComputeDigest(method)                                             \
    return [NSData dataWithBytes:digest length:method##_DIGEST_LENGTH];

#define HEComputeDigestNSString(method)                                 \
    static char __HEHexDigits[] = "0123456789abcdef";                   \
    unsigned char digestString[2*method##_DIGEST_LENGTH];               \
    unsigned int i;                                                     \
    HEComputeDigest(method)                                             \
    for(i=0; i<method##_DIGEST_LENGTH; i++) {                           \
        digestString[2*i]   = __HEHexDigits[digest[i] >> 4];            \
        digestString[2*i+1] = __HEHexDigits[digest[i] & 0x0f];          \
    }                                                                   \
    return [NSString stringWithCString:(char *)digestString length:2*method##_DIGEST_LENGTH];

#pragma mark -
#pragma mark SHA1 Re-mappings
#define SHA1_CTX				SHA_CTX
#define SHA1_DIGEST_LENGTH		SHA_DIGEST_LENGTH

#pragma mark -
#pragma mark SHA1 Hashing routines
- (NSData*) sha1Digest
{
	HEComputeDigestNSData(SHA1);
}
- (NSString*) sha1DigestString
{
	HEComputeDigestNSString(SHA1);
}

@end
