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
- (id)initWithStores:(GITObjectStore*)firstStore, ...
{
    GITObjectStore * eachStore;
    va_list argumentList;

    if (self = [super init])
    {
        self.stores = [NSMutableArray array];

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

@end
