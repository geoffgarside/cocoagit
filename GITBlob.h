//
//  GITBlob.h
//  CocoaGit
//
//  Created by Geoffrey Garside on 05/08/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GITObject.h"

@class GITRepo;
/*! Git object type representing a file.
 */
@interface GITBlob : NSObject <GITObject>
{
    GITRepo  * repo;    //!< Repository which this blob is a part of
    NSString * sha1;    //!< The SHA1 hash reference of this blob
    NSUInteger size;    //!< The file size of the contents of this blob
    NSData   * data;    //!< The binary data of this blob
}

@property(readonly,copy) NSString * sha1;
@property(readonly,assign) NSUInteger size;
@property(readonly,copy) NSData * data;

/*! Returns flag indicating probability that data is textual.
 * It is important to note that this indicates only the probability
 * that the receiver's data is textual. The indication is based on
 * the presence, or lack, of a NULL byte in the receivers data.
 * \return Flag indicating probability that data is textual.
 */
- (BOOL)canBeRepresentedAsString;

/*! Returns string contents of data.
 * \return String contents of data.
 */
- (NSString*)stringValue;

@end
