//
//  NSData+Searching.h
//  CocoaGit
//
//  Created by Geoffrey Garside on 17/07/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import <Foundation/NSData.h>

@interface NSData (Searching)

- (NSRange)rangeOfNullTerminatedBytesFrom:(NSInteger)start;
- (NSData*)subdataFromIndex:(NSUInteger)anIndex;
- (NSData*)subdataToIndex:(NSUInteger)anIndex;

@end
