#import <Foundation/Foundation.h>
#import "SSHConnection.h"

int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

    NSError *err = [SSHConnection scpData:[NSData dataWithBytes:"hellyes" length:7] to:[NSURL URLWithString:@"scp://user:password@host/file.txt"]];
    if (err)
        NSLog(@"%@ %@",err,[err userInfo]);
    
    [pool drain];
    return 0;
}
