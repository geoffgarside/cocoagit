//
//  GITObject.h
//  CocoaGit
//
//  Created by Geoffrey Garside on 29/06/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern const NSString * kGITObjectsDirectoryRoot;

@interface GITObject : NSObject {
    NSString* sha1;
}

#pragma mark -
#pragma mark Properties
@property(retain) NSString* sha1;

#pragma mark -
#pragma mark Class Methods
+ (NSString*)objectPathFromHash:(NSString*)theHash;
+ (GITObject*)objectFromHash:(NSString*)objectHash;


#pragma mark -
#pragma mark Instance Methods
- (id)initFromHash:(NSString*)objectHash;
- (NSString*)hashObject;
- (NSString*)objectPath;

@end
