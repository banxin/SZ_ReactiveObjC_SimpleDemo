//
//  SZEasyTestViewController.m
//  SZ_ReactiveObjC_SimpleDemo
//
//  Created by yanl on 2018/1/25.
//  Copyright © 2018年 yanl. All rights reserved.
//

#import "SZEasyTestViewController.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "SZSimpleView2.h"
#import "SZSimpleView.h"

@interface SZEasyTestViewController ()
{
    SZSimpleView2 *_simpleView;
}

@end

@implementation SZEasyTestViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"RAC 简单测试";
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
//    [self testKVO];
    
//    [self testButtonEvent];
    
//    [self testDelegate];
    
//    _simpleView.frame = CGRectMake(80, 360, 80, 40);
    
//    [self testNotifyCation];
    
//    [self testTextChange];
    
//    [self testRequests];
    
//    [self testForArray];
    
//    [self testKVOForBackgroundColor];
    
    [self testButtonStatus];
}

#pragma mark -- 监听事件(按钮点击)

/*
 原理：将系统的UIControlEventTouchUpInside事件转化为信号、我们只需要订阅该信号就可以了。
 
 点击按钮的时候触发UIControlEventTouchUpInside事件---> 发出信号 实际是:  执行订阅者(subscriber)的sendNext方法
 */

- (void)testButtonEvent
{
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(100, 200, 100, 50)];
    
    btn.backgroundColor = [[UIColor purpleColor] colorWithAlphaComponent:0.3];
    
    [btn setTitle:@"测试监听按钮事件" forState:UIControlStateNormal];
    
    [self.view addSubview:btn];
    
    [[btn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        
        //x 就是被点击的按钮
        NSLog(@"按钮被点击了 %@", x);
    }];
}

#pragma mark -- 代替代理

/*
 需求：自定义redView,监听红色view中按钮点击
 之前都是需要通过代理监听，给红色View添加一个代理属性，点击按钮的时候，通知代理做事情,符合封装的思想。
 rac_signalForSelector:把调用某个对象的方法的信息转换成信号(RACSubject)，就会调用这个方法，就会发送信号。
 这里表示只要监听了redView的btnClick:方法。(只要redView的btnClick:方法执行了,就会执行下面的方法,并且将参数传递过来)
 */

- (void)testDelegate
{
    // 初始化 simpleView
    SZSimpleView2 *simpleView = [[SZSimpleView2 alloc] initWithFrame:CGRectMake(100, 400, 80, 40)];
    
    [self.view addSubview:simpleView];
    
    [[simpleView rac_signalForSelector:NSSelectorFromString(@"switchDidTap:")] subscribeNext:^(RACTuple * _Nullable x) {
        
        // x 就是 sender
        NSLog(@"按钮被点击了 %@", x);
    }];
}

#pragma mark -- 代替KVO (TODO, 没实现)

/*
 // 把监听simpleView的center属性改变转换成信号，只要值改变就会发送信号
 // observer:可以传入nil
 */

- (void)testKVO
{
    // 初始化 simpleView
    SZSimpleView *simpleView = [[SZSimpleView alloc] initWithFrame:CGRectMake(100, 200, 80, 40)];
    
    [self.view addSubview:simpleView];
    
    // 设置代理信号
    simpleView.delegateSignal = [RACSubject subject];
    
    // 订阅代理信号, 监听 Switch 状态的改变
    [simpleView.delegateSignal subscribeNext:^(NSNumber * _Nullable x) {
        
        simpleView.backgroundColor = x.integerValue == 0 ? [UIColor blueColor] : [UIColor whiteColor];
    }];
    
    // 监听 simpleView 的背景颜色变化
    [[simpleView rac_valuesAndChangesForKeyPath:@"backgroundColor" options:NSKeyValueObservingOptionNew observer:self] subscribeNext:^(RACTwoTuple<id,NSDictionary *> * _Nullable x) {
        
        // x 就是 simpleView，如果 simpleView 的 frame 改变了就会触发
        NSLog(@"backgroundColor 变了 %@", x);
    }];
}

#pragma mark -- 代替通知

/*
 // 把监听到的通知转换信号
 */

- (void)testNotifyCation
{
    UITextField *txtTest = [[UITextField alloc] initWithFrame:CGRectMake(50, 100, 200, 20)];
    
    txtTest.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.3f];
    
    [self.view addSubview:txtTest];
    
    // 把监听到的通知转换信号
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillShowNotification object:nil] takeUntil:[self rac_willDeallocSignal]] subscribeNext:^(NSNotification * _Nullable x) {
        
        NSLog(@"键盘被唤起了 %@", x);
    }];
}

#pragma mark -- 监听文本框的文字改变

/*
 // 监听文本框的文字改变、获取文本框文字改变的信号
 */

