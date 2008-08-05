#import <Foundation/Foundation.h>
#import "NSData+Compression.h"
#import "NSData+Hashing.h"
#import "GITObject.h"
#import "GITBlob.h"
#import "NSTimeZone+Offset.h"

NSString * unpack_sha1_from_string(NSString *packedSHA1);

int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    if (argc != 2) {
        NSLog(@"Usage: %s sha1hash", argv[0]);
        exit(0);
    }
    
    NSString *inspectHash = [NSString stringWithCString:argv[1]];
    GITObject *gitObject  = [[GITObject alloc] initWithHash:inspectHash];
    NSData *objectData    = [gitObject dataContentOfObject];
    
    NSString *content = [[NSString alloc] initWithData:objectData
                                              encoding:NSASCIIStringEncoding];
    
    if ([gitObject.type isEqualToString:@"blob"])
    {
        NSLog(@"GITBlob, textual or binary content");
        GITBlob *blob = [[GITBlob alloc] initWithHash:inspectHash];
        
        if ([blob hasEmbeddedNulls])
            NSLog(@"Blob data: %@", [blob data]);
        else
            NSLog(@"Blob text:\n%@", [blob stringValue]);
    }
    else if ([gitObject.type isEqualToString:@"commit"])
    {
        NSRange endOfCommitInfo = [content rangeOfString:@"\n\n"];
        
        NSString *commitInfo = [content substringToIndex:endOfCommitInfo.location];
        NSArray *commitInfoLines = [commitInfo componentsSeparatedByString:@"\n"];
        for (NSString *infoLine in commitInfoLines)
        {
            NSLog(@"Commit info: %@", infoLine);
        }
        
        NSString *commitMsg  = [content substringFromIndex:endOfCommitInfo.location + endOfCommitInfo.length];
        NSLog(@"Commit msg: %@", commitMsg);
    }
    else if ([gitObject.type isEqualToString:@"tag"])
    {
        NSLog(@"GITTag, textual content");
        
        // Need to get :object, :type, :tag, :tagger fields
        // then \n\n and tag message
        NSRange endOfTagInfo = [content rangeOfString:@"\n\n"];
        
        NSString *tagInfo = [content substringToIndex:endOfTagInfo.location];
        NSArray *tagInfoLines = [tagInfo componentsSeparatedByString:@"\n"];
        for (NSString *tagLine in tagInfoLines)
        {
            NSLog(@"Tag Info: %@", tagLine);
        }
        
        NSString *tagMsg = [content substringFromIndex:endOfTagInfo.location + endOfTagInfo.length];
        NSLog(@"Tag Msg: %@", tagMsg);
    }
    else if ([gitObject.type isEqualToString:@"tree"])
    {
        NSLog(@"GITTree, textual content (binary packed sha1 references)");
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
        
        unsigned entryStart = 0;
        
        NSLog(@"\tMode\tName\t\tSHA1");
        
        do {
            NSRange searchRange = NSMakeRange(entryStart, [content length] - entryStart);
            NSRange entryModeRange = [content rangeOfString:@" " options:0 range:searchRange];
            NSRange entrySha1Range = [content rangeOfString:@"\0" options:0 range:searchRange];
            
            NSString * entryMode = [content substringWithRange:NSMakeRange(entryStart, entryModeRange.location - entryStart)];
            NSString * entryName = [content substringWithRange:NSMakeRange(entryModeRange.location + 1, entrySha1Range.location - entryModeRange.location - 1)];
            
            entrySha1Range.location += entrySha1Range.length;   //!< Increment past the found char
            entrySha1Range.length = 20;                         //!< Set length to size of packed sha1
            NSString * entrySha1 = unpack_sha1_from_string([content substringWithRange:entrySha1Range]);
            
            entryStart = entrySha1Range.location + entrySha1Range.length;
            
            NSLog(@"\t%@\t%@\t%@", entryMode, entryName, entrySha1);
        } while(entryStart < [content length]);
    }
    else
    {
        NSLog(@"Unknown git object type");
    }
    
    [pool drain];
    return 0;
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
