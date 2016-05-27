//
//  TimerUtils.h
//  YY2
//
//  Created by Qun Huang on 13-4-2.
//  Copyright (c) 2013年 YY Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kTimerUtilsNotificationTaskIdInfoKey;

@interface BSTimerUtils : NSObject

+ (void)startRepeatTimer:(NSTimeInterval)timeInterval delegate:(id)delegate selector:(SEL)aSelector;
+ (void)stopRepeatTimer:(NSTimeInterval)timeInterval delegate:(id)delegate;

+ (id)startRepeatedTaskWithDelegate:(id)delegate selector:(SEL)selector interval:(NSTimeInterval)seconds;
+ (void)stopRepeatedTaskWithDelegate:(id)delegate selector:(SEL)selector interval:(NSTimeInterval)seconds;
+ (void)stopRepeatedTaskWithTaskId:(id)taskId;

@end
