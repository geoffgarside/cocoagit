//
//  GITRepo.m
//  CocoaGit
//
//  Created by Geoffrey Garside on 05/08/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import "GITRepo.h"
#import "GITObject.h"
#import "GITCommit.h"
#import "GITTree.h"
#import "GITBranch.h"
#import "GITBlob.h"
#import "GITTag.h"

#import "GITObjectStore.h"
#import "GITRefStore.h"
#import "GITFileStore.h"
#import "GITPackStore.h"
#import "GITCombinedStore.h"

#import <CommonCrypto/CommonDigest.h>
#import "NSData+Hashing.h"
#import "NSData+Searching.h"
#import "NSData+Compression.h"
#import "NSFileManager+DirHelper.h"
#import "NSCharacterSet+StringComparison.h"

#import "GITUtilityBelt.h"
#import "GITErrors.h"

/*! \cond
 Make properties readwrite so we can use
 them within the class.
*/
@interface GITRepo ()
@property(readwrite,copy) NSString * root;
@property(readwrite,copy) NSString * desc;
@property(readwrite,assign) BOOL bare;
@property(readwrite,retain) GITObjectStore * store;
@property(readwrite,retain) GITRefStore *refStore;
@end
/*! \endcond */

@interface GITBranch ()
@property(readwrite,retain) GITRepo * repo;
@property(readwrite,copy) NSString * name;
@end

@implementation GITRepo
@synthesize root;
@synthesize desc;
@synthesize bare;
@synthesize store;
@synthesize refStore;

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
    
    GITRefStore *rStore = [[[GITRefStore alloc] 
                            initWithPath:[rootPath stringByAppendingPathComponent:@"refs"]
                            packFile:[rootPath stringByAppendingPathComponent:@"packed-refs"]
                            error:error] autorelease];
    if ( !rStore )
        return nil;
    
    objectStore = [[[GITCombinedStore alloc] initWithStores: fileStore, packStore, nil] autorelease];
    if ( [self initWithObjectStore:objectStore refStore:nil] ) {
        self.root = rootPath;
        NSString * descFile = [self.root stringByAppendingPathComponent:@"description"];
        self.desc = [NSString stringWithContentsOfFile:descFile];
        self.bare = isBare;
        self.refStore = rStore;
    }
    return self;
}

- (id) initWithObjectStore:(GITObjectStore *)objectStore refStore:(GITRefStore *)referenceStore
{
    if (! [super init])
        return nil;

    self.root = nil;
    self.desc = nil;
    self.bare = NO;
    self.store = objectStore;
    self.refStore = referenceStore;
    
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
    return [[self store] dataWithContentsOfObject:sha1];
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
		GITError(error, GITErrorObjectNotFound, NSLocalizedString(@"Object not found", @"GITErrorObjectNotFound"));
		return nil;
	}
	
 	if (! (eType == GITObjectTypeUnknown || eType == type)) {
		GITError(error, GITErrorObjectTypeMismatch, NSLocalizedString(@"Object type mismatch", @"GITErrorObjectTypeMismatch")); 
		return nil;
	}
	
	Class klass;
    switch (type) {
		case GITObjectTypeCommit:
            klass = [GITCommit class]; 
            break;
		case GITObjectTypeTree:
            klass = [GITTree class];
            break;
		case GITObjectTypeBlob:
            klass = [GITBlob class];
            break;
		case GITObjectTypeTag:
            klass = [GITTag class];
            break;
	}
    
    if ( !klass ) {
        // If we get here, then we've got a type that we don't understand. If the only way this could happen is a programming error, then it should be an exception.  For now, just create an error.
        GITError(error, GITErrorObjectTypeMismatch, NSLocalizedString(@"Object type mismatch", @"GITErrorObjectTypeMismatch"));
    }
    
    return [[[klass alloc] initWithSha1:sha1 type:type data:data repo:self error:error] autorelease];
}

#pragma mark -
#pragma mark Low Level Loader
- (BOOL)loadObjectWithSha1:(NSString*)sha1 intoData:(NSData**)data
                      type:(GITObjectType*)type error:(NSError**)error
{
    return [self.store loadObjectWithSha1:sha1 intoData:data type:type error:error];
}

#pragma mark -
#pragma mark Refs Stuff

// KVC accessors for refs
- (NSUInteger) countOfRefs { return [[self refs] count]; }

- (id) objectInRefsAtIndex:(NSUInteger) i;
{
	return [[self refs] objectAtIndex:i];
}
// end KVC accessors

- (NSString *) refsPath
{
	return [[self root] stringByAppendingPathComponent:@"refs"];
}

- (NSString *) packedRefsPath
{
	return [[self root] stringByAppendingPathComponent:@"packed-refs"];
}

- (NSString *) headRefPath
{
	return [[self root] stringByAppendingPathComponent:@"HEAD"];
}

