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
        NSString *blob = [content substringFromIndex:endOfMetaData + 1];
        
        // No embedded nulls assume text data.
        if ([blob rangeOfString:@"\0"].location == NSNotFound)
            NSLog(@"Blob Text: %@", blob);
        else
        {
            NSData *blobData = [blob dataUsingEncoding:NSASCIIStringEncoding];
            NSLog(@"Blob Data: %@", blobData);
        }
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
        
        // Need to get :object, :type, :tag, :tagger fields
        // then \n\n and tag message
        
        NSString * tag = [content substringFromIndex:endOfMetaData + 1];
        NSRange endOfTagInfo = [tag rangeOfString:@"\n\n"];
        
        NSString *tagInfo = [tag substringToIndex:endOfTagInfo.location];
        NSArray *tagInfoLines = [tagInfo componentsSeparatedByString:@"\n"];
        for (NSString *tagLine in tagInfoLines)
        {
            NSLog(@"Tag Info: %@", tagLine);
        }
        
        NSString *tagMsg = [tag substringFromIndex:endOfTagInfo.location + endOfTagInfo.length];
        NSLog(@"Tag Msg: %@", tagMsg);
    }
    else if ([objectType isEqualToString:@"tree"])
    {
        NSLog(@"GITTree, textual content (binary packed sha1 references)");
        NSString *tree = [content substringFromIndex:endOfMetaData + 1];
        
        //NSMutableArray * entries = [NSMutableArray arrayWithCapacity:2];    //!< Start with a small size as we dont know how many entries there are
        
        // Algorithm to read tree entries
        // To read each entry we need the following data
        // Index at which the entry starts
        // Index at which the entry sha1 starts
        // Index at which the entry ends (sha1 start + 20)
        //
        // Looping (do,while)
        // Vars
        // NSRange sha1Range = NSMakeRange(sha1Start, sha1Start + 20)
        
        // The point at which the entries all start is after the first \0
        // however in this case that value is already determined as endOfMetaData
        unsigned entryStart = 0;
        
        NSLog(@"\tMode\tName\t\tSHA1");
        
        do {
            NSRange searchRange = NSMakeRange(entryStart, [tree length] - entryStart);
            NSRange entryModeRange = [tree rangeOfString:@" " options:0 range:searchRange];
            NSRange entrySha1Range = [tree rangeOfString:@"\0" options:0 range:searchRange];
            
            NSString * entryMode = [tree substringWithRange:NSMakeRange(entryStart, entryModeRange.location - entryStart)];
            NSString * entryName = [tree substringWithRange:NSMakeRange(entryModeRange.location + 1, entrySha1Range.location - entryModeRange.location - 1)];
            
            entrySha1Range.location += entrySha1Range.length;   //!< Increment past the found char
            entrySha1Range.length = 20;                         //!< Set length to size of packed sha1
            NSString * entrySha1 = unpack_sha1_from_string([tree substringWithRange:entrySha1Range]);
            
            entryStart = entrySha1Range.location + entrySha1Range.length;
            
            NSLog(@"\t%@\t%@\t%@", entryMode, entryName, entrySha1);
        } while(entryStart < [tree length]);
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
