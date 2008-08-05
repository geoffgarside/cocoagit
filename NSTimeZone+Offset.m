//
//  NSTimeZone+Offset.m
//  CocoaGit
//
//  Created by Geoffrey Garside on 28/07/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import "NSTimeZone+Offset.h"


@implementation NSTimeZone (Offset)

+ (id)timeZoneWithStringOffset:(NSString*)offset
{
    NSString * hours = [offset substringWithRange:NSMakeRange(1, 2)];
    NSString * mins  = [offset substringWithRange:NSMakeRange(3, 2)];
    
    NSInteger seconds = ([hours integerValue] * 3600) + ([mins integerValue] * 60);
    if ([offset characterAtIndex:0] == '-')
        seconds = seconds * -1;
    
    return [self timeZoneForSecondsFromGMT:seconds];
}

@end
