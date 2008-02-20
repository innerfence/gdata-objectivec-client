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
//  GDataReminder.h
//

#import "GDataObject.h"

#undef _EXTERN
#undef _INITIALIZE_AS
#ifdef GDATAREMINDER_DEFINE_GLOBALS
#define _EXTERN 
#define _INITIALIZE_AS(x) =x
#else
#define _EXTERN extern
#define _INITIALIZE_AS(x)
#endif

// When reading reminders from a feed, "none" and "all" do not apply.
// For an explanation of setting reminder methods when writing an event,
// see the comments at the top of the Java client library file Reminder.java
_EXTERN NSString* kGDataReminderMethodSMS _INITIALIZE_AS(@"sms");
_EXTERN NSString* kGDataReminderMethodEmail _INITIALIZE_AS(@"email");
_EXTERN NSString* kGDataReminderMethodAlert _INITIALIZE_AS(@"alert");
_EXTERN NSString* kGDataReminderMethodNone _INITIALIZE_AS(@"none");
_EXTERN NSString* kGDataReminderMethodAll _INITIALIZE_AS(@"all");

// reminder, as in 
//   <gd:reminder absoluteTime="2005-06-06T16:55:00-08:00" method="sms" />
//
// http://code.google.com/apis/gdata/common-elements.html#gdReminder

@interface GDataReminder : GDataObject <NSCopying, GDataExtension> {
  NSString* days_;
  NSString* hours_;
  NSString* minutes_;
  NSString* method_;
  GDataDateTime* absoluteTime_;
}
+ (GDataReminder *)reminder;

- (id)initWithXMLElement:(NSXMLElement *)element
                  parent:(GDataObject *)parent;
- (NSString *)days;
- (void)setDays:(NSString *)str;
- (NSString *)hours;
- (void)setHours:(NSString *)str;
- (NSString *)minutes;
- (void)setMinutes:(NSString *)str;
- (NSString *)method;
- (void)setMethod:(NSString *)str; // use kGDataReminderMethod strings defined above
- (GDataDateTime *)absoluteTime;
- (void)setAbsoluteTime:(GDataDateTime *)cdate;
@end
