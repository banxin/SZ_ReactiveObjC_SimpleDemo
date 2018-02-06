//
//  SZLoginViewModel.h
//  SZ_ReactiveObjC_SimpleDemo
//
//  Created by yanl on 2018/1/29.
//  Copyright © 2018年 yanl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveObjC/ReactiveObjC.h>

@class SZAccount;

@interface SZLoginViewModel : NSObject

@property (nonatomic, strong) SZAccount *account;

// 是否允许登录的信号
@property (nonatomic, strong, readonly) RACSignal  *enableLoginSignal;

@property (nonatomic, strong, readonly) RACCommand *loginCommand;

@end
