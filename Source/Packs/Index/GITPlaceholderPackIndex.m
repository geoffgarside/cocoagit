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
    NSString * description,
             * suggestion;
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
                    return [[GITPackIndexVersion2 allocWithZone:z] initWithPath:thePath];
                default:
                    description = NSLocalizedString(@"Pack Index version is not supported", @"");
                    NSArray * errKeys = [NSArray arrayWithObjects:NSLocalizedDescriptionKey,
                                         NSFilePathErrorKey, nil];
                    NSArray * errObjs = [NSArray arrayWithObjects:description, thePath, nil];
                    NSDictionary * eInfo = [NSDictionary dictionaryWithObjects:errObjs forKeys:errKeys];
                    if (outError != NULL)
                        *outError = [[[NSError alloc] initWithDomain:GITErrorDomain
                                                                code:GITPackIndexErrorVersionUnsupported
                                                            userInfo:eInfo] autorelease];
                    return nil;
            }
        }
        else
            return [[GITPackIndexVersion1 allocWithZone:z] initWithPath:thePath];
    }
    else
    {
        description = NSLocalizedString(@"The Pack Index file could not be read", @"");
        suggestion  = NSLocalizedString(@"Check the file exists and that you have permission to read it", @"");
        NSArray * errKeys = [NSArray arrayWithObjects:NSLocalizedDescriptionKey,
                             NSLocalizedRecoverySuggestionErrorKey, NSFilePathErrorKey, nil];
        NSArray * errObjs = [NSArray arrayWithObjects:description, suggestion, thePath, nil];
        NSDictionary * eInfo = [NSDictionary dictionaryWithObjects:errObjs forKeys:errKeys];
        if (outError != NULL)
            *outError = [[[NSError alloc] initWithDomain:GITErrorDomain
                                                    code:GITPackIndexErrorCannotRead
                                                userInfo:eInfo] autorelease];
        return nil;
    }
}
@end
