/* Copyright (c) 2008 Google Inc.
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

#import <XCTest/XCTest.h>
#import "GDataServerError.h"

#define typeof __typeof__ // fixes http://brethorsting.com/blog/2006/02/25/stupid-issue-with-ocunit/

@interface GDataServerErrorTest : XCTestCase
@end

@implementation GDataServerErrorTest

- (void)testServerErrorGroup {

  // define XML for an errors group with two errors
  NSString *xmlStr = @"<errors xmlns='http://schemas.google.com/g/2005'>"

    "<error><domain>GData domain</domain><code>code red</code>"
    "<internalReason>something happened</internalReason>"
    "<extendedHelp>http://domain.com?whatever=no</extendedHelp>"
    "<sendReport>http://domain.com/send</sendReport></error>"

    "<error><domain>Second domain</domain><code>code blue</code>"
    "<internalReason>who knows</internalReason></error></errors>";

  NSData *xmlData = [xmlStr dataUsingEncoding:NSUTF8StringEncoding];

  GDataServerErrorGroup *group, *groupCopy;

  group = [[[GDataServerErrorGroup alloc] initWithData:xmlData] autorelease];

  // copy the group, to exercise all the copying code
  groupCopy = [[group copy] autorelease];

  XCTAssertEqual([[groupCopy errors] count], (NSUInteger) 2,
                 @"should be two errors");

  GDataServerError *error = [groupCopy mainError];

  // this error should be equal to the one in the original error group,
  // but a distinct copy
  XCTAssertEqualObjects(error, [group mainError], @"copy is unequals");
  XCTAssertTrue(error != [group mainError], @"copy is not distinct");

  // test the error fields
  XCTAssertEqualObjects([error domain], @"GData domain", @"domain test");
  XCTAssertEqualObjects([error code], @"code red", @"code test");
  XCTAssertEqualObjects([error internalReason], @"something happened", @"reason test");
  XCTAssertEqualObjects([error extendedHelpURI], @"http://domain.com?whatever=no", @"help test");
  XCTAssertEqualObjects([error sendReportURI], @"http://domain.com/send", @"send test");
  XCTAssertEqualObjects([error summary], @"GData domain error code red: \"something happened\"", @"summary test");

  GDataServerError *error2 = [[group errors] lastObject];
  XCTAssertEqualObjects([error2 domain], @"Second domain", @"domain test");
  XCTAssertEqualObjects([error2 code], @"code blue", @"code test");
  XCTAssertEqualObjects([error2 internalReason], @"who knows", @"reason test");
  XCTAssertNil([error2 extendedHelpURI], @"help test");
  XCTAssertNil([error2 sendReportURI], @"send test");

  // test invalid input
  xmlStr = @"abcdefg";
  xmlData = [xmlStr dataUsingEncoding:NSUTF8StringEncoding];
  group = [[GDataServerErrorGroup alloc] initWithData:xmlData];
  XCTAssertNil(group, @"invalid error xml data");

  xmlStr = @"<errors xmlns='http://schemas.google.com/g/2005 />";
  xmlData = [xmlStr dataUsingEncoding:NSUTF8StringEncoding];
  group = [[[GDataServerErrorGroup alloc] initWithData:xmlData] autorelease];
  XCTAssertNil(group, @"empty errors list data");
}

@end
