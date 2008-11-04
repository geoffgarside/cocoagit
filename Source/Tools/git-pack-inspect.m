#import <Foundation/Foundation.h>
#import "GITPackFile.h"
#import "GITPackIndex.h"

void p(NSString * str);

int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    NSProcessInfo * info = [NSProcessInfo processInfo];
    NSArray * args = [info arguments];
    
    if ([args count] != 2) {
        p([NSString stringWithFormat:@"Usage: %@ path/to/pack-hash.pack", [info processName]]);
        exit(0);
    }
    
    GITPackFile * pack = [[GITPackFile alloc] initWithPath:[args objectAtIndex:1]];
    GITPackIndex * idx = [[GITPackIndex alloc] initWithPath:[pack idxPath]];
    
    NSLog(@"packPath: %@", pack.packPath);
    NSLog(@"idxPath: %@", pack.idxPath);
    
    // Obtain the PACK version
    NSLog(@"Pack Version: %lu", [pack readVersionFromPack]);
    NSLog(@"Index Version: %lu", [idx version]);
    
    [pool drain];
    return 0;
}

void p(NSString * str)
{
    printf([str UTF8String]);
    printf("\n");
}
