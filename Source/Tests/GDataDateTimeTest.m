/* Copyright (c) 2007 Google Inc.
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*     http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

//
//  GDataDateTimeTest.m
//

#import <XCTest/XCTest.h>

#import "GDataDateTime.h"

#define typeof __typeof__ // fixes http://www.brethorsting.com/blog/2006/02/stupid-issue-with-ocunit.html

@interface GDataDateTimeTest : XCTestCase
@end

@implementation GDataDateTimeTest
- (void)testGDataDateTime {
  
  const NSCalendarUnit kComponents = 
    NSEraCalendarUnit
    | NSYearCalendarUnit 
    | NSMonthCalendarUnit 
    | NSDayCalendarUnit
    | NSHourCalendarUnit
    | NSMinuteCalendarUnit
    | NSSecondCalendarUnit;
  
  struct DateTimeTestRecord {
    NSString *dateTimeStr;
    NSInteger year;
    NSInteger month;
    NSInteger day;
    NSInteger hour;
    NSInteger minute;
    NSInteger second;
    NSInteger timeZoneOffsetSeconds;
    BOOL isUniversalTime;
    BOOL hasTime;
  };
  
  struct DateTimeTestRecord tests[] = {
    { @"2006-10-14T15:00:00-01:00", 2006, 10, 14, 15, 0, 0, -60*60, 0, 1 },
    { @"2006-10-14T15:00:00Z", 2006, 10, 14, 15, 0, 0, 0, 1, 1 },
    { @"2006-10-14", 2006, 10, 14, 12, 0, 0, 0, 1, 0 },
    { nil, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
  };
  
  int idx;
  for (idx = 0; tests[idx].dateTimeStr != nil; idx++) {
  
    NSString *testString1 = tests[idx].dateTimeStr;
    GDataDateTime *dateTime = [GDataDateTime dateTimeWithRFC3339String:testString1];
    NSString *outputString = [dateTime RFC3339String];
    
    XCTAssertEqualObjects(outputString, testString1, @"failed to recreate string %@ as %@", testString1, outputString); 

    NSDate *outputDate = [dateTime date];
    
    NSCalendar *cal = [dateTime calendar];
    NSDateComponents *outputComponents = [cal components:kComponents 
                                                fromDate:outputDate];
    XCTAssertEqual([outputComponents year], tests[idx].year, @"bad year");
    XCTAssertEqual([outputComponents month], tests[idx].month, @"bad month");
    XCTAssertEqual([outputComponents day], tests[idx].day, @"bad day");
    XCTAssertEqual([outputComponents hour], tests[idx].hour, @"bad hour");
    XCTAssertEqual([outputComponents minute], tests[idx].minute, @"bad minute");
    XCTAssertEqual([outputComponents second], tests[idx].second, @"bad second");

    XCTAssertEqual([[dateTime timeZone] secondsFromGMT], tests[idx].timeZoneOffsetSeconds, @"bad timezone");
    XCTAssertEqual([dateTime isUniversalTime], tests[idx].isUniversalTime, @"bad Zulu value");
    XCTAssertEqual([dateTime hasTime], tests[idx].hasTime, @"bad hasTime value");
    
    if ([dateTime hasTime]) {
      // remove the time, test the output
      [dateTime setHasTime:NO];
      NSString *outputStringWithoutTime = [dateTime RFC3339String];
      XCTAssertFalse([dateTime hasTime], @"should have time removed");
      XCTAssertTrue([testString1 hasPrefix:outputStringWithoutTime]
                   && [testString1 length] > [outputStringWithoutTime length],
                   @"bad string after time removed");
    } else {
      // add time, test the output
      [dateTime setHasTime:YES];
      NSString *outputStringWithTime = [dateTime RFC3339String];
      XCTAssertTrue([dateTime hasTime], @"should have time added");
      XCTAssertTrue([outputStringWithTime hasPrefix:testString1]
                   && [testString1 length] < [outputStringWithTime length],
                   @"bad string after time removed");
    }
  }
}

- (void)testTimeZonePreservation {
  NSTimeZone *denverTZ = [NSTimeZone timeZoneWithName:@"America/Denver"];
  NSCalendarDate *date = [NSCalendarDate dateWithYear:2007 month:01 day:01 
                                                 hour:01 minute:01 second:01 
                                             timeZone:denverTZ];
  
  GDataDateTime *dateTime = [GDataDateTime dateTimeWithDate:date 
                                                   timeZone:denverTZ];
  NSTimeZone *testTZ = [dateTime timeZone];
  XCTAssertEqualObjects(testTZ, denverTZ, @"Time zone changed");
}
@end

//2006-11-20 17:53:23.880 otest[5401] timezone=GMT-0100 (GMT-0100) offset -3600
//2006-11-20 17:53:23.880 otest[5401] era:1 year:2006 month:10 day:14   hour:15 min:0 sec:0
