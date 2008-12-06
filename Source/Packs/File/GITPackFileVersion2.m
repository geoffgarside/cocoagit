//
//  GITPackFileVersion2.m
//  CocoaGit
//
//  Created by Geoffrey Garside on 04/11/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import "GITPackFileVersion2.h"
#import "GITPackIndex.h"
#import "GITUtilityBelt.h"
#import "NSData+Hashing.h"
#import "NSData+Compression.h"

static const NSRange kGITPackFileObjectCountRange = { 8, 4 };

enum {
    // Base Types - These mirror those of GITObjectType
    kGITPackFileTypeCommit = 1,
    kGITPackFileTypeTree   = 2,
    kGITPackFileTypeBlob   = 3,
    kGITPackFileTypeTag    = 4,

    // Delta Types
    kGITPackFileTypeDeltaOfs  = 6,
    kGITPackFileTypeDeltaRefs = 7
};

/*! \cond */
@interface GITPackFileVersion2 ()
@property(readwrite,copy) NSString * path;
@property(readwrite,retain) NSData * data;
@property(readwrite,retain) GITPackIndex * index;
- (NSData*)objectAtOffset:(NSUInteger)offset;
- (NSRange)rangeOfPackedObjects;
- (NSRange)rangeOfChecksum;
- (NSData*)checksum;
- (NSString*)checksumString;
- (BOOL)verifyChecksum;
@end
/*! \endcond */

@implementation GITPackFileVersion2
@synthesize path;
@synthesize data;
@synthesize index;

#pragma mark -
#pragma mark Primitive Methods
- (NSUInteger)version
{
    return 2;
}
- (id)initWithPath:(NSString*)thePath
{
    if (self = [super init])
    {
        NSError * err;
        self.path = thePath;
        self.data = [NSData dataWithContentsOfFile:thePath
                                           options:NSUncachedRead
                                             error:&err];
        NSString * idxPath = [[thePath stringByDeletingPathExtension] 
                              stringByAppendingPathExtension:@"idx"];
        self.index  = [[GITPackIndex alloc] initWithPath:idxPath];
    }
    return self;
}
- (NSUInteger)numberOfObjects
{
    if (!numberOfObjects)
    {
        uint32_t value;
        [self.data getBytes:&value range:kGITPackFileObjectCountRange];
        numberOfObjects = CFSwapInt32BigToHost(value);
    }
    return numberOfObjects;
}
- (NSData*)dataForObjectWithSha1:(NSString*)sha1
{
    // We've defined it this way so if we can determine a better way
    // to test for hasObjectWithSha1 then packOffsetForSha1 > 0
    // then we can simply change the implementation in GITPackIndex.
    if (![self hasObjectWithSha1:sha1]) return nil;

    NSUInteger offset = [self.index packOffsetForSha1:sha1];
    NSData * raw = [self objectAtOffset:offset];
    return [raw zlibInflate];
}
- (BOOL)loadObjectWithSha1:(NSString*)sha1 intoData:(NSData**)objectData
                      type:(GITObjectType*)objectType error:(NSError**)error
{
    NSUInteger errorCode = 0;
    NSString * errorDescription = nil;
    NSDictionary * errorUserInfo = nil;

    uint8_t buf = 0x0;    // a single byte buffer
    NSUInteger size, type, shift = 4;
    NSUInteger offset = [self.index packOffsetForSha1:sha1];

    if (offset > 0)
    {
        [self.data getBytes:&buf range:NSMakeRange(offset++, 1)];
        NSAssert(buf != 0x0, @"buf should not be NULL");

        size = buf & 0xf;
        type = (buf >> 4) & 0x7;

        while ((buf & 0x80) != 0)
        {
            [self.data getBytes:&buf range:NSMakeRange(offset++, 1)];
            NSAssert(buf != 0x0, @"buf should not be NULL");

            size |= ((buf & 0x7f) << shift);
            shift += 7;
        }

        *objectData = nil;    //!< nil out the outgoing data
        switch (type) {
            case kGITPackFileTypeCommit:
                *objectType = type;
                *objectData = [self.data subdataWithRange:NSMakeRange(offset, size)];
                break;
            case kGITPackFileTypeTree:
                *objectType = type;
                *objectData = [self.data subdataWithRange:NSMakeRange(offset, size)];
                break;
            case kGITPackFileTypeTag:
                *objectType = type;
                *objectData = [self.data subdataWithRange:NSMakeRange(offset, size)];
                break;
            case kGITPackFileTypeBlob:
                *objectType = type;
                *objectData = [self.data subdataWithRange:NSMakeRange(offset, size)];
                break;
            case kGITPackFileTypeDeltaOfs:
            case kGITPackFileTypeDeltaRefs:
                NSAssert(NO, @"Cannot handle Delta Object types yet");
                break;
            default:
                NSLog(@"bad object type %d", type);
                break;
        }

        if (*objectData && *objectType && size == [*objectData length])
            return YES;
        else
        {
            errorCode = GITErrorObjectSizeMismatch;
            errorDescription = NSLocalizedString(@"Object size mismatch", @"GITErrorObjectSizeMismatch");
        }
    }
    else
    {
        errorCode = GITErrorObjectNotFound;
        errorDescription = [NSString stringWithFormat:NSLocalizedString(@"Object %@ not found", @"GITErrorObjectNotFound"), sha1];
    }

    if (errorCode != 0 && error != NULL)
    {
        errorUserInfo = [NSDictionary dictionaryWithObject:errorDescription forKey:NSLocalizedDescriptionKey];
        *error = [[[NSError alloc] initWithDomain:GITErrorDomain code:errorCode userInfo:errorUserInfo] autorelease];
    }

    return NO;
}

