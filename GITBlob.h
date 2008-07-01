//
//  GITBlob.h
//  CocoaGit
//
//  Created by Geoffrey Garside on 29/06/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GITObject.h"

extern const NSString *kGITObjectBlobType;

@interface GITBlob : GITObject {
    NSData * data;
}

#pragma mark -
#pragma mark Properties
@property(retain) NSData * data;

#pragma mark -
#pragma mark Reading existing Blob objects
- (id)initFromHash:(NSString*)objectHash;

#pragma mark -
#pragma mark Creating new Blob objects
- (id)initWithData:(NSData*)dataContent;
- (id)initWithContentsOfFile:(NSString*)filePath;

#pragma mark -
#pragma mark Instance Methods
- (NSString*)objectType;
@end
