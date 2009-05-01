/*
 *  git-rev-list.m
 *  CocoaGit
 *
 *  Created by chapbr on 4/16/09.
 *  Copyright 2009 Brian Chapados. All rights reserved.
 *
 */
#import <getopt.h>
#import <Foundation/Foundation.h>
#import <Git/Git.h>

#import "GITCommitEnumerator.h"
#import "GITUtilityBelt.h"
#import "GITGraph.h"

void usage();
void pp(NSString *fmt, ...);

@class GITGraph;
int main (int argc, char * const argv[])
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    static int option_topo, option_date;
    static int option_quiet, option_show_date;
    char *option_repo;
    char *target_commit;
    
    while(1) {
        static struct option rev_list_options[] =
        {
            {"topo-order", no_argument, &option_topo, 1},
            {"date-order", no_argument, &option_date, 1},
            {"show-date", no_argument, &option_show_date, 1},
            {"quiet", no_argument, &option_quiet, 1},
            {"repo", optional_argument, 0, 'r'},
            {0, 0, 0, 0}
        };
        
        int option_index = 0;
        int c = getopt_long(argc, argv, "qr:", rev_list_options, &option_index);
    
        if ( c == -1 )
            break;
        
        switch(c) {
            case 0:
                break;
            case 'q':
                option_quiet = 1;
                break;
            case 'r':
                option_repo = optarg;
                break;
            default:
                break;
        }
    }
            
    if ( optind < argc ) {
        target_commit = (char *)argv[optind++];
    }
    
    if ( target_commit == NULL ) {
        usage();
        [pool drain];
        exit(0);
    }
    
    NSString *path;
    if ( option_repo == NULL ) {
        path = @".";
    } else {
        path = [NSString stringWithUTF8String:option_repo];
    }
    
    NSError * error;
    GITRepo * repo = [[GITRepo alloc] initWithRoot:path error:&error];
    if (!repo) {
        pp(@"Error loading Repo: %@", [error localizedDescription]);
        [pool drain];
        return [error code];
    }
    
    // target commit can either be a commit-id (sha1) or a ref
    // no support for partial sha1 lookup yet
    NSString *targetString = [NSString stringWithUTF8String:target_commit];
    NSError *commitError = nil;
    GITCommit *commit;
    if ( isSha1StringValid(targetString) ) {
        commit = [repo commitWithSha1:targetString error:&commitError];
    } else {
        if ( [targetString isEqual:@"HEAD"] ) {
            commit = [repo head];
        } else {
            GITRef *ref = [repo branchWithName:targetString];
            if ( ref )
                commit = [repo commitWithSha1:[ref sha1] error:&commitError];
        }
    }
    
    if ( commit == nil ) {
        pp(@"Error processing commit: %@\n%@", targetString,
           commitError ? [commitError localizedDescription] : @"");
        [repo release];
        [pool drain];
        return commitError ? [commitError code] : -1;
    }
    
    GITGraph *g = [[GITGraph alloc] init];
    [g buildGraphWithStartingCommit:commit];

    NSArray *sorted;
    if ( option_topo || option_date ) {
        sorted = [g nodesSortedByTopology:option_topo];
    } else {
        sorted = [g nodesSortedByDate];
    }

    if ( !option_quiet ) {
        for ( id n in sorted ) {
            fprintf(stdout, "%s", [[n key] UTF8String]);
            if ( option_show_date )
                fprintf(stdout, " %lu", [n date]);
            fprintf(stdout, "\n");
        }
    }
    [g release];

    [repo release];
    [pool drain];
    return 0;
}

void usage()
{
    pp(
       @"usage: git-rev-list [OPTIONS] <commit-id (sha1)>\n"
       @"  -r, --repo <dir>    Path to git repository\n"
       @"DISPLAY\n"
       @"  -q, --quiet         Do not print to stdout\n"
       @"      --show-date     Print the BSD date next to the commit\n"
       @"                       (useful for debugging)\n"
       @"SORTING\n"
       @"      --topo-order    List commits in topological order\n"
       @"                       (no parent appears before all of its children)\n"
       @"      --date-order    List commits in topological order,\n"
       @"                        sorted by commit date within in the topological constraint"
    );
}

void pp(NSString *fmt, ...)
{
	va_list ap;
	va_start(ap, fmt);
    
	NSString *output = [[NSString alloc] initWithFormat:fmt arguments:ap];
	fprintf(stdout, [output UTF8String]);
	fprintf(stdout, "\n");
	[output release];
    
	va_end(ap);
}