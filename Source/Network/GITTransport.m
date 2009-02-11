//
//  GITTransport.m
//  CocoaGit
//
//  Created by Brian Chapados on 2/9/09.
//  Copyright 2009 Brian Chapados. All rights reserved.
//

#import "GITTransport.h"
#import "GITUtilityBelt.h"

NSString * const GITTransportFetch = @"GITTransportFetch";
NSString * const GITTransportPush = @"GITTransportPush";
NSString * const GITTransportOpen = @"GITTransportOpen";
NSString * const GITTransportClosed = @"GITTransportClosed";

@interface GITTransport ()
@property (nonatomic, copy) NSError *error;
@property (nonatomic, copy) NSString *status;
@end

@implementation GITTransport
@synthesize localRepo;
@synthesize remoteURL;
@synthesize connection;
@synthesize error;
@synthesize status;

+ (BOOL) canHandleURL:(NSURL *)aURL;
{
    return [[aURL scheme] isEqualToString:@"git"];
}

- (id) initWithURL:(NSURL *)url repo:(GITRepo *)repo;
{
    if (! [self init])
        return nil;
    
    [self setLocalRepo:repo];
    [self setRemoteURL:url];
    return self;
}

- (void) dealloc;
{
    [self disconnect];
    [connection release], connection = nil;
    [localRepo release], localRepo = nil;
    [remoteURL release], remoteURL = nil;
    [error release], error = nil;
    [status release], status = nil;
    [super dealloc];
}
- (void) finalize;
{
    [self disconnect];
    [super finalize];
}

- (BOOL) connect;
{
    // Parse host, port, and path out of user's URL
	// int userPort = [[remoteURL port] intValue];
	NSString *userHostName = [remoteURL host];
    
    BufferedSocket *socket = [BufferedSocket bufferedSocket];
	[socket connectToHostName:userHostName port:9418];
    
    if (! [socket isConnected])
        return NO;

    [self setConnection:socket];
    return YES;
}

- (void) disconnect;
{
    if ([[self connection] isConnected])
        [[self connection] close];
}

- (void) startFetch;
{
    // Parse host, port, and path out of user's URL
	NSString *userHostName = [remoteURL host];
	NSString *userPath = [remoteURL path];
    
    // Construct request 
	// "0032git-upload-pack /project.git\000host=myserver.com\000"
	NSString *request = [[NSString alloc] initWithFormat:@"git-upload-pack %@\0host=%@\0", userPath, userHostName];
    [self writePacket:[self packetWithString:request]];
    [self setStatus:GITTransportFetch];
}

- (NSData *) readPacket;
{
	NSMutableData *packetLen = [[self connection] readData:4];
    NSData *nullLen = [NSData dataWithBytes:"0000" length:4];
    
    if ([packetLen isEqualToData:nullLen])
        return [NSData dataWithBytes:"0" length:0];
    
    NSUInteger len = hexLengthToInt((NSData *)packetLen);
    
    // check for bad length
    if (len < 0) {
        NSLog(@"protocol error: bad length");
        return nil;
    }
    
    NSMutableData *packetData = [[self connection] readData:(int)len-4];
    //NSLog(@"readPacket: len = %d, data:\n%@", len, [packetLen hexdump]);
    return [NSData dataWithData:packetData];
}

- (NSString *) readPacketLine;
{
    NSData *packetData = [self readPacket];
    if (! (packetData && ([packetData length] > 0)))
        return nil;
    return [[[NSString alloc] initWithData:packetData encoding:NSASCIIStringEncoding] autorelease];
}

- (NSArray *) readPackets;
{
	NSMutableArray *packets = [NSMutableArray new];
    NSData *packetData = [self readPacket];
    
    while (packetData && [packetData length] > 0) {
        //NSLog(@"packet:\n%@", [packetData hexdump]);
        [packets addObject:packetData];
        packetData = [self readPacket];
    }
	
    NSArray *thePackets = [NSArray arrayWithArray:packets];
    [packets release];
    return thePackets;
}

- (void) writePacket:(NSData *)thePacket;
{
    [[self connection] writeData:thePacket];
}

- (void) writePacketLine:(NSString *)packetLine;
{
    [[self connection] writeString:packetLine];
}

- (NSData *) packetWithString:(NSString *)line;
{
    NSUInteger len = [line length] + 4;
    NSData *hexLength = intToHexLength(len);
    NSMutableData *packetData = [NSMutableData dataWithCapacity:len];
    [packetData appendData:hexLength];
    [packetData appendData:[line dataUsingEncoding:NSUTF8StringEncoding]];
    return [NSData dataWithData:packetData];
}

- (NSString *) transportStatus { return status; }
- (NSError *) transportError { return error; }

@end