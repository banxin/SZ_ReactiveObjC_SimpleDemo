//
//  SZRequestViewModel.h
//  SZ_ReactiveObjC_SimpleDemo
//
//  Created by yanl on 2018/1/29.
//  Copyright © 2018年 yanl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveObjC/ReactiveObjC.h>

@interface SZRequestViewModel : NSObject<UITableViewDataSource, UITableViewDelegate>

// 请求命令
@property (nonatomic, strong, readonly) RACCommand *reuqesCommand;

// 模型数组
@property (nonatomic, strong) NSArray *models;

@end
