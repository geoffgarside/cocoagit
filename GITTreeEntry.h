//
//  GITTreeEntry.h
//  CocoaGit
//
//  Created by Geoffrey Garside on 05/08/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern const NSUInteger kGITPackedSha1Length;
extern const NSUInteger kGITUnpackedSha1Length;

@class GITRepo;
/*! An entry in tree listing.
 * \todo Consider changing from having a GITRepo instance
 * as part of the class to having an instance of the tree
 * which the entry is a part of. We can then defer to the
 * trees repo for object loading. We then need to be very
 * careful about creating memory dependencies which are
 * difficult to manage and may result in memory leakage.
 */
@interface GITTreeEntry : NSObject
{
    GITRepo  * repo;    //!< Repository the entry belongs to. Used for accessing the object
    NSString * name;    //!< Name of the entry, either a file or directory name
    NSUInteger mode;    //!< File mode of the entry
    
    NSString * sha1;    //!< SHA1 of the object referenced
    id object;          //!< The object which is referenced. This is lazy loaded.
}

@property(readonly,copy) GITRepo * repo;
@property(readonly,copy) NSString * name;
@property(readonly,assign) NSUInteger mode;
@property(readonly,copy) NSString * sha1;
@property(readonly,copy) id object;

/*! Creates and returns a new entry by extracting the information tree line.
 * \param treeLine The raw line as extracted from a tree object file
 * \param repo The repository the object belongs to
 * \return A new entry
 */
- (id)initWithTreeLine:(NSString*)treeLine repo:(GITRepo*)repo;

/*! Creates and returns a new entry the given settings
 * \param mode The file mode of the file or directory described
 * \param name The file name of the filr or directory described
 * \param hash The SHA1 of the object referenced
 * \param repo The repository the object referenced belongs to
 */
- (id)initWithMode:(NSUInteger)mode name:(NSString*)name hash:(NSString*)hash repo:(GITRepo*)repo;

/*! Creates and returns a new entry the given settings
 * \param mode The file mode as a string of the file or directory described
 * \param name The file name of the filr or directory described
 * \param hash The SHA1 of the object referenced
 * \param repo The repository the object referenced belongs to
 */
- (id)initWithModeString:(NSString*)mode name:(NSString*)name hash:(NSString*)hash repo:(GITRepo*)repo;

@end
