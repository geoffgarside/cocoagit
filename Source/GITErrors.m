//
//  GITError.m
//  CocoaGit
//
//  Created by Geoffrey Garside on 09/11/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import "GITErrors.h"

NSString const * GITErrorDomain = @"com.manicpanda.GIT.ErrorDomain";

const NSInteger GITErrorPackIndexReadFailure        = -1;
const NSInteger GITErrorPackIndexUnsupportedVersion = -2;

const NSInteger GITErrorObjectStoreSizeMismatch     = -3;
const NSInteger GITErrorObjectStoreMissingObject    = -4;
