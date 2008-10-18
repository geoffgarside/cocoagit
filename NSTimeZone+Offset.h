//
//  NSTimeZone+Offset.h
//  CocoaGit
//
//  Created by Geoffrey Garside on 28/07/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import <Foundation/NSTimeZone.h>

@interface NSTimeZone (Offset)

+ (id)timeZoneWithStringOffset:(NSString*)offset;
- (NSString*)offsetString;
@end
