//
//  GITUser.m
//  CocoaGit
//
//  Created by Geoffrey Garside on 01/07/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import "GITUser.h"


@implementation GITUser

#pragma mark -
#pragma mark Properties
@synthesize name;
@synthesize email;

#pragma mark -
#pragma mark Init Methods
- (id)initWithName:(NSString*)theName
{
    return [self initWithName:theName andEmail:NULL];
}
- (id)initWithName:(NSString*)theName andEmail:(NSString*)theEmail
{
    if (self = [super init])
    {
        self.name = theName;
        self.email = theEmail;
    }
    return self;
}

- (NSString*)description
{
    if (self.email)
        return [NSString stringWithFormat:@"%@ <%@>",
                self.name, self.email];
    else
        return self.name;
}

@end
