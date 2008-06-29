//
//  GITObject.h
//  CocoaGit
//
//  Created by Geoffrey Garside on 29/06/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface GITObject : NSObject {
    NSString* hash;
}

#pragma mark -
#pragma mark Properties
@property(retain) NSString* hash;

#pragma mark -
#pragma mark Class Methods
+ (NSString*)objectPathFromHash:(NSString*)theHash;


#pragma mark -
#pragma mark Instance Methods

@end
