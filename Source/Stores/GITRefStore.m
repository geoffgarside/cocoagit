//
//  GITRefStore.m
//  CocoaGit
//
//  Created by chapbr on 4/7/09.
//  Copyright 2009 Brian Chapados. All rights reserved.
//

#import "GITRefStore.h"
#import "GITErrors.h"
#import "GITRef.h"
#import "GITRepo.h"
#import "GITUtilityBelt.h"

@interface GITRefStore ()
- (NSString *) sha1ByResolvingSymbolicRef:(GITRef *)symRef;
- (void) resolveSymbolicRefs;
- (NSDictionary *) cachedRefs;
- (void) fetchRefs;
- (void) fetchLooseRefs;
- (void) fetchPackedRefs;
@end


@implementation GITRefStore
@synthesize refsDir;
@synthesize packFile;

- (id) initWithRepo:(GITRepo *)repo error:(NSError **)error;
{
    NSString *packedRefsFile = [[repo root] stringByAppendingPathComponent:@"packed-refs"];
    return [self initWithPath:[repo refsPath] packFile:packedRefsFile error:error];
}

- (id) initWithPath:(NSString *)aPath packFile:(NSString *)packedRefsFile error:(NSError **)error;
{
    if ( ! [super init] )
        return nil;
    
    BOOL isDir;
    NSFileManager * fm = [NSFileManager defaultManager];
    if ( !([fm fileExistsAtPath:aPath isDirectory:&isDir] && isDir) ) {
        NSString * errFmt = NSLocalizedString(@"Ref store not accessible %@ does not exist or is not a directory", @"GITErrorRefStoreNotAccessible (GITRefStore)");
        NSString * errDesc = [NSString stringWithFormat:errFmt, aPath];
        GITError(error, GITErrorRefStoreNotAccessible, errDesc);
        [self release];
        return nil;
    }
    [self setRefsDir:aPath];
    
    if ( [fm fileExistsAtPath:packedRefsFile] ) {
        [self setPackFile:packedRefsFile];
    }
    cachedRefs = [NSMutableDictionary new];
    symbolicRefs = [NSMutableArray new];
    
    return self;
}

- (void) dealloc
{
    [refsDir release];
    [packFile release];
    [cachedRefs release];
    [symbolicRefs release];
    [super dealloc];
}

- (NSArray *) refsWithPrefix:(NSString *)refPrefix
{
    [self fetchRefs];
    
    if ( ![refPrefix hasPrefix:@"refs/"] )
        refPrefix = [NSString stringWithFormat:@"refs/%@"];
    
    NSMutableArray *matchingRefs = [NSMutableArray arrayWithCapacity:[cachedRefs count]/2];
    for (NSString *key in cachedRefs) {
        if ( ![key hasPrefix:refPrefix] )
            continue;
        [matchingRefs addObject:[cachedRefs objectForKey:key]];
    }
    return [NSArray arrayWithArray:matchingRefs];
}

- (NSArray *) branches
{
    return [self refsWithPrefix:@"refs/heads"];
}

- (NSArray *) heads
{
    return [self refsWithPrefix:@"refs/heads"];
}

- (NSArray *) tags
{
    return [self refsWithPrefix:@"refs/tags"];
}

- (NSArray *) remotes
{
    return [self refsWithPrefix:@"refs/remotes"];
}

- (void) invalidateCachedRefs
{
    [cachedRefs release];
    cachedRefs = [NSMutableDictionary new];
    fetchedLoose = NO;
    fetchedPacked = NO;
    [symbolicRefs release];
    symbolicRefs = [NSMutableArray new];
}

- (GITRef *) refWithName:(NSString *)refName
{
    return [[[[self cachedRefs] objectForKey:refName] copy] autorelease];
}

- (GITRef *) refByResolvingSymbolicRef:(GITRef *)symRef
{
    [self fetchRefs];
    if ( ![symRef isLink] )
        return symRef;
    NSString *sha1 = [self sha1ByResolvingSymbolicRef:symRef];
    [symRef setSha1:sha1];
    return [[symRef copy] autorelease];
}

- (NSString *) sha1ByResolvingSymbolicRef:(GITRef *)symRef
{
    GITRef *targetRef = [cachedRefs objectForKey:[symRef linkName]];
    if ( [targetRef isLink] )
        return [self sha1ByResolvingSymbolicRef:targetRef];
    return [[[targetRef sha1] copy] autorelease];
}

- (void) resolveSymbolicRefs
{
    while ([symbolicRefs count] > 0) {
        GITRef *symRef = [[symbolicRefs lastObject] retain];
        NSString *sha1 = [self sha1ByResolvingSymbolicRef:symRef];
        NSAssert(isSha1StringValid(sha1), @"linked ref has invalid sha1");
        [symRef setSha1:sha1];
        [symbolicRefs removeLastObject];
    }
}

- (NSDictionary *) cachedRefs
{
    [self fetchRefs];
    return cachedRefs;
}

- (void) fetchRefs
{
    if ( !fetchedLoose )
        [self fetchLooseRefs];
    if ( !fetchedPacked )
        [self fetchPackedRefs];
    [self resolveSymbolicRefs];
}

- (void) fetchLooseRefs
{
    NSString *thisRef;
    NSFileManager *fm =  [NSFileManager defaultManager];
    NSEnumerator *e = [fm enumeratorAtPath:[self refsDir]];
    while ( (thisRef = [e nextObject]) ) {
        NSString *tempRef = [[self refsDir] stringByAppendingPathComponent:thisRef];
        BOOL isDir;
        if ( [fm fileExistsAtPath:tempRef isDirectory:&isDir] && !isDir ) {
            // TODO: extract name, lookup in cache
            NSString *refName = [NSString stringWithFormat:@"refs/%@", thisRef];
            if ( ![cachedRefs objectForKey:refName] ) {
                id theRef = [GITRef refWithContentsOfFile:tempRef];
                [cachedRefs setObject:theRef forKey:refName];
                if ( [theRef isLink] )
                    [symbolicRefs addObject:theRef];
            }
        }
    }
    fetchedLoose = YES;
}

- (void) fetchPackedRefs
{
    if ( ![self packFile] )
        return;
    if ( ![[NSFileManager defaultManager] fileExistsAtPath:[self packFile]] )
        return;    
    
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    NSString *packedRefs = [[NSString alloc]
                            initWithContentsOfFile:[self packFile]
                                          encoding:NSASCIIStringEncoding 
                                             error:NULL];
    NSArray *packedRefLines = [packedRefs componentsSeparatedByCharactersInSet:
                               [NSCharacterSet newlineCharacterSet]];
    for (NSString *line in packedRefLines) {
        if ([line length] < 1 || [line hasPrefix:@"#"] || [line hasPrefix:@"^"])
            continue;
        // line with ref = @"<40-char sha1> <refName>"
        NSString *thisSha = [line substringWithRange:NSMakeRange(0,40)];
        NSString *thisRef = [line substringFromIndex:41];
        if ( ![cachedRefs objectForKey:thisRef] ) {
            id theRef = [GITRef refWithName:thisRef sha1:thisSha packed:YES];
            [cachedRefs setObject:theRef forKey:thisRef];
            if ( [theRef isLink] )
                [symbolicRefs addObject:theRef];
        }
    }
    [packedRefs release];
    [pool release];
    fetchedPacked = YES;
}
@end