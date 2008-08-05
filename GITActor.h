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

@property(readonly,copy) NSString * name;
@property(readonly,copy) NSString * email;

- (id)initWithName:(NSString*)theName;
- (id)initWithName:(NSString*)theName andEmail:(NSString*)theEmail;

@end
