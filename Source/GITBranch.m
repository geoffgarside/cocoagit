//
//  GITBranch.m
//  CocoaGit
//
//  Created by Geoffrey Garside on 05/08/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import "GITBranch.m"
#import "GITRepo.h"
#import "GITCommit.h"

/*! \cond
 Make properties readwrite so we can use
 them within the class.
*/
@interface GITBranch ()
@property(readwrite,retain) GITRepo * repo;
@property(readwrite,copy) NSString * name;
@end
/*! \endcond */

@implementation GITBranch
@synthesize repo;
@synthesize name;

- (GITCommit*)head
{
    NSString * heads = [self.repo.root stringByAppendingPathComponent:@"refs/heads"];
    NSString * file  = [heads stringByAppendingPathComponent:self.name];
    NSString * ref   = [NSString stringWithContentsOfFile:file];
    return [self.repo commitWithHash:ref];
}

@end
