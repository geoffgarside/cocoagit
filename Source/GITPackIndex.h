//
//  GITPackIndex.h
//  CocoaGit
//
//  Created by Geoffrey Garside on 04/11/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import <Foundation/Foundation.h>

/*! GITPackIndex is a class cluster.
 */
@interface GITPackIndex : NSObject
{
}

- (id)initWithPath:(NSString*)path;
- (id)copyWithZone:(NSZone*)zone;

#pragma mark -
#pragma mark Primitive Methods
- (id)initWithPath:(NSString*)path;
- (NSUInteger)version;
- (NSArray*)offsets;
- (NSUInteger)packOffsetForSha1:(NSString*)sha1;

#pragma mark -
#pragma mark Derived Methods
- (NSUInteger)numberOfObjects;
- (NSUInteger)numberOfObjectsWithFirstByte:(char)byte;

/*! Returns a range describing the number of objects to the beginning of
 * those starting with <tt>byte</tt> and the number of objects ending
 * with <tt>byte</tt>.
 */
- (NSRange)rangeOfObjectsWithFirstByte:(char)byte;

@end

#import "GITPlaceholderPackIndex.h"
#import "GITPackIndexVersion1.h"
#import "GITPackIndexVersion2.h"
