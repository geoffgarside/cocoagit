//
//  GITPackStore.m
//  CocoaGit
//
//  Created by Geoffrey Garside on 07/10/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import "GITPackStore.h"

/*! \cond */
@interface GITPackStore ()
@property(readwrite,copy) NSString * packsDir;
@end
/*! \endcond */

@implementation GITPackStore
@synthesize packsDir;

- (id)initWithRoot:(NSString*)root
{
    if(self = [super init])
    {
        self.packsDir = [root stringByAppendingPathComponent:@"objects/pack"];
    }
    return self;
}
@end
