//
//  NSData+Compression.h
//  CocoaGit
//
//  Created by Geoffrey Garside on 29/06/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//
//  Methods extracted from source given at
//  http://www.cocoadev.com/index.pl?NSDataCategory
//

#import <Cocoa/Cocoa.h>

@interface NSData (Compression)

#pragma mark -
#pragma mark Zlib Compression routines
- (NSData *) zlibInflate;
- (NSData *) zlibDeflate;

#pragma mark -
#pragma mark Gzip Compression routines
- (NSData *) gzipInflate;
- (NSData *) gzipDeflate;

@end
