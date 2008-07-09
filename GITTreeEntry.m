//
//  GITTreeEntry.m
//  CocoaGit
//
//  Created by Geoffrey Garside on 06/07/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import "GITTreeEntry.h"


@implementation GITTreeEntry

- (NSString*)description
{
    return [NSString stringWithFormat:@"%u %@ %@",
            self.mode, self.name, self.sha1];
}

@end
