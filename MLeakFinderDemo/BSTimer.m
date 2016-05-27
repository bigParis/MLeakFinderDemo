//
//  BSTimer.m
//  MakeFriends
//
//  Created by kai on 15/7/11.
//
//

#import "BSTimer.h"

@interface TimerTargetWrapper : NSObject

@property(weak, nonatomic) id target;
@property(assign, nonatomic) SEL aSelector;
@property (nonatomic, strong) id userInfo;

- (void)onTimeout:(id)timer;

@end

@implementation TimerTargetWrapper

- (void)onTimeout:(BSTimer *)timer
{
    if (_target ) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Warc-performSelector-leaks"
        [_target performSelector:_aSelector withObject:self];
#pragma clang diagnostic pop
    }
}
@end

@interface BSTimer()

@property(strong, nonatomic) NSTimer *timer;

@end

@implementation BSTimer

+ (void)timeoutBlock:(id)timer {
    if ([timer userInfo]) {
        void (^block)(BSTimer *timer) = (void (^)(BSTimer *timer))[timer userInfo];
        block(timer);
    }
}

+ (BSTimer *)timerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(id)userInfo repeats:(BOOL)yesOrNo
{
    BSTimer *bstimer = [BSTimer new];
    
    TimerTargetWrapper *wrapper = [TimerTargetWrapper new];
    wrapper.target = aTarget;
    wrapper.aSelector = aSelector;
    wrapper.userInfo = userInfo;
    
    bstimer.timer = [NSTimer timerWithTimeInterval:ti target:wrapper selector:@selector(onTimeout:) userInfo:userInfo repeats:yesOrNo];
    [[NSRunLoop currentRunLoop] addTimer:bstimer.timer forMode:NSRunLoopCommonModes];
    return bstimer;
}

+ (BSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(id)userInfo repeats:(BOOL)yesOrNo
{
    BSTimer *bstimer = [BSTimer new];
    
    TimerTargetWrapper *wrapper = [TimerTargetWrapper new];
    wrapper.target = aTarget;
    wrapper.aSelector = aSelector;
    wrapper.userInfo = userInfo;
    
    bstimer.timer = [NSTimer scheduledTimerWithTimeInterval:ti target:wrapper selector:@selector(onTimeout:) userInfo:userInfo repeats:yesOrNo];
    [[NSRunLoop currentRunLoop] addTimer:bstimer.timer forMode:NSRunLoopCommonModes];
    return bstimer;
}

+ (BSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)seconds block:(void (^)(BSTimer *timer))block repeats:(BOOL)repeats {
    return [BSTimer scheduledTimerWithTimeInterval:seconds target:self selector:@selector(timeoutBlock:) userInfo:[block copy] repeats:repeats];
}

+ (BSTimer *)timerWithTimeInterval:(NSTimeInterval)seconds block:(void (^)(BSTimer *timer))block repeats:(BOOL)repeats {
    return [BSTimer timerWithTimeInterval:seconds target:self selector:@selector(timeoutBlock:) userInfo:[block copy] repeats:repeats];
}

- (void)fire
{
    [_timer fire];
}

- (void)invalidate
{
    [_timer invalidate];
}

- (BOOL)isValid
{
    return [_timer isValid];
}

@end
