//
//  GITBlob.m
//  CocoaGit
//
//  Created by Geoffrey Garside on 29/06/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import "GITBlob.h"


@implementation GITBlob

#pragma mark -
#pragma mark Properties
@synthesize data;

#pragma mark -
#pragma mark Reading existing Blob objects
- (id)initFromHash:(NSString*)objectHash
{
    if (self = [super initFromHash:objectHash])
    {
        
    }
    return self;
}

#pragma mark -
#pragma mark Creating new Blob objects
- (id)initWithData:(NSData*)dataContent
{
    if (self = [super init])
    {
        self.data = dataContent;
    }
    return self;
}
- (id)initWithContentsOfFile:(NSString*)filePath
{
    return [self initWithData:[NSData dataWithContentsOfFile:filePath]];
}

#pragma mark -
#pragma mark Instance Methods
- (NSData*)toData
{
    NSMutableData * objectData = [NSMutableData data];
    
    NSString *meta = [NSString stringWithFormat:@"blob %d\0", [self.data length]];
    [objectData appendData:[meta dataUsingEncoding:NSUTF8StringEncoding]];
    [objectData appendData:self.data];
    
    return *objectData;
}

@end
