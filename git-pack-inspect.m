#import <Foundation/Foundation.h>

void p(NSString * str);

int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    NSProcessInfo * info = [NSProcessInfo processInfo];
    NSArray * args = [info arguments];
    
    if ([args count] != 2) {
        p([NSString stringWithFormat:@"Usage: %@ path/to/pack-hash.pack", [info processName]]);
        exit(0);
    }
    
    NSString * packPath = [args objectAtIndex:1];
    NSString * idxPath = [[packPath stringByDeletingPathExtension] stringByAppendingPathExtension:@"idx"];
    
    NSLog(@"packPath: %@", packPath);
    NSLog(@"idxPath: %@", idxPath);
    
    [pool drain];
    return 0;
}

void p(NSString * str)
{
    printf([str UTF8String]);
    printf("\n");
}
