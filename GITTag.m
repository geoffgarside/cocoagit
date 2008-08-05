//
//  GITTag.m
//  CocoaGit
//
//  Created by Geoffrey Garside on 01/07/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import "GITTag.h"
#import "NSTimeZone+Offset.h"

const NSString *kGITObjectTagType = @"tag";

@implementation GITTag

#pragma mark -
#pragma mark Properties
@synthesize ref;
@synthesize type;
@synthesize name;
@synthesize tagger;
@synthesize taggedAt;
@synthesize taggedTz;
@synthesize message;

- (id)initWithHash:(NSString*)objectHash
{
    if (self = [super initType:kGITObjectBlobType withHash:objectHash])
    {
        // self.data will be set by our -loadContentFromData: method
    }
    return self;
}
- (void)loadContentFromData:(NSData*)contentData
{
    NSString  * dataStr = [[NSString alloc] initWithData:contentData 
                                                encoding:NSASCIIStringEncoding];
    NSScanner * scanner = [NSScanner scannerWithString:dataStr];
    
    static NSString * NewLine = @"\n";
    NSString    * taggedCommit,
                * taggedType,      //!< Should be @"commit"
                * tagName,
                * taggerName,
                * taggerEmail,
                * taggerTimezone,
                * msg;
    NSTimeInterval taggerTimestamp;
    
    while ([scanner isAtEnd] == NO)
    {
        [scanner scanString:@"object" intoString:NULL];
        [scanner scanUpToString:NewLine intoString:&taggedCommit];
        
        [scanner scanString:@"type" intoString:NULL];
        [scanner scanUpToString:NewLine intoString:&taggedType];
        
        [scanner scanString:@"tag" intoString:NULL];
        [scanner scanUpToString:NewLine intoString:&tagName];
        
        [scanner scanString:@"tagger" intoString:NULL];
        [scanner scanUpToString:@"<" intoString:&taggerName];
        [scanner scanUpToString:@">" intoString:&taggerEmail];
        [scanner scanDouble:&taggerTimestamp];
        [scanner scanUpToString:NewLine intoString:&taggerTimezone];
        
        self.message = [dataStr substringFromIndex:[scanner scanLocation]];
        [scanner setScanLocation:[dataStr length]]; // Take us to the end
    }
    
    self.name = tagName;
    self.type = taggedType;
    self.ref  = taggedCommit;
    
    self.tagger = [[GITActor alloc] initWithName:taggerName andEmail:taggerEmail];
    self.taggedAt = [NSDate dateWithTimeIntervalSince1970:taggerTimestamp];
    self.taggedTz = [NSTimeZone timeZoneWithStringOffset:taggerTimezone];
}

- (id)initWithHash:(NSString*)hash
{
    // Open File
    // Expand File
    // Convert to String
    // Get Data from String
    // Parse Data
}


#pragma mark -
#pragma mark Instance Methods
- (NSString*)objectType
{
    return kGITObjectTagType;
}

@end
