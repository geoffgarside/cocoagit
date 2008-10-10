#import <Foundation/Foundation.h>
#import "GITRepo+Protected.h"
#import "GITBlob.h"
#import "GITTree.h"
#import "GITCommit.h"
#import "GITTag.h"
#import "GITTreeEntry.h"

void p(NSString * str);

int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    if (argc != 2) {
        p([NSString stringWithFormat:@"Usage: %s sha1hash", argv[0]]);
        exit(0);
    }
    
    GITRepo * repo = [[GITRepo alloc] initWithRoot:@"."];
    
    NSString *inspectHash = [NSString stringWithCString:argv[1]];
    id object  = [[repo objectWithHash:inspectHash] autorelease];
    
    if ([object isKindOfClass:[GITBlob class]])
    {
        GITBlob * blob = (GITBlob*)object;
        p([NSString stringWithFormat:@"Blob (%lu)", blob.size]);
        if ([blob canBeRepresentedAsString])
        {
            p([blob stringValue]);
        }
        else
        {
            p([[blob data] description]);
        }
    }
    else if ([object isKindOfClass:[GITCommit class]])
    {
        GITCommit * commit = (GITCommit*)object;
        p([NSString stringWithFormat:@"Commit (%lu)", commit.size]);
        p([NSString stringWithFormat:@"Tree\t\t%@", commit.tree.sha1]);
        p([NSString stringWithFormat:@"Parent\t\t%@", commit.parent.sha1]);
        p([NSString stringWithFormat:@"Author\t\t%@\t%@", commit.author, commit.authored]);
        p([NSString stringWithFormat:@"Committer\t%@\t%@", commit.committer, commit.committed]);
        p([NSString stringWithFormat:@"Message\n%@", commit.message]);
    }
    else if ([object isKindOfClass:[GITTag class]])
    {
        GITTag * tag = (GITTag*)object;
        p([NSString stringWithFormat:@"Tag (%lu)", tag.size]);
        p([NSString stringWithFormat:@"Commit\t\t%@", tag.commit.sha1]);
        p([NSString stringWithFormat:@"Name\t\t%@", tag.name]);
        p([NSString stringWithFormat:@"Tagger\t\t%@\t%@", tag.tagger, tag.tagged]);
        p([NSString stringWithFormat:@"Message\n%@", tag.message]);
    }
    else if ([object isKindOfClass:[GITTree class]])
    {
        GITTree * tree = (GITTree*)object;
        p([NSString stringWithFormat:@"Tree (%lu)", tree.size]);
        p(@"Mode\tSHA1\t\t\t\t\t\tName");
        for (GITTreeEntry * entry in tree.entries)
        {
            p([NSString stringWithFormat:@"%lu\t%@\t%@",
               entry.mode, entry.sha1, entry.name]);
        }
    }
    else
    {
        p(@"Unknown git object type");
    }
    
    [pool drain];
    return 0;
}

void p(NSString * str)
{
    printf([str UTF8String]);
    printf("\n");
}
