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
    
    [pool drain];
    return 0;
}
