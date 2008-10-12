//
//  GITTreeEntry.m
//  CocoaGit
//
//  Created by Geoffrey Garside on 05/08/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import "GITTreeEntry.h"
#import "GITRepo+Protected.h"
#import "GITObject.h"
#import "GITUtilityBelt.h"

const NSUInteger GITTreeEntryTypeMask   = 00170000;
const NSUInteger GITTreeEntryLinkMask   =  0120000;
const NSUInteger GITTreeEntryFileMask   =  0100000;
const NSUInteger GITTreeEntryDirMask    =  0040000;
const NSUInteger GITTreeEntryModMask    =  0160000;

/*! \cond
 Make properties readwrite so we can use
 them within the class.
*/
@interface GITTreeEntry ()
@property(readwrite,copy) GITRepo * repo;
@property(readwrite,copy) NSString * name;
@property(readwrite,assign) NSUInteger mode;
@property(readwrite,copy) NSString * sha1;
@property(readwrite,copy) id object;

- (NSUInteger)extractModeFromString:(NSString*)stringMode;

@end
/*! \endcond */

@implementation GITTreeEntry

@synthesize repo;
@synthesize name;
@synthesize mode;
@synthesize sha1;
@synthesize object;

- (id)initWithTreeLine:(NSString*)treeLine repo:(GITRepo*)theRepo
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
            entrySha1 = [[scanner string] substringFromIndex:[scanner scanLocation] + 1];
            [scanner setScanLocation:[scanner scanLocation] + 1 + kGITPackedSha1Length];
        }
    }

    return [self initWithModeString:entryMode 
                               name:entryName 
                               hash:unpackSHA1FromString(entrySha1)
                               repo:theRepo];
}
- (id)initWithMode:(NSUInteger)theMode 
              name:(NSString*)theName 
              hash:(NSString*)theHash 
              repo:(GITRepo*)theRepo
{
    if (self = [super init])
    {
        self.repo = theRepo;
        self.mode = theMode;
        self.name = theName;
        self.sha1 = theHash;
    }
    return self;
}
- (id)initWithModeString:(NSString*)modeString 
                    name:(NSString*)theName 
                    hash:(NSString*)hash 
                    repo:(GITRepo*)theRepo
{
    NSUInteger theMode = [modeString integerValue];
    return [self initWithMode:theMode name:theName hash:hash repo:theRepo];
}
- (void)dealloc
{
    self.repo = nil;
    self.name = nil;
    self.mode = 0;
    self.sha1 = nil;
    
    if (object)     //!< can't check with self.object as that would load it
        self.object = nil;
    
    [super dealloc];
}
- (id)object    //!< Lazily loads the target object
{
    if (!object && self.sha1)
        self.object = [self.repo objectWithHash:self.sha1];
    return object;
}
/*!
 Presently unsure of the purpose of this method.
*/
- (NSUInteger)extractModeFromString:(NSString*)stringMode
{
    NSUInteger i, modeMask = 0;
    for (i = 0; i < [stringMode length]; i++)
    {
        unichar c = [stringMode characterAtIndex:i];
        modeMask = (modeMask << 3) | (c - '0');
    }
    
    return modeMask;
}
- (NSData*)raw
{
    NSString * meta = [NSString stringWithFormat:@"%lu %@\0",
                       (unsigned long)self.mode, self.name];
    NSMutableData * data = [NSMutableData dataWithData:[meta dataUsingEncoding:NSASCIIStringEncoding]];
    return [data appendData:packSHA1(self.sha1)];
}
@end