- (void)testTextChange
{
    UITextField *txtTest = [[UITextField alloc] initWithFrame:CGRectMake(50, 100, 200, 20)];
    
    txtTest.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.3f];
    
    [self.view addSubview:txtTest];
    
    [txtTest.rac_textSignal subscribeNext:^(NSString * _Nullable x) {
        
       NSLog(@"文字改变了，当前：%@", x);
    }];
}

#pragma mark -- 处理多个请求

- (void)testRequests
{
    // 处理多个请求，都返回结果的时候，统一做处理.
    RACSignal *request1 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [NSThread sleepForTimeInterval:2.f];
        
        // 发送请求1
        [subscriber sendNext:@"发送请求1"];
        
        return nil;
    }];
    
    RACSignal *request2 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        // 发送请求2
        [subscriber sendNext:@"发送请求2"];
        
        return nil;
    }];
    
    // 使用注意：几个信号，selector的方法就几个参数，每个参数对应信号发出的数据。
    // *** 不需要订阅:不需要主动订阅,内部会主动订阅
    [self rac_liftSelector:@selector(updateUIWithR1:r2:) withSignalsFromArray:@[request1,request2]];
}

// 更新UI
- (void)updateUIWithR1:(id)data r2:(id)data1
{
    NSLog(@"更新UI%@ %@", data, data1);
}

#pragma mark -- 遍历数组

- (void)testForArray
{
    // 1.遍历数组
    NSArray *numbers = @[@1, @2, @3, @4];
    
    // 这里其实是三步(底层已经封装好了,直接使用就行)
    // 第一步: 把数组转换成集合RACSequence numbers.rac_sequence
    // 第二步: 把集合RACSequence转换RACSignal信号类,numbers.rac_sequence.signal
    // 第三步: 订阅信号，激活信号，会自动把集合中的所有值，遍历出来。
    [numbers.rac_sequence.signal subscribeNext:^(id x) {
        
         NSLog(@"%@", x);
    }];
}

#pragma mark--KVO

/*
 RACObserve(就是一个宏定义):快速的监听某个对象的某个属性改变
 监听self.view的center属性,当center发生改变的时候就会触发NSLog方法
 */
- (void)testKVOForBackgroundColor
{
    // 初始化 simpleView
    SZSimpleView *simpleView = [[SZSimpleView alloc] initWithFrame:CGRectMake(100, 200, 80, 40)];
    
    [self.view addSubview:simpleView];
    
    // 设置代理信号
    simpleView.delegateSignal = [RACSubject subject];
    
    // 订阅代理信号, 监听 Switch 状态的改变
    @weakify(self)
    [simpleView.delegateSignal subscribeNext:^(NSNumber * _Nullable x) {
        
        @strongify(self)
        self.view.backgroundColor = x.integerValue == 0 ? [UIColor blueColor] : [UIColor whiteColor];
    }];
    
    [RACObserve(self.view, backgroundColor) subscribeNext:^(id x) {
        
        NSLog(@"监控到了背景颜色的变化 %@", x);
    }];
}

#pragma mark - 登录按钮的状态实时监听

- (void)testButtonStatus
{
    UITextField *txtAccount = [[UITextField alloc] initWithFrame:CGRectMake(50, 100, 200, 50)];
    
    txtAccount.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.3f];
    txtAccount.placeholder = @"请输入您的账号";
    
    [self.view addSubview:txtAccount];
    
    UITextField *txtPassword = [[UITextField alloc] initWithFrame:CGRectMake(50, 160, 200, 50)];
    
    txtPassword.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.3f];
    txtPassword.placeholder = @"请输入您的密码";
    txtPassword.secureTextEntry = YES;
    
    [self.view addSubview:txtPassword];
    
    UIButton *btnLogin = [[UIButton alloc] initWithFrame:CGRectMake(100, 220, 100, 50)];
    
    btnLogin.backgroundColor = [[UIColor purpleColor] colorWithAlphaComponent:0.3f];
    [btnLogin setTitle:@"登录" forState:UIControlStateNormal];
    
    [self.view addSubview:btnLogin];
    
    [[btnLogin rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        
        //x 就是被点击的按钮
        NSLog(@"登录按钮被点击了 %@", x);
    }];
    
    RAC(btnLogin, enabled) = [RACSignal combineLatest:@[txtAccount.rac_textSignal, txtPassword.rac_textSignal] reduce:^id _Nonnull (NSString * username, NSString * password) {
        
        return @(username.length && password.length);
    }];
}

/*
 *** 所有控件在使用RAC之前一定要先初始化!先初始化!先初始化!
 *** 所有控件在使用RAC之前一定要先初始化!先初始化!先初始化!
 *** 所有控件在使用RAC之前一定要先初始化!先初始化!先初始化!
 */

@end
