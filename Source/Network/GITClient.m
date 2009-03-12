//
//  GITClient.m
//  CocoaGit
//
//  Created by Scott Chacon on 1/3/09.
//  Copyright 2009 GitHub. All rights reserved.
//

#import "GITClient.h"
#import "GITUtilityBelt.h"
#import "Socket.h"

@implementation GITClient

@synthesize socket;

- (BOOL)clone: (NSString *)url;
{
    NSLog(@"clone url %@", url);

    NSMutableData *response;
    NSString *responseString;
    NSString *userHostName;
    NSString *userPath;
    int	userPort;
    NSURL *userURL;

    NS_DURING

    // Parse host, port, and path out of user's URL

    userURL = [NSURL URLWithString: url];
    userPort = [[userURL port] intValue];
    userHostName = [userURL host];
    userPath = [userURL path];

    // if ([[gitURL scheme] isEqualToString:@"git"]) {

    if ( userPort == 0 )
        userPort = 9418;

    NSLog(@"cloning from [ %d : %@ : %@ ]", userPort, userHostName, userPath);

    // Construct request
    // "0032git-upload-pack /project.git\000host=myserver.com\000"
    NSString *request =
        [[NSString alloc] initWithFormat: @"git-upload-pack %@\0host=%@\0", userPath, userHostName];

    // Create socket, connect, and send request

    socket = [Socket socket];
    [socket connectToHostName: userHostName port: userPort];

    NSLog(@"connected");

    [self writeServer: request];

    // Read response from server

    response = [[[NSMutableData alloc] init] autorelease];

    NSLog(@"wrote");

    while ( [socket readData: response] )
        // Read until other side disconnects
        NSLog(@"read");

    // Display response in context textview
    NSLog(@"readed");

    responseString = [[[NSString alloc] initWithData: response
                       encoding:[NSString defaultCStringEncoding]] autorelease];

    return true;

    NS_HANDLER
    // If an exception occurs, ...
    NSLog(@"error");

    NS_ENDHANDLER

    return false;
}

- (void)sendPacket: (NSString *)dataWrite {
    NSLog(@"send:[%@]", dataWrite);
    [socket writeString: dataWrite];
}

#define hex(a) (hexchar[(a) & 15])
- (void)writeServer: (NSString *)dataWrite {
    NSLog(@"write:[%@]", dataWrite);
    NSUInteger len = [dataWrite length];
    len += 4;
    [self writeServerLength: len];
    NSLog(@"write data");
    [self sendPacket: dataWrite];
}

- (void)writeServerLength: (NSUInteger)length {
    static char hexchar[] = "0123456789abcdef";
    uint8_t buffer[5];

    buffer[0] = hex(length >> 12);
    buffer[1] = hex(length >> 8);
    buffer[2] = hex(length >> 4);
    buffer[3] = hex(length);

    NSLog(@"write len [%c %c %c %c]", buffer[0], buffer[1], buffer[2], buffer[3]);
    [socket writeData: bytesToData(buffer, 4)];
}

@end
