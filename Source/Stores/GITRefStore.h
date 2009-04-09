//
//  GITRefStore.h
//  CocoaGit
//
//  Created by chapbr on 4/7/09.
//  Copyright 2009 Brian Chapados. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GITRepo, GITRef;

@interface GITRefStore : NSObject {
    // properties
    NSString *refsDir;
    NSString *packFile;
    
    // internal state
    NSMutableDictionary *cachedRefs;
    NSMutableArray *symbolicRefs;
    BOOL fetchedLoose;
    BOOL fetchedPacked;
}
@property (readwrite, copy) NSString *refsDir;
@property (readwrite, copy) NSString *packFile;

- (id) initWithRepo:(GITRepo *)repo error:(NSError **)error;
- (id) initWithPath:(NSString *)aPath packFile:(NSString *)packedRefsFile error:(NSError **)error;

- (GITRef *) refWithName:(NSString *)refName;
- (GITRef *) refByResolvingSymbolicRef:(GITRef *)symRef;

- (NSArray *) refsWithPrefix:(NSString *)refPrefix;
- (NSArray *) branches;
- (NSArray *) heads;
- (NSArray *) tags;
- (NSArray *) remotes;

- (void) invalidateCachedRefs;
@end