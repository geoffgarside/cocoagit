//
//  GITUser.h
//  CocoaGit
//
//  Created by Geoffrey Garside on 01/07/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface GITActor : NSObject {
    NSString * name;
    NSString * email;
}

#pragma mark -
#pragma mark Properties
@property(retain) NSString * name;
@property(retain) NSString * email;

#pragma mark -
#pragma mark Init Methods
- (id)initWithName:(NSString*)theName;
- (id)initWithName:(NSString*)theName andEmail:(NSString*)theEmail;

@end
