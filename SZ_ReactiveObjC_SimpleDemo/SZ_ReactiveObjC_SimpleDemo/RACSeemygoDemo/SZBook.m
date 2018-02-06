//
//  SZBook.m
//  SZ_ReactiveObjC_SimpleDemo
//
//  Created by yanl on 2018/1/29.
//  Copyright © 2018年 yanl. All rights reserved.
//

#import "SZBook.h"

@implementation SZBook

// 修改映射的 字段名
+ (NSDictionary *)modelCustomPropertyMapper
{
    return @{@"boodId" : @"id"};
}

// 指定 modelList 的 model 类型
//+ (NSDictionary *)modelContainerPropertyGenericClass
//{
//    return @{@"property name" : [YourModel class]};
//}

@end
