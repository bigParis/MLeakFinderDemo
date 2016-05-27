//
//  YelloView.m
//  MLeakFinderDemo
//
//  Created by yy on 16/5/27.
//  Copyright © 2016年 BP. All rights reserved.
//

#import "YelloView.h"
#import "YYTimer.h"

@interface YellowView()

//@property (nonatomic, strong) YYTimer *viewTimer;
@property (nonatomic, strong) NSTimer *viewTimer;
@end

@implementation YellowView

- (void)dealloc {
    NSLog(@"YellowView dealloc");
}

+ (instancetype)yellowView {
    return [[self alloc] init];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = UIColor.yellowColor;
//        _viewTimer = [YYTimer timerWithTimeInterval:1.0 target:self selector:@selector(viewTimeout:) repeats:YES];
        _viewTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(viewTimeout:) userInfo:nil repeats:YES];
    }
    
    return self;
}

- (void)viewTimeout:(YYTimer *)timer {
    NSLog(@"timeout execute");
}

@end
