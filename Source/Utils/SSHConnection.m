#import "SSHConnection.h"

#include <string.h>
#include "libssh2_sftp.h"
#include <netinet/in.h>
#include <sys/socket.h>
#include <netdb.h>
#include <stdio.h>

#define CSTR(x) [(x) cStringUsingEncoding:NSUTF8StringEncoding]

@implementation SSHConnection

@synthesize host;
@synthesize port;

#pragma mark error utilities

// make a generic error
+(NSError *)makeErrorWithCode:(int)code message:(NSString *)message {
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"The file could not be transferred.", NSLocalizedDescriptionKey,
																		message, NSLocalizedRecoverySuggestionErrorKey, NULL];
	return [NSError errorWithDomain:SSHConnectionErrorDomain code:code userInfo:userInfo];
}

// generates an NSError based on the last error reported by libssh2, preceded by a more general message
// generalMessage is capitalized but does not have a trailing period
+(NSError *)libssh2ErrorForSession:(LIBSSH2_SESSION *)session message:(NSString *)generalMessage {
	char *desc;
	int code = libssh2_session_last_error(session, &desc, NULL, 0);
	
	NSString *message;
	if (strlen(desc) == 0) {
		message = [generalMessage stringByAppendingString:@"."];
	} else {
		message = [NSString stringWithFormat:@"%@ (%s).",generalMessage,desc];
	}
	return [SSHConnection makeErrorWithCode:code message:message];
}



#pragma mark memory management

-(id)init
{
    self = [super init];
    sock = -1;
    session = nil;
    host = NULL;
    port = 22u;
    return self;
}

-(void)dealloc
{
    if (host)
        [host release];
    [self disconnect];
    [super dealloc];
}



# pragma mark connections

-(NSError *)connectToHost:(NSString *)newHost port:(unsigned short)newPort user:(NSString *)user password:(NSString *)password
{
    int err;
    [self disconnect]; // (if we're connected already)
    
	// resolve hostname
	NSSocketPort *socketPort = [[NSSocketPort alloc] initRemoteWithTCPPort:newPort host:newHost];
	if (![socketPort address])
        return [SSHConnection makeErrorWithCode:SSHCONNECTION_ERROR_LOOKUP message:[NSString stringWithFormat:@"Could not look up the hostname (%@).", newHost]];
	
	// establish connection
	const struct sockaddr *addr = [[socketPort address] bytes];
	sock = socket(addr->sa_family, SOCK_STREAM, 0);
	if (sock == -1)
		return [SSHConnection makeErrorWithCode:errno message:[NSString stringWithFormat:@"Socket could not be opened for connection (%i).",errno]];
	err = connect(sock, [[socketPort address] bytes], [[socketPort address] length]);
	[socketPort release];
	if (err)
		return [SSHConnection makeErrorWithCode:errno message:[NSString stringWithFormat:@"Connection failed (%i).",errno]];
	
	// establish SSH session
	session = libssh2_session_init();
	if (libssh2_session_startup(session, sock)) {
		[self disconnect];
        return [SSHConnection makeErrorWithCode:SSHCONNECTION_ERROR_SESSION message:@"SSH session establishment failed."];
	}
	
	// authenticate
	// FIXME skipping fingerprint validation!
	if (libssh2_userauth_password(session, CSTR(user), CSTR(password))) {
        [self disconnect];
		return [SSHConnection makeErrorWithCode:SSHCONNECTION_ERROR_AUTH message:@"Authentication failed."];
	}
	
    host = [newHost copy];
    port = newPort;
	return NULL;
}

-(NSError *)connectToHost:(NSString *)newHost user:(NSString *)user password:(NSString *)password
{
    return [self connectToHost:newHost port:22u user:user password:password];
}

-(void)disconnect
{
    if (session) {
        libssh2_session_free(session);
        session = nil;
    }
    
    if (sock != -1) {
        close(sock);
        sock = -1;
    }
    
    if (host) {
        [host release];
        host = NULL;
    }
    port = 22u;
}

+(SSHConnection *)connectionToURL:(NSURL *)url error:(NSError **)errorOut
{
    SSHConnection *conn = [[[SSHConnection alloc] init] autorelease];
    
    NSError *err = [conn connectToHost:[[url host] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                                  user:[[url user] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                              password:[[url password] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    if (err && errorOut) {
        *errorOut = err;
        return NULL;
    }
        
    return conn;
}

+(SSHConnection *)connectionToURL:(NSURL *)url
{
    return [SSHConnection connectionToURL:url error:NULL];
}



#pragma mark scp

-(NSError *)writeData:(NSData *)data toPath:(NSString *)destPath
{
    if (!session)
        return [SSHConnection makeErrorWithCode:SSHCONNECTION_ERROR_NOSESSION message:@"Data can't be written because no session is open."];
    
    // open scp channel
	LIBSSH2_CHANNEL *channel = libssh2_scp_send(session, CSTR(destPath), 0666, [data length]);
	if (!channel) {
        NSError *err = [SSHConnection libssh2ErrorForSession:session message:@"scp channel initialization failed"];
        [self disconnect];
		return err;
	}
	libssh2_channel_set_blocking(channel,1);
	
	// write the calendar
	int written = libssh2_channel_write(channel, [data bytes], [data length]);
	if (written != [data length]) {
		return [SSHConnection libssh2ErrorForSession:session message:@"Some data could not be written"];
	}
	libssh2_channel_send_eof(channel);

    return NULL;
}

+(NSError *)scpData:(NSData *)data to:(NSURL *)url
{
    NSError *err = NULL;
    
    SSHConnection *conn = [SSHConnection connectionToURL:url error:&err];
    if (err) return err;
    
    err = [conn writeData:data toPath:[[url path] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/"]]];
    [conn disconnect];
    
    return err;
}



# pragma mark sftp

-(NSError *)deleteFileAtPath:(NSString *)path
{
    NSError *err = NULL;

    if (!session)
        return [SSHConnection makeErrorWithCode:SSHCONNECTION_ERROR_NOSESSION message:@"File cannot be deleted because no session is open."];
    
    LIBSSH2_SFTP *sftp = libssh2_sftp_init(session);
	if (!sftp)
		return [SSHConnection libssh2ErrorForSession:session message:@"SFTP session initialization failed"];
	
	if (libssh2_sftp_unlink(sftp, (char *)CSTR(path)))
		err = [SSHConnection libssh2ErrorForSession:session message:@"File could not be deleted"];
    
    libssh2_sftp_shutdown(sftp);
    
    return err;
}

+(NSError *)deleteFileAtURL:(NSURL *)url
{
    NSError *err = NULL;
    
    SSHConnection *conn = [SSHConnection connectionToURL:url error:&err];
    if (err) return err;
    
    err = [conn deleteFileAtPath:[[url path] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/"]]];
    [conn disconnect];
    
    return err;
}

@end
