//
//  GITRepo+Protected.h
//  CocoaGit
//
//  Created by Geoffrey Garside on 05/08/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import "GITRepo.h"

@protocol GITObject;
@class GITCommit, GITTag, GITTree, GITBlob;
@interface GITRepo ()

/*! Returns a string of the path to the loose file object.
 * \deprecated
 * The purpose of this method has been superceeded by the
 * GITObjectStore classes. You can expect this method to
 * be removed once GITObjectStores have stabilised.
 * \param hash The SHA1 name of the object.
 */
- (NSString*)objectPathFromHash:(NSString*)hash;

/*! Returns the contents of the loose file object.
 * \deprecated
 * This method has been replaced by dataWithContentsOfObject:
 * which utilises the new GITObjectStores.
 * \param hash The SHA1 name of the object to fetch.
 */
- (NSData*)dataWithContentsOfHash:(NSString*)hash;
- (void)extractFromData:(NSData*)data
                   type:(NSString**)theType
                   size:(NSUInteger*)theSize
                andData:(NSData**)theData;

#pragma mark -
#pragma mark Object instanciation methods
- (id)objectWithHash:(NSString*)hash;
- (GITCommit*)commitWithHash:(NSString*)hash;
- (GITTag*)tagWithHash:(NSString*)hash;
- (GITTree*)treeWithHash:(NSString*)hash;
- (GITBlob*)blobWithHash:(NSString*)hash;

@end
