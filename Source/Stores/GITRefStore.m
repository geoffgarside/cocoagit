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

@implementation GITRefStore
@synthesize refsDir;

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
    cachedRefs = [NSMutableArray new];
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


- (void) fetchLooseRefs;
{}

- (void) fetchPackedRefs;
{}

- (void) invalidateCachedRefs
{
    [cachedRefs release];
    cachedRefs = [NSMutableArray new]
}

- (NSArray *) looseRefsAtPath:(NSString *)refsPath prefix:(NSString *)refPrefix
{
	NSMutableArray *refs = [NSMutableArray array];
	NSString *tempRef, *thisSha, *thisRef;

    NSString *searchPath = [refsPath stringByAppendingPathComponent:refPrefix];
	id theRef;
    
	NSFileManager *fm = [NSFileManager defaultManager];
	BOOL isDir;
    if ( !([fm fileExistsAtPath:searchPath isDirectory:&isDir] && isDir) )
        return nil;

    NSEnumerator *e = [fm enumeratorAtPath:searchPath];
    while ( (thisRef = [e nextObject]) ) {
        tempRef = [searchPath stringByAppendingPathComponent:thisRef];
        //thisRef = [refPrefix stringByAppendingPathComponent:thisRef];
        BOOL isDir;
        if ( [fm fileExistsAtPath:tempRef isDirectory:&isDir] && !isDir ) {
            // TODO: extract name, lookup in cache
            theRef = [GITRef refWithContentsOfFile:tempRef];
            //theRef = [self looseRefWithName:thisRef repo:repo];
            if ( ![refs containsObject:theRef] ) {
                [refs addObject:theRef];
                if ([theRef isLink])
                    [symbolicRefs addObject:theRef];
                if ( ![cachedRefs containsObject:theRef] )
                    [cachedRefs addObject:theRef];
            }
        }
    }
    return [NSArray arrayWithArray:refs];
}

- (NSArray *) packedRefsWithContentsOfFile:(NSString *)packedRefsFile prefix:(NSString *)refPrefix
{
    if ( ![[NSFileManager defaultManager] fileExistsAtPath:packedRefsFile] )
        return nil;
    
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    
    if ( refPrefix && ! [refPrefix hasPrefix:@"refs/"] ) {
        refPrefix = [NSString stringWithFormat:@"refs/%@/", refPrefix];
    }
    
    NSString *packedRefs = [[NSString alloc]
                            initWithContentsOfFile:packedRefsPath
                                          encoding:NSASCIIStringEncoding 
                                             error:NULL];
    NSArray *packedRefLines = [packedRefs componentsSeparatedByCharactersInSet:
                               [NSCharacterSet newlineCharacterSet]];

    NSMutableArray *refs = [[NSMutableArray alloc] initWithCapacity:[packedRefLines count]];
    for (NSString *line in packedRefLines) {
        if ([line length] < 1 || [line hasPrefix:@"#"] || [line hasPrefix:@"^"])
            continue;
        // line = @"<40-char sha1> <refName>"
        NSString *thisSha = [line substringWithRange:NSMakeRange(0,40)];
        NSString *thisRef = [line substringFromIndex:41];
        if ( refPrefix && ![thisRef hasPrefix:refPrefix] ) {
            continue;
        }
        id theRef = [GITRef refWithName:thisRef value:thisSha packed:YES];
        if ( ![refs containsObject:theRef] ) {
            [refs addObject:theRef];
            if ([theRef isLink])
                [symbolicRefs addObject:theRef];
            if ( ![cachedRefs containsObject:theRef] )
                [cachedRefs addObject:theRef];
        }
    }
    [packedRefs release];
    [pool release];
    
    NSArray *refsCopy = [refs copy];
    [refs release];
    return [refsCopy autorelease];
}
@end
