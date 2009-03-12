//
//  SSHSession.h
//  SSHSession
//
//  Created by Brian Chapados on 2/6/09.
//  Copyright 2009 Brian Chapados. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "SSHChannel.h"

extern NSString *const SSHUserDirectory;
extern NSString *const SSHUserPublicKeyFileKey;
extern NSString *const SSHUserPublicKeyFile;
extern NSString *const SSHUserPrivateKeyFileKey;
extern NSString *const SSHUserPrivateKeyFile;

@interface SSHSession : NSObject {
    NSSocketNativeHandle native;
    LIBSSH2_SESSION *session;
    NSDictionary *config;
}
@property (readwrite, copy) NSDictionary *config;

+ (id)sessionToHost: (NSString *)aHost port: (unsigned short)aPort error: (NSError **)error;

- (id)initWithSocket: (NSSocketNativeHandle)sock;
- (BOOL)start: (NSError **)error;
- (BOOL)disconnect;

// configuration - mainly for public-key auth right now
- (NSDictionary *)configurationWithSshDir: (NSString *)sshDir publicKey: (NSString *)publicKey
privateKey: (NSString *)privateKey;
- (NSDictionary *)configurationWithPublicKey: (NSString *)publicKey privateKey: (NSString *)
privateKey;
- (NSDictionary *)defaultConfiguration;

// authentication
- (NSString *)authenticationTypesWithUser: (NSString *)username;
- (BOOL)authenticateUser: (NSString *)username password: (NSString *)password;
- (BOOL)authenticateUser: (NSString *)username publicKeyFile: (NSString *)publicKeyFile
privateKeyFile: (NSString *)privateKeyFile password: (NSString *)password;
- (BOOL)authenticateUser: (NSString *)username;
- (BOOL)isFingerprintValid;

// factory methods for opening channels
//- (SSHChannel *)channelWithShell;
- (SSHChannel *)channelWithCommand: (NSString *)command;

@end
