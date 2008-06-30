//
//  GITBlob.h
//  CocoaGit
//
//  Created by Geoffrey Garside on 29/06/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GITObject.h"

@interface GITBlob : GITObject {
    NSData * data;
}

#pragma mark -
#pragma mark Properties
@property(retain) NSData * data;

#pragma mark -
#pragma mark Init Methods
- (id)initWithContentsOfFile:(NSString*)filePath;
- (id)initWithData:(NSData*)dataContent;

#pragma mark -
#pragma mark Instance Methods
- (BOOL)write;
- (BOOL)writeWithError:(NSError**)errorPtr;
@end
