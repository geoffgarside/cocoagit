//
//  GITObject.h
//  CocoaGit
//
//  Created by Geoffrey Garside on 05/08/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

@class GITRepo;
@protocol GITObject <NSCopying>

- (id)initWithHash:(NSString*)hash
           andData:(NSData*)data
          fromRepo:(GITRepo*)repo;
- (NSData*)rawData; //!< For writing objects (may change to -data)

@end
