#import <Foundation/Foundation.h>
#import "GITRepo.h"

void pp(NSString *fmt, ...);
void printObject(GITObject * object);

int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    NSProcessInfo * info = [NSProcessInfo processInfo];
    NSArray * args = [info arguments];
    
    if ([args count] != 2) {
        pp(@"Usage: %@ sha1hash", [info processName]);
        exit(0);
    }

    NSError * error;
    GITRepo * repo = [[GITRepo alloc] initWithRoot:@"." error:&error];
    if (!repo) {
        pp(@"Error loading Repo: %@", [error localizedDescription]);
        return [error code];
    }

    NSString *sha1 = [args objectAtIndex:1];
    GITObject * object = [repo objectWithSha1:sha1 error:&error];

    if (!object)
    {
        pp(@"Error: %@", [error localizedDescription]);
        return [error code];
    }
    else
    {
        printObject(object);
    }
    
    [pool drain];
    return 0;
}
void printObject(GITObject * object)
{
    if ([object isKindOfClass:[GITBlob class]])
    {
        GITBlob * blob = (GITBlob*)object;
        pp(@"Blob (%lu)", blob.size);
        if ([blob canBeRepresentedAsString])
        {
            pp([blob stringValue]);
        }
        else
        {
            pp([[blob data] description]);
        }
    }
    else if ([object isKindOfClass:[GITCommit class]])
    {
        GITCommit * commit = (GITCommit*)object;
        pp(@"Commit (%lu)", commit.size);
        pp(@"Tree\t\t%@", commit.treeSha1);
        pp(@"Parent\t\t%@", commit.parentSha1);
        pp(@"Author\t\t%@\t%@", commit.author, commit.authored);
        pp(@"Committer\t%@\t%@", commit.committer, commit.committed);
        pp(@"Message\n%@", commit.message);
    }
    else if ([object isKindOfClass:[GITTag class]])
    {
        GITTag * tag = (GITTag*)object;
        pp(@"Tag (%lu)", tag.size);
        pp(@"Commit\t\t%@", tag.objectSha1);
        pp(@"Name\t\t%@", tag.name);
        pp(@"Tagger\t\t%@\t%@", tag.tagger, tag.tagged);
        pp(@"Message\n%@", tag.message);
    }
    else if ([object isKindOfClass:[GITTree class]])
    {
        GITTree * tree = (GITTree*)object;
        pp(@"Tree (%lu)", tree.size);
        pp(@"Mode\tSHA1\t\t\t\t\t\tName");
        for (GITTreeEntry * entry in tree.entries)
        {
            pp(@"%lu\t%@\t%@", entry.mode, entry.sha1, entry.name);
        }
    }
    else
    {
        pp(@"Unknown git object type");
    }
}
void pp(NSString *fmt, ...)
{
	va_list ap;
	va_start(ap, fmt);
    
	NSString *output = [[NSString alloc] initWithFormat:fmt arguments:ap];
	printf([output UTF8String]);
	printf("\n");
	[output release];

	va_end(ap);
}
