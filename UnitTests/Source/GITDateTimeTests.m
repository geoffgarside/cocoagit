//
//  GITDateTimeTests.m
//  CocoaGit
//
//  Created by Geoffrey Garside on 07/10/2008.
//  Copyright 2008 ManicPanda.com. All rights reserved.
//

#import "GITDateTimeTests.h"
#import "GITDateTime.h"
#import "NSTimeZone+Offset.h"

@implementation GITDateTimeTests

- (void)testInitWithDateAndTimeZone
{
    NSDate * date = [NSDate date];
    NSTimeZone * timezone = [NSTimeZone timeZoneWithStringOffset:@"+0100"];
    
    GITDateTime * dateTime = [[GITDateTime alloc] initWithDate:date timeZone:timezone];
    STAssertNotNil(dateTime, @"Should not be nil");
    STAssertEqualObjects(dateTime.date, date, @"Should be the same");
    STAssertEqualObjects(dateTime.timezone, timezone, @"Should be the same");
}
- (void)testInitWithTimestampAndTimeZoneOffset
{
    NSDate * date = [NSDate dateWithTimeIntervalSince1970:1214920980];
    NSTimeZone * timezone = [NSTimeZone timeZoneWithStringOffset:@"+0100"];
    
    GITDateTime * dateTime = [[GITDateTime alloc] initWithTimestamp:[date timeIntervalSince1970]
                                                     timeZoneOffset:@"+0100"];
    STAssertNotNil(dateTime, @"Should not be nil");
    STAssertEqualObjects(dateTime.date, date, @"Should be the same");
    STAssertEqualObjects(dateTime.timezone, timezone, @"Should be the same");
}
- (void)testDateTimeDescription
{
    GITDateTime * dateTime = [[GITDateTime alloc] initWithTimestamp:1214920980 timeZoneOffset:@"+0100"];
    STAssertEqualObjects([dateTime description], @"1214920980 +0100", @"Should format datetime with timezone correctly");
}
@end
