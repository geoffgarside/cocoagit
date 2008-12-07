//
//  GITRepo.m
//  CocoaGit
//
//  Created by Geoffrey Garside on 05/08/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import "GITRepo.h"
#import "GITFileStore.h"
#import "GITPackStore.h"
#import "GITCombinedStore.h"
#import "GITObject.h"
#import "GITCommit.h"
#import "GITBlob.h"
#import "GITTree.h"
#import "GITTag.h"

#import "NSData+Searching.h"

/*! \cond
 Make properties readwrite so we can use
 them within the class.
*/
@interface GITRepo ()
@property(readwrite,copy) NSString * root;
@property(readwrite,copy) NSString * desc;
@property(readwrite,retain) GITObjectStore * store;
@end
/*! \endcond */

@implementation GITRepo
@synthesize root;
@synthesize desc;
@synthesize store;

- (id)initWithRoot:(NSString*)repoRoot
{
    return [self initWithRoot:repoRoot bare:NO];
}
- (id)initWithRoot:(NSString*)repoRoot bare:(BOOL)isBare
{
    if (self = [super init])
    {
        if ([repoRoot hasSuffix:@".git"])
            self.root = repoRoot;
        else
        {
            if (isBare)
                self.root = repoRoot; //[repoRoot stringByAppendingPathExtension:@".git"];
            else
                self.root = [repoRoot stringByAppendingPathComponent:@".git"];
        }
        
        NSString * descFile = [self.root stringByAppendingPathComponent:@"description"];
        self.desc = [NSString stringWithContentsOfFile:descFile];
        self.store = [[GITCombinedStore alloc] initWithStores:
                        [[GITFileStore alloc] initWithRoot:self.root],
                        [[GITPackStore alloc] initWithRoot:self.root], nil];
    }
    return self;
}
- (id)copyWithZone:(NSZone*)zone
{
    return [[GITRepo allocWithZone:zone] initWithRoot:self.root];
}

#pragma mark -
#pragma mark Internal Methods
- (NSData*)dataWithContentsOfObject:(NSString*)sha1
{
    NSData * data = [self.store dataWithContentsOfObject:sha1];
    NSRange range = [data rangeOfNullTerminatedBytesFrom:0];
    return [data subdataFromIndex:range.length + 1];
}
- (NSData*)dataWithContentsOfObject:(NSString*)sha1 type:(NSString*)expectedType
{
    NSString * type; NSUInteger size; NSData * data;

    if ([self.store extractFromObject:sha1 type:&type size:&size data:&data])
        if ([expectedType isEqualToString:type] && [data length] == size)
            return data;
    return nil;
}

#pragma mark -
#pragma mark Deprecated Loaders
- (GITObject*)objectWithSha1:(NSString*)sha1
{
    return [self objectWithSha1:sha1 type:GITObjectTypeUnknown error:NULL];
}
- (GITCommit*)commitWithSha1:(NSString*)sha1
{
    return [self commitWithSha1:sha1 error:NULL];
}
- (GITBlob*)blobWithSha1:(NSString*)sha1
{
    return [self blobWithSha1:sha1 error:NULL];
}
- (GITTree*)treeWithSha1:(NSString*)sha1
{
    return [self treeWithSha1:sha1 error:NULL];
}
- (GITTag*)tagWithSha1:(NSString*)sha1
{
    return [self tagWithSha1:sha1 error:NULL];
}

#pragma mark -
#pragma mark Error aware loaders
- (GITCommit*)commitWithSha1:(NSString*)sha1 error:(NSError**)error
{
    return [self objectWithSha1:sha1 type:GITObjectTypeCommit error:error];
}
- (GITBlob*)blobWithSha1:(NSString*)sha1 error:(NSError**)error
{
    return [self objectWithSha1:sha1 type:GITObjectTypeBlob error:error];
}
- (GITTree*)treeWithSha1:(NSString*)sha1 error:(NSError**)error
{
    return [self objectWithSha1:sha1 type:GITObjectTypeTree error:error];
}
- (GITTag*)tagWithSha1:(NSString*)sha1 error:(NSError**)error
{
    return [self objectWithSha1:sha1 type:GITObjectTypeTag error:error];
}
- (GITObject*)objectWithSha1:(NSString*)sha1 error:(NSError**)error
{
    return [self objectWithSha1:sha1 type:GITObjectTypeUnknown error:error];
}
- (GITObject*)objectWithSha1:(NSString*)sha1 type:(GITObjectType)eType error:(NSError**)error
{
    NSError * undError;
    NSString * errorDescription;
    NSDictionary * errorUserInfo;

    GITObjectType type; NSData * data;

    if ([self.store loadObjectWithSha1:sha1 intoData:&data type:&type error:&undError])
    {
        if (eType == GITObjectTypeUnknown || eType == type)
        {
            switch (type)
            {
                case GITObjectTypeCommit:
                    return [[GITCommit alloc] initWithSha1:sha1 data:data repo:self];
                case GITObjectTypeTree:
                    return [[GITTree alloc] initWithSha1:sha1 data:data repo:self];
                case GITObjectTypeBlob:
                    return [[GITBlob alloc] initWithSha1:sha1 data:data repo:self];
                case GITObjectTypeTag:
                    return [[GITTag alloc] initWithSha1:sha1 data:data repo:self];
            }
        }
        else if (error != NULL)
        {
            errorDescription = NSLocalizedString(@"Object type mismatch", @"GITErrorObjectTypeMismatch");
            errorUserInfo = [NSDictionary dictionaryWithObject:errorDescription forKey:NSLocalizedDescriptionKey];
            *error = [[[NSError alloc] initWithDomain:GITErrorDomain code:GITErrorObjectTypeMismatch userInfo:errorUserInfo] autorelease];
        }
    }

    return nil;
}
@end
