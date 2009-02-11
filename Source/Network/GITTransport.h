//
//  GITTransport.h
//  CocoaGit
//
//  Created by Brian Chapados on 2/9/09.
//  Copyright 2009 Brian Chapados. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GITRepo.h"
#import "BufferedSocket.h"

extern NSString * const GITTransportFetch;
extern NSString * const GITTransportPush;
extern NSString * const GITTransportOpen;
extern NSString * const GITTransportClosed;

@interface GITTransport : NSObject {
    BufferedSocket *connection;
    GITRepo *localRepo;
    NSURL *remoteURL;
    
    NSError *error;
    NSString *status;
}
@property (nonatomic, retain) GITRepo *localRepo;
@property (nonatomic, copy) NSURL *remoteURL;
@property (nonatomic, retain) BufferedSocket *connection;

+ (BOOL) canHandleURL:(NSURL *)url;

- (id) initWithURL:(NSURL *)url repo:(GITRepo *)repo;
- (BOOL) connect;
- (void) disconnect;

// start fetch process
- (void) startFetch;

// read
- (NSData *) readPacket;
- (NSString *) readPacketLine;
- (NSArray *) readPackets;

// write
- (NSData *) packetWithString:(NSString *)line;
- (void) writePacket:(NSData *)thePacket;
- (void) writePacketLine:(NSString *)packetLine;

// status
- (NSString *) transportStatus;
- (NSError *) transportError;
@end
