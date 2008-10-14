//
//  GITBlob.m
//  CocoaGit
//
//  Created by Geoffrey Garside on 05/08/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import "GITBlob.h"
#import "GITRepo.h"

#import "NSData+Searching.h"

NSString * const kGITObjectBlobName = @"blob";

/*! \cond
 Make properties readwrite so we can use
 them within the class.
*/
@interface GITBlob ()
@property(readwrite,copy) NSData * data;
@end
/*! \endcond */

@implementation GITBlob
@synthesize data;

+ (NSString*)typeName
{
    return kGITObjectBlobName;
}
- (id)initWithSha1:(NSString*)newSha1 data:(NSData*)raw repo:(GITRepo*)theRepo
{
    if (self = [super initType:kGITObjectBlobName sha1:newSha1
                          size:[raw length] repo:theRepo])
    {
        self.data = raw;
    }
    return self;
}
- (void)dealloc
{
    self.data = nil;
    [super dealloc];
}
- (id)copyWithZone:(NSZone*)zone
{
    GITBlob * blob = (GITBlob*)[super copyWithZone:zone];
    blob.data = self.data;
    return blob;
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
- (NSData*)rawContent
{
    return self.data;
}

@end
