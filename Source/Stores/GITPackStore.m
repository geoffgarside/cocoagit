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
@property(readwrite,copy) NSArray * packFiles;

- (NSArray*)loadPackFilesWithError:(NSError**)outError;
@end
/*! \endcond */

@implementation GITPackStore
@synthesize packsDir;
@synthesize packFiles;

- (id)initWithRoot:(NSString*)root
{
    if(self = [super init])
    {
        NSError * error;
        self.packsDir = [root stringByAppendingPathComponent:@"objects/pack"];
        self.packFiles = [self loadPackFilesWithError:&error];
    }
    return self;
}
- (NSArray*)loadPackFilesWithError:(NSError**)outError
{
    NSError * error;
    GITPackFile * pack;
    NSMutableArray * packs;
    NSFileManager * fm = [NSFileManager defaultManager];
    NSArray * files    = [fm contentsOfDirectoryAtPath:dir error:&error];

    if (files)
    {
        // Should only be pack & idx files, so div(2) should be about right
        packs = [NSMutableArray arrayWithCapacity:[files count] / 2];
        for (NSString * file in files)
        {
            if ([[file pathExtension] isEqualToString:@"pack"])
            {
                pack = [[GITPackFile alloc] initWithPath:[dir stringByAppendingPathComponent:file]]; // retain?
                [packs addObject:pack];
            }
        }
    }
    else
    {
        *outError = error; // The simple way, if we want to add more later we can :D
        packs = nil;
    }

    return packs;
}
@end
