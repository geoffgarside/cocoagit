//
//  GITTree.h
//  CocoaGit
//
//  Created by Geoffrey Garside on 05/08/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GITObject.h"

extern NSString * const kGITObjectTreeName;

/*! Git object type representing a directory.
 */
@interface GITTree : GITObject
{
    NSArray  * entries; //!< Array of entrys in this tree.
}

@property(readonly,copy) NSArray * entries;

@end
