//
//  GITCombinedStore.m
//  CocoaGit
//
//  Created by Geoffrey Garside on 24/11/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import "GITCombinedStore.h"

/*! \cond */
@interface GITCombinedStore ()
@property(readwrite,retain) NSMutableArray * stores;
@property(readwrite,assign) GITObjectStore * recentStore;
@end
/*! \endcond */

@implementation GITCombinedStore
@synthesize stores;
@synthesize recentStore;

- (id)init
{
    return [self initWithStores:nil];
}
- (id)initWithRoot:(NSString*)root
{
    return [self initWithStores:nil];
}
- (id)initWithStores:(GITObjectStore*)firstStore, ...
{
    GITObjectStore * eachStore;
    va_list argumentList;

    if (self = [super init])
    {
        self.stores = [NSMutableArray array];
        self.recentStore = nil;

        // process arguments
        if (firstStore)                                                 // The first argument isn't part of the varargs list,
        {                                                               // so we'll handle it separately.
            [self addStore:firstStore priority:GITNormalPriority];
            va_start(argumentList, firstStore);                         // Start scanning for arguments after firstStore.
            while (eachStore = va_arg(argumentList, GITObjectStore*))   // As many times as we can get an argument of type "GITObjectStore*"
                [self addStore:eachStore priority:GITNormalPriority];   // that isn't nil, add it to self's contents.
            va_end(argumentList);
        }
    }

    return self;
}

- (void)addStore:(GITObjectStore*)store
{
    [self addStore:store priority:GITNormalPriority];
}
- (void)addStores:(GITObjectStore*)firstStore, ...
{
    GITObjectStore * eachStore;
    va_list argumentList;
    
    // process arguments
    if (firstStore)                                                 // The first argument isn't part of the varargs list,
    {                                                               // so we'll handle it separately.
        [self addStore:firstStore priority:GITNormalPriority];
        va_start(argumentList, firstStore);                         // Start scanning for arguments after firstStore.
        while (eachStore = va_arg(argumentList, GITObjectStore*))   // As many times as we can get an argument of type "GITObjectStore*"
            [self addStore:eachStore priority:GITNormalPriority];   // that isn't nil, add it to self's contents.
        va_end(argumentList);
    }
}
- (void)addStore:(GITObjectStore*)store priority:(GITCombinedStorePriority)priority
{
    // High goes at the front, Normal and Low append to the end.
    switch (priority)
    {
        case GITHighPriority:
            [self.stores insertObject:store atIndex:0];
            break;
        case GITNormalPriority:
        case GITLowPriority:
            [self.stores addObject:store];
            break;
    }
}
- (NSData*)dataWithContentsOfObject:(NSString*)sha1
{
    NSData * objectData = nil;
    if (self.recentStore)
        objectData = [self.recentStore dataWithContentsOfObject:sha1];
    if (objectData) return objectData;

    for (GITObjectStore * store in self.stores)
    {
        objectData = [store dataWithContentsOfObject:sha1];
        if (objectData)
        {
            self.recentStore = store;
            return objectData;
        }
    }

    return nil;
}
- (BOOL)loadObjectWithSha1:(NSString*)sha1 intoData:(NSData**)data
                      type:(GITObjectType*)type error:(NSError**)error
{
    NSError * undError;
	
    if (recentStore != nil) {
        if ([self.recentStore loadObjectWithSha1:sha1 intoData:data type:type error:&undError])
            return YES;

        if ([undError code] != GITErrorObjectNotFound) {
            if (error != NULL)
				*error = undError;
			return NO;
		}
    }
    
    for (GITObjectStore * store in self.stores) {
        if (store == self.recentStore)
			continue;
		
		if ([store loadObjectWithSha1:sha1 intoData:data type:type error:&undError]) {
			self.recentStore = store;
			return YES;
		}
        
		if ([undError code] != GITErrorObjectNotFound) {
			if (error != NULL)
				*error = undError;
			return NO;
		}
    }

    // If we've made it this far then the object can't be found
	NSString *errorDescription = [NSString stringWithFormat:NSLocalizedString(@"Object %@ not found", @"GITErrorObjectNotFound"), sha1];
	GITError(error, GITErrorObjectNotFound, errorDescription);
    return NO;
}

@end
