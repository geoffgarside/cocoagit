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

#import "NSData+Searching.h"

/*! \cond
 Make properties readwrite so we can use
 them within the class.
*/
@interface GITRepo ()
@property(readwrite,copy) NSString * root;
@property(readwrite,copy) NSString * desc;
@property(readwrite,assign) BOOL bare;
@property(readwrite,retain) GITObjectStore * store;
@end
/*! \endcond */

@implementation GITRepo
@synthesize root;
@synthesize desc;
@synthesize bare;
@synthesize store;

- (void) dealloc
{
    [root release], root = nil;
    [desc release], desc = nil;
    [store release], store = nil;
    [super dealloc];
}

- (id)initWithRoot:(NSString*)repoRoot
{
    return [self initWithRoot:repoRoot bare:NO error:NULL];
}
- (id)initWithRoot:(NSString*)repoRoot error:(NSError**)error
{
    return [self initWithRoot:repoRoot bare:NO error:error];
}
- (id)initWithRoot:(NSString*)repoRoot bare:(BOOL)isBare
{
    return [self initWithRoot:repoRoot bare:isBare error:NULL];
}
- (id)initWithRoot:(NSString*)repoRoot bare:(BOOL)isBare error:(NSError**)error
{
    NSString * rootPath = repoRoot;
    GITObjectStore * objectStore;
    if (![repoRoot hasSuffix:@".git"] && !isBare)
        rootPath = [repoRoot stringByAppendingPathComponent:@".git"];

    GITFileStore * fileStore = [GITFileStore storeWithRoot:rootPath error:error];
    if (!fileStore)
        return nil;

    GITPackStore * packStore = [GITPackStore storeWithRoot:rootPath error:error];
    if (!packStore)
        return nil;

    objectStore = [[[GITCombinedStore alloc] initWithStores: fileStore, packStore, nil] autorelease];
    if ([self initWithStore:objectStore])
    {
        self.root = rootPath;
        NSString * descFile = [self.root stringByAppendingPathComponent:@"description"];
        self.desc = [NSString stringWithContentsOfFile:descFile];
        self.bare = isBare;
    }
    return self;
}
- (id)initWithStore:(GITObjectStore*)objectStore
{
    if (! [super init])
        return nil;

    self.root = nil;
    self.desc = nil;
    self.bare = NO;
    self.store = objectStore;
    
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
    return (GITCommit*)[self objectWithSha1:sha1 type:GITObjectTypeCommit error:error];
}
- (GITBlob*)blobWithSha1:(NSString*)sha1 error:(NSError**)error
{
    return (GITBlob*)[self objectWithSha1:sha1 type:GITObjectTypeBlob error:error];
}
- (GITTree*)treeWithSha1:(NSString*)sha1 error:(NSError**)error
{
    return (GITTree*)[self objectWithSha1:sha1 type:GITObjectTypeTree error:error];
}
- (GITTag*)tagWithSha1:(NSString*)sha1 error:(NSError**)error
{
    return (GITTag*)[self objectWithSha1:sha1 type:GITObjectTypeTag error:error];
}
- (GITObject*)objectWithSha1:(NSString*)sha1 error:(NSError**)error
{
    return [self objectWithSha1:sha1 type:GITObjectTypeUnknown error:error];
}
- (GITObject*)objectWithSha1:(NSString*)sha1 type:(GITObjectType)eType error:(NSError**)error
{
    GITObjectType type; NSData * data;
    if (![self.store loadObjectWithSha1:sha1 intoData:&data type:&type error:error]) {
		return nil;
	}
	
 	if (! (eType == GITObjectTypeUnknown || eType == type)) {
		GITError(error, GITErrorObjectTypeMismatch, NSLocalizedString(@"Object type mismatch", @"GITErrorObjectTypeMismatch")); 
		return nil;
	}
		
	switch (type)
	{
		case GITObjectTypeCommit:
			return [[[GITCommit alloc] initWithSha1:sha1 data:data repo:self] autorelease];
		case GITObjectTypeTree:
			return [[[GITTree alloc] initWithSha1:sha1 data:data repo:self] autorelease];
		case GITObjectTypeBlob:
			return [[[GITBlob alloc] initWithSha1:sha1 data:data repo:self] autorelease];
		case GITObjectTypeTag:
			return [[[GITTag alloc] initWithSha1:sha1 data:data repo:self] autorelease];
	}

	// If we get here, then we've got a type that we don't understand. If the only way this could happen is a programming error, then it should be an exception.  For now, just create an error.
	GITError(error, GITErrorObjectTypeMismatch, NSLocalizedString(@"Object type mismatch", @"GITErrorObjectTypeMismatch"));

    return nil;
}

#pragma mark -
#pragma mark Low Level Loader
- (BOOL)loadObjectWithSha1:(NSString*)sha1 intoData:(NSData**)data
                      type:(GITObjectType*)type error:(NSError**)error
{
    return [self.store loadObjectWithSha1:sha1 intoData:data type:type error:error];
}

@end
