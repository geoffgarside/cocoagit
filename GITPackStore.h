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
 */
@interface GITPackStore : GITObjectStore
{
    NSString * packsDir;    //!< Path to <tt>.git/objects/pack</tt> directory.
}

@property(readonly,copy) NSString * packsDir;

@end
