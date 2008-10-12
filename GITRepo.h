//
//  GITRepo.h
//  CocoaGit
//
//  Created by Geoffrey Garside on 05/08/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class GITBranch, GITTag;
/*! A repository of git objects.
 * This class serves to encapsulate the access to the
 * objects of a repository.
 * \todo Consider the lifetime of this object. Is it going
 * to be better to retain the repo in the objects instead
 * of copying it. Should we enforce this by changing
 * -copyWithZone: to just return the retained instance of
 * GITRepo or should we leave it capable of being copied
 * but change our usage of it to retains?
 */
@interface GITRepo : NSObject <NSCopying>
{
    NSString * root;    //!< Path to the repository root
    NSString * desc;    //!< Description of the repository
                        // Interesting issue here the function used for
                        // an object to print itself is -description
}

@property(readonly,copy) NSString * root;
@property(readonly,copy) NSString * desc;

/*! Creates and returns a repo object with the provided root.
 * \param repoRoot The path, relative or absolute, to the repository root.
 * \return A repo object with the provided root.
 */
- (id)initWithRoot:(NSString*)repoRoot;

/*! Creates and returns a repo object with the provided root.
 * \param repoRoot The path, relative or absolute, to the repository root.
 * \param isBare Flag indicating if the repository is bare.
 * \return A repo object with the provided root.
 */
- (id)initWithRoot:(NSString*)repoRoot bare:(BOOL)isBare;

/*! Returns a new instance that's a copy of the receiver.
 * \internal
 * This will create a new instance of the GITObjectStore for the receiver.
 * \param zone The zone identifies an area of memory from which to allocate
 * for the new instance. If <tt>zone</tt> is <tt>NULL</tt>, the new instance
 * is allocated from the default zone, which is returned from the function
 * <tt>NSDefaultMallocZone</tt>.
 */
- (id)copyWithZone:(NSZone*)zone;

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
