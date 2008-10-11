//
//  GITBlob.m
//  CocoaGit
//
//  Created by Geoffrey Garside on 05/08/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import "GITBlob.h"
#import "GITRepo+Protected.h"

#import "NSData+Searching.h"

/*! \cond
 Make properties readwrite so we can use
 them within the class.
*/
@interface GITBlob ()
@property(readwrite,retain) GITRepo * repo;
@property(readwrite,copy) NSString * sha1;
@property(readwrite,assign) NSUInteger size;
@property(readwrite,copy) NSData * data;
@end
/*! \endcond */

@implementation GITBlob
@synthesize repo;
@synthesize sha1;
@synthesize size;
@synthesize data;

- (id)initWithHash:(NSString*)hash
           andData:(NSData*)blobData
          fromRepo:(GITRepo*)parentRepo
{
    if (self = [super init])
    {
        self.repo = parentRepo;
        self.sha1 = hash;
        self.size = [blobData length];
        self.data = blobData;
    }
    return self;
}
- (void)dealloc
{
    self.repo = nil;
    self.sha1 = nil;
    self.size = 0;
    self.data = nil;
    [super dealloc];
}
- (id)copyWithZone:(NSZone*)zone
{
    return [[GITBlob allocWithZone:zone] initWithHash:self.sha1
                                              andData:self.data
                                             fromRepo:self.repo];
}
- (BOOL)canBeRepresentedAsString
{
    // If we can't find a null byte then it can be represented as string
    if ([self.data rangeOfNullTerminatedBytesFrom:0].location == NSNotFound)
        return YES;
    return NO;
}
- (NSString*)stringValue    //!< Implicitly retained by the sender
{
    NSString * v = [[NSString alloc] initWithData:self.data
                                         encoding:NSASCIIStringEncoding];
    return [[v autorelease] retain];
}
- (NSData*)rawData
{
    NSString * rawString = [NSString stringWithFormat:@"blob %lu\0%@",
                            (unsigned long)self.size, self.data];
    return [rawString dataUsingEncoding:NSASCIIStringEncoding];
}

@end
