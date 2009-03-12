//
//  SSHError.h
//  SSHSession
//
//  Created by Brian Chapados on 1/29/09.
//  Copyright 2009 Brian Chapados. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "libssh2.h"

struct error_code {
    NSInteger val;
    NSString *identifier;
};

#define __ssh_error(code, val) extern struct error_code code
#define __ssh_error_domain(dom, code) extern NSString * const dom

extern NSString *const SSHErrorDomain;

#import "NSError-OBExtensions.h"
// Define SSHError* macros to use the OmniBase _OBError helper functions. If we
// decide to move away from OmniBase code, we can just redfine these.
#define SSHErrorWithDescription(error, code, description, ...) _OBErrorWithDescription(\
        error, \
        SSHErrorDomain, \
        code.val, \
        __FILE__, \
        __LINE__, \
        description)
#define SSHError(error, code, description) _OBError(error,\
                                                    SSHErrorDomain, \
                                                    code, \
                                                    __FILE__, \
                                                    __LINE__, \
                                                    NSLocalizedDescriptionKey, \
                                                    description, \
                                                    nil)
#define SSHErrorWithInfo(error, code, ...) _OBError(error,\
                                                    SSHErrorDomain, \
                                                    code, \
                                                    __FILE__, \
                                                    __LINE__, \
                                                    # # __VA_ARGS__)

__ssh_error(SSHErrorLookup, 4915);
__ssh_error(SSHErrorAuth, 4916);
__ssh_error(SSHErrorNoSession, 4917);
__ssh_error(SSHErrorSession, 4918);
__ssh_error(SSHErrorChannel, 4919);
__ssh_error(SSHErrorSocketOpen, 4920);
__ssh_error(SSHErrorSocketConnection, 4921);

NSString *
libssh2ErrorDescription(LIBSSH2_SESSION *session, NSString *description);


#undef __ssh_error
#undef __ssh_error_domain
