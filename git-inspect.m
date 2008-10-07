#import <Foundation/Foundation.h>
#import "GITRepo.h"
#import "GITBlob.h"
#import "GITTree.h"
#import "GITCommit.h"
#import "GITTag.h"

int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    if (argc != 2) {
        NSLog(@"Usage: %s sha1hash", argv[0]);
        exit(0);
    }
    
    GITRepo * repo = [[GITRepo alloc] initWithRoot:@"."];
    
    NSString *inspectHash = [NSString stringWithCString:argv[1]];
    id<GITObject> object  = [repo objectWithHash:inspectHash];
    
    if ([object isKindOfClass:[GITBlob class]])
    {
        NSLog(@"Blob (%lu)", object.size);
        if ([object canBeRepresentedAsString])
        {
            NSLog(@"%@", [object stringValue]);
        }
        else
        {
            NSLog(@"%@", [object data]);
        }
    }
    else if ([object isKindOfClass:[GITCommit class]])
    {
        NSLog(@"Commit (%lu)", object.size);
    }
    else if ([object isKindOfClass:[GITTag class]])
    {
        NSLog(@"Tag (%lu)", object.size);
    }
    else if ([object isKindOfClass:[GITTree class]])
    {
        NSLog(@"Tree (%lu)", object.size);
        NSLog(@"\tMode\tName\t\tSHA1");
    }
    else
    {
        NSLog(@"Unknown git object type");
    }
    
    [pool drain];
    return 0;
}
