//
//  GITRef.h
//  CocoaGit
//
//  Created by Brian Chapados on 2/10/09.
//  Copyright 2009 Brian Chapados. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GITRepo.h"

@class GITRepo;
@class GITCommit;

@interface GITRef : NSObject {
    NSString *name;
    NSString *sha1;
}
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *sha1;

+ (id) looseRefWithName:(NSString *)refName repo:(GITRepo *)repo;
+ (id) refWithName:(NSString *)refName sha1:(NSString *)sha1String;
+ (id) refWithContentsOfFile:(NSString *)aPath;
+ (id) refWithPacketLine:(NSString *)packetLine;

- (id) initWithName:(NSString *)refName sha1:(NSString *)sha1String;

+ (NSArray *) findAllInRepo:(GITRepo *)repo;

- (GITCommit *) commitWithRepo:(GITRepo *)repo;
@end