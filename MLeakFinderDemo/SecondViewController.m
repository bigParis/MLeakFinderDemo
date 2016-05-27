//
//  SecondViewController.m
//  MLeakFinderDemo
//
//  Created by yy on 16/5/27.
//  Copyright © 2016年 BP. All rights reserved.
//

#import "SecondViewController.h"
#import "BSTimer.h"
#import "YYTimer.h"
#import "YelloView.h"

@interface SecondViewController ()
@property (nonatomic, strong) NSTimer *ivarTimer;
@property (nonatomic, strong) BSTimer *ivarBSTimer;
@property (nonatomic, weak) YellowView *yellowView;
@end

@implementation SecondViewController

- (void)dealloc {
    
    NSLog(@"绿色控制器dealloc");
    // for testIvarBSTimer testBSTimerBlock
    if (_ivarBSTimer.valid) {
        [_ivarBSTimer invalidate];
        _ivarBSTimer = nil;
    }
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"绿色控制器";
    self.view.backgroundColor = UIColor.greenColor;
    
    [self testViewLeak];
}

- (void)testNSTimer {
    // 使用NSTimer会内存泄露
    [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(onTimeout:) userInfo:nil repeats:YES];
}

- (void)testBSTimer {
    // 使用BSTimer不会内存泄露
    [BSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(onTimeout:) userInfo:nil repeats:YES];
}

- (void)testYYTimer {
    [YYTimer timerWithTimeInterval:5.0 target:self selector:@selector(onTimeout:) repeats:YES];
}

- (void)testIvarNSTimer {
    _ivarTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(onIvarTimeout:) userInfo:nil repeats:YES];
}

- (void)testIvarBSTimer {
    _ivarBSTimer = [BSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(onIvarBSTimeout:) userInfo:nil repeats:YES];
}

- (void)testBSTimerBlock {
    __weak typeof(self) weak_self = self;
    _ivarBSTimer = [BSTimer scheduledTimerWithTimeInterval:1.0 block:^(BSTimer *timer) {
        __strong typeof(self) self = weak_self;
        NSLog(@"testBSTimerBlock execute frame=%@", NSStringFromCGRect(self.view.frame));
    } repeats:YES];
}

- (void)testViewLeak {
    YellowView *yellowView = [YellowView yellowView];
    [self.view addSubview:yellowView];
    self.yellowView = yellowView;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.yellowView.frame = CGRectMake(100, 100, 100, 100);
}

- (void)onTimeout:(NSTimer *)timer {
    NSLog(@"time out execute");
}

- (void)onIvarTimeout:(NSTimer *)timer {
    NSLog(@"ivar time out execute");
    [timer invalidate];
}

- (void)onIvarBSTimeout:(BSTimer *)timer {
    NSLog(@"ivar bstime out execute");
    [timer invalidate];
}
@end
