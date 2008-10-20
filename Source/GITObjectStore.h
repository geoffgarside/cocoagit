//
//  GITObjectStore.h
//  CocoaGit
//
//  Created by Geoffrey Garside on 09/10/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import <Foundation/Foundation.h>

/*! Generic object storage class.
 * Desendants of GITObjectStore implement different ways of
 * accessing the objects of a repository. 
 */
@interface GITObjectStore : NSObject
{
}

/*! Creates and returns a new store object from the provided .git root
 * \attention This method must be overridden
 * \param root Path to the .git root directory
 * \return A new store object.
 */
- (id)initWithRoot:(NSString*)root;

/*! Returns the contents of an object for the given <tt>sha1</tt>.
 * The data returned should be in a form which is usable to initialise an
 * object. If the data is stored compressed or encrypted it should be
 * decompressed or decrypted before returning.
 * \attention This method must be overridden
 * \param sha1 The object reference to return the data for
 * \return Contents of an object
 */
- (NSData*)dataWithContentsOfObject:(NSString*)sha1;

/*! Extracts the basic information from a git object file.
 * \param sha1 The object reference to extract the data from
 * \param[out] type The type of the object as a string
 * \param[out] size The size of <tt>data</tt> in bytes
 * \param[out] data The data content of the object
 * \return Indication that the extraction was successful.
 */
- (BOOL)extractFromObject:(NSString*)sha1 type:(NSString**)type
                     size:(NSUInteger*)size data:(NSData**)data;
@end
