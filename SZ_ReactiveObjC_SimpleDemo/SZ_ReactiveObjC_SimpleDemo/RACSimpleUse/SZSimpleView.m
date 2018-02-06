//
//  SZSimpleView.m
//  SZ_ReactiveObjC_SimpleDemo
//
//  Created by yanl on 2018/1/24.
//  Copyright © 2018年 yanl. All rights reserved.
//

#import "SZSimpleView.h"

@implementation SZSimpleView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        [self setupUI];
    }
    
    return self;
}

- (void)setupUI
{
    UISwitch *sender = [[UISwitch alloc] initWithFrame:self.bounds];
    
    [sender addTarget:self action:@selector(switchDidTap:) forControlEvents:UIControlEventValueChanged];
    
    [self addSubview:sender];
}

- (void)switchDidTap:(UISwitch *)sender
{
    // 判断代理信号是否有值
    if (self.delegateSignal) {
        
        // 有值，才需要发送 UISwitch 的状态
        [self.delegateSignal sendNext:@(sender.isOn)];
    }
}

@end