#pragma mark -
#pragma mark Internal Methods
- (NSData*)objectAtOffset:(NSUInteger)offset
{
    uint8_t buf;    // a single byte buffer
    NSUInteger size, type, shift = 4;
    
    // NOTE: ++ should increment offset after the range has been created
    [self.data getBytes:&buf range:NSMakeRange(offset++, 1)];

    size = buf & 0xf;
    type = (buf >> 4) & 0x7;
    
    while ((buf & 0x80) != 0)
    {
        // NOTE: ++ should increment offset after the range has been created
        [self.data getBytes:&buf range:NSMakeRange(offset++, 1)];
        size |= ((buf & 0x7f) << shift);
        shift += 7;
    }
    
	//NSLog(@"offset: %d size: %d type: %d", offset, size, type);
	
	NSData *objectData = nil;
	switch (type) {
		case kGITPackFileTypeCommit:
		case kGITPackFileTypeTree:
		case kGITPackFileTypeTag:
		case kGITPackFileTypeBlob:
			objectData = [self.data subdataWithRange:NSMakeRange(offset, size)];
			break;
		case kGITPackFileTypeDeltaOfs:
		case kGITPackFileTypeDeltaRefs:
			NSAssert(NO, @"Cannot handle Delta Object types yet");
			break;
		default:
			NSLog(@"bad object type %d", type);
			break;
	}
	
    return objectData; 
}
- (NSRange)rangeOfPackedObjects
{
    return NSMakeRange(12, [self rangeOfChecksum].location - 12);
}
- (NSRange)rangeOfChecksum
{
    return NSMakeRange([self.data length] - 20, 20);
}
- (NSData*)checksum
{
    return [self.data subdataWithRange:[self rangeOfChecksum]];
}
- (NSString*)checksumString
{
    return unpackSHA1FromData([self checksum]);
}
- (BOOL)verifyChecksum
{
    NSData * checkData = [[self.data subdataWithRange:NSMakeRange(0, [self.data length] - 20)] sha1Digest];
    return [checkData isEqualToData:[self checksum]];
}
@end
