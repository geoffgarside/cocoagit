//
//  GITPackFile.h
//  CocoaGit
//
//  Created by Geoffrey Garside on 05/08/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GITPackIndex.h"

/*! GITPackFile is a class which provides access to individual
 * PACK files within a git repository.
 *
 * A PACK file is an archive format used by git primarily for
 * network transmission of repository objects. Once transmitted
 * the received PACK files are then used for access to the stored
 * objects.
 *
 * \attention GITPackFile is a class cluster, subclasses must
 * override the following primitive methods.
 */
@interface GITPackFile : NSObject
{
}

#pragma mark -
#pragma mark Primitive Methods
/*! Returns the version of PACK file which the receiver is providing
 * access to.
 * \return Numerical version of the receiver
 * \internal Subclasses must override this method
 */
- (NSUInteger)version;

/*! Returns the corresponding index for the receiver
 * \return The index for the receiver
 * \internal Subclasses must override this method
 */
- (GITPackIndex*)index;

/*! Creates and returns a new PACK object at the specified <tt>path</tt>.
 * \param path Path of the PACK file in the repository
 * \return A new PACK object
 * \internal
 * Subclasses must override this method, failure to do so will result in
 * an error. The overriding implementation should not call this implementation
 * as part of itself. Instead it is recommended to use [super init] instead.
 */
- (id)initWithPath:(NSString*)path;

/*! Returns the data for the object specified by the given <tt>sha1</tt>.
 * The <tt>sha1</tt> will first be checked to see if it exists
 * \param sha1 The SHA1 of the object to retrieve the data for.
 * \return Data for the object or <tt>nil</tt> if the object is not in
 * the receiver
 */
- (NSData*)dataForObjectWithSha1:(NSString*)sha1;

- (BOOL)loadObjectWithSha1:(NSString*)sha1 intoData:(NSData**)data
                      type:(GITObjectType*)type error:(NSError**)error;

#pragma mark -
#pragma mark Checksum Methods
/*! Returns checksum data for the receiver
 * \return Checksum data of the receiver
 */
- (NSData*)checksum;

/*! Returns checksum string for the receiver
 * \return Checksum string of the receiver
 */
- (NSString*)checksumString;

/*! Verifies if the checksum matches for the contents of the receiver.
 * \return YES if checksum matches, NO if it does not.
 */
- (BOOL)verifyChecksum;

#pragma mark -
#pragma mark Derived Methods
/*! Returns the number of objects in the receiver
 * \return Number of objects in the receiver
 */
- (NSUInteger)numberOfObjects;

/*! Indicates whether the receiver contains the object specified by the
 * given <tt>sha1</tt>.
 * \param sha1 The SHA1 of the object to check the presence of
 * \return BOOL indicating if the receiver contains the object
 */
- (BOOL)hasObjectWithSha1:(NSString*)sha1;

@end

#import "GITPlaceholderPackFile.h"
#import "GITPackFileVersion2.h"
