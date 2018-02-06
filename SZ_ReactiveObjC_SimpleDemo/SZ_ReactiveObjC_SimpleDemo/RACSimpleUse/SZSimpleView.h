//
//  SZSimpleView.h
//  SZ_ReactiveObjC_SimpleDemo
//
//  Created by yanl on 2018/1/24.
//  Copyright © 2018年 yanl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ReactiveObjC/ReactiveObjC.h>

@interface SZSimpleView : UIView

@property (nonatomic, strong) RACSubject *delegateSignal;

@end
