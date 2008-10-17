//
//  GITPackFile.h
//  CocoaGit
//
//  Created by Geoffrey Garside on 05/08/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface GITPackFile : NSObject
{
    NSData * idxData;
    NSData * packData;

    NSString * idxPath;
    NSString * packPath;
    
    NSArray  * idxOffsets;

    NSUInteger idxVersion;
    NSUInteger packVersion;
    
    NSUInteger numberOfObjects;
}

@end

@property(readonly,copy) NSString * idxPath;
@property(readonly,copy) NSString * packPath;
