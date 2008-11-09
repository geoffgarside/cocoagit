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
const NSInteger GITPackIndexErrorCannotRead = -1;
const NSInteger GITPackIndexErrorVersionUnsupported = -2;

@end
