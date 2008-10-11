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

/*!
 Indicates if the blobs contents are likely to be textual.
*/
- (BOOL)canBeRepresentedAsString;

/*!
 Converts the binary data into a string.
*/
- (NSString*)stringValue;

@end
