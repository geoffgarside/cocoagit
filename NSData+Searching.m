//
//  NSData+Searching.m
//  CocoaGit
//
//  Created by Geoffrey Garside on 17/07/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import "NSData+Searching.h"

@implementation NSData (Searching)

- (NSRange)rangeOfNullTerminatedBytesFrom:(NSInteger)start
{
	const Byte *pdata = [self bytes];
	NSUInteger len = [self length];
	if (start < len)
	{
		const Byte *end = memchr (pdata + start, 0x00, len - start);
		if (end != NULL) return NSMakeRange (start, end - (pdata + start));
	}
	return NSMakeRange (NSNotFound, 0);
}

- (NSData*)subdataFromIndex:(NSUInteger)anIndex
{
    NSRange theRange = NSMakeRange(anIndex, [self length] - anIndex);
    return [self subdataWithRange:theRange];
}
- (NSData*)subdataToIndex:(NSUInteger)anIndex
{
    NSRange theRange = NSMakeRange(0, anIndex);
    return [self subdataWithRange:theRange];
}

@end
