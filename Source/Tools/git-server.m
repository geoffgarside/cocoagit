#import <Foundation/Foundation.h>
#import "GITServer.h"

int
main (int argc, const char *argv[]) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSProcessInfo *info = [NSProcessInfo processInfo];
    NSArray *args = [info arguments];

    if ([args count] != 2 ) {
        printf("You have to provide a path\n");
        exit(0);
    }

    NSString *path = [args objectAtIndex: 1];
    GITServer *server = [[GITServer alloc] init];
    [server startListening: path];

    do {
        [[NSRunLoop currentRunLoop] runMode: NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]
        ];
    } while ( ![server shouldExit] );


    [pool drain];
    return 0;
}
