//
//  GITPlaceholderPackIndex.m
//  CocoaGit
//
//  Created by Geoffrey Garside on 04/11/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import "GITPlaceholderPackIndex.h"
#import "GITUtilityBelt.h"

static const char const kGITPackIndexMagicNumber[] = { '\377', 't', 'O', 'c' };

@implementation GITPlaceholderPackIndex
- (id)initWithPath:(NSString*)thePath
{
    unsigned char buf[4];
    NSError * err;
    NSUInteger ver;
    NSString * reason;
    NSZone * z = [self zone]; [self release];
    NSData * data = [NSData dataWithContentsOfFile:thePath
                                           options:NSUncachedRead
                                             error:&err];
    if (!data)
    {
        reason = [NSString stringWithFormat:@"Pack Idx File %@ failed to open", thePath];
        NSException * ex  = [NSException exceptionWithName:@"GITPackIndexOpeningFailed"
                                                    reason:reason
                                                  userInfo:[err userInfo]];
        @throw ex;
    }

    // File opened successfully, read the first four bytes to see if
    // we are a version 1 index or a later version index.
    [data getBytes:buf range:NSMakeRange(0, 4)];
    if (memcmp(buf, kGITPackIndexMagicNumber, 4) == 0)
    {   // Its a v2+ index file
        memset(buf, 0x0, 4);
        [data getBytes:buf range:NSMakeRange(4, 4)];
        ver = integerFromBytes(buf, 4);

        switch (ver)
        {
            case 2:
                return [[GITPackIndexVersion2 allocWithZone:z] initWithPath:thePath];
            default:
                reason = [NSString stringWithFormat:@"Pack Index version %lu not supported", ver];
                NSException * ex  = [NSException exceptionWithName:@"GITPackIndexVersionUnsupported"
                                                            reason:reason userInfo:nil];
                @throw ex;
        }
    }
    else
        return [[GITPackIndexVersion1 allocWithZone:z] initWithPath:thePath];
}
@end
