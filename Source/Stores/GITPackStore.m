//
//  GITPackStore.m
//  CocoaGit
//
//  Created by Geoffrey Garside on 07/10/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import "GITPackStore.h"
#import "GITPackFile.h"

/*! \cond */
@interface GITPackStore ()
@property(readwrite,copy) NSString * packsDir;
@property(readwrite,copy) NSArray * packFiles;
@property(readwrite,assign) GITPackFile * lastReadPack;

- (NSArray*)loadPackFilesWithError:(NSError**)outError;
@end
/*! \endcond */

@implementation GITPackStore
@synthesize packsDir;
@synthesize packFiles;
@synthesize lastReadPack;

- (id)initWithRoot:(NSString*)root
{
    if(self = [super init])
    {
        NSError * error;
        self.packsDir = [root stringByAppendingPathComponent:@"objects/pack"];
        self.packFiles = [self loadPackFilesWithError:&error];
        self.lastReadPack = nil;
    }
    return self;
}
- (NSData*)dataWithContentsOfObject:(NSString*)sha1
{
    NSData * objectData;

    // Check the cached lastReadPack first
    NSLog(@"Checking to see if lastReadPack is set");
    if (lastReadPack != nil) {
        NSLog(@"lastReadPack is set, attempting to read data");
        objectData = [self.lastReadPack dataForObjectWithSha1:sha1];
    }
    NSLog(@"objectData is now: %@", objectData);
    if (objectData) return objectData;

    NSLog(@"objectData not found in lastReadPack, checking other packs");
    for (GITPackFile * pack in self.packFiles)
    {
        NSLog(@"pack(%@) != lastReadPack(%@)", pack, lastReadPack);
        if (pack != self.lastReadPack)
        {
            NSLog(@"Checking pack(%@) for sha1 data", pack);
            objectData = [pack dataForObjectWithSha1:sha1];
            if (objectData)
            {
                NSLog(@"Object data found, setting lastReadPack and returning");
                self.lastReadPack = pack;
                return objectData;
            }
        }
    }

    NSLog(@"All failed, returning nil");
    return nil;
}
- (NSArray*)loadPackFilesWithError:(NSError**)outError
{
    NSError * error;
    GITPackFile * pack;
    NSMutableArray * packs;
    NSFileManager * fm = [NSFileManager defaultManager];
    NSArray * files    = [fm contentsOfDirectoryAtPath:self.packsDir error:&error];

    if (files)
    {
        // Should only be pack & idx files, so div(2) should be about right
        packs = [NSMutableArray arrayWithCapacity:[files count] / 2];
        for (NSString * file in files)
        {
            if ([[file pathExtension] isEqualToString:@"pack"])
            {
                pack = [[GITPackFile alloc] initWithPath:[self.packsDir stringByAppendingPathComponent:file]]; // retain?
                [packs addObject:pack];
            }
        }
    }
    else
    {
        *outError = error; // The simple way, if we want to add more later we can :D
        NSLog(@"Error loading pack files: %@", [error userInfo]);
        packs = nil;
    }

    return packs;
}
@end
