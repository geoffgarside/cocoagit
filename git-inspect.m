#import <Foundation/Foundation.h>
#import "NSData+Compression.h"
#import "NSData+Hashing.h"
#import "GITObject.h"

NSString * open_hash_file(NSString * objectHash);

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
        NSString *commitMsg  = [commit substringFromIndex:endOfCommitInfo.location + endOfCommitInfo.length];
        NSLog(@"Commit info:\n%@", commitInfo);
        NSLog(@"Commit msg:\n%@", commitMsg);
    }
    else if ([objectType isEqualToString:@"tag"])
    {
        NSLog(@"GITTag, textual content");
    }
    else if ([objectType isEqualToString:@"tree"])
    {
        NSLog(@"GITTree, textual content (binary packed sha1 references)");
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
