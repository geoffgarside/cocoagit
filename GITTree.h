//
//  GITTree.h
//  CocoaGit
//
//  Created by Geoffrey Garside on 05/08/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GITObject.h"

@class GITRepo;
/*! Git object type representing a directory.
 */
@interface GITTree : NSObject <GITObject>
{
    GITRepo  * repo;    //!< Repository which this tree is a part of
    NSString * sha1;    //!< The SHA1 hash reference of this tree
    NSUInteger size;    //!< The file size of the raw content of this tree
    NSArray  * entries; //!< Array of entrys in this tree.
}

@property(readonly,copy) NSString * sha1;
@property(readonly,assign) NSUInteger size;
@property(readonly,copy) NSArray * entries;

@end
