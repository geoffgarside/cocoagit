//
//  GITPackFileVersion2.m
//  CocoaGit
//
//  Created by Geoffrey Garside on 04/11/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import "GITPackFileVersion2.h"
#import "GITPackIndex.h"

static const NSRange kGITPackFileObjectCountRange = { 8, 4 };

/*! \cond */
@interface GITPackFileVersion2 ()
@property(readwrite,copy) NSString * path;
@property(readwrite,retain) NSData * data;
@property(readwrite,retain) GITPackIndex * idx;
@end
/*! \endcond */

@implementation GITPackFileVersion2
@synthesize path;
@synthesize data;
@synthesize idx;

- (id)initWithPath:(NSString*)thePath
{
    if (self = [super init])
    {
        NSError * err;
        self.path = thePath;
        self.data = [NSData dataWithContentsOfFile:thePath
                                           options:NSUncachedRead
                                             error:&err];
        NSString * idxPath = [[thePath stringByDeletingPathExtension] 
                              stringByAppendingPathExtension:@"idx"];
        self.idx  = [[GITPackIndex alloc] initWithPath:idxPath];
    }
    return self;
}
- (NSUInteger)version
{
    return 2;
}
- (NSUInteger)numberOfObjects
{
    if (!numberOfObjects)
    {
        uint32_t value;
        [self.data getBytes:&value range:kGITPackFileObjectCountRange];
        numberOfObjects = CFSwapInt32BigToHost(value);
    }

    return numberOfObjects;
}
- (NSRange)rangeOfPackedObjects
{
    return NSMakeRange(12, [self rangeOfChecksum].location - 12);
}
- (NSRange)rangeOfChecksum
{
    return NSMakeRange([self.data length] - 20, 20);
}
- (NSData*)checksum
{
    return [self.data subdataWithRange:[self rangeOfChecksum]];
}
- (NSString*)checksumString
{
    return unpackSHA1FromData([self checksum]);
}
- (BOOL)verifyChecksum
{
    NSData * checkData = [[self.data subdataWithRange:NSMakeRange(0, [self.data length] - 20)] sha1Digest];
    return [checkData isEqualToData:[self checksum]];
}
- (NSData*)objectAtOffset:(NSUInteger)offset
{
    char buf;    // a single byte buffer
    NSUInteger size, type, shift = 4;
    
    // NOTE: ++ should increment offset after the range has been created
    [self.data getBytes:&buf range:NSMakeRange(offset++, 1)];
    
    size = buf & 0xf;
    type = (buf >> 4) & 0x7;
    
    while (buf & 0x80 != 0)
    {
        // NOTE: ++ should increment offset after the range has been created
        [self.data getBytes:&buf range:NSMakeRange(offset++, 1)];
        size |= ((buf & 0x7f) << shift);
        shift += 7;
    }
    
    return nil; // Method not finished yet
}

@end
