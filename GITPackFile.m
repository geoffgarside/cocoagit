//
//  GITPackFile.m
//  CocoaGit
//
//  Created by Geoffrey Garside on 05/08/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import "GITPackFile.h"
#import "GITUtilityBelt.h"

//            Name of Range                 Start   Length
const NSRange kGITPackFileSignatureRange = {     0,      4 };
const NSRange kGITPackFileVersionRange   = {     4,      4 };
const NSRange kGITPackFileNumberRange    = {     8,      4 };

const NSUInteger kGITPackIndexFanOutSize  = 4;          //!< bytes
const NSUInteger kGITPackIndexFanOutCount = 256;
const NSUInteger kGITPackIndexFanOutEnd   = 4 * 256;    //!< Update when either of the two above change
const NSUInteger kGITPackIndexEntrySize   = 24;         //!< bytes

const NSUInteger kGITPackFileTypeCommit   = 1;
const NSUInteger kGITPackFileTypeTree     = 2;
const NSUInteger kGITPackFileTypeBlob     = 3;
const NSUInteger kGITPackFileTypeTag      = 4;

/*! \cond
 Make properties readwrite so we can use
 them within the class.
*/
@interface GITPackFile ()
@property(readwrite,copy)   NSData * idxData;
@property(readwrite,copy)   NSData * packData;
@property(readwrite,copy)   NSString * idxPath;
@property(readwrite,copy)   NSString * packPath;
@property(readwrite,copy)   NSArray  * idxOffsets;
@property(readwrite,assign) NSUInteger idxVersion;
@property(readwrite,assign) NSUInteger packVersion;
@property(readwrite,assign) NSUInteger numberOfObjects;
@end
/*! \endcond */

@implementation GITPackFile
@synthesize idxData;
@synthesize idxPath;
@synthesize packData;
@synthesize packPath;
@synthesize idxOffsets;
@synthesize idxVersion;
@synthesize packVersion;
@synthesize numberOfObjects;

