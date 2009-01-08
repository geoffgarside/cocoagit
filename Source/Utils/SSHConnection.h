// SSHConnection
// Adrian Sampson
// A lightweight Objective-C wrapper for libssh2. For now only supports scp transfers
// and SFTP deletes.
// Functions that return NSError* return NULL on success.

#import <Foundation/Foundation.h>
#include "libssh2.h"

#define SSHConnectionErrorDomain @"com.pygmy.SSHConnection.ErrorDomain"
#define SSHCONNECTION_ERROR_LOOKUP        4915 // hostname is invalid
#define SSHCONNECTION_ERROR_AUTH          4916 // authentication failed
#define SSHCONNECTION_ERROR_NOSESSION     4917 // tried to write data while not connected
#define SSHCONNECTION_ERROR_SESSION       4918 // couldn't open session

@interface SSHConnection : NSObject {
    int sock;
    LIBSSH2_SESSION *session;
    
    NSString *host;
    unsigned short port;
}
@property(readonly) NSString *host;
@property(readonly) unsigned short port;

// managing SSH connections
-(NSError *)connectToHost:(NSString *)host port:(unsigned short)port user:(NSString *)user password:(NSString *)password;
-(NSError *)connectToHost:(NSString *)host user:(NSString *)user password:(NSString *)password; // port 22
-(void)disconnect;
+(SSHConnection *)connectionToURL:(NSURL *)url;
+(SSHConnection *)connectionToURL:(NSURL *)url error:(NSError **)err;

// scp transfers
-(NSError *)writeData:(NSData *)data toPath:(NSString *)destPath;
+(NSError *)scpData:(NSData *)data to:(NSURL *)url;

// sftp deletes
-(NSError *)deleteFileAtPath:(NSString *)path;
+(NSError *)deleteFileAtURL:(NSURL *)url;

@end
