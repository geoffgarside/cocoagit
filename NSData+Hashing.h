//
//  NSData+Hashing.h
//  CocoaGit
//
//  Created by Geoffrey Garside on 29/06/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSData (Hashing)

#pragma mark -
#pragma mark SHA1 Hashing routines
- (NSData*) sha1Digest;
- (NSString*) sha1DigestString;

@end
