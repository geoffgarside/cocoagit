//
//  GITRef.m
//  CocoaGit
//
//  Created by Brian Chapados on 2/10/09.
//  Copyright 2009 Brian Chapados. All rights reserved.
//

#import "GITRef.h"
#import "GITUtilityBelt.h"
#import "NSFileManager+DirHelper.h"

@implementation GITRef
@synthesize name;
@synthesize sha1;

- (id) init { return [self initWithName:nil sha1:nil]; }

// designated initializer
- (id) initWithName:(NSString *)refName sha1:(NSString *)sha1String;
{
    if (! [super init])
        return nil;
    [self setName:refName];
    [self setSha1:sha1String];
    return self;
}

- (void) dealloc;
{
    [name release], name = nil;
    [sha1 release], sha1 = nil;
    [super dealloc];
}

+ (NSString *) prefix
{
    NSString *klassName = NSStringFromClass([self class]);
    return [NSString stringWithFormat:@"refs/%@s", [[klassName substringFromIndex:3] lowercaseString]];
}

// convenience initializers - return autoreleased objects
+ (id) refWithName:(NSString *)refName sha1:(NSString *)sha1String;
{
    return [[[self alloc] initWithName:refName sha1:sha1String] autorelease];
}

+ (id) refWithContentsOfFile:(NSString *)aPath;
{
    NSString *contents = [NSString stringWithContentsOfFile:aPath];
    if (! contents)
        return nil;
    
    NSString *trimmed = [contents stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    if ( [trimmed hasPrefix:@"ref: "] ) {
        NSRange pathRange = [aPath rangeOfString:@"/refs/"];
        NSString *pathPrefix = [aPath substringToIndex:pathRange.location];
        NSString *refLink = [pathPrefix stringByAppendingFormat:@"/%@", [trimmed substringFromIndex:5]];
        NSLog(@"trimmed = %@\nrefLink for %@ = %@", trimmed, aPath, refLink);
        return [self refWithContentsOfFile:refLink];
    }
    
    NSRange prefixRange = [aPath rangeOfString:[self prefix]];
    NSString *refName = [aPath substringFromIndex:
                         (prefixRange.location + prefixRange.length + 1)]; // +1 removes the starting '/'
    
    // Not sure what this case should be, maybe a "ref: <ref>" - ref to a ref
    // just die immediately so we can debug
    NSString *exception = [NSString stringWithFormat:
                           @"GITRef#refWithContentsOfFile: invalid sha1\n"
                           @"path=%@\nname=%@\nsha1=%@\n", aPath, refName, trimmed];
    //NSAssert(isSha1StringValid(trimmed), @"GITRef#refWithContentsOfFile: invalid sha1");
    NSAssert(isSha1StringValid(trimmed), exception);

    return [[[self alloc] initWithName:refName sha1:trimmed] autorelease];
}

+ (id) refWithPacketLine:(NSString *)packetLine;
{
    NSString *refName, *refSha1;
    NSScanner *scanner = [NSScanner scannerWithString:packetLine];
    [scanner scanUpToString:@" " intoString:&refSha1];
    [scanner scanUpToString:@"\n" intoString:&refName];
    
    if (! (refName && refSha1))
        return nil;
    
    return [[[self alloc] initWithName:refName sha1:refSha1] autorelease];
}

- (GITCommit *) commitWithRepo:(GITRepo *)repo;
{
    return [repo commitWithSha1:[self sha1] error:NULL];
}

+ (id) looseRefWithName:(NSString *)refName repo:(GITRepo *)repo;
{
    NSString *refPath = [[repo root] stringByAppendingFormat:@"%@/%@", [self prefix], refName];
    if ( ![[NSFileManager defaultManager] fileExistsAtPath:refPath] )
        return nil;
    return [self refWithContentsOfFile:refPath];
}

+ (NSArray *) findAllInRepo:(GITRepo *)repo;
{
	NSMutableArray *refs = [NSMutableArray array];
	NSString *tempRef, *thisSha, *thisRef;
    
    NSString *refPrefix = [self prefix];
	NSString *refsPath = [[repo root] stringByAppendingPathComponent:refPrefix];
	id theRef;
    
	NSFileManager *fm = [NSFileManager defaultManager];
	BOOL isDir;
    if ([fm fileExistsAtPath:refsPath isDirectory:&isDir] && isDir) {
		NSEnumerator *e = [fm enumeratorAtPath:refsPath];
		while ( (thisRef = [e nextObject]) ) {
			tempRef = [refsPath stringByAppendingPathComponent:thisRef];
			//thisRef = [refPrefix stringByAppendingPathComponent:thisRef];
			BOOL isDir;
			if ([fm fileExistsAtPath:tempRef isDirectory:&isDir] && !isDir) {
                theRef = [self looseRefWithName:thisRef repo:repo];
                if ( ![refs containsObject:theRef] )
                    [refs addObject:theRef];
			}
		}
	}
    
    NSString *searchPrefix = refPrefix;
    NSString *packedRefsPath = [repo packedRefsPath];
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
            if ( ![thisRef hasPrefix:searchPrefix] )
                continue;
            NSString *refName = [thisRef stringByReplacingOccurrencesOfString:searchPrefix withString:@""];
            theRef = [self refWithName:refName sha1:thisSha];
            if ( ![refs containsObject:theRef] )
                [refs addObject:theRef];
        }
        [packedRefs release];
    }
	return [NSArray arrayWithArray:refs];
}

@end