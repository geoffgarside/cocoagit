//
//  GITRepo+Protected.h
//  CocoaGit
//
//  Created by Geoffrey Garside on 05/08/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import "GITRepo.h"

@protocol GITObject;
@interface GITRepo ()

- (NSString*)objectPathFromHash:(NSString*)hash;
- (NSData*)dataWithContentsOfHash:(NSString*)hash;
- (void)extractFromData:(NSData*)data
                   type:(NSString**)theType
                   size:(NSUInteger*)theSize
                andData:(NSData**)theData;

#pragma mark -
#pragma mark Object instanciation methods
//- (id <GITObject>)objectWithHash:(NSString*)hash;
//- (GITCommit*)commitWithHash:(NSString*)hash;
//- (GITTag*)tagWithHash:(NSString*)hash;
//- (GITTree*)treeWithHash:(NSString*)hash;
//- (GITBlob*)blobWithHash:(NSString*)hash;

@end
