//
//  GITError.h
//  CocoaGit
//
//  Created by Geoffrey Garside on 09/11/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//
// We use the __git_error and __git_error_domain macros to
// make it easier to enter and update the error codes in
// the project. If you define them here with the macro then
// you can copy/paste the same code into GITErrors.m and
// then add the value argument to the end of them.
//

#import <Foundation/Foundation.h>
#define __git_error(code) extern const NSInteger code
#define __git_error_domain(dom) extern NSString const * dom

__git_error_domain(GITErrorDomain);

#pragma mark Object Loading Errors
__git_error(GITErrorObjectSizeMismatch);
__git_error(GITErrorObjectNotFound);

#pragma mark PACK and Index Error Codes
__git_error(GITErrorPackIndexReadFailure);
__git_error(GITErrorPackIndexUnsupportedVersion);

#undef __git_error
#undef __git_error_domain
