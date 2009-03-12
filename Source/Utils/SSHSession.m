//
//  SSHSession.m
//  SSHSession
//
//  Created by Brian Chapados on 2/5/09.
//  Copyright 2009 Brian Chapados. All rights reserved.
//

#import "SSHSession.h"
#import "SSHError.h"
#import <sys/socket.h>
#import <netinet/in.h>
#include <netdb.h>
#include <stdio.h>

NSString *const SSHUserDirectory = @".ssh";
NSString *const SSHUserPublicKeyFileKey = @"SSHUserPublicKeyFile";
NSString *const SSHUserRSAPublicKeyFile = @"id_rsa.pub";
NSString *const SSHUserDSAPublicKeyFile = @"id_dsa.pub";
NSString *const SSHUserPrivateKeyFileKey = @"SSHUserPrivateKeyFile";
NSString *const SSHUserRSAPrivateKeyFile = @"id_rsa";
NSString *const SSHUserDSAPrivateKeyFile = @"id_dsa";

@implementation SSHSession
@synthesize config;

- (id)init {
    return [self initWithSocket: -1];
}

- (id)initWithSocket: (NSSocketNativeHandle)sock;
{
    if ( ! [super init] )
        return nil;

    session = libssh2_session_init();
    if ( session == NULL )
        return nil;

    native = sock;
    [self setConfig:[self defaultConfiguration]];

    return self;
}

- (void)dealloc;
{
    [self disconnect];
    session = NULL;
    native = -1;
    [super dealloc];
}

- (void)finalize;
{
    [self disconnect];
    [super finalize];
}

- (NSDictionary *)configurationWithSshDir: (NSString *)sshDir publicKey: (NSString *)publicKey
privateKey: (NSString *)privateKey;
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [sshDir stringByAppendingPathComponent: publicKey],
            SSHUserPublicKeyFileKey,
            [sshDir stringByAppendingPathComponent: privateKey],
            SSHUserPrivateKeyFileKey, nil];
}

- (NSDictionary *)configurationWithPublicKey: (NSString *)publicKey privateKey: (NSString *)
privateKey;
{
    return [self configurationWithSshDir:[NSHomeDirectory() stringByAppendingPathComponent:
                                          SSHUserDirectory] publicKey: publicKey privateKey:
            privateKey];
}

- (NSDictionary *)defaultConfiguration;
{
    return [self configurationWithPublicKey: SSHUserRSAPublicKeyFile privateKey:
            SSHUserRSAPublicKeyFile];
}

// connection helper
+ (id)sessionToHost: (NSString *)aHost port: (unsigned short)aPort error: (NSError **)error;
{
    // resolve hostname
    NSSocketNativeHandle sock;
    NSSocketPort *socketPort = [[NSSocketPort alloc] initRemoteWithTCPPort: aPort host: aHost];
    if ( ![socketPort address] ) {
        SSHErrorWithDescription(error,
                                SSHErrorLookup,
                                @"Could not look up the hostname (%@).",
                                aHost);
        return NO;
    }

    // establish connection
    const struct sockaddr *addr = [[socketPort address] bytes];
    sock = socket(addr->sa_family, SOCK_STREAM, 0);
    if ( sock == -1 ) {
        SSHErrorWithDescription(error,
                                SSHErrorSocketOpen,
                                @"Socket could not be opened for connection (%d).",
                                errno);
        return NO;
    }

    int status = connect(sock, [[socketPort address] bytes], [[socketPort address] length]);
    if ( status != 0 ) {
        SSHErrorWithDescription(error, SSHErrorSocketConnection, @"Connection failed (%i).", errno);
        return NO;
    }


    id newSession = [[[self alloc] initWithSocket: sock] autorelease];
    [socketPort release];

    return newSession;
}


- (BOOL)start: (NSError **)error;
{
    // establish SSH session
    int status = libssh2_session_startup(session, native);
    if ( status != 0 ) {
        [self disconnect];
        SSHErrorWithDescription(error, SSHErrorSession, @"Could not establish SSH session");
        return NO;
    }
    return YES;
}

- (NSString *)authenticationTypesWithUser: (NSString *)username;
{
    char *auth_list = libssh2_userauth_list(session, [username UTF8String], [username length]);
    return [NSString stringWithCString: auth_list length: strlen(auth_list)];
}


- (BOOL)authenticateUser: (NSString *)username password: (NSString *)password;
{
    // authenticate
    int status = libssh2_userauth_password(session, [username UTF8String], [password UTF8String]);
    if ( status != 0 ) {
        [self disconnect];
        //return [SSHConnection makeErrorWithCode:SSHCONNECTION_ERROR_AUTH
        // message:@"Authentication failed."];
        return NO;
    }
    // NSLog(@"user %@ authenticated", username);
    return YES;
}

- (BOOL)authenticateUser: (NSString *)username;
{
    // try RSA key
    if ([self authenticateUser: username publicKeyFile:[config valueForKey: SSHUserPublicKeyFileKey
         ] privateKeyFile:[config valueForKey: SSHUserPrivateKeyFileKey] password: nil] )
        return YES;

    // try DSA key
    [self setConfig:[self configurationWithPublicKey: SSHUserDSAPublicKeyFile privateKey:
                     SSHUserDSAPrivateKeyFile]];
    return [self authenticateUser: username publicKeyFile:[config valueForKey:
                                                           SSHUserPublicKeyFileKey] privateKeyFile:
            [config valueForKey: SSHUserPrivateKeyFileKey] password:
            nil];
}

- (BOOL)authenticateUser: (NSString *)username publicKeyFile: (NSString *)publicKeyFile
privateKeyFile: (NSString *)privateKeyFile password: (NSString *)password;
{
    const char *passPhrase = "";
    if ( password )
        passPhrase = [password UTF8String];

    int status =
        libssh2_userauth_publickey_fromfile(session,
                                            [username UTF8String],
                                            [publicKeyFile UTF8String],
                                            [privateKeyFile UTF8String],
                                            passPhrase);

    if ( status != 0 )
        return NO;


    return YES;
}

- (BOOL)isFingerprintValid;
{
    // TODO: libssh2 1.0.x does not provide a way to easily access this info
    // skip this check for now
    return YES;
}

- (SSHChannel *)channelWithCommand: (NSString *)command;
{
    SSHChannel *channel = [[SSHChannel alloc] initWithSession: session];
    [channel execCommand: command];
    return [channel autorelease];
}

- (BOOL)disconnect;
{
    if ( session ) {
        libssh2_session_disconnect(session, "SSHSession: Normal Shutdown");
        libssh2_session_free(session);
        session = NULL;
    }

    if ( native != -1 ) {
        close(native);
        native = -1;
    }

    return YES;
}

@end
