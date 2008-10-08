//
//  GITRepo.h
//  CocoaGit
//
//  Created by Geoffrey Garside on 05/08/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class GITBranch, GITTag;
@interface GITRepo : NSObject <NSCopying>
{
    NSString * root;
    NSString * desc;    // Interesting issue here
                        // the function used for
                        // an object to print itself
                        // is -description
}

@property(readonly,copy) NSString * root;
@property(readwrite,copy) NSString * desc;

- (id)initWithRoot:(NSString*)repoRoot;
- (id)initWithRoot:(NSString*)repoRoot bare:(BOOL)isBare;

/*
- (NSArray*)branches;
- (NSArray*)commits;
- (NSArray*)tags;

- (GITBranch*)head;
- (GITBranch*)master;
- (GITBranch*)branchWithName:(NSString*)name;

- (GITTag*)tagWithName:(NSString*)name;
*/
@end
