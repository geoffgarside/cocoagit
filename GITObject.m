//
//  GITObject.m
//  CocoaGit
//
//  Created by Geoffrey Garside on 29/06/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import "GITObject.h"
#import "GITCommit.h"
#import "GITBlob.h"
#import "GITTree.h"
#import "GITTag.h"

const NSString * kGITObjectsDirectoryRoot = @".git/objects";

@implementation GITObject

#pragma mark -
#pragma mark Properties
@synthesize hash;

#pragma mark -
#pragma mark Class Methods
+ (NSString*)objectPathFromHash:(NSString*)theHash
{
    return [NSString stringWithFormat:@"%@/%@/%@",
            kGITObjectsDirectoryRoot,
            [theHash substringToIndex:2],       //!< Gets the first two characters of the sha1
            [theHash substringFromIndex:2]];    //!< Gets the remaining characters of the sha1
}
+ (GITObject*)objectFromHash:(NSString*)objectHash
{
    // This method opens up the sha1 file, decompresses it and
    // reads up to the first " " character. It then dispatches
    // the content after the "\0" to the correct GITObject child.
    GITObject *obj = [[GITObject alloc] initFromHash:objectHash];
    [obj autorelease];
    
    return [obj retain];
}

#pragma mark -
#pragma mark Instance Methods
- (id)initFromHash:(NSString*)objectHash
{
    if (self = [super init])
    {
        self.hash = objectHash;
    }
    return self;
}
- (void)dealloc
{
    [hash release];
    [super dealloc];
}
- (NSString*)hashObject
{
    return @"";
}
- (NSString*)objectPath
{
    return [[self class] objectPathFromHash:self.hash];
}

@end
