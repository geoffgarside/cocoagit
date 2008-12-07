//
//  GITFileStore.m
//  CocoaGit
//
//  Created by Geoffrey Garside on 07/10/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import "GITFileStore.h"
#import "NSData+Compression.h"
#import "GITObject.h"

/*! \cond */
@interface GITFileStore ()
@property(readwrite,copy) NSString * objectsDir;
@end
/*! \endcond */

@implementation GITFileStore
@synthesize objectsDir;

- (id)initWithRoot:(NSString*)root
{
    if (self = [super init])
    {
        self.objectsDir = [root stringByAppendingPathComponent:@"objects"];
    }
    return self;
}
- (NSString*)stringWithPathToObject:(NSString*)sha1
{
    NSString * ref = [NSString stringWithFormat:@"%@/%@",
                      [sha1 substringToIndex:2], [sha1 substringFromIndex:2]];
    
    return [self.objectsDir stringByAppendingPathComponent:ref];
}
- (NSData*)dataWithContentsOfObject:(NSString*)sha1
{
    NSFileManager * fm = [NSFileManager defaultManager];
    NSString * path = [self stringWithPathToObject:sha1];

    if ([fm isReadableFileAtPath:path])
    {
        NSData * zlibData = [NSData dataWithContentsOfFile:path];
        return [zlibData zlibInflate];
    }

    return nil;
}
- (BOOL)loadObjectWithSha1:(NSString*)sha1 intoData:(NSData**)data
                      type:(GITObjectType*)type error:(NSError**)error
{
    NSUInteger errorCode = 0;
    NSString * errorDescription = nil;
    NSDictionary * errorUserInfo = nil;

    NSFileManager * fm = [NSFileManager defaultManager];
    NSString * path = [self stringWithPathToObject:sha1];

    if ([fm isReadableFileAtPath:path])
    {
        NSData * zlibData = [NSData dataWithContentsOfFile:path];
        NSData * raw = [zlibData zlibInflate];

        NSRange range = [raw rangeOfNullTerminatedBytesFrom:0];
        NSData * meta = [raw subdataWithRange:range];
        *data = [raw subdataFromIndex:range.length + 1];

        NSString * metaStr = [[NSString alloc] initWithData:meta
                                                   encoding:NSASCIIStringEncoding];
        NSUInteger indexOfSpace = [metaStr rangeOfString:@" "].location;
        NSInteger size = [[metaStr substringFromIndex:indexOfSpace + 1] integerValue];

        // This needs to be a GITObjectType value instead of a string
        NSString * typeStr = [metaStr substringToIndex:indexOfSpace];
        *type = [GITObject objectTypeForString:typeStr];

        if (*data && *type && size == [*data length])
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
        *error = [NSError errorWithDomain:GITErrorDomain code:errorCode userInfo:errorUserInfo];
    }

    return NO;
}
@end
