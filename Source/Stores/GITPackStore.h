//
//  GITPackStore.h
//  CocoaGit
//
//  Created by Geoffrey Garside on 07/10/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GITObjectStore.h"

/*! Packed objects storage.
 * Accesses objects stored as in PACK files in
 * <tt>.git/objects/pack</tt> directory.
 * \internal
 * PACK files are do not independently represent
 * the objects of a repository. Instead each PACK
 * holds only the objects which were not already
 * stored within a PACK.
 * For this reason the GITPackStore must to keep a
 * reference to each PACK file within the packsDir
 * so that it may correctly find the objects which
 * are requested. To improve the speed of retrieval
 * some kind of caching should probably be done.
 * The two main options I can see are an NSDictionary
 * of SHA1 -> PACK mappings and a reference to the
 * last PACK which successfully returned an object.
 * The first method is primarily useful for repetitive
 * accesses of the same SHA, while possible it would
 * probably be a better idea to leave this option for
 * now and see how often a SHA is accessed. The other
 * method is useful for accessing objects which are
 * likely to be nearby to each other. This would be
 * the most useful as typical operation would involve
 * reading a Commit, accessing its Tree and the Tree
 * contents. These objects are all reasonably likely
 * to be contained within the same PACK file.
 */
@interface GITPackStore : GITObjectStore
{
    NSString * packsDir;    //!< Path to <tt>.git/objects/pack</tt> directory.
    NSArray * packFiles;
}

@property(readonly,copy) NSString * packsDir;

@end
