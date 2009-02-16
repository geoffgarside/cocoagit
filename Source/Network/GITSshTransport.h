//
//  GITSshTransport.h
//  CocoaGit
//
//  Created by chapbr on 2/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GITTransport.h"
#import "SSHSession.h"
#import "SSHChannel.h"

@interface GITSshTransport : GITTransport {
    SSHSession *session;
}
@end
