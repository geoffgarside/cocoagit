#import <Foundation/Foundation.h>
#import "NSData+Compression.h"
#import "NSData+Hashing.h"
#import "GITObject.h"

int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    if (argc != 2) {
        NSLog(@"Usage: %s sha1hash", argv[0]);
        exit(0);
    }
    
    NSString *inspectHash = [NSString stringWithCString:argv[1]];
    NSString *filePath = [GITObject objectPathFromHash:inspectHash];
    
    NSData *data = [[NSData dataWithContentsOfFile:filePath] zlibInflate];
    
    NSString *content = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    [content autorelease];
    
    unsigned int endOfMetaData = [content rangeOfString:@"\0"].location;
    NSString *metaData = [content substringToIndex:endOfMetaData];
    
    NSLog(@"Meta Data: %@", metaData);
    NSString *objectType = [metaData substringToIndex:[metaData rangeOfString:@" "].location];
    NSLog(@"Object Type: %@", objectType);
    
    [pool drain];
    return 0;
}
