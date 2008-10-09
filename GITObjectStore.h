//
//  GITObjectStore.h
//  CocoaGit
//
//  Created by Geoffrey Garside on 09/10/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface GITObjectStore : NSObject {

}

- (NSData*)dataForObject:(NSString*)sha1;

#pragma mark -
#pragma mark Delegate Methods
- (void)store:(GITObjectStore*)store didFindObject:(NSString*)sha1 withData:(NSData*)data;

@end
