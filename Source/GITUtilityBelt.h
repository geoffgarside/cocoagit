//
//  GITUtilityBelt.h
//  CocoaGit
//
//  Created by Geoffrey Garside on 12/08/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NSData   * packSHA1(NSString * unpackedSHA1);
NSString * unpackSHA1FromString(NSString * packedSHA1);
NSString * unpackSHA1FromData(NSData * packedSHA1);
NSUInteger integerFromBytes(unichar * bytes, NSUInteger length);