//
//  GITObject.h
//  CocoaGit
//
//  Created by Geoffrey Garside on 05/08/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GITRepo;
/*! Abstract base class for the git objects
 */
@interface GITObject : NSObject <NSCopying>
{
    GITRepo  * repo;    //!< Repository the object belongs to
    NSString * sha1;    //!< The SHA1 identifier of the object
    NSString * type;    //!< The blob/commit/tag/tree type
    NSUInteger size;    //!< Size of the content of the object
}

@property(readonly,retain) GITRepo  * repo;
@property(readonly,copy)   NSString * sha1;
@property(readonly,copy)   NSString * type;
@property(readonly,assign) NSUInteger size;

/*! Returns the string name of the type.
 */
+ (NSString*)typeName;

/*! Raises a doesNotRecognizeSelector error to enforce the use of
 * the correct initialiser.
 */
- (id)init;

/*! Creates and returns a new git object for the given <tt>sha1</tt>
 * in the <tt>repo</tt>.
 *
 * This initialiser requests the object data from the <tt>repo</tt> and
 * then creates the object from the returned data.
 *
 * This the most common initialiser to use to load a type of git object.
 *
 * \attention This is a concrete method.
 * \param sha1 The hash of the object to load
 * \param repo The repository to load the object from
 * \return A new git object for the given <tt>sha1</tt> in the <tt>repo</tt>
 */
- (id)initWithSha1:(NSString*)sha1 repo:(GITRepo*)repo;

/*! Creates and returns a new git object with the given <tt>sha1</tt> composed
 * of the given <tt>data</tt> in the <tt>repo</tt>.
 *
 * This initialiser is usually called from <tt>-initWithSha1:repo:</tt> once it
 * has obtained the raw data for the object.
 *
 * This initialiser does most of the heavy-lifting for the individual child
 * object types.
 *
 * \attention This is an abstract method.
 * \param sha1 The hash of the object
 * \param data The raw data of the object
 * \param repo The repo the object belongs to
 * \return A new git object with the given <tt>sha1</tt> composed of the given 
 * <tt>data</tt> in the <tt>repo</tt>
 */
- (id)initWithSha1:(NSString*)sha1 data:(NSData*)data repo:(GITRepo*)repo;

/*! Creates and returns a new git object.
 * This method is intended to be called only by children of this
 * class in their own initialisers. Where they would normally do
 * \code
 * if (self = [super init])
 * \endcode
 * they will instead do (assuming a blob in this instance)
 * \code
 * if (self = [super initType:@"blob" sha:theSHA1
 *                       size:objectSize repo:theRepo])
 * \endcode
 * and this will setup the common fields for each object type.
 *
 * \attention This is a concrete method.
 * \param newType The type blob/commit/tag/tree of the object
 * \param newSha1 The SHA hash of the object
 * \param newSize The size of the object
 * \param theRepo The repo to which this object belongs
 * \return New git object.
 */
- (id)initType:(NSString*)newType sha1:(NSString*)newSha1
          size:(NSUInteger)newSize repo:(GITRepo*)theRepo;

/*! Returns a new instance that's a copy of the receiver.
 * Children should call this implementation first when overriding it as this will init
 * the fields of the base object first. Children can then add to the copied object any
 * further content which is required.
 *
 * Here is an example implementation for a child defining a blob object
 * \code
 * - (id)copyWithZone:(NSZone*)zone
 * {
 *     MyBlob * blob = (MyBlob*)[super copyWithZone:zone];
 *     blob.data = self.data;
 *     return blob;
 * }
 * \endcode
 * \attention This is a concrete method.
 * \param zone The zone identifies an area of memory from which to allocate for the new 
 * instance. If zone is <tt>NULL</tt>, the new instance is allocated from the default 
 * zone, which is returned from the function NSDefaultMallocZone.
 * \return A new instance that's a copy of the receiver.
 */
- (id)copyWithZone:(NSZone*)zone;

/*! Returns the raw data of the object.
 * \attention This is a concrete method.
 * \see rawContent
 * \return Raw data of the object
 */
- (NSData*)rawData;

/*! Returns the raw content of the object.
 * \attention This is an abstract method.
 * \see rawData
 * \return Raw content of the object
 */
- (NSData*)rawContent;
@end
