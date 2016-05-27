//
//  TimerUtils.m
//  YY2
//
//  Created by Qun Huang on 13-4-2.
//  Copyright (c) 2013年 YY Inc. All rights reserved.
//

#import "BSTimerUtils.h"
//#import "BSLogger.h"

NSString * const kTimerUtilsNotificationTaskIdInfoKey = @"kTimerUtilsNotificationTaskIdInfoKey";
NSString * const kTimerUtilsNotificationNameKey = @"kTimerUtilsNotificationNameKey";
static NSString *const kTimerNotificationNameFormat = @"%p|%p|%f";

@interface TimerUtilsTaskIdInfo : NSObject

@property (weak, atomic) id delegate;
@property (unsafe_unretained, atomic) SEL selector;
@property (assign, atomic) NSTimeInterval interval;

@end

@implementation TimerUtilsTaskIdInfo

@synthesize delegate = _delegate;
@synthesize selector = _selector;
@synthesize interval = _interval;

@end

@interface BSTimerUtils()
{
    NSMutableDictionary *_timeDict;
}
@end

@implementation BSTimerUtils

static BSTimerUtils *sharedSingleton;

-(id)init
{
    if(self=[super init]){
        _timeDict = [[NSMutableDictionary alloc] init];
    }
    return self;
}

+ (BSTimerUtils *)sharedObject
{
    @synchronized(self)
    {
        if (!sharedSingleton)
            sharedSingleton = [[BSTimerUtils alloc] init];
        
        return sharedSingleton;
    }
}
+ (void)startRepeatTimer:(NSTimeInterval)timeInterval delegate:(id)delegate selector:(SEL)aSelector
{
    NSString *notificationName = [NSString stringWithFormat:@"%d|%d",(int)delegate,(int)(timeInterval * 1000) ];
    if([[BSTimerUtils sharedObject] startRepeatTimer:timeInterval notifiName:notificationName withTaskIdInfo:nil])
    {
        [[NSNotificationCenter defaultCenter] addObserver:delegate
                                                 selector:aSelector
                                                     name:notificationName
                                                   object:[BSTimerUtils sharedObject]];
    }
}

+ (void)stopRepeatTimer:(NSTimeInterval)timeInterval delegate:(id)delegate
{
    NSString *notificationName = [NSString stringWithFormat:@"%d|%d",(int)delegate,(int)(timeInterval * 1000) ];
    [[NSNotificationCenter defaultCenter] removeObserver:delegate name:notificationName object:nil];
    [[BSTimerUtils sharedObject] stopRepeatTimer:notificationName];
}

+ (id)startRepeatedTaskWithDelegate:(id)delegate selector:(SEL)selector interval:(NSTimeInterval)seconds
{
    TimerUtilsTaskIdInfo *taskIdInfo = [TimerUtilsTaskIdInfo new];
    taskIdInfo.delegate = delegate;
    taskIdInfo.selector = selector;
    taskIdInfo.interval = seconds;
    
    NSString *notificationName = [NSString stringWithFormat:kTimerNotificationNameFormat, delegate, selector, seconds];
    BSTimerUtils *timerUtils = [BSTimerUtils sharedObject];
    if ( [timerUtils startRepeatTimer:seconds notifiName:notificationName withTaskIdInfo:(TimerUtilsTaskIdInfo *)taskIdInfo] )
    {
        [[NSNotificationCenter defaultCenter] addObserver:delegate
                                                 selector:selector
                                                     name:notificationName
                                                   object:timerUtils];
    } else {
        taskIdInfo = nil;
    }
    return taskIdInfo;
}

+ (void)stopRepeatedTaskWithDelegate:(id)delegate selector:(SEL)selector interval:(NSTimeInterval)seconds
{
    NSString *notificationName = [NSString stringWithFormat:kTimerNotificationNameFormat, delegate, selector, seconds];
    BSTimerUtils *timerUtils = [BSTimerUtils sharedObject];
    [[NSNotificationCenter defaultCenter] removeObserver:delegate name:notificationName object:timerUtils];
    [timerUtils stopRepeatTimer:notificationName];
}

+ (void)stopRepeatedTaskWithTaskId:(id)taskId
{
    if ( taskId != nil )
    {
        if ( ![taskId isKindOfClass:[TimerUtilsTaskIdInfo class]] )
        {
//            MFLogInfo(@"BSTimerUtils", @"taskId is NOT TimerUtilsTaskInfo object." );
        }
        TimerUtilsTaskIdInfo *taskInfo = taskId;
        [BSTimerUtils stopRepeatedTaskWithDelegate:taskInfo.delegate
                                        selector:taskInfo.selector
                                        interval:taskInfo.interval];
    }
}

- (BOOL)startRepeatTimer:(NSTimeInterval)timeInterval notifiName:(NSString *)notifiName withTaskIdInfo:(TimerUtilsTaskIdInfo *)taskIdInfo
{
    @synchronized(self)
    {
        if([_timeDict objectForKey:notifiName]){
            return NO;
        }
        NSDictionary *userInfo = @{kTimerUtilsNotificationNameKey: notifiName};
        if (taskIdInfo) {
            userInfo = @{kTimerUtilsNotificationNameKey: notifiName,
                                       kTimerUtilsNotificationTaskIdInfoKey: taskIdInfo};
        }
        NSTimer *nsTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(timeOut:) userInfo:userInfo repeats:YES];
        [_timeDict setObject:nsTimer forKey:notifiName];
        return YES;
    }
}

- (void)stopRepeatTimer:(NSString *)notifiName
{
    @synchronized(self)
    {
        NSTimer * timer = [_timeDict objectForKey:notifiName];
        if(timer){
            [timer invalidate];
            [_timeDict removeObjectForKey:notifiName];
        }
    }
}

- (void)timeOut:(NSTimer *)timer
{
    NSDictionary *userInfo = timer.userInfo;
    NSString *notifiName = [userInfo objectForKey:kTimerUtilsNotificationNameKey];
    if(notifiName){
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:notifiName object:self userInfo:userInfo];
        });        
    }
}
@end