- (NSArray *) branches {
    NSArray *refs = [self refs];
    NSMutableArray *branches = [[NSMutableArray alloc] initWithCapacity:[refs count]];
    for (NSDictionary *ref in refs) {
        NSString *refName = [ref objectForKey:@"name"];
        if (![refName hasPrefix:@"refs/heads"]) {
            continue;
        }
        GITBranch *branch = [[GITBranch alloc] init];
        branch.name = [refName lastPathComponent]; // probably should explicitly split on slashes
        branch.repo = self;
        [branches addObject:branch];
        [branch release];
    }
    NSArray *branchesCopy = [[branches copy] autorelease];
    [branches release];
    return branchesCopy;
}

- (NSDictionary *) dictionaryWithRefName:(NSString *) aName sha:(NSString *) shaString
{
	return [NSDictionary dictionaryWithObjectsAndKeys:
							 aName, @"name",
							 shaString, @"sha", nil];
}

- (GITCommit*)head
{
    for (NSDictionary *ref in self.refs) {
        if ([[ref objectForKey:@"name"] isEqualToString:@"HEAD"]) {
            return [self commitWithSha1:[ref objectForKey:@"sha"]];
        }
    }
    return nil;
}

- (GITBranch*)master
{
	return [self branchWithName:@"master"];
}

- (GITBranch*)branchWithName:(NSString*)name
{
	for (GITBranch *branch in self.branches) {
        if ([branch.name isEqualToString:name]) {
            return branch;
        }
    }
    return nil;
}

- (NSArray *) refs
{
	NSMutableArray *refs = [[NSMutableArray alloc] init];
	
	NSString *tempRef, *thisSha, *thisRef;
	NSString *refsPath = [self refsPath];
	
	NSFileManager *fm = [NSFileManager defaultManager];
	BOOL isDir;
    if ([fm fileExistsAtPath:refsPath isDirectory:&isDir] && isDir) {
		NSEnumerator *e = [fm enumeratorAtPath:refsPath];
		while ( (thisRef = [e nextObject]) ) {
			tempRef = [refsPath stringByAppendingPathComponent:thisRef];
			thisRef = [@"refs" stringByAppendingPathComponent:thisRef];
			
			BOOL isDir;
			if ([fm fileExistsAtPath:tempRef isDirectory:&isDir] && !isDir) {
				NSString *shaString = [[NSString alloc] initWithContentsOfFile:tempRef
																	  encoding:NSASCIIStringEncoding 
																		 error:nil];
				thisSha = [shaString stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
				[shaString release];
				
				[refs addObject:[self dictionaryWithRefName:thisRef sha:thisSha]];
			}
		}
	}
    
    NSString *packedRefsPath = [self packedRefsPath];
    if ([fm fileExistsAtPath:packedRefsPath]) {
        NSString *packedRefs = [[NSString alloc] initWithContentsOfFile:packedRefsPath
                                                               encoding:NSASCIIStringEncoding 
                                                                  error:nil];
        NSArray *packedRefLines = [packedRefs componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];        
        for (NSString *line in packedRefLines) {
            if ([line length] < 1 || [line hasPrefix:@"#"] || [line hasPrefix:@"^"]) {
                continue;
            }
            NSArray *parts = [line componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            thisSha = [parts objectAtIndex:0];
            thisRef = [parts objectAtIndex:1];
            [refs addObject:[self dictionaryWithRefName:thisRef sha:thisSha]];
        }
        [packedRefs release];
    }
    
    NSString *headRefContents = [[NSString alloc] initWithContentsOfFile:[self headRefPath]
                                                        encoding:NSASCIIStringEncoding 
                                                           error:nil];
    NSString *headRefTemp = [headRefContents stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    [headRefContents release];
    NSDictionary *headRef = nil;
    
    if ([headRefTemp hasPrefix:@"ref:"]) {
        for (NSDictionary *ref in refs) {
            if ([headRefTemp hasSuffix:[ref objectForKey:@"name"]]) {
                headRef = [self dictionaryWithRefName:@"HEAD" sha:[ref objectForKey:@"sha"]];
                break;
            }
        }
    } else {
        headRef = [self dictionaryWithRefName:@"HEAD" sha:headRefTemp];
    }

    if (headRef) {
        [refs addObject:headRef];
    }
    
	NSArray *refsCopy = [[refs copy] autorelease];
	[refs release];
	
	return refsCopy;
}

- (BOOL) updateRef:(NSString *)refName toSha:(NSString *)toSha
{
	return [self updateRef:refName toSha:toSha error:nil];
}

- (BOOL) updateRef:(NSString *)refName toSha:(NSString *)toSha error:(NSError **)error
{
	NSString *refPath = [[self root] stringByAppendingPathComponent:refName];
	return [toSha writeToFile:refPath atomically:YES encoding:NSUTF8StringEncoding error:error];
}

+ (BOOL) isShaValid:(NSString *) shaString
{
    if ( [shaString length] != 40 )
        return NO;

    NSCharacterSet *cs = [NSCharacterSet characterSetWithCharactersInString:@"0123456789abcdef"];
    return [cs stringIsComposedOfCharactersInSet:shaString];
}

- (BOOL) writeObject:(NSData *)objectData withType:(NSString *)type
{
    return [self.store writeObject:objectData type:[GITObject objectTypeForString:type] error:NULL];
}

- (BOOL) hasObject: (NSString *)sha1
{
	return [self.store hasObjectWithSha1:sha1];
}
@end