//
//  GITCommit.m
//  CocoaGit
//
//  Created by Geoffrey Garside on 05/08/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import "GITCommit.h"
#import "GITRepo.h"
#import "GITTree.h"
#import "GITActor.h"
#import "GITDateTime.h"
#import "GITErrors.h"

NSString * const kGITObjectCommitName = @"commit";

/*! \cond
 Make properties readwrite so we can use
 them within the class.
*/
@interface GITCommit ()
@property(readwrite,copy) NSString * treeSha1;
@property(readwrite,copy) GITTree * tree;
@property(readwrite,copy) NSArray * parents;
@property(readwrite,copy) GITActor * author;
@property(readwrite,copy) GITActor * committer;
@property(readwrite,copy) GITDateTime * authored;
@property(readwrite,copy) GITDateTime * committed;
@property(readwrite,copy) NSString * message;
@end
/*! \endcond */

@implementation GITCommit
@synthesize treeSha1;
@synthesize parentShas;
@synthesize tree;
@synthesize parents;
@synthesize author;
@synthesize committer;
@synthesize authored;
@synthesize committed;
@synthesize message;

+ (NSString*)typeName
{
    return kGITObjectCommitName;
}
- (GITObjectType)objectType
{
    return GITObjectTypeCommit;
}

#pragma mark -
#pragma mark Mem overrides
- (void)dealloc
{
    self.tree = nil;
    self.parents = nil;
    self.author = nil;
    self.committer = nil;
    self.authored = nil;
    self.committed = nil;
    
    [super dealloc];
}

- (id)copyWithZone:(NSZone*)zone
{
    GITCommit * commit  = (GITCommit*)[super copyWithZone:zone];
    commit.tree         = self.tree;
    commit.parents      = self.parents;
    commit.author       = self.author;
    commit.committer    = self.committer;
    commit.authored     = self.authored;
    commit.committed    = self.committed;
    
    return commit;
}

- (BOOL)isFirstCommit
{
    return ([self.parents count] > 0);
}

#pragma mark -
#pragma mark Object Loaders
- (GITTree*)tree
{
    if (!tree && self.treeSha1)
        self.tree = [self.repo treeWithSha1:self.treeSha1 error:NULL];  //!< Ideally we'd like to care about the error
    return tree;
}

- (NSString *)parentSha1
{
    return self.parent.sha1;
}

- (GITCommit*)parent
{
    return [self.parents lastObject];
}

- (NSArray *)parents
{
    if (!parents && self.parentShas) {
        NSMutableArray *newParents = [[NSMutableArray alloc] initWithCapacity:[self.parentShas count]];
        for (NSString *parentSha1 in self.parentShas) {
            GITCommit *parent = [self.repo commitWithSha1:parentSha1 error:NULL];
            [newParents addObject:parent];
        }
        self.parents = newParents;
        [newParents release];
    }
    return parents;
}

#pragma mark -
#pragma mark Data Parser

typedef struct parseInfo {
    char *startPattern;
    NSUInteger startLen;
    NSInteger matchLen;
    char endChar;
    
} parseInfo;

static parseInfo p_tree =  { "tree ", 5, 40, '\n' };
static parseInfo p_parent = { "parent ", 7, 40, '\n' };
static parseInfo p_cName = { "committer ", 10, 0, '<' };
static parseInfo p_aName = { "author ", 7, 0, '<' };
static parseInfo p_email = { "", 0, 0, '>' };
static parseInfo p_dateString = { " ", 1, 0, '\n' };
//static parseInfo p_date = { " ", 1, 0, ' ' };
//static parseInfo p_tz = { " ", 1, 0, '\n' };

//NSString *parseTree(const char **buffer)
//{
//    const char *buf = *buffer;
//    // "tree <40-cahr sha1>\n"
//    if ( memcmp(buf, p_tree.startPattern, p_tree.startLen) ||
//        buf[p_tree.startLen + p_tree.matchLen] != p_tree.endChar ) {
//        return nil;
//    }
//    NSString *commitTree = [[NSString alloc] initWithBytes:(buf+p_tree.startLen)
//                                                    length:p_tree.matchLen
//                                                  encoding:NSASCIIStringEncoding];
//    if ( !commitTree )
//        return nil;
//    *buffer += p_tree.startLen + p_tree.matchLen + 1;
//    return [commitTree autorelease];
//}

NSString *parseBuffer(const char **buffer, parseInfo *delim)
{
    const char *buf = *buffer;
    if ( delim->startLen > 0 && memcmp(buf, delim->startPattern, delim->startLen) ) {
        //NSLog(@"start pattern does not match: %s\nbuf:%s", delim->startPattern, buf);
        return nil;
    }
    
    NSUInteger matchLen;
    if ( delim->matchLen > 0 ) {
        matchLen = delim->matchLen;
    } else {
        //char *end = memchr(buf+delim->startLen, delim->endChar, strlen(buf));
        char *end = (char *)buf+delim->startLen;
        while ( *end++ != delim->endChar )
            ;
        end--;
//        if ( end == NULL ) {
//            NSLog(@"could not determine matchLen");
//            return nil;
//        }
        matchLen = end - (buf+delim->startLen);
    }
    
    if ( buf[delim->startLen+matchLen] != delim->endChar ) {
        NSLog(@"end delimiter (%c) does not match end char:%c\n matchLen = %d", delim->endChar, buf[delim->startLen+matchLen], matchLen);
        return nil;
    }
    NSString *s = [[NSString alloc] initWithBytes:buf+delim->startLen
                                           length:matchLen
                                         encoding:NSASCIIStringEncoding];
    if ( !s )
        return nil;
    *buffer += delim->startLen + matchLen + 1;    
    return [s autorelease];
}


- (BOOL)parseRawDataWithC:(NSData*)raw error:(NSError**)error
{
    NSMutableArray *commitParents = [NSMutableArray new];
    
    const char *rawString = [raw bytes];
    
    NSString *commitTree = parseBuffer(&rawString, &p_tree);
    if ( !commitTree )
        return NO;
    [self setTreeSha1:commitTree];
    
    // parents
    NSString *commitParent;
    while ( commitParent = parseBuffer(&rawString, &p_parent) ) {
        [commitParents addObject:commitParent];
    }
    
    NSString *authorName = parseBuffer(&rawString, &p_aName);
    NSString *authorEmail = parseBuffer(&rawString, &p_email);
    NSString *authorDateString = parseBuffer(&rawString, &p_dateString);
    [self setAuthor:[GITActor actorWithName:authorName email:authorEmail]];
    //NSLog(@"name: %@, email: %@, date: %@", authorName, authorEmail, authorDateString);
    
    NSString *committerName = parseBuffer(&rawString, &p_cName);
    NSString *committerEmail = parseBuffer(&rawString, &p_email);
    NSString *committerDateString = parseBuffer(&rawString, &p_dateString);
    [self setCommitter:[GITActor actorWithName:committerName email:committerEmail]];
    
    [self setParentShas:commitParents];
    [commitParents release];
    
    return YES;
}

typedef struct CFParseInfo {
    CFStringRef startPattern;
    CFIndex startLen;
    CFIndex matchLen;
    UniChar endChar;
    
} CFParseInfo;

static CFParseInfo cf_tree =  { CFSTR("tree "), 5, 40, '\n' };
static CFParseInfo cf_parent = { CFSTR("parent "), 7, 40, '\n' };
//static CFParseInfo cf_cName = { CFSTR("committer "), 10, 0, '<' };
//static CFParseInfo cf_aName = { CFSTR("author "), 7, 0, '<' };
//static CFParseInfo cf_email = { CFSTR(""), 0, 0, '>' };
//static CFParseInfo cf_dateString = { CFSTR(" "), 1, 0, '\n' };

CFRange parseString(CFStringRef *sPtr, CFRange r, CFParseInfo delim, CFRange *rest)
{
    CFStringRef s = *sPtr;
    if ( CFStringCompareWithOptions(s, delim.startPattern, CFRangeMake(r.location, delim.startLen), 0) != 0 ) {
        //NSLog(@"r.location = %u, bad line for prefix %@\n", r.location, delim.startPattern);
        return CFRangeMake(-1, 0);
    }
    
    NSUInteger matchLen;
    if ( delim.matchLen > 0 ) {
        matchLen = delim.matchLen;
    } else {
        CFRange searchRange = CFRangeMake(r.location + delim.startLen, r.length - delim.startLen);
        CFStringInlineBuffer buf;
        CFStringInitInlineBuffer(s, &buf, searchRange);
        CFIndex i = 0;
        while ( CFStringGetCharacterFromInlineBuffer(&buf, i++) != (UniChar)delim.endChar )
            ;
        matchLen = (i - 1) - (r.location + delim.startLen);
    }
    
    CFIndex end = r.location + delim.startLen + matchLen;
    //printf("r.location = %u, end = %u\n", r.location, end);
    if ( CFStringGetCharacterAtIndex(s, end) != delim.endChar ) {
        //NSLog(@"delim = %@ - end delimiter (%d) does not match end char:%d\n matchLen = %d", delim.startPattern, delim.endChar, CFStringGetCharacterAtIndex(s, end), matchLen);
        return CFRangeMake(-1, 0);
    }
    
    *rest = CFRangeMake(end + 1, r.length - end + 1);
    return CFRangeMake(r.location + delim.startLen, matchLen);
}

- (BOOL)parseRawData:(NSData*)raw error:(NSError**)error
{
    NSMutableArray *commitParents = [NSMutableArray new];
    
    CFStringRef rawString = CFStringCreateWithBytesNoCopy(kCFAllocatorDefault, [raw bytes], [raw length], kCFStringEncodingASCII, false, kCFAllocatorNull);
    CFIndex length = CFStringGetLength(rawString);
    CFRange rawRange = CFRangeMake(0, length);
    
    CFRange treeRange = parseString(&rawString, rawRange, cf_tree, &rawRange);
    //printf("** rawRange = %u, %u", rawRange.location, rawRange.length);
    CFStringRef commitTree = CFStringCreateWithSubstring(NULL, rawString, treeRange);
    //NSLog(@"tree = %@", commitTree);
    [self setTreeSha1:(NSString *)commitTree];
    CFRelease(commitTree);
    
    CFRange parentRange;
    while ( (parentRange = parseString(&rawString, rawRange, cf_parent, &rawRange)).location != -1 ) {
        CFStringRef p = CFStringCreateWithSubstring(NULL, rawString, parentRange);
        //NSLog(@"parent = %@",p);
        [commitParents addObject:(NSString *)p];
        CFRelease(p);
    }
    [self setParentShas:commitParents];
    [commitParents release];
    CFRelease(rawString);
    
    return YES;
}
    

- (BOOL)BCparseRawData:(NSData*)raw error:(NSError**)error
{
    // TODO: Update this method to support errors
    NSString * errorDescription;
    
    NSString  *dataStr = [[NSString alloc] initWithBytesNoCopy:(char *)[raw bytes]
                                                        length:strlen([raw bytes])
                                                      encoding:[NSString defaultCStringEncoding]
                                                  freeWhenDone:NO];
    NSMutableArray *commitParents = [NSMutableArray new];

//    const char *rawString = [raw bytes];
//    
//    // "tree <40-cahr sha1>\n", len = 5 + 40 + 1, pos[45] = '\n'
//    rawString += 5; // "tree "
//    NSString *commitTree = [[NSString alloc] initWithBytes:rawString
//                                                    length:40
//                                                  encoding:NSASCIIStringEncoding];
//    [self setTreeSha1:commitTree];
//    [commitTree release];
//    
//
//    rawString += 41;
//    //printf("%s",rawString);
//    while (!memcmp(rawString, "parent ", 7)) {
//        rawString += 7;
//        NSString *commitParent = [[NSString alloc] initWithBytes:rawString
//                                                          length:40
//                                                        encoding:NSASCIIStringEncoding];
//        if ( commitParent ) {
//            //NSLog(@"bad parent: %@, (%d)", commitParent, [commitParent length]);
//            [commitParents addObject:commitParent];
//        }
//        rawString += 41;
//        [commitParent release];
//    }

    NSRange treeRange = NSMakeRange(5, 40);
    NSRange parentsRange;
    parentsRange = NSMakeRange(46, 47);
    
    //NSLog(@"parentsRange string = %@", [dataStr substringWithRange:parentsRange]);
    
    NSString *p;
    while ( [(p = [dataStr substringWithRange:parentsRange]) hasPrefix:@"parent "] ) {
        NSString *commitParent = [p substringFromIndex:7];
        [commitParents addObject:commitParent];
        parentsRange = NSMakeRange(parentsRange.location+parentsRange.length+1, parentsRange.length);
    }
    

    [self setParentShas:commitParents];
    //NSLog(@"parsed raw data for tree: %@", self.treeSha1);

    [commitParents release];
    [dataStr release];
    return YES;
}    


- (BOOL)parseRawDataWithScanner:(NSData*)raw error:(NSError**)error
{
    // TODO: Update this method to support errors
    NSString * errorDescription;

    NSString  *dataStr = [[NSString alloc] initWithData:raw
                                               encoding:NSASCIIStringEncoding];    
    NSScanner * scanner = [NSScanner scannerWithString:dataStr];
    [dataStr release];
    
    static NSString * NewLine = @"\n";
    NSString * commitTree,
             * commitParent,
             * authorName,
             * authorEmail,
             * authorTimezone,
             * committerName,
             * committerEmail,
             * committerTimezone;

	NSMutableArray *newParentShas = [[NSMutableArray alloc] init];

    NSTimeInterval authorTimestamp,
                   committerTimestamp;
     
    if ([scanner scanString:@"tree" intoString:NULL] &&
        [scanner scanUpToString:NewLine intoString:&commitTree])
    {
        self.treeSha1 = commitTree;
        if (!self.treeSha1) return NO;
    }
    else
    {
        errorDescription = NSLocalizedString(@"Failed to parse tree reference for commit", @"GITErrorObjectParsingFailed (GITCommit:tree)");
        GITError(error, GITErrorObjectParsingFailed, errorDescription);
        return NO;
    }
    
    while ([scanner scanString:@"parent" intoString:NULL])
    {
        // If we've got a parent at all then we'll parse the name
        if ([scanner scanUpToString:NewLine intoString:&commitParent])
        {
			[newParentShas addObject:commitParent];
        }
        else
        {
            errorDescription = NSLocalizedString(@"Failed to parse parent reference for commit", @"GITErrorObjectParsingFailed (GITCommit:parent)");
            GITError(error, GITErrorObjectParsingFailed, errorDescription);
            return NO;
        }
    }
	
	[self setParentShas:newParentShas];
    
    if ([scanner scanString:@"author" intoString:NULL] &&
        [scanner scanUpToString:@"<" intoString:&authorName] &&
        [scanner scanString:@"<" intoString:NULL] &&
        [scanner scanUpToString:@">" intoString:&authorEmail] &&
        [scanner scanString:@">" intoString:NULL] &&
        [scanner scanDouble:&authorTimestamp] &&
        [scanner scanUpToString:NewLine intoString:&authorTimezone])
    {
        self.author = [GITActor actorWithName:authorName email:authorEmail];
        self.authored = [[[GITDateTime alloc] initWithTimestamp:authorTimestamp
                                                 timeZoneOffset:authorTimezone] autorelease];
    }
    else
    {
        errorDescription = NSLocalizedString(@"Failed to parse author details for commit", @"GITErrorObjectParsingFailed (GITCommit:author)");
        GITError(error, GITErrorObjectParsingFailed, errorDescription);
        return NO;
    }
    
    if ([scanner scanString:@"committer" intoString:NULL] &&
        [scanner scanUpToString:@"<" intoString:&committerName] &&
        [scanner scanString:@"<" intoString:NULL] &&
        [scanner scanUpToString:@">" intoString:&committerEmail] &&
        [scanner scanString:@">" intoString:NULL] &&
        [scanner scanDouble:&committerTimestamp] &&
        [scanner scanUpToString:NewLine intoString:&committerTimezone])
    {
        self.committer = [GITActor actorWithName:committerName email:committerEmail];
        self.committed = [[[GITDateTime alloc] initWithTimestamp:committerTimestamp
                                                  timeZoneOffset:committerTimezone] autorelease];
    }
    else
    {
        errorDescription = NSLocalizedString(@"Failed to parse committer details for commit", @"GITErrorObjectParsingFailed (GITCommit:committer)");
        GITError(error, GITErrorObjectParsingFailed, errorDescription);
        return NO;
    }
        
    self.message = [[[scanner string] substringFromIndex:[scanner scanLocation]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (!self.message)
    {
        errorDescription = NSLocalizedString(@"Failed to parse message for commit", @"GITErrorObjectParsingFailed (GITCommit:message)");
        GITError(error, GITErrorObjectParsingFailed, errorDescription);
        return NO;
    }

    return YES;
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"Commit <%@>", self.sha1];
}

#pragma mark -
#pragma mark Output Methods
- (NSData*)rawContent
{
    NSMutableString *treeString = [NSMutableString stringWithFormat:@"tree %@\n", self.tree.sha1];                                   
    for (GITCommit *parent in [self parents]) {
        [treeString appendFormat:@"parent %@\n", [parent sha1]];
    }
    return [[NSString stringWithFormat:@"%@author %@ %@\ncommitter %@ %@\n\n%@\n",
                        treeString, self.author, self.authored,
                        self.committer, self.committed, self.message]
                            dataUsingEncoding:NSASCIIStringEncoding];
}

@end
