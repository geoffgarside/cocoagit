//
//  GITObject.h
//  CocoaGit
//
//  Created by Geoffrey Garside on 05/08/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import "GITObject.h"
#import "GITRepo.h"

/*! \cond */
@interface GITObject ()
@property(readwrite,retain) GITRepo  * repo;
@property(readwrite,copy)   NSString * sha1;
@property(readwrite,copy)   NSString * type;
@property(readwrite,assign) NSUInteger size;
@end
/*! \endcond */

@implementation GITObject
@synthesize repo;
@synthesize sha1;
@synthesize type;
@synthesize size;

+ (NSString*)typeName
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}
- (id)init
{
    [self doesNotRecognizeSelector:_cmd];
    [self release];
    return nil;
}
- (id)initWithSha1:(NSString*)newSha1 repo:(GITRepo*)theRepo
{
    NSData * data = [theRepo dataWithContentsOfObject:newSha1 type:[[self class] typeName]];
    if (data)
        return [self initWithSha1:newSha1 data:data repo:theRepo];
    return nil;
}
- (id)initWithSha1:(NSString*)sha1 data:(NSData*)raw repo:(GITRepo*)theRepo
{
    [self doesNotRecognizeSelector:_cmd];
    [self release];
    return nil;
}
- (id)initType:(NSString*)newType sha1:(NSString*)newSha1
          size:(NSUInteger)newSize repo:(GITRepo*)theRepo
{
    if (self = [super init])
    {
        self.repo = theRepo;
        self.sha1 = newSha1;
        self.type = newType;
        self.size = newSize;
    }
    return self;
}
- (void)dealloc
{
    self.repo = nil;
    self.sha1 = nil;
    self.type = nil;
    self.size = 0;
    
    [super dealloc];
}
- (id)copyWithZone:(NSZone*)zone
{
    GITObject * obj = [[[self class] allocWithZone:zone] initType:self.type sha1:self.sha1
                                                             size:self.size repo:self.repo];
    return obj;
}
- (NSData*)rawData
{
    NSString * head = [NSString stringWithFormat:@"%@ %lu\0",
                       self.type, (unsigned long)self.size];
    NSMutableData * raw = [NSMutableData dataWithData:[head dataUsingEncoding:NSASCIIStringEncoding]];
    [raw appendData:[self rawContent]];

    return raw;
}
- (NSData*)rawContent
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}
@end
