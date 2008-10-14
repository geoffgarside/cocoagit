//
//  GITTreeEntry.m
//  CocoaGit
//
//  Created by Geoffrey Garside on 05/08/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import "GITTreeEntry.h"
#import "GITObject.h"
#import "GITTree.h"
#import "GITRepo.h"
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
@property(readwrite,copy) NSString * name;
@property(readwrite,assign) NSUInteger mode;
@property(readwrite,copy) NSString * sha1;
@property(readwrite,copy) GITTree * parent;
@property(readwrite,copy) GITObject * object;
@end
/*! \endcond */

@implementation GITTreeEntry
@synthesize name;
@synthesize mode;
@synthesize sha1;
@synthesize parent;
@synthesize object;

- (id)initWithTreeLine:(NSString*)line parent:(GITTree*)parentTree
{
    NSScanner * scanner = [NSScanner scannerWithString:line];
    NSString  * entryMode, * entryName, * entrySha1;
    
    while ([scanner isAtEnd] == NO)
    {
        if ([scanner scanUpToString:@" " intoString:&entryMode] &&
            [scanner scanUpToString:@"\0" intoString:&entryName])
        {
            entrySha1 = [[scanner string] substringFromIndex:[scanner scanLocation] + 1];
            [scanner setScanLocation:[scanner scanLocation] + 1 + kGITPackedSha1Length];
        }
    }

    return [self initWithModeString:entryMode name:entryName
                               sha1:unpackSHA1FromString(entrySha1)
                             parent:parentTree];
}
- (id)initWithMode:(NSUInteger)theMode name:(NSString*)theName
              sha1:(NSString*)theHash parent:(GITTree*)parentTree
{
    if (self = [super init])
    {
        self.mode = theMode;
        self.name = theName;
        self.sha1 = theHash;
        self.parent = parentTree;
    }
    return self;
}
- (id)initWithModeString:(NSString*)str name:(NSString*)theName
                    sha1:(NSString*)hash parent:(GITTree*)parentTree
{
    NSUInteger theMode = [str integerValue];
    return [self initWithMode:theMode name:theName sha1:hash parent:parentTree];
}
- (void)dealloc
{
    self.name = nil;
    self.mode = 0;
    self.sha1 = nil;
    self.parent = nil;
    
    if (object)     //!< can't check with self.object as that would load it
        self.object = nil;
    
    [super dealloc];
}
- (GITObject*)object    //!< Lazily loads the target object
{
    if (!object && self.sha1)
        self.object = [self.parent.repo objectWithSha1:self.sha1];
    return object;
}
- (NSData*)raw
{
    NSString * meta = [NSString stringWithFormat:@"%lu %@\0",
                       (unsigned long)self.mode, self.name];
    NSMutableData * data = [NSMutableData dataWithData:[meta dataUsingEncoding:NSASCIIStringEncoding]];
    [data appendData:packSHA1(self.sha1)];
    return data;
}
@end
