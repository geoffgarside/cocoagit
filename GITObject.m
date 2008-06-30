//
//  GITObject.m
//  CocoaGit
//
//  Created by Geoffrey Garside on 29/06/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import "GITObject.h"

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
    
}

@end
