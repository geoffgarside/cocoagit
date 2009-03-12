//
//  SSHError.m
//  SSHSession
//
//  Created by Brian Chapados on 1/29/09.
//  Copyright 2009 Brian Chapados. All rights reserved.
//


#import "SSHError.h"


#define __ssh_error_domain(dom, str) NSString * const dom = str
#define __ssh_error(code, val) struct error_code code = { val, @ # code }

__ssh_error_domain(SSHErrorDomain, @"org.sciencegeeks.SSHSession.ErrorDomain");

__ssh_error(SSHErrorLookup, 4915);
__ssh_error(SSHErrorAuth, 4916);
__ssh_error(SSHErrorNoSession, 4917);
__ssh_error(SSHErrorSession, 4918);
__ssh_error(SSHErrorChannel, 4919);
__ssh_error(SSHErrorSocketOpen, 4920);
__ssh_error(SSHErrorSocketConnection, 4921);


// generates an error message based on the last error reported by libssh2,
// preceded by a more general general description
NSString *
libssh2ErrorDescription(LIBSSH2_SESSION *session, NSString *description){
    char *ssh2_error;
    int ssh2_code = libssh2_session_last_error(session, &ssh2_error, NULL, 0);

    NSString *errorDescription;
    if ( strlen(ssh2_error) == 0 )
        errorDescription =
            [NSString stringWithFormat: @"%@ ([LIBSSH2 Error %d]", description, ssh2_code];
    else
        errorDescription =
            [NSString stringWithFormat: @"%@ ([LIBSSH2 Error %d]: %s)", description, ssh2_code,
        ssh2_error];
    return errorDescription;
}
