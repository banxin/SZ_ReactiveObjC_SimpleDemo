//
//  SZSimpleView2.m
//  SZ_ReactiveObjC_SimpleDemo
//
//  Created by yanl on 2018/1/24.
//  Copyright © 2018年 yanl. All rights reserved.
//

#import "SZSimpleView2.h"

@implementation SZSimpleView2

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
    
}

@end
