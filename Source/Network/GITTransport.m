//
//  GITTransport.m
//  CocoaGit
//
//  Created by Brian Chapados on 2/9/09.
//  Copyright 2009 Brian Chapados. All rights reserved.
//

#import "GITTransport.h"
#import "GITObject.h"
#import "GITUtilityBelt.h"
#import "GITPackFile.h"
#import "NSData+Hashing.h"
#import "NSData+Searching.h"
#import "NSData+Compression.h"
#import "NSData+HexDump.h"
#include <zlib.h>

NSString * const GITTransportFetch = @"GITTransportFetch";
NSString * const GITTransportPush = @"GITTransportPush";
NSString * const GITTransportOpen = @"GITTransportOpen";
NSString * const GITTransportClosed = @"GITTransportClosed";

@interface GITTransport ()
@property (nonatomic, copy) NSError *error;
@property (nonatomic, copy) NSString *status;
- (NSDictionary *) readPackHeader;
- (NSData *) unpackObjectWithSize:(int)size compressedSize:(int *)cSize compressedData:(NSData **)cData;
- (NSData *) unpackDeltaObjectWithSize:(NSUInteger)size type:(NSUInteger)type compressedData:(NSData **)cData;
@end


@implementation GITTransport
@synthesize localRepo;
@synthesize remoteURL;
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
    NSData *nullPacket = [NSData dataWithBytes:"0000" length:4];
    
    if ([packetLen isEqualToData:nullPacket])
        return [NSData dataWithBytes:"0" length:0];
    
    NSUInteger len = hexLengthToInt((NSData *)packetLen);
    
    // check for bad length
    if (len < 0) {
        NSLog(@"protocol error: bad length");
        return nil;
    }
    
    NSMutableData *packetData = [[self connection] readData:(int)len-4];
    return [NSData dataWithData:packetData];
}

- (NSString *) readPacketLine;
{
    NSData *packetData = [self readPacket];
    if (! (packetData && ([packetData length] > 0)))
        return nil;
    return [[[NSString alloc] initWithData:packetData encoding:NSASCIIStringEncoding] autorelease];
}

- (NSData *) packetByRemovingCapabilitiesFromPacket:(NSData *)data;
{
    NSRange refRange = [data rangeOfNullTerminatedBytesFrom:0];
        
    if (refRange.location == NSNotFound)
        return data;
    
    return [data subdataToIndex:refRange.length-1];
}

- (NSString *) capabilitiesWithPacket:(NSData *)data;
{
    NSRange refRange = [data rangeOfNullTerminatedBytesFrom:0];
        
    if (refRange.location == NSNotFound)
        return nil;
        
    NSUInteger capStart = refRange.length+1;
    NSData *capData = [data subdataFromIndex:capStart];
 
    return [[[NSString alloc] initWithData:capData encoding:[NSString defaultCStringEncoding]] autorelease];
}

- (NSArray *) readPackets;
{
	NSMutableArray *packets = [NSMutableArray new];
    NSData *packetData = [self readPacket];
    
    // extract capabilities string and remove '\0'
    NSString *capabilities = [self capabilitiesWithPacket:packetData];
    if (capabilities) {
        packetData = [packetData subdataToIndex:([packetData length] - [capabilities length] - 1)];
        NSLog(@"remote capabilities: %@", capabilities);
    }
        
    while (packetData && [packetData length] > 0) {
        [packets addObject:packetData];
        packetData = [self readPacket];
    }
	
    NSArray *thePackets = [NSArray arrayWithArray:packets];
    [packets release];
    return thePackets;
}

- (void) packetFlush;
{
    [[self connection] writeData:[NSData dataWithBytes:"0000" length:4]];
}

- (void) writePacket:(NSData *)thePacket;
{
    [[self connection] writeData:thePacket];
}

