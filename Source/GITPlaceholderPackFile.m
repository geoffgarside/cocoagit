//
//  GITPlaceholderPackFile.m
//  CocoaGit
//
//  Created by Geoffrey Garside on 04/11/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import "GITPlaceholderPackFile.h"
#import "GITUtilityBelt.h"

static const char const kGITPackFileSignature[] = {'P', 'A', 'C', 'K'};

//            Name of Range                 Start   Length
const NSRange kGITPackFileSignatureRange = {     0,      4 };
const NSRange kGITPackFileVersionRange   = {     4,      4 };

@implementation GITPlaceholderPackFile
- (id)initWithPath:(NSString*)thePath
{
    uint8_t buf[4];
    NSError * err;
    NSUInteger ver;
    NSString * reason;
    NSZone * z = [self zone]; [self release];
    NSData * data = [NSData dataWithContentsOfFile:thePath
                                           options:NSUncachedRead
                                             error:&err];
    if (!data)
    {
        reason = [NSString stringWithFormat:@"Pack File %@ failed to open", thePath];
        NSException * ex  = [NSException exceptionWithName:@"GITPackFileOpeningFailed"
                                                    reason:reason
                                                  userInfo:[err userInfo]];
        @throw ex;
    }
    
    // File opened successfully
    [data getBytes:buf range:kGITPackFileSignatureRange];
    if (memcmp(buf, kGITPackFileSignature, kGITPackFileSignatureRange.length) == 0)
    {   // Its a valid PACK file
        memset(buf, 0x0, kGITPackFileSignatureRange.length);
        [data getBytes:buf range:kGITPackFileVersionRange];
        ver = integerFromBytes(buf, kGITPackFileVersionRange.length);
        
        switch (ver)
        {
            case 2:
                return [[GITPackFileVersion2 allocWithZone:z] initWithPath:thePath];
            //case 3:
            //    return [[GITPackFileVersion3 allocWithZone:z] initWithPath:thePath];
            default:
                reason = [NSString stringWithFormat:@"Pack version %lu not supported", ver];
                NSException * ex  = [NSException exceptionWithName:@"GITPackFileVersionUnsupported"
                                                            reason:reason userInfo:nil];
                @throw ex;
        }
    }
    else
    {
        reason = [NSString stringWithFormat:@"File %@ is not a PACK file", thePath];
        NSException * ex = [NSException exceptionWithName:@"GITPackFileInvalid"
                                                   reason:reason
                                                 userInfo:nil];
        @throw ex;
    }
}
@end
