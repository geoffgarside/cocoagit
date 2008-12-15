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
    NSData * objectData = nil;

    // Check the cached lastReadPack first
    if (lastReadPack != nil) {
        objectData = [self.lastReadPack dataForObjectWithSha1:sha1];
		if (objectData) return objectData;
	}
		
    for (GITPackFile * pack in self.packFiles) {
        if (pack == self.lastReadPack)
			continue;
		
		objectData = [pack dataForObjectWithSha1:sha1];
		if (objectData)	{
			self.lastReadPack = pack;
			return objectData;
		}
    }

    return nil;
}
- (NSArray*)loadPackFilesWithError:(NSError**)outError
{
    GITPackFile * pack;
    NSMutableArray * packs;
    NSFileManager * fm = [NSFileManager defaultManager];
    NSArray * files    = [fm contentsOfDirectoryAtPath:self.packsDir error:outError];

    if (!files) {
		GITError(outError, GITErrorPackStoreNotAccessible, NSLocalizedString(@"Could not access pack directory", @"GITErrorPackStoreNotAccessible"));
		return nil;
	}

	// Should only be pack & idx files, so div(2) should be about right
	packs = [NSMutableArray arrayWithCapacity:[files count] / 2];
	for (NSString * file in files) {
		if ([[file pathExtension] isEqualToString:@"pack"]) {
			pack = [[GITPackFile alloc] initWithPath:[self.packsDir stringByAppendingPathComponent:file]];
			[packs addObject:pack];
			[pack release];
		}
	}

    return packs;
}
- (BOOL)loadObjectWithSha1:(NSString*)sha1 intoData:(NSData**)data
                      type:(GITObjectType*)type error:(NSError**)error
{
    NSError * undError;

	if (lastReadPack != nil) {
		if ([self.lastReadPack loadObjectWithSha1:sha1 intoData:data type:type error:&undError])
			return YES;
		if ([undError code] != GITErrorObjectNotFound) {
			if (error != NULL)
				*error = undError;
			return NO;
		}
	}
	
	for (GITPackFile * pack in self.packFiles) {
        if (pack == self.lastReadPack)
			continue;
		
		if ([pack loadObjectWithSha1:sha1 intoData:data type:type error:&undError]) {
			self.lastReadPack = pack;
			return YES;
		}
		
		if ([undError code] != GITErrorObjectNotFound) {
			if (error != NULL)
				*error = undError;
			return NO;
		}
	}
	
    // If we've made it this far then the object can't be found
    // no other error has been detected yet, so make our NotFound error
	NSString *errorDescription = [NSString stringWithFormat:NSLocalizedString(@"Object %@ not found", @"GITErrorObjectNotFound"), sha1];
	GITError(error, GITErrorObjectNotFound, errorDescription);
	
    return NO;
}
@end
