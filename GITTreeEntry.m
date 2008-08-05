//
//  GITTreeEntry.m
//  CocoaGit
//
//  Created by Geoffrey Garside on 05/08/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import "GITTreeEntry.h"
#import "GITRepo.h"
#import "GITObject.h"

const NSUInteger GITTreeEntryTypeMask   = 00170000;
const NSUInteger GITTreeEntryLinkMask   =  0120000;
const NSUInteger GITTreeEntryFileMask   =  0100000;
const NSUInteger GITTreeEntryDirMask    =  0040000;
const NSUInteger GITTreeEntryModMask    =  0160000;

const NSUInteger kGITPackedSha1Length   = 20;
const NSUInteger kGITUnpackedSha1Length = 40;

@interface GITTreeEntry ()
@property(readwrite,copy) NSString * name;
@property(readwrite,assign) NSUInteger mode;
@property(readwrite,copy) NSString * sha1;
@property(readwrite,copy) id <GITObject> object;

- (NSUInteger)extractModeFromString:(NSString*)stringMode;
- (NSData*)packSHA1:(NSString*)unpackedSHA1;
- (NSString*)unpackSHA1FromString:(NSString*)packedSHA1;
- (NSString*)unpackSHA1FromData:(NSData*)packedSHA1;

@end

@implementation GITTreeEntry

@synthesize name;
@synthesize mode;
@synthesize sha1;
@synthesize object;

- (id)initWithTreeLine:(NSString*)treeLine
{
    NSScanner * scanner = [NSScanner scannerWithString:treeLine];
    NSString  * entryMode,
              * entryName,
              * entrySha1;
    
    while ([scanner isAtEnd] == NO)
    {
        if ([scanner scanUpToString:@" " intoString:&entryMode] &&
            [scanner scanUpToString:@"\0" intoString:&entryName])
        {
            entrySha1 = [[scanner string] substringFromIndex:[scanner scanLocation]];
            [scanner setScanLocation:[scanner scanLocation] + kGITPackedSha1Length];
        }
    }
    
    return [self initWithModeString:entryMode 
                               name:entryName 
                            andHash:[self unpackSHA1FromString:entrySha1]];
}
- (id)initWithMode:(NSUInteger)theMode name:(NSString*)theName andHash:(NSString*)theHash
{
    if (self = [super init])
    {
        self.mode = theMode;
        self.name = theName;
        self.sha1 = theHash;
    }
    return self;
}
- (id)initWithModeString:(NSString*)mode name:(NSString*)name andHash:(NSString*)hash
{
    NSUInteger theMode = [self extractModeFromString:mode];
    return [self initWithMode:mode name:name andHash:hash];
}
- (void)dealloc
{
    self.repo = nil;
    self.name = nil;
    self.mode = nil;
    self.sha1 = nil;
    
    if (object)     //!< can't check with self.object as that would load it
        self.object = nil;
    
    [super dealloc];
}
- (id <GITObject>)object    //!< Lazily loads the target object
{
    if (!object && sha1)
        self.object = [self.repo objectWithHash:self.sha1];
    return object;
}
- (NSUInteger)extractModeFromString:(NSString*)stringMode
{
    NSUInteger i, modeMask = 0;
    for (i = 0; i < [stringMode length]; i++)
    {
        unichar c = [stringMode characterAtIndex:i];
        modeMask = (modeMask << 3) | (c - '0')
    }
    
    return modeMask;
}
- (NSData*)packSHA1:(NSString*)unpackedSHA1
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
- (NSString*)unpackSHA1FromString:(NSString*)packedSHA1
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
- (NSString*)unpackSHA1FromData:(NSData*)packedSHA1
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

@end
