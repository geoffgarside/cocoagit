//
//  GITObject.m
//  CocoaGit
//
//  Created by Geoffrey Garside on 29/06/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import "GITObject.h"


@implementation GITObject

#pragma mark -
#pragma mark Properties
@synthesize hash;

#pragma mark -
#pragma mark Class Methods
+ (NSString*)objectPathFromHash:(NSString*)theHash
{
    return [NSString stringWithFormat:@"%@/%@",
            [theHash substringToIndex:2],       //!< Gets the first two characters of the hash
            [theHash substringFromIndex:2]];    //!< Gets the remaining characters of the hash
}


#pragma mark -
#pragma mark Instance Methods

@end
