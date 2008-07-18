//
//  GITObject.m
//  CocoaGit
//
//  Created by Geoffrey Garside on 29/06/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import "GITObject.h"
#import "NSData+Compression.h"
#import "NSData+Searching.h"

const NSString * kGITObjectsDirectoryRoot = @".git/objects";

// Make the properties readwrite
@interface GITObject ()
@property(readwrite,retain) NSString * sha1;
@property(readwrite,retain) NSString * type;
@property(readwrite,assign) NSUInteger size;

- (void)loadMetaData;

@end

@implementation GITObject
@synthesize sha1;
@synthesize type;
@synthesize size;

#pragma mark -
#pragma mark Class Methods
+ (NSString*)objectPathFromHash:(NSString*)theHash
{
    return [NSString stringWithFormat:@"%@/%@/%@",
            kGITObjectsDirectoryRoot,
            [theHash substringToIndex:2],       //!< Gets the first two characters of the sha1
            [theHash substringFromIndex:2]];    //!< Gets the remaining characters of the sha1
}

#pragma mark -
#pragma mark Instance Methods
- (id)initWithHash:(NSString*)objectHash
{
    if (self = [super init])
    {
        self.sha1 = objectHash;
        [self loadMetaData];
    }
    return self;
}
- (void)dealloc
{
    self.sha1 = nil;
    [super dealloc];
}
- (NSString*)objectPath
{
    return [[self class] objectPathFromHash:self.sha1];
}
- (NSData*)dataContentOfObject
{
    NSData *data = [[NSData dataWithContentsOfFile:[self objectPath]] zlibInflate];
    NSRange metaRange = [data rangeOfNullTerminatedBytesFrom:0];

    return [data subdataFromIndex:metaRange.length + 1];
}
- (void)loadMetaData
{
    NSData * decompressedData = [[NSData dataWithContentsOfFile:[self objectPath]] zlibInflate];
    NSRange metaRange         = [decompressedData rangeOfNullTerminatedBytesFrom:0];
    NSData * metaData         = [decompressedData subdataWithRange:metaRange];
    NSString * meta           = [[NSString alloc] initWithData:metaData
                                                      encoding:NSASCIIStringEncoding];
    NSUInteger indexOfSpace   = [meta rangeOfString:@" "].location;
    
    self.type = [meta substringToIndex:indexOfSpace];
    self.size = [[meta substringFromIndex:indexOfSpace + 1] integerValue];
}

@end
