//
//  GITObject.h
//  CocoaGit
//
//  Created by Geoffrey Garside on 29/06/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern const NSString * kGITObjectsDirectoryRoot;

@interface GITObject : NSObject {
    NSString* sha1;     //!< Stores the SHA1 of objects committed to the file system
    NSUInteger size;    //!< Stores the content size of the data portion of the object
}

#pragma mark -
#pragma mark Properties
@property(retain) NSString* sha1;

#pragma mark -
#pragma mark Class Methods
+ (NSString*)objectPathFromHash:(NSString*)theHash;

#pragma mark -
#pragma mark Instance Methods
- (id)initWithHash:(NSString*)objectHash;
- (NSString*)objectPath;
- (NSData*)dataContentOfObject;

@end
