//
//  GITPackFile.h
//  CocoaGit
//
//  Created by Geoffrey Garside on 05/08/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GITPackFile : NSObject
{
}

- (id)initWithPath:(NSString*)path;
- (NSUInteger)version;

@end

#import "GITPlaceholderPackFile.h"
#import "GITPackFileVersion2.h"