- (id)initWithPath:(NSString*)path
{
    if (self = [super init])
    {
        self.idxPath = path;
        self.packPath = path;

        [self openIdxAndPackFiles];
    }
    return self;
}
- (void)setPackPath:(NSString*)thePath
{
    if (thePath != packPath)
    {
        [packPath release];
        packPath = [[thePath stringByDeletingPathExtension] 
            stringByAppendingPathExtension:@"pack"];
    }
}
- (void)setIdxPath:(NSString*)thePath
{
    if (thePath != idxPath)
    {
        [idxPath release];
        idxPath = [[thePath stringByDeletingPathExtension] 
            stringByAppendingPathExtension:@"idx"];
    }
}
- (void)openIdxAndPackFiles
{
    NSError * err;
    self.packData = [NSData dataWithContentsOfFile:self.packPath
                                           options:NSUncachedRead
                                             error:&err];
    if (!self.packData)
    {
        NSString * reason = [NSString stringWithFormat:@"Pack File %@ failed to open", self.packPath];
        NSException * ex  = [NSException exceptionWithName:@"GITPackFileOpeningFailed"
                                                    reason:reason
                                                  userInfo:[err userInfo]];
        @throw ex;
    }
    
    self.idxData  = [NSData dataWithContentsOfFile:self.idxPath
                                           options:NSUncachedRead
                                             error:&err];
    if (!self.idxData)
    {
        NSString * reason = [NSString stringWithFormat:@"Pack Idx File %@ failed to open", self.idxPath];
        NSException * ex  = [NSException exceptionWithName:@"GITPackFileIdxOpeningFailed"
                                                    reason:reason
                                                  userInfo:[err userInfo]];
        @throw ex;
    }
}
- (void)readPack
{
    unichar buf[4];
    [self.packData getBytes:buf range:kGITPackFileSignatureRange];
    if ([[NSString stringWithCharacters:buf length:4] isEqualToString:@"PACK"])
    {   // Its a valid PACK file, continue
        [self.packData getBytes:buf range:kGITPackFileVersionRange];
        self.packVersion = integerFromBytes(buf, 4);
    }
}
- (NSData*)objectAtOffset:(NSUInteger)offset
{
    NSString * reason;
    NSException *  ex;
    switch (self.packVersion)
    {
        case 1:
            return [self objectAtOffsetVersion1:offset];
            break;
        case 2:
            return [self objectAtOffsetVersion2:offset];
            break;
        default:
            reason = [NSString stringWithFormat:@"PACK v%ld format not supported", self.packVersion];
            ex     = [NSException exceptionWithName:@"GITUnknownPackVersion" reason:reason userInfo:nil];
            @throw ex;
    }
    return nil;     // FAIL
}
- (NSData*)objectAtOffsetVersion1:(NSUInteger)offset
{
    return nil;
}
- (NSData*)objectAtOffsetVersion2:(NSUInteger)offset
{
    unichar buf;    // a single byte buffer
    NSUInteger size, type, shift = 4;

    // NOTE: ++ should increment offset after the range has been created
    [self.packData getBytes:&buf range:NSMakeRange(offset++, 1)];

    size = buf & 0xf;
    type = (buf >> 4) & 0x7;

    while (buf & 0x80 != 0)
    {
        // NOTE: ++ should increment offset after the range has been created
        [self.packData getBytes:&buf range:NSMakeRange(offset++, 1)];
        size |= ((buf & 0x7f) << shift);
        shift += 7;
    }

    return nil; // Method not finished yet
}
- (void)readIdx
{
    unichar buf[4];
    NSUInteger i, lastCount, thisCount;
    NSMutableArray * offsets = [NSMutableArray arrayWithCapacity:256];

    lastCount = thisCount = 0;

    // The Fanout table
    // The fanout table consists of 256 entries. These
    // entries correspond to the first byte of an object
    // sha1. The value at each entry is the number of
    // object sha1's in the corresponding PACK file
    // in which the first byte is less than or equal
    // to the entry index. This also applies to the
    // list of SHA1 entries in the IDX file as well.
    // The value of each entry should be greater than
    // or equal to the previous value, if it is not 
    // then the index file is corrupt.
    // At the moment I am not sure if the fan out
    // entry index corresponds to the compressed or
    // uncompressed SHA1 hash value.
    for (i = 0; i < kGITPackIndexFanOutCount; i++)
    {
        [self.idxData getBytes:buf range:NSMakeRange(i * kGITPackIndexFanOutSize, kGITPackIndexFanOutSize)];
        thisCount = integerFromBytes(buf, kGITPackIndexFanOutSize);

        // Assuming an NSUInteger is less expensive than calling
        // [[idxOffsets objectAtIndex:i - 1] unsignedIntegerValue]
        if (lastCount > thisCount)
        {
            NSString * reason = [NSString stringWithFormat:@"IDX %@ is corrupt", [self.idxPath lastPathComponent]];
            NSException * ex  = [NSException exceptionWithName:@"GITPackFileCorruptIndexException"
                                                        reason:reason
                                                      userInfo:nil];
            @throw ex;
        }

        [offsets addObject:[NSNumber numberWithUnsignedInteger:thisCount]];
        lastCount = thisCount;
    }

    self.numberOfObjects = thisCount;   // The value of the last offset
    self.idxOffsets = offsets;
}
- (NSData*)dataForSha1:(NSString*)sha1
{
    NSUInteger offset = [self offsetForSha1:sha1];

    return nil; // Method not finished yet
}
- (NSUInteger)offsetForSha1:(NSString*)sha1
{
    unichar firstByte = [sha1 characterAtIndex:0];
    NSUInteger thisFanout, prevFanout = 0;
    
    // prevFanout = number of objects with firstByte less than that of sha1
    // thisFanout = number of objects with firstByte less than or equal to that of sha1
    // fanoutDiff = number of objects with firstByte equal to that of sha1
    thisFanout = [[self.idxOffsets objectAtIndex:firstByte] unsignedIntegerValue];
    if (firstByte != 0x0)
        prevFanout = [[self.idxOffsets objectAtIndex:firstByte - 1] unsignedIntegerValue];

    // There are entries to examine
    if (thisFanout > prevFanout)
    {
        NSUInteger i;
        unichar buf[20];

        NSUInteger startLocation = kGITPackIndexFanOutEnd +
            (kGITPackIndexEntrySize * prevFanout);
        NSUInteger endLocation   = kGITPackIndexFanOutEnd +
            (kGITPackIndexEntrySize * thisFanout);
        
        for (i = startLocation; i < endLocation; i += kGITPackIndexEntrySize)
        {
            memset(buf, 0x0, 20);
            [self.idxData getBytes:buf range:NSMakeRange(i, 4)];
            NSUInteger offset = integerFromBytes(buf, 4);

            memset(buf, 0x0, 20);
            [self.idxData getBytes:buf range:NSMakeRange(i + 4, 20)];
            NSString * packedSha1 = [NSString stringWithCharacters:buf length:20];
            NSString * name = unpackSHA1FromString(packedSha1);

            if ([name isEqualToString:sha1])
                return offset;
        }
    }

    // If its found the SHA1 then it will have returned by now.
    // Otherwise the SHA1 is not in this PACK file, so we should
    // raise an error.
    NSString * reason = [NSString stringWithFormat:@"SHA1 %@ is not known in this PACK %@",
                         sha1, [self.idxPath lastPathComponent]];
    NSException * ex  = [NSException exceptionWithName:@"GITPackFileUnknownSHA1"
                                                reason:reason
                                              userInfo:nil];
    @throw ex;
}

@end
