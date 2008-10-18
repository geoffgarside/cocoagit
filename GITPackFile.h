//
//  GITPackFile.h
//  CocoaGit
//
//  Created by Geoffrey Garside on 05/08/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import <Foundation/Foundation.h>

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

@property(readonly,copy) NSString * idxPath;
@property(readonly,copy) NSString * packPath;
@property(readonly,assign) NSUInteger idxVersion;
@property(readonly,assign) NSUInteger packVersion;
@property(readonly,assign) NSUInteger numberOfObjects;

- (id)initWithPath:(NSString*)path;
- (void)setPackPath:(NSString*)path;
- (void)setIdxPath:(NSString*)path;
- (void)openIdxAndPackFiles;
- (void)readPack;
- (NSData*)objectAtOffset:(NSUInteger)offset;
- (NSData*)objectAtOffsetVersion1:(NSUInteger)offset;
- (NSData*)objectAtOffsetVersion2:(NSUInteger)offset;
- (void)readIdx;
- (NSData*)dataForSha1:(NSString*)sha1;
- (NSUInteger)offsetForSha1:(NSString*)sha1;

@end
