#import <Foundation/Foundation.h>
#import "GITPackFile.h"
#import "GITPackIndex.h"

void p(NSString * str);

// Silence warnings
@interface GITPackFile ()
- (GITPackIndex*)idx;
- (NSString*)path;
@end
@interface GITPackIndex ()
- (NSString*)path;
@end

int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    NSProcessInfo * info = [NSProcessInfo processInfo];
    NSArray * args = [info arguments];
    
    if ([args count] != 3) {
        p([NSString stringWithFormat:@"Usage: %@ path/to/pack-hash.pack sha1", [info processName]]);
        exit(0);
    }
    
    GITPackFile * pack = [[GITPackFile alloc] initWithPath:[args objectAtIndex:1]];
    GITPackIndex * idx = [pack idx];
    
    NSLog(@"packPath: %@", [pack path]);
    NSLog(@"idxPath: %@", [idx path]);
    
    // Obtain the PACK version
    NSLog(@"Pack Version: %lu", [pack version]);
    NSLog(@"Index Version: %lu", [idx version]);
    
    NSUInteger i = 0;
    for (NSNumber * offset in [idx offsets])
    {
        NSLog(@"%lu: %lu", i++, [offset unsignedIntegerValue]);
    }

    NSLog(@"Number of objects in index: %lu", [idx numberOfObjects]);
    NSLog(@"Offset for '%@': %lu", [args objectAtIndex:2], [idx packOffsetForSha1:[args objectAtIndex:2]]);

    [pool drain];
    return 0;
}

void p(NSString * str)
{
    printf([str UTF8String]);
    printf("\n");
}