- (void) writePacketLine:(NSString *)packetLine;
{
    [self writePacket:[self packetWithString:packetLine]];
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

- (NSDictionary *) readPackHeader;
{	
	NSUInteger version, entries;

    NSRange versionRange = NSMakeRange(4,4);
    NSRange entriesRange = NSMakeRange(8,4);
    
    NSData *header = [[self connection] readData:12];

    uint32_t value;
    [header getBytes:&value range:versionRange];
    version = CFSwapInt32BigToHost(value);
    [header getBytes:&value range:entriesRange];
    entries = CFSwapInt32BigToHost(value);
    
    if (version != 2)
        return nil;

    return [NSDictionary dictionaryWithObjectsAndKeys:header, @"data", [NSNumber numberWithUnsignedInt:entries], @"entries", nil];
}

// read until the other end disconnects - should get the entire packfile.
- (NSData *) readPackStream;
{
    NSMutableData *data = [NSMutableData dataWithCapacity:4096];
    
    while(1) {
        NSMutableData *d = [[self connection] readData:4096];
        if ([d length] == 0) {
            NSData *rest = [[self connection] buffer];
            [data appendData:rest];
            if (! [[self connection] isConnected])
                break;
        }
        [data appendData:d];        
    }
    NSRange checksumRange = NSMakeRange([data length] - 20, 20);
    NSData *checksum = [data subdataWithRange:checksumRange];
    
    NSRange checkdataRange = NSMakeRange(0, [data length] - 20);
    NSData *checkData = [[data subdataWithRange:checkdataRange] sha1Digest];
    
    if (! [checkData isEqualToData:checksum]) {
        NSLog(@"bad checkum");
        return nil;
    }
    
    return [NSData dataWithData:data];
}

- (NSData *) readPackObjects;
{
    NSDictionary *packInfo = [self readPackHeader];
    NSMutableData *packData = [NSMutableData new];
    
    NSData *header = [packInfo objectForKey:@"data"];
    [packData appendData:header];
    
    NSNumber *entries = [packInfo objectForKey:@"entries"];
    NSUInteger objectCount = [entries unsignedIntValue];
    
    NSLog(@"Expecting %d objects", objectCount);
    
    NSUInteger i = 0;
    for (i = 0; i < objectCount; i++) {
        NSData *o = [self readPackObject];
        [packData appendData:o];
        NSLog(@"read object #%d, size:%d", i, [o length]);
    }
        
    // read checksum
    NSData *checksum = [[self connection] readData:20];
    NSLog(@"checksum:\n%@", [checksum hexdump]);
    [packData appendData:checksum];
    
    NSData *packfile = [NSData dataWithData:packData];
    [packData release];
    return packfile;
}

- (NSData *) readPackObject;
{
    NSMutableData *packData = [NSMutableData dataWithCapacity:1];
    
    // read in the header
	int size, type, shift;
    
    NSMutableData *d = [[self connection] readData:1];
	[packData appendData:d];
     
    uint8_t *byte = (uint8_t *)[d mutableBytes];
    	
    type = (byte[0] >> 4) & 7;
    size = byte[0] & 15;
    shift = 4;
    
    size = byte[0] & 0xf;
    type = (byte[0] >> 4) & 7;
    shift = 4;
	while((byte[0] & 0x80) != 0) {
		d = [[self connection] readData:1];
        [packData appendData:d];
        byte = (uint8_t *)[d mutableBytes];

        size |= ((byte[0] & 0x7f) << shift);
        shift += 7;
	}
    
    // NSLog(@"-readObject: type => %d, size => %d", type, size);
    // NSLog(@"  header: %d bytes", [packData length]);
    
    // In each case, we throw away the unpacked object data
    // and just collect the compressed packdata.
    // We do this, because packfiles do not provide the size of the compressed object
    // only the size of the unpacked object...
    NSData *compressed;
    switch (type) {
        case GITObjectTypeCommit:
        case GITObjectTypeTree:
        case GITObjectTypeBlob:
        case GITObjectTypeTag:
        {
            [self unpackObjectWithSize:size compressedSize:NULL compressedData:&compressed];
            [compressed retain];
            break;
        }
        case kGITPackFileTypeDeltaRefs:
        case kGITPackFileTypeDeltaOfs:
        {
            [self unpackDeltaObjectWithSize:size type:type compressedData:&compressed];
            [compressed retain];
            break;
        }
        default:
            NSAssert(NO, @"Bad Object Type");
            break;
    }
            
    [packData appendData:compressed];
    [compressed release];
    
    return [[packData copy] autorelease];
}


- (NSData *) unpackDeltaObjectWithSize:(NSUInteger)size type:(NSUInteger)type compressedData:(NSData **)cData;
{
    NSMutableData *deltaData = [NSMutableData dataWithCapacity:0];

    // read the offset data
    if (type == kGITPackFileTypeDeltaRefs) {
        [deltaData appendData:[[self connection] readData:20]];
    } else if (type == kGITPackFileTypeDeltaOfs) {        
        // TODO: This is currently broken.  I'm not sure I fully understand Delta Offsets yet
        NSMutableData *buf = [[self connection] readData:1];
        [deltaData appendData:buf];
        uint8_t *data = [buf mutableBytes];
        uint8_t c = data[0] & 0xff;
        
        // from jgit: IndexPack.java
        while ((c & 128) != 0) {
            buf = [[self connection] readData:1];
            data = [buf mutableBytes];
            [deltaData appendData:buf];
            c = data[0] && 0xff;
        }
        NSLog(@"  delta object, c = %d, read %d bytes", c, [deltaData length]);
    } else {
        NSAssert(NO, @"Bad Object");
    }
    
    NSData *compressed;
    NSData *objData = [self unpackObjectWithSize:size compressedSize:NULL compressedData:&compressed];
    [deltaData appendData:compressed];
    
    if (cData != NULL)
        *cData = [NSData dataWithData:deltaData];
    
    return objData;
}

- (NSData *) unpackObjectWithSize:(int)size compressedSize:(int *)cSize compressedData:(NSData **)cData;
{
	// read in the data
    NSMutableData *compressed;
    NSMutableData *readCompressed = [NSMutableData dataWithCapacity:size];
    NSMutableData *decompressed = [NSMutableData dataWithLength:size];
    uint8_t *decompressedBytes = [decompressed mutableBytes];
    BOOL done = NO;
	int zstatus;
	
    compressed = [[self connection] readData:1];
    [readCompressed appendData:compressed];
	
	z_stream strm;
	strm.next_in = [compressed mutableBytes];
	strm.avail_in = 1;
	strm.total_out = 0;
	strm.zalloc = Z_NULL;
	strm.zfree = Z_NULL;
	
	if (inflateInit (&strm) != Z_OK) 
		NSLog(@"Inflate Issue");
	
	while (!done)
	{
		// Make sure we have enough room and reset the lengths.
		if (strm.total_out >= [decompressed length]) {
			[decompressed increaseLengthBy:100];
        }
		strm.next_out = decompressedBytes + strm.total_out;
		strm.avail_out = [decompressed length] - strm.total_out;
		
		// Inflate another chunk.
		zstatus = inflate (&strm, Z_SYNC_FLUSH);
		if (zstatus == Z_STREAM_END) done = YES;
		else if (zstatus != Z_OK) {
			NSLog(@"status for break: %d, next_out = %x, avail_out = %d, total = %d", zstatus, strm.next_out, strm.avail_out, strm.total_out);
			break;
		}
		
		if(!done) {
            compressed = [[self connection] readData:1];
            [readCompressed appendData:compressed];
			strm.next_in = [compressed mutableBytes];
			strm.avail_in = 1;
		}
	}
	if (inflateEnd (&strm) != Z_OK)
		NSLog(@"Inflate Issue");
	    
	// Set real length.
	if (done)
		[decompressed setLength: strm.total_out];
	
    if (cSize != NULL)
        *cSize = [readCompressed length];
    
    NSLog(@"  inflated size: %d, compressed size: %d", strm.total_out, [readCompressed length]);
    
    if (cData != NULL)
        *cData = [NSData dataWithData:readCompressed];
    
	return decompressed;
}

- (NSString *) transportStatus { return status; }
- (NSError *) transportError { return error; }

- (BufferedSocket *)connection;
{
    return (BufferedSocket *)connection;
}

- (void) setConnection:(id)newConnection;
{
    if (connection != newConnection) {
        [newConnection retain];
        [connection release];
        connection = newConnection;
    }
}

@end