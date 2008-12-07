//
//  GITPlaceholderPackIndex.m
//  CocoaGit
//
//  Created by Geoffrey Garside on 04/11/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import "GITPlaceholderPackIndex.h"
#import "GITUtilityBelt.h"
#import "GITErrors.h"

static const char const kGITPackIndexMagicNumber[] = { '\377', 't', 'O', 'c' };

@implementation GITPlaceholderPackIndex
- (id)initWithPath:(NSString*)thePath error:(NSError**)outError
{
    uint8_t buf[4];
    NSError * err;
    NSUInteger ver;
    NSString * description;
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSZone * z = [self zone]; [self release];

    if ([fileManager isReadableFileAtPath:thePath])
    {
        NSData * data = [NSData dataWithContentsOfFile:thePath
                                               options:NSUncachedRead
                                                 error:&err];
        if (!data) // Another type of error occurred
        {
            if (outError != nil)
                *outError = err;
            return nil;
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
                    return [[GITPackIndexVersion2 allocWithZone:z] initWithPath:thePath error:outError];
                default:
                    if (outError != NULL)
                    {
                        description = [NSString stringWithFormat:NSLocalizedString(@"Pack Index version %lu is not supported",
                                                                                   @"GITErrorPackIndexUnsupportedVersion"), ver];
                        NSDictionary * eInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                                description, NSLocalizedDescriptionKey,
                                                thePath, NSFilePathErrorKey, nil];
                        *outError = [NSError errorWithDomain:GITErrorDomain
                                                        code:GITErrorPackIndexUnsupportedVersion
                                                    userInfo:eInfo];
                    }
                    return nil;
            }
        }
        else
            return [[GITPackIndexVersion1 allocWithZone:z] initWithPath:thePath error:outError];
    }
    else
    {
        if (outError != NULL)
        {
            description = [NSString stringWithFormat:NSLocalizedString(@"File %@ not found",
                                                                       @"GITErrorFileNotFound (GITPackIndex)"), thePath];
            NSDictionary * eInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                    description, NSLocalizedDescriptionKey,
                                    thePath, NSFilePathErrorKey, nil];
            *outError = [NSError errorWithDomain:GITErrorDomain
                                            code:GITErrorFileReadFailure
                                        userInfo:eInfo];
        }

        return nil;
    }
}
@end
