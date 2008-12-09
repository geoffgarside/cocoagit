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

#pragma mark -
#pragma mark GITObjectType Translators
+ (GITObjectType)objectTypeForString:(NSString*)type
{
    if ([type isEqualToString:@"commit"])
        return GITObjectTypeCommit;
    else if ([type isEqualToString:@"tree"])
        return GITObjectTypeTree;
    else if ([type isEqualToString:@"blob"])
        return GITObjectTypeBlob;
    else if ([type isEqualToString:@"tag"])
        return GITObjectTypeTag;
    return 0;
}
+ (NSString*)stringForObjectType:(GITObjectType)type
{
    switch (type)
    {
        case GITObjectTypeCommit:
            return @"commit";
        case GITObjectTypeTree:
            return @"tree";
        case GITObjectTypeBlob:
            return @"blob";
        case GITObjectTypeTag:
            return @"tag";
    }
}

- (GITObjectType)objectType
{
    return GITObjectTypeUnknown;
}

#pragma mark -
#pragma mark Deprecated Initializsers
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

#pragma mark -
#pragma mark Error Aware Initializers
- (id)initWithSha1:(NSString*)theSha1 repo:(GITRepo*)theRepo error:(NSError**)error
{
    NSError * undError;
    NSString * errorDescription;

    // We could get a loading error here
    NSData * raw = [theRepo objectWithSha1:theSha1 type:[self objectType] error:&undError]

    if (raw)
    {
        return [self initWithSha1:theSha1 type:[self objectType] raw:raw repo:theRepo error:error]
    }
    else if (error != NULL)
    {
        *error = undError;
        [self release];
        return nil;
    }
}
- (id)initWithSha1:(NSString*)theSha1 type:(GITObjectType)theType data:(NSData*)theData
              repo:(GITRepo*)theRepo error:(NSError**)error
{
    if (self = [super init])
    {
        self.sha1 = theSha1;
        // Remove when type is changed to a GITObjectType instead of a string
        self.type = [[self class] stringForObjectType:theType];
        self.size = [raw length];
        self.repo = theRepo;

        // Should only need to override -parseRawData:error: in subclasses
        if (![self parseRawData:theData error:error])
        {
            [self release];
            return nil;
        }
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

#pragma mark -
#pragma mark Data Parser
- (BOOL)parseRawData:(NSData*)data error:(NSError**)error
{
    return YES;     // should we return NO?
}

#pragma mark -
#pragma mark NSCopying
- (id)copyWithZone:(NSZone*)zone
{
    GITObject * obj = [[[self class] allocWithZone:zone] initType:self.type sha1:self.sha1
                                                             size:self.size repo:self.repo];
    return obj;
}

#pragma mark -
#pragma mark Raw Format methods
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
