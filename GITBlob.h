//
//  GITBlob.h
//  CocoaGit
//
//  Created by Geoffrey Garside on 29/06/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GITObject.h"

extern NSString * const kGITObjectBlobType;

@interface GITBlob : GITObject {
    NSData * data;
}

#pragma mark -
#pragma mark Read-only Properties
@property(readonly,retain) NSData * data;

#pragma mark -
#pragma mark Reading existing Blob objects
- (id)initWithHash:(NSString*)objectHash;

#pragma mark -
#pragma mark Instance Methods
- (NSString*)objectType;
- (BOOL)hasEmbeddedNulls;
- (NSString*)stringValue;
@end
