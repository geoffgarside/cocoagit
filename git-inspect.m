#import <Foundation/Foundation.h>
#import "NSData+Compression.h"
#import "NSData+Hashing.h"
#import "GITObject.h"

NSString * open_hash_file(NSString * objectHash);
NSString * unpack_sha1_from_string(NSString *packedSHA1);

int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    if (argc != 2) {
        NSLog(@"Usage: %s sha1hash", argv[0]);
        exit(0);
    }
    
    NSString *inspectHash = [NSString stringWithCString:argv[1]];
    NSString *content = open_hash_file(inspectHash);
    
    unsigned int endOfMetaData = [content rangeOfString:@"\0"].location;
    NSString *metaData = [content substringToIndex:endOfMetaData];
    
    NSLog(@"Meta Data: %@", metaData);
    NSString *objectType = [metaData substringToIndex:[metaData rangeOfString:@" "].location];
    NSLog(@"Object Type: %@", objectType);
    
    if ([objectType isEqualToString:@"blob"])
    {
        NSLog(@"GITBlob, textual or binary content");
    }
    else if ([objectType isEqualToString:@"commit"])
    {
        NSString *commit = [content substringFromIndex:endOfMetaData + 1];
        NSRange endOfCommitInfo = [commit rangeOfString:@"\n\n"];
        
        NSString *commitInfo = [commit substringToIndex:endOfCommitInfo.location];
        NSArray *commitInfoLines = [commitInfo componentsSeparatedByString:@"\n"];
        for (NSString *infoLine in commitInfoLines)
        {
            NSLog(@"Commit info: %@", infoLine);
        }
        
        NSString *commitMsg  = [commit substringFromIndex:endOfCommitInfo.location + endOfCommitInfo.length];
        NSLog(@"Commit msg: %@", commitMsg);
    }
    else if ([objectType isEqualToString:@"tag"])
    {
        NSLog(@"GITTag, textual content");
    }
    else if ([objectType isEqualToString:@"tree"])
    {
        NSLog(@"GITTree, textual content (binary packed sha1 references)");
        NSString *tree = [content substringFromIndex:endOfMetaData + 1];
        
        //NSMutableArray * entries = [NSMutableArray arrayWithCapacity:2];    //!< Start with a small size as we dont know how many entries there are
        NSRange entrySplit = [tree rangeOfString:@"\0"];
        NSString * modeAndName = [tree substringToIndex:entrySplit.location];
        NSString * packedEntryRef = [tree substringWithRange:NSMakeRange(entrySplit.location + 1, 20)];
        
        NSString * entryRef = unpack_sha1_from_string(packedEntryRef);
        NSLog(@"First entry: modeAndName: %@", modeAndName);
        NSLog(@"First entry: entryRef: %@", entryRef);
    }
    else
    {
        NSLog(@"Unknown git object type");
    }
    
    [pool drain];
    return 0;
}

NSString * open_hash_file(NSString * objectHash)
{
    NSString * filePath = [GITObject objectPathFromHash:objectHash];
    NSData * fileData = [[NSData dataWithContentsOfFile:filePath] zlibInflate];
    
    NSString * content = [[NSString alloc] initWithData:fileData
                                               encoding:NSASCIIStringEncoding];
    [content autorelease];
    
    return [content retain];
}

NSString * unpack_sha1_from_string(NSString *packedSHA1)
{
    static const char hexchars[] = "0123456789abcdef";
    unsigned int bits;
    NSMutableString *unpackedSHA1 = [NSMutableString stringWithCapacity:40];
    for(int i = 0; i < 20; i++)
    {
        bits = [packedSHA1 characterAtIndex:i];
        [unpackedSHA1 appendFormat:@"%c", hexchars[bits >> 4]];
        [unpackedSHA1 appendFormat:@"%c", hexchars[bits & 0xf]];
    }
    return unpackedSHA1;
}
