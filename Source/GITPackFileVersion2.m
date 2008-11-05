//
//  GITPackFileVersion2.m
//  CocoaGit
//
//  Created by Geoffrey Garside on 04/11/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import "GITPackFileVersion2.h"
#import "GITPackIndex.h"

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
