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
- (NSUInteger)version;

@end

#import "GITPlaceholderPackIndex.h"
#import "GITPackIndexVersion1.h"
#import "GITPackIndexVersion2.h"