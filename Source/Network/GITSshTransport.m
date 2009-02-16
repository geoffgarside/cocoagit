//
//  GITSshTransport.m
//  CocoaGit
//
//  Created by Brian Chapados on 2/12/09.
//  Copyright 2009 Brian Chapados. All rights reserved.
//
#import "GITSshTransport.h"

@interface GITSshTransport ()
@property (nonatomic, retain) SSHSession *session;
@property (nonatomic, copy) NSError *error;
@property (nonatomic, copy) NSString *status;
@end


@implementation GITSshTransport
@synthesize session;
@synthesize error;
@synthesize status;

+ (BOOL) canHandleURL:(NSURL *)aURL;
{
    return [[aURL scheme] isEqualToString:@"ssh"];
}

- (void) dealloc;
{
    [self disconnect];
    [connection release];
    [session release];
    [super dealloc];
}

- (BOOL) connect;
{
    // Parse host, port, and path out of user's URL
	// int userPort = [[remoteURL port] intValue];
	NSString *userHostName = [remoteURL host];
    NSString *userName = [remoteURL user];
    
    NSError *sessionError;
    SSHSession *sshSession = [SSHSession sessionToHost:userHostName port:22 error:&sessionError];
    
    if (! sshSession) {
        NSLog(@"Error: %@", [sessionError localizedDescription]);
        [self setError:sessionError];
        return NO;
    }

    if (! [sshSession start:&sessionError]) {
        NSLog(@"Error: %@", [sessionError localizedDescription]);
        [self setError:sessionError];
        return NO;
    }
    
    if (! [sshSession authenticateUser:userName]) {
        NSLog(@"authentication error for user: %@", userName);
        [sshSession disconnect];
        return NO;
    }
    
    [self setSession:sshSession];
    return YES;
}

- (void) startFetch;
{
    // Parse path out of user's URL
	NSString *userPath = [remoteURL path];
    
    // Construct command
    // NOTE: the repository argument must be surrounded by single-quotes
	// "git-upload-pack 'myrepo.git'"
    // We are doing the equivalent of this command:
    // ssh git@github.com "git-upload-pack 'geoffgarside/cocoagit.git'"
    if ([userPath hasPrefix:@"/"])
        userPath = [userPath substringFromIndex:1];

	NSString *command = [NSString stringWithFormat:@"git-upload-pack '%@'", userPath];
    SSHChannel *sshChannel = [[self session] channelWithCommand:command];

    if (! sshChannel) {
        NSLog(@"Could not open channel");
        return;
    }
    
    [self setConnection:sshChannel];
    [self setStatus:GITTransportFetch];
}



@end
