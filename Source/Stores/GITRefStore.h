//
//  GITRefStore.h
//  CocoaGit
//
//  Created by chapbr on 4/7/09.
//  Copyright 2009 Brian Chapados. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GITRepo;

@interface GITRefStore : NSObject {
    NSString *refsDir;
    NSString *packFile;
    NSMutableArray *cachedRefs;
    NSMutableArray *symbolicRefs;
}
@property (readwrite, copy) NSString *refsDir;
@property (readwrite, copy) NSString *packFile;

- (id) initWithPath:(NSString *)aPath packFile:(NSString *)packedRefsFile error:(NSError **)error;
- (id) initWithRepo:(GITRepo *)repo;
@end
