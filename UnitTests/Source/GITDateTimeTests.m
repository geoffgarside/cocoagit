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
    
    GITDateTime * dateTime = [[[GITDateTime alloc] initWithDate:date timeZone:timezone] autorelease];
    GHAssertNotNil(dateTime, @"Should not be nil");
    GHAssertEqualObjects(dateTime.date, date, @"Should be the same");
    GHAssertEqualObjects(dateTime.timezone, timezone, @"Should be the same");
}
- (void)testInitWithTimestampAndTimeZoneOffset
{
    NSDate * date = [NSDate dateWithTimeIntervalSince1970:1214920980];
    NSTimeZone * timezone = [NSTimeZone timeZoneWithStringOffset:@"+0100"];
    
    GITDateTime * dateTime = [[[GITDateTime alloc] initWithTimestamp:[date timeIntervalSince1970]
                                                     timeZoneOffset:@"+0100"] autorelease];
    GHAssertNotNil(dateTime, @"Should not be nil");
    GHAssertEqualObjects(dateTime.date, date, @"Should be the same");
    GHAssertEqualObjects(dateTime.timezone, timezone, @"Should be the same");
}
- (void)testDateTimeDescription
{
    GITDateTime * dateTime = [[[GITDateTime alloc] initWithTimestamp:1214920980 timeZoneOffset:@"+0100"] autorelease];
    GHAssertEqualObjects([dateTime description], @"1214920980 +0100", @"Should format datetime with timezone correctly");
}
- (void)testCompare
{
    NSTimeInterval nowTimeInterval = [NSDate timeIntervalSinceReferenceDate];
    NSTimeInterval beforeTimeInterval = nowTimeInterval - 1.0;
    NSTimeInterval afterTimeInterval = nowTimeInterval + 1.0;
    NSString *timeZoneOffset = @"+0100";
    
    GITDateTime *before = [[[GITDateTime alloc] initWithTimestamp:beforeTimeInterval timeZoneOffset:timeZoneOffset] autorelease];
    GITDateTime *now = [[[GITDateTime alloc] initWithTimestamp:nowTimeInterval timeZoneOffset:timeZoneOffset] autorelease];
    GITDateTime *after = [[[GITDateTime alloc] initWithTimestamp:afterTimeInterval timeZoneOffset:timeZoneOffset] autorelease];
    
    GHAssertThrowsSpecificNamed([before compare:nil], NSException, NSInternalInconsistencyException, nil);
    
    GHAssertEquals([before compare:before], NSOrderedSame, nil);
    GHAssertEquals([before compare:[[before copy] autorelease]], NSOrderedSame, nil);
    
    GHAssertEquals([before compare:now], NSOrderedAscending, nil);
    GHAssertEquals([before compare:after], NSOrderedAscending, nil);
    
    GHAssertEquals([now compare:before], NSOrderedDescending, nil);
    GHAssertEquals([now compare:after], NSOrderedAscending, nil);
    
    GHAssertEquals([after compare:before], NSOrderedDescending, nil);
    GHAssertEquals([after compare:now], NSOrderedDescending, nil);
    
    NSArray *descArray = [NSArray arrayWithObjects:after, now, before, nil];
    NSArray *descArraySortedToAscArray = [descArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"self" ascending:YES] autorelease]]];
    GHAssertTrue(before == [descArraySortedToAscArray objectAtIndex:0], nil);
    GHAssertTrue(now == [descArraySortedToAscArray objectAtIndex:1], nil);
    GHAssertTrue(after == [descArraySortedToAscArray objectAtIndex:2], nil);
    
    // TODO: test timezones
}
@end
