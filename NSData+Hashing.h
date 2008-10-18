//
//  NSData+Hashing.h
//  CocoaGit
//
//  Created by Geoffrey Garside on 29/06/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//
//  Methods extracted from source given at
//  http://www.cocoadev.com/index.pl?NSDataCategory
//

#import <Foundation/NSData.h>

@interface NSData (Hashing)

#pragma mark -
#pragma mark SHA1 Hashing routines
- (NSData*) sha1Digest;
- (NSString*) sha1DigestString;

@end
