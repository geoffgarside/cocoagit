//
//  GITPackIndex.h
//  CocoaGit
//
//  Created by Geoffrey Garside on 04/11/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GITPlaceholderPackIndex.h"
#import "GITPackIndexVersion1.h"
#import "GITPackIndexVersion2.h"

/*! GITPackIndex is a class cluster.
 */
@interface GITPackIndex : NSObject
{
}

- (id)initWithPath:(NSString*)path;

#pragma mark -
- (NSUInteger)version;
@end
