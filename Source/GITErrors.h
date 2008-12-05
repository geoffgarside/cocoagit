//
//  GITError.h
//  CocoaGit
//
//  Created by Geoffrey Garside on 09/11/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString const * GITErrorDomain;

#pragma mark PACK and Index Error Codes
extern const NSInteger GITErrorPackIndexReadFailure;
extern const NSInteger GITErrorPackIndexUnsupportedVersion;

#pragma mark Store error codes
extern const NSInteger GITErrorObjectStoreSizeMismatch;
extern const NSInteger GITErrorObjectStoreMissingObject;

@end
