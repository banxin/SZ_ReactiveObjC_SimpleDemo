//
//  SZLoginViewModel.m
//  SZ_ReactiveObjC_SimpleDemo
//
//  Created by yanl on 2018/1/29.
//  Copyright © 2018年 yanl. All rights reserved.
//

#import "SZLoginViewModel.h"
#import "SZAccount.h"

@implementation SZLoginViewModel

- (instancetype)init
{
    if (self = [super init]) {
        
        [self initialBind];
    }
    
    return self;
}

// 初始化绑定
- (void)initialBind
{
    // 监听账号的属性值改变，把他们聚合成一个信号。
    _enableLoginSignal = [RACSignal combineLatest:@[RACObserve(self.account, account), RACObserve(self.account, pwd)] reduce:^id(NSString *account,NSString *pwd) {
        
        return @(account.length && pwd.length);
    }];
    
    // 处理登录业务逻辑
    _loginCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        
        NSLog(@"点击了登录, %@", input);
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            
            // 模仿网络延迟
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                [subscriber sendNext:@"登录成功"];
                
                // 数据传送完毕，必须调用完成，否则命令永远处于执行状态
                [subscriber sendCompleted];
            });
            
            return nil;
        }];
    }];
    
    // 监听登录产生的数据
    [_loginCommand.executionSignals.switchToLatest subscribeNext:^(id x) {
        
        if ([x isEqualToString:@"登录成功"]) {
            
            NSLog(@"登录成功");
        }
    }];
    
    // 监听登录状态
    [[_loginCommand.executing skip:1] subscribeNext:^(id x) {
        
        NSLog(@"监听收到的信号，%@", x);
        
        if ([x isEqualToNumber:@(YES)]) {
            
            // 正在登录ing...
            // 用蒙版提示
            NSLog(@"正在登录...");
        
        } else {
            
            // 登录成功
            // 隐藏蒙版
            NSLog(@"登录成功...");
        }
    }];
}

#pragma mark - lazy load

- (SZAccount *)account
{
    if (!_account) {
        
        _account = [SZAccount new];
    }
    
    return _account;
}

@end
