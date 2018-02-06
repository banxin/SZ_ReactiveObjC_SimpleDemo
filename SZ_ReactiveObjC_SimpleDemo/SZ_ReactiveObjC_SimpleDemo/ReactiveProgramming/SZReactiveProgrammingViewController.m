//
//  SZReactiveProgrammingViewController.m
//  SZ_ReactiveObjC_SimpleDemo
//
//  Created by yanl on 2018/1/24.
//  Copyright © 2018年 yanl. All rights reserved.
//

#import "SZReactiveProgrammingViewController.h"
#import "SZPerson.h"

/*
 ReactiveCocoa是一个基于函数响应式编程的OC框架.
 
 那么什么是函数式响应式编程呢?概念我就不讲了 因为我讲的也不一定准确, 大家可以去baidu看看大神们的解释
 
 下面我大概演示下响应式编程的样子
 
 Masonry是比较常见的一个响应式框架, 它的的用法举例如下:
 
 make.centerY.equalTo(self.view).offset(100);
 大家注意它的用法, 点号调用一个事件或属性后可以接着点号调用, 这里一个比较明显的函数响应式编程的好处就是我们可以把一些要使用的连贯的或者有先后顺序的调用方法和事件连在一起, 逻辑清晰明了的完成代码.
 
 那么要如何实现这样的调用方式呢?
 
 centerY.equalTo(self.view)这个能执行的话equalTo就必须是一个返回对象的block
 
 下面试试自己来实现这个,
 
 建一个Person对象,  加上跑步, 走路的方法
 
 Class: Person;  Method: run; walk;
 
 我们拆分成几个步骤来做, 首先实现
 
 [[person run] walk];先跑, 跑累了再走
 
 要实现这样的调用的话, run就必须返回person, 为了还能继续接着这样调用walk也要返回person
 
 [self testSimple];
 
 然后再实现 实现person.run().walk();
 
 [self testReactive];
 
 实现了一个基于函数响应式的小Demo
 
 常规情况下, 我们写代码是一般是定义很多个变量和方法,  在不同的状态和业务流程下去改变变量的值或者调用对应的方法.
 
 而RAC采用信号机制来获取当前的, 同时也能直接处理将来要如何修改这些值, 通过利用链式响应编程来书写结构逻辑清晰的代码, 不用我们在不同的地方去给我们属性值做处理
 
 */

@interface SZReactiveProgrammingViewController ()

@end

@implementation SZReactiveProgrammingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"响应式编程基本实现";
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
//    [self testSimple];
    
    [self testReactive];
}

- (void)testSimple
{
    // 创建对象
    SZPerson *person = [[SZPerson alloc] init];
    
    // 尝试调用
    [[person run] walk];
}

/**
 实现了一个基于函数响应式的小Demo
 */
- (void)testReactive
{
    // 创建对象
    SZPerson *person = [[SZPerson alloc] init];
    
    person.runBlock().walkBlock();
}

@end


















