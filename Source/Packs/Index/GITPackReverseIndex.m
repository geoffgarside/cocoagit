//
//  GITPackReverseIndex.m
//  CocoaGit
//
//  Created by Brian Chapados on 2/16/09.
//  Copyright 2009 Brian Chapados. All rights reserved.
//
/*
 Build Arrays for Reverse Index lookups:
 
 1. pack offsets (temporary - don't keep this.  It is accessible through PackFile)
 ------------
 i  offset
 0  500
 1  300
 2  200
 3  600
 4  100
 5  400
   
   |  sort
   v
 
 2. offsets [pack-offsets sorted in order of increasing offset values]
 -------
 j  offset
 0  100
 1  200
 2  300
 3  400
 4  500
 5  600
   
   |  binary search
   v
 
 3. indexMap [map of offset indexes to sorted offset indexes]
 -------------
 j  i
 0  4 
 1  2
 2  1
 3  5
 4  0
 5  3
 
 */

#import "GITPackReverseIndex.h"

@interface NSArray (CFBinarySearch)
- (NSUInteger) bsIndexOfNumber:(NSNumber *)n;
@end


@implementation NSArray (CFBinarySearch)
// thanks to quickie from Borkware: http://www.borkware.com/quickies/single?id=372
- (NSUInteger) binSearchWithNumber:(NSNumber *)n;
{
    return (NSUInteger)CFArrayBSearchValues((CFArrayRef)self, CFRangeMake(0, [self count]), (CFNumberRef)n, (CFComparatorFunction)CFNumberCompare, NULL);
}

- (NSUInteger) bsIndexOfNumber:(NSNumber *)n;
{
    NSUInteger result = [self binSearchWithNumber:n];
    if (! CFArrayContainsValue((CFArrayRef)self, CFRangeMake(result, 1), n))
        return NSNotFound;
    return result;
}
@end


@interface GITPackReverseIndex ()
- (BOOL) buildReverseIndex;
@end


@implementation GITPackReverseIndex
@synthesize index;
@synthesize offsets;
@synthesize indexMap;

/*
+ (id) reverseIndexWithIndex:(GITPackIndex *)packIndex;
{
    return [[[self alloc] initWithIndex:packIndex] autorelease];
}
*/

- (id) initWithPackIndex:(GITPackIndex *) packIndex;
{
    if (! [super init])
        return nil;
    
    [self setIndex:packIndex];
    
    if (! [self buildReverseIndex])
        return nil;
    
    return self;
}

- (void) dealloc;
{
    [offsets release], offsets = nil;
    [indexMap release], indexMap = nil;
    index = nil;
    [super dealloc];
}


- (BOOL) buildReverseIndex;
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    NSUInteger objectCount = [[self index] numberOfObjects];    
    NSMutableArray *off32 = [[NSMutableArray alloc] initWithCapacity:objectCount];
    
    NSUInteger i;    
    for(i = 0; i < objectCount; i++) {
        NSUInteger packOffset = [index packOffsetWithIndex:i];
        [off32 addObject:[NSNumber numberWithUnsignedInt:packOffset]];
    }
        
    NSArray *off32Sorted = [off32 sortedArrayUsingSelector:@selector(compare:)];
    [self setOffsets:off32Sorted];
    
    NSMutableArray *index32 = [[NSMutableArray alloc] initWithCapacity:objectCount];
    for(i = 0; i < objectCount; i++) [index32 addObject:[NSNull null]];
    for(i = 0; i < objectCount; i++) {
        NSUInteger offsetIndex = [offsets bsIndexOfNumber:[off32 objectAtIndex:i]];
        [index32 replaceObjectAtIndex:offsetIndex withObject:[NSNumber numberWithUnsignedInt:i]];
    }
    
    [self setIndexMap:[NSArray arrayWithArray:index32]];
    [off32 release];
    [index32 release];
    [pool release];
    
    return YES;
}

- (NSUInteger) indexWithOffset:(NSUInteger)offset;
{
    NSUInteger i = [offsets bsIndexOfNumber:[NSNumber numberWithUnsignedInt:offset]];
    return [[indexMap objectAtIndex:i] unsignedIntValue];
}

// return the next offset after object at offset: thisOffset
//   return NSNotFound if thisOffset isn't found
//   return -1 if thisOffset is the last offset
- (NSUInteger) nextOffsetWithOffset:(NSUInteger)thisOffset;
{
    NSUInteger i = [offsets bsIndexOfNumber:[NSNumber numberWithUnsignedInt:thisOffset]];
    if (i == NSNotFound)
        return NSNotFound;
    if (i+1 == [offsets count])
        return -1;
    NSNumber *nextOffset = [offsets objectAtIndex:i+1];
    return (NSUInteger)[nextOffset unsignedIntValue];
}

@end
