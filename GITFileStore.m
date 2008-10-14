//
//  GITFileStore.m
//  CocoaGit
//
//  Created by Geoffrey Garside on 07/10/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import "GITFileStore.h"
#import "NSData+Compression.h"

/*! \cond */
@interface GITFileStore ()
@property(readwrite,copy) NSString * objectsDir;
@end
/*! \endcond */

@implementation GITFileStore
@synthesize objectsDir;

- (id)initWithRoot:(NSString*)root
{
    if (self = [super init])
    {
        self.objectsDir = [root stringByAppendingPathComponent:@"objects"];
    }
    return self;
}
- (NSString*)stringWithPathToObject:(NSString*)sha1
{
    NSString * ref = [NSString stringWithFormat:@"%@/%@",
                      [sha1 substringToIndex:2], [sha1 substringFromIndex:2]];
    
    return [self.objectsDir stringByAppendingPathComponent:ref];
}
- (NSData*)dataWithContentsOfObject:(NSString*)sha1
{
    NSString * path = [self stringWithPathToObject:sha1];
    NSData * zlibData = [NSData dataWithContentsOfFile:path];
    return [zlibData zlibInflate];
}
@end
