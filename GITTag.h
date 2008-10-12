//
//  GITTag.h
//  CocoaGit
//
//  Created by Geoffrey Garside on 05/08/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GITObject.h"

@class GITRepo, GITCommit, GITActor, GITDateTime;
@interface GITTag : GITObject
{
    NSString * name;
    
    // At such time as Tags can reference objects
    // other than commits we'll change this.
    GITCommit * commit;
    GITActor  * tagger;

    GITDateTime * tagged;
    
    NSString * message;
}

@property(readonly,copy) NSString * name;
@property(readonly,copy) GITCommit * commit;
@property(readonly,copy) GITActor * tagger;
@property(readonly,copy) GITDateTime * tagged;
@property(readonly,copy) NSString * message;

@end
