//
//  GITBlob.m
//  CocoaGit
//
//  Created by Geoffrey Garside on 29/06/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import "GITBlob.h"
#import "NSData+Searching.h"

NSString * const kGITObjectBlobType = @"blob";

@interface GITBlob ()
@property(readwrite,retain) NSData * data;
@end

@implementation GITBlob
@synthesize data;

#pragma mark -
#pragma mark Reading existing Blob objects
- (id)initWithHash:(NSString*)objectHash
{
    if (self = [super initType:kGITObjectBlobType withHash:objectHash])
    {
        // self.data will be set by our -loadContentFromData: method
    }
    return self;
}

#pragma mark -
#pragma mark Instance Methods
- (NSString*)objectType
{
    return kGITObjectBlobType;
}
- (NSString*)description
{
    return [NSString stringWithFormat:@"GITBlob: %@", self.sha1];
}
- (BOOL)hasEmbeddedNulls
{
    if ([self.data rangeOfNullTerminatedBytesFrom:0].location != NSNotFound)
        return YES;
    return NO;
}
- (NSString*)stringValue
{
    return [[NSString alloc] initWithData:self.data
                                 encoding:NSASCIIStringEncoding];
}
- (void)loadContentFromData:(NSData*)contentData
{
    self.data = contentData;
}

@end
