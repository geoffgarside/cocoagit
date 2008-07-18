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
    if (self = [super initWithHash:objectHash])
    {
        if ([self.type isEqualToString:kGITObjectBlobType])
        {
            self.data = [self dataContentOfObject];
        }
        else
        {
            NSException *exception = [NSException exceptionWithName:@"GitObjectTypeMismatchException"
                                                             reason:@"The parsed type is not 'blob'"
                                                           userInfo:nil];
            @throw exception;
        }
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

@end
