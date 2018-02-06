//
//  SZRAC&MVVMViewController.m
//  SZ_ReactiveObjC_SimpleDemo
//
//  Created by yanl on 2018/1/29.
//  Copyright © 2018年 yanl. All rights reserved.
//

#import "SZRAC&MVVMViewController.h"

#import <ReactiveObjC/ReactiveObjC.h>
#import <ReactiveObjC/RACReturnSignal.h>
#import "SZLoginViewModel.h"
#import "SZAccount.h"

/*
  需求：1.监听两个文本框的内容，有内容才允许按钮点击
 2.默认登录请求.
 
 用MVVM：实现，之前界面的所有业务逻辑
 分析：1.之前界面的所有业务逻辑都交给控制器做处理
 2.在MVVM架构中把控制器的业务全部搬去VM模型，也就是每个控制器对应一个VM模型.
 
 步骤：1.创建LoginViewModel类，处理登录界面业务逻辑.
 2.这个类里面应该保存着账号的信息，创建一个账号Account模型
 3.LoginViewModel应该保存着账号信息Account模型。
 4.需要时刻监听Account模型中的账号和密码的改变，怎么监听？
 5.在非RAC开发中，都是习惯赋值，在RAC开发中，需要改变开发思维，由赋值转变为绑定，可以在一开始初始化的时候，就给Account模型中的属性绑定，并不需要重写set方法。
 6.每次Account模型的值改变，就需要判断按钮能否点击，在VM模型中做处理，给外界提供一个能否点击按钮的信号.
 7.这个登录信号需要判断Account中账号和密码是否有值，用KVO监听这两个值的改变，把他们聚合成登录信号.
 8.监听按钮的点击，由VM处理，应该给VM声明一个RACCommand，专门处理登录业务逻辑.
 9.执行命令，把数据包装成信号传递出去
 10.监听命令中信号的数据传递
 11.监听命令的执行时刻
 */

@interface SZRAC_MVVMViewController ()

@property (nonatomic, weak) UITextField *txtAccount;
@property (nonatomic, weak) UITextField *txtPassword;

@property (nonatomic, weak) UIButton *btnLogin;

@property (nonatomic, strong) SZLoginViewModel *loginViewModel;

@end

@implementation SZRAC_MVVMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"RAC & MVVM Demo";
    
    [self setupUI];
    
    [self bindModel];
}

- (void)setupUI
{
    UITextField *txtAccount = [[UITextField alloc] initWithFrame:CGRectMake(50, 100, 200, 50)];
    
    txtAccount.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.3f];
    txtAccount.placeholder = @"请输入您的账号";
    
    [self.view addSubview:txtAccount];
    
    self.txtAccount = txtAccount;
    
    UITextField *txtPassword = [[UITextField alloc] initWithFrame:CGRectMake(50, 160, 200, 50)];
    
    txtPassword.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.3f];
    txtPassword.placeholder = @"请输入您的密码";
    txtPassword.secureTextEntry = YES;
    
    [self.view addSubview:txtPassword];
    
    self.txtPassword = txtPassword;
    
    UIButton *btnLogin = [[UIButton alloc] initWithFrame:CGRectMake(100, 220, 100, 50)];
    
    btnLogin.backgroundColor = [[UIColor purpleColor] colorWithAlphaComponent:0.3f];
    [btnLogin setTitle:@"登录" forState:UIControlStateNormal];
    
    [self.view addSubview:btnLogin];
    
    self.btnLogin = btnLogin;
}

// 视图模型绑定
- (void)bindModel
{
    // 给模型的属性绑定信号
    // 只要账号文本框一改变，就会给account赋值
    RAC(self.loginViewModel.account, account) = _txtAccount.rac_textSignal;
    RAC(self.loginViewModel.account, pwd)     = _txtPassword.rac_textSignal;
    
    // 绑定登录按钮
    RAC(self.btnLogin, enabled) = self.loginViewModel.enableLoginSignal;
    
    @weakify(self)
    // 监听登录按钮点击
    [[self.btnLogin rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {

        NSLog(@"btn 被点击了！");

        @strongify(self)
        // 执行登录事件
        [self.loginViewModel.loginCommand execute:nil];
    }];
}

#pragma mark - lazy load

- (SZLoginViewModel *)loginViewModel
{
    if (!_loginViewModel) {
        
        _loginViewModel = [SZLoginViewModel new];
    }
    
    return _loginViewModel;
}

@end
