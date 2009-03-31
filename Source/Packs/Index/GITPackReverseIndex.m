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
- (NSUInteger) binSearchWithNumber:(NSNumber *)n;
- (NSUInteger) bsIndexOfNumber:(NSNumber *)n;
@end


@implementation NSArray (CFBinarySearch)
/* CFArrayBSearchValues does a binary search, and returns the following:
 * - The index of a value that matched, if the target value matches one or more in the range.
 * - Greater than or equal to the end point of the range, if the value is greater than all the values in the range.
 * - The index of the value greater than the target value, if the value lies between two of (or less than all of) the values in the range. 
 *
 * This is a specific method for doing a binary search in an NSArray filled with NSNumber values that represent object offsets
 * The return value is either:
 * - NSNotFound if n > MaxOffset
 * - The index of the value greater than the target value, if the value lies between two of (or less than all of) the values in the range.
 */
// thanks to quickie from Borkware: http://www.borkware.com/quickies/single?id=372
- (NSUInteger) binSearchWithNumber:(NSNumber *)n;
{
    NSUInteger result = (NSUInteger)CFArrayBSearchValues((CFArrayRef)self, CFRangeMake(0, [self count]), (CFNumberRef)n, (CFComparatorFunction)CFNumberCompare, NULL);
    if (result >= [self count])
        return NSNotFound;
    return result;
}

/* bsIndexOfNumber works exactly like NSArray#indexOfObject:, expect that:
 * - It assumes that the NSArray is composed of NSNumber objects, which are compared them using #isEqual:
 * - It assumes that the array is sorted, and uses a binary search
 *
 * returns index or NSNotFound if 'n' is not in the array
 */
- (NSUInteger) bsIndexOfNumber:(NSNumber *)n;
{
    NSUInteger result = [self binSearchWithNumber:n];
    if (! CFArrayContainsValue((CFArrayRef)self, CFRangeMake(result, 1), n))
        return NSNotFound;
    return result;
}
@end

@interface GITPackReverseIndex ()
@property (nonatomic, assign) GITPackIndex *index;
@property (nonatomic, copy) NSArray *offsets;
@property (nonatomic, copy) NSArray *indexMap;
@property (nonatomic, copy) NSArray *offsets64;
@property (nonatomic, copy) NSArray *indexMap64;
- (BOOL) buildReverseIndex;
@end


@implementation GITPackReverseIndex
@synthesize index;
@synthesize offsets;
@synthesize indexMap;
@synthesize offsets64;
@synthesize indexMap64;

+ (id) reverseIndexWithIndex:(GITPackIndex *)packIndex;
{
    return [[[self alloc] initWithPackIndex:packIndex] autorelease];
}

- (id) initWithPackIndex:(GITPackIndex *) packIndex;
{
    if (! [super init])
        return nil;
    
    [self setIndex:packIndex];
    
    if (! [self buildReverseIndex]) {
        [self release];
        return nil;
    }
    
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
    NSMutableArray *off64 = [NSMutableArray new];
    
    NSUInteger i;
    for(i = 0; i < objectCount; i++) {
        off_t packOffset = [index packOffsetWithIndex:i];
        if (packOffset > UINT32_MAX) {
            [off64 addObject:[NSNumber numberWithUnsignedLongLong:packOffset]];
        } else {
            [off32 addObject:[NSNumber numberWithUnsignedLong:packOffset]];
        }
    }
        
    [self setOffsets:[off32 sortedArrayUsingSelector:@selector(compare:)]];
    [self setOffsets64:[off64 sortedArrayUsingSelector:@selector(compare:)]];

    NSMutableArray *index32 = [off32 mutableCopy];
    for(i = 0; i < [offsets count]; i++) {
        NSUInteger offsetIndex = [offsets bsIndexOfNumber:[off32 objectAtIndex:i]];
        [index32 replaceObjectAtIndex:offsetIndex withObject:[NSNumber numberWithUnsignedInt:i]];
    }
    [self setIndexMap:[NSArray arrayWithArray:index32]];
    [off32 release];
    [index32 release];
    
    NSMutableArray *index64 = [off64 mutableCopy];
    for(i = 0; i < [offsets64 count]; i++) {
        NSUInteger offsetIndex = [offsets64 bsIndexOfNumber:[off64 objectAtIndex:i]];
        [index64 replaceObjectAtIndex:offsetIndex withObject:[NSNumber numberWithUnsignedInt:i]];
    }
    [self setIndexMap64:[NSArray arrayWithArray:index64]];
    [off64 release];
    [index64 release];
    
    //NSLog(@"GITPackReverseIndex -buildReverseIndex: (%d) 32bit offsets, (%d) 64bit offsets)", [offsets count], [offsets64 count]);
        
    [pool release];
    
    return YES;
}

- (NSUInteger) indexWithOffset:(off_t)offset;
{
    NSArray *searchOffsets = offsets;
    NSArray *searchIndexMap = indexMap;
    NSNumber *offsetNumber = [NSNumber numberWithUnsignedLong:offset];
    if (offset > UINT32_MAX) {
        searchOffsets = offsets64;
        searchIndexMap = indexMap64;
        offsetNumber = [NSNumber numberWithUnsignedLongLong:offset];
    }
    NSUInteger i = [searchOffsets bsIndexOfNumber:[NSNumber numberWithUnsignedLong:offset]];
    if (i == NSNotFound)
        return NSNotFound;
    return [[searchIndexMap objectAtIndex:i] unsignedIntValue];
}

// return the next offset after object at offset: thisOffset
//   return NSNotFound if thisOffset isn't found
//   return -1 if thisOffset is the last offset
- (off_t) nextOffsetWithOffset:(off_t)thisOffset;
{
    NSArray *searchOffsets = offsets;
    NSNumber *offsetNumber = [NSNumber numberWithUnsignedLongLong:thisOffset];
    if (thisOffset > UINT32_MAX) {
        searchOffsets = offsets64;
        offsetNumber = [NSNumber numberWithUnsignedLongLong:thisOffset];
    }
    NSUInteger i = [searchOffsets binSearchWithNumber:[NSNumber numberWithUnsignedLong:thisOffset]];
    if (i == NSNotFound)
        return NSNotFound;
    if (i+1 == [searchOffsets count])
        return -1;
    NSNumber *nextOffset = [searchOffsets objectAtIndex:i+1];
    return (off_t)[nextOffset unsignedLongValue];
}

// return the start offset of the object containing for current offset
//  return offsetOfLastObject if 'theOffset' > offsetOfLastObject
//  return offsetOfFirstObject if 'theOffset' < offsetOfFirstObject
// NOTE: these return values are mostly a feature of the binSearchWithNumber
// wrapper around CFArrayBSearchValues
- (off_t) baseOffsetWithOffset:(off_t)theOffset;
{
    NSArray *searchOffsets = offsets;
    NSNumber *offsetNumber = [NSNumber numberWithUnsignedLong:theOffset];
    if (theOffset > UINT32_MAX) {
        offsetNumber = [NSNumber numberWithUnsignedLongLong:theOffset];
        searchOffsets = offsets64;
    }
    NSUInteger i = [searchOffsets binSearchWithNumber:offsetNumber];
    if (i == NSNotFound) {
        i = [searchOffsets count] - 1;
    } else {
        if ( i > 0 ) i--;
    }
    NSNumber *result = [searchOffsets objectAtIndex:i];
    return (off_t)[result unsignedLongValue];
}
@end
