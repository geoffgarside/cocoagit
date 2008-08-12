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
#import "GITUtilityBelt.h"

const NSUInteger GITTreeEntryTypeMask   = 00170000;
const NSUInteger GITTreeEntryLinkMask   =  0120000;
const NSUInteger GITTreeEntryFileMask   =  0100000;
const NSUInteger GITTreeEntryDirMask    =  0040000;
const NSUInteger GITTreeEntryModMask    =  0160000;

@interface GITTreeEntry ()
@property(readwrite,copy) NSString * name;
@property(readwrite,assign) NSUInteger mode;
@property(readwrite,copy) NSString * sha1;
@property(readwrite,copy) id <GITObject> object;

- (NSUInteger)extractModeFromString:(NSString*)stringMode;

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
                            andHash:unpackSHA1FromString(entrySha1)];
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
@end
