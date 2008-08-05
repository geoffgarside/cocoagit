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

- (void)loadAndVerifyWithType:(NSString*)expectedType;
- (void)loadMetaFromData:(NSData*)data;
- (void)shouldLoadContentsFromData:(NSData*)data;

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
    return [self initType:nil withHash:objectHash];
}
- (id)initType:(NSString*)expectedType withHash:(NSString*)objectHash
{
    if (self = [super init])
    {
        self.sha1 = objectHash;
        [self loadAndVerifyWithType:expectedType];
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
- (void)loadAndVerifyWithType:(NSString*)expectedType
{
    NSData * file = [[NSData dataWithContentsOfFile:[self objectPath]] zlibInflate];
    NSRange range = [file rangeOfNullTerminatedBytesFrom:0];
    NSData * meta = [file subdataWithRange:range];
    NSData * data = [file subdataFromIndex:range.length + 1];

    [self loadMetaFromData:meta];

    if (expectedType)
    {
        if ([self.type isEqualToString:expectedType])
            [self loadContentFromData:data];
        else
        {
            NSString * reason = [NSString stringWithFormat:@"File type is '%@' not '%@'",
                                 self.type, expectedType];
            NSException * ex  = [NSException exceptionWithName:@"GITTypeMisMatchException"
                                                        reason:reason
                                                      userInfo:nil];
            @throw ex;
        }
    }
}
- (void)loadMetaFromData:(NSData*)data
{
    NSString * meta = [[NSString alloc] initWithData:data
                                            encoding:NSASCIIStringEncoding];
    NSUInteger indexOfSpace   = [meta rangeOfString:@" "].location;

    self.type = [meta substringToIndex:indexOfSpace];
    self.size = [[meta substringFromIndex:indexOfSpace + 1] integerValue];
}
- (void)loadContentFromData:(NSData*)data
{
    NSException * ex = [NSException exceptionWithName:@"NotImplementedException"
                                               reason:@"-loadContentFromData: should be overridden in child classes"
                                             userInfo:nil];
    @throw ex;
}

@end
