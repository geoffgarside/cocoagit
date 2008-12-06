//
//  GITError.m
//  CocoaGit
//
//  Created by Geoffrey Garside on 09/11/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import "GITErrors.h"
#define __git_error(code, val) const NSInteger code = val
#define __git_error_domain(dom, str) NSString const * dom = str

__git_error_domain(GITErrorDomain, @"com.manicpanda.GIT.ErrorDomain");

#pragma mark Object Loading Errors
__git_error(GITErrorObjectSizeMismatch,             -1);
__git_error(GITErrorObjectNotFound,                 -2);

#pragma mark PACK and Index Error Codes
__git_error(GITErrorPackIndexReadFailure,           -3);
__git_error(GITErrorPackIndexUnsupportedVersion,    -4);

#undef __git_error
