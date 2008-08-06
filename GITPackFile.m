//
//  GITPackFile.m
//  CocoaGit
//
//  Created by Geoffrey Garside on 05/08/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import "GITPackFile.h"

//            Name of Range                 Start   Length
const NSRange kGITPackFileSignatureRange = {     0,      4 };
const NSRange kGITPackFileVersionRange   = {     4,      4 };
const NSRange kGITPackFileNumberRange    = {     8,      4 };

const NSUInteger kGITPackIndexFanOutSize = 256;

@interface GITPackFile ()
@property(readwrite,retain) GITRepo * repo;
@property(readwrite,copy)   NSString * idxPath;
@property(readwrite,copy)   NSString * packPath;
@property(readwrite,copy)   NSArray  * idxOffsets;
@property(readwrite,assign) NSUInteger idxVersion;
@property(readwrite,assign) NSUInteger packVersion;
@property(readwrite,assign) NSUInteger numberOfObjects;
@end

@implementation GITPackFile

@synthesize repo;
@synthesize idxPath;
@synthesize packPath;
@synthesize idxOffsets;
@synthesize idxVersion;
@synthesize packVersion;
@synthesize numberOfObjects;

- (id)initWithPath:(NSString*)path
{
    if (self = [super init])
    {
        self.idxPath = path;
        self.packPath = path;
    }
}
- (void)setPackPath:(NSString*)thePath
{
    if (thePath != packPath)
    {
        [packPath release];
        packPath = [[thePath stringByDeletingPathExtension] 
            stringByAppendingPathExtension:@"pack"];
    }
}
- (void)setIdxPath:(NSString*)thePath
{
    if (thePath != idxPath)
    {
        [idxPath release];
        idxPath = [[thePath stringByDeletingPathExtension] 
            stringByAppendingPathExtension:@"idx"];
    }
}
- (void)readPack
{
    NSError * err;
    NSData * pack = [NSData dataWithContentsOfFile:self.packPath
                                           options:NSUncachedRead
                                             error:&err];
    
    unichar buf[4];
    [pack getBytes:buf range:kGITPackFileSignatureRange];
    if ([[NSString stringWithCharacters:buf length:4] isEqualToString:@"PACK"])
    {   // Its a valid PACK file, continue
        [pack getBytes:buf range:kGITPackFileVersionRange];
        self.version = [self integerFromBytes:buf length:4];
        
        if (self.version == 2)
            [self readVersion2:pack];
    }
}
- (void)readPackVersion2:(NSData*)pack
{
    unichar buf[4];
    [pack getBytes:buf range:kGITPackFileNumberRange];
    
    self.numberOfObjects = [self integerFromBytes:buf length:4];
    
    
}
- (void)readIdx
{
    NSError * err;
    NSData * idx = [NSData dataWithContentsOfFile:self.idxPath
                                          options:NSUncachedRead
                                            error:&err];
    unichar buf[4];
    NSUInteger i;
    
    // The Fanout table
    // The fanout table consists of 256 entries. These
    // entries correspond to first byte of an object
    // sha1. The value at each entry is the number of
    // object sha1's in the corresponding PACK file
    // in which the first byte is less than or equal
    // to the entry index.
    // The value of each entry should be greater than
    // or equal to the previous value, if it is not 
    // then the index file is corrupt.
    // At the moment I am not sure if the fan out
    // entry index corresponds to the compressed or
    // uncompressed SHA1 hash value.
    for (i = 0; i < kGITPackIndexFanOutSize; i++)
    {
        [idx getBytes:buf range:NSMakeRange(i * 4, 4)];
        
    }
}
- (NSUInteger)integerFromBytes:(unichar*)bytes length:(NSUInteger)length
{
    NSUInteger i, value = 0;
    for (i = 0; i <= length; i++)
        value = (value << 4) | bytes[i];
    return value;
}

@end
