//
//  SZSimpleUseViewController.m
//  SZ_ReactiveObjC_SimpleDemo
//
//  Created by yanl on 2018/1/24.
//  Copyright © 2018年 yanl. All rights reserved.
//

#import "SZSimpleUseViewController.h"
#import "SZSimpleView.h"
#import "SZSimpleView2.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import <ReactiveObjC/RACReturnSignal.h>

@interface SZSimpleUseViewController ()
{
    UITextField *_textField;
}

@end

@implementation SZSimpleUseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"RAC 简单使用";
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
//    [self testRACSubject];
    
//    [self test_rac_signalForSelector];
    
//    [self testRACCommand];
    
//    [self creteTextFieldAndTest];
    
//    [self testConcat];
    
//    [self testThen];
    
//    [self testMerge];
    
//    [self testZipWith];
    
//    [self testCombineLatet];
    
//    [self testReduce];
    
//    [self testInterval];
    
    [self testDelay];
}

/*
 通过改变 colorSwitch 控件的开关来改变控制器的背景色，以下两种实现方式
 */

/*
 1.利用 RACSubject 实现
 */
- (void)testRACSubject
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
}

/*
 2.利用 rac_signalForSelector 实现
 */
- (void)test_rac_signalForSelector
{
    // 初始化 simpleView
    SZSimpleView2 *simpleView = [[SZSimpleView2 alloc] initWithFrame:CGRectMake(100, 400, 80, 40)];
    
    [self.view addSubview:simpleView];
    
    // 监听 switchDidTap 方法，订阅代理信号
    @weakify(self)
    [[simpleView rac_signalForSelector:@selector(switchDidTap:)] subscribeNext:^(RACTuple * _Nullable x) {
        
         UISwitch *sender = (UISwitch *)x[0];
        
        @strongify(self)
        self.view.backgroundColor = sender.isOn ? [UIColor blueColor] : [UIColor whiteColor];
    }];
}

/*
 RACCommand 简介和使用
 
 RACCommand: RAC中用于处理事件的类，可以把事件如何处理,事件中的数据如何传递，包装到这个类中，他可以很方便的监控事件的执行过程
 
 使用场景:监听按钮点击，网络请求
 
 一、RACCommand使用步骤:
 
 1.创建命令initWithSignalBlock:(RACSignal*(^)(id input))signalBlock
 2.在signalBlock中，创建RACSignal，并且作为signalBlock的返回值
 3.订阅RACCommand中的信号，获取数据
 4.执行命令 - (RACSignal *)execute:(id)input
 */
- (void)testRACCommand
{
    // 1.创建命令
    RACCommand *cmmand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        
        // 2.创建信号,用来传递数据
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            
            // 模拟网络加载
            [self loadData:^(id response) {
                
                // 注意：数据传递完，最好调用sendCompleted，这时命令才执行完毕。
                [subscriber sendNext:response];
                
                [subscriber sendCompleted];
                
            } fail:^(NSError *error) {
                
                [subscriber sendError:error];
            }];
            
            return nil;
        }];
    }];
    
    // 3.订阅RACCommand中的信号
//    [cmmand.executionSignals subscribeNext:^(id  _Nullable x) {
//
//        // x 为信号中的信号
//        [x subscribeNext:^(id  _Nullable x) {
//
//            // 此处的 x 才是网络请求到的数据
//            NSLog(@"command received: %@", x);
//        }];
//    }];
    
    // 其中上述步骤三可以简化
    // switchToLatest:用于signal of signals，获取signal of signals发出的最新信号,也就是可以直接拿到RACCommand中的信号
    [cmmand.executionSignals.switchToLatest subscribeNext:^(id x) {

        // 网络请求到的数据
        NSLog(@"command received: %@", x);
    }];
    
    // 4.执行命令, 执行时可以传值
    [cmmand execute:nil];
}

- (void)loadData:(void(^)(id response))suc fail:(void(^)(NSError *error))error
{
    // 延时2s
    [NSThread sleepForTimeInterval:2];
    
    suc(@"请求数据成功！！！");
}

- (void)creteTextFieldAndTest
{
    UITextField *txtTest = [[UITextField alloc] initWithFrame:CGRectMake(50, 100, 200, 20)];
    
    txtTest.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.3f];
    
    [self.view addSubview:txtTest];
    
    _textField = txtTest;
    
//    [self testBind];
    
//    [self testFlattenMap];
    
//    [self testMap];
    
    [self testFilter];
}

/*
 bind 绑定/包装
 这里的bind的主要作用属于包装，将信号返回的值包装成一个新的值
 
 是通过获取到信号返回的值，并包装成新的值, 再次通过信号返回给订阅者
 
 bind方法使用步骤:
 1.传入一个返回值RACSignalBindBlock的block;
 2.描述一个RACSignalBindBlock类型的bindBlock作为block的返回值;
 3.描述一个返回结果的信号，作为bindBlock的返回值.
 注意：在bindBlock中做信号结果的处理
 */

- (void)testBind
{
    // 尝试修改 UITextField 的值，观察控制台输出
    [[_textField.rac_textSignal bind:^RACSignalBindBlock _Nonnull {
        
        return ^RACSignal*(id value, BOOL *stop) {
            
            // 做好处理，通过信号返回出去.
            // 需要引入头文件 #import <ReactiveObjC/RACReturnSignal.h>
            return [RACSignal return:[NSString stringWithFormat:@"hello: %@", value]];
        };
        
    }] subscribeNext:^(id  _Nullable x) {
        
        NSLog(@"%@", x); // 打印结果：hello: "x"
    }];
}

/*
 flattenMap & Map 映射
 flattenMap，Map都是用于把源信号内容映射成新的内容
 
 flattenMap 的底层实现是通过bind实现的
 Map 的底层实现是通过 flattenMap 实现的
 */

/*
 flatternMap和Map的区别
 
 FlatternMap中的Block返回信号
 Map中的Block返回对象
 开发中，如果信号发出的值不是信号，映射一般使用Map
 开发中，如果信号发出的值是信号，映射一般使用FlatternMap
 */

/*
 flattenMap使用步骤:
 1.传入一个block，block类型是返回值RACStream，参数value；
 2.参数value就是源信号的内容，拿到源信号的内容做处理；
 3.包装成RACReturnSignal信号，返回出去。
 */
- (void)testFlattenMap
{
    [[_textField.rac_textSignal flattenMap:^__kindof RACSignal * _Nullable(NSString * _Nullable value) {
        
        return [RACSignal return:[NSString stringWithFormat:@"hello: %@", value]];
        
    }] subscribeNext:^(id  _Nullable x) {
        
        NSLog(@"%@", x); // hello "x"
    }];
}

/*
 Map使用步骤:
 1.传入一个block,类型是返回对象，参数是value;
 2.value就是源信号的内容，直接拿到源信号的内容做处理;
 3.把处理好的内容，直接返回就好了，不用包装成信号，返回的值，就是映射的值。
 */
- (void)testMap
{
    [[_textField.rac_textSignal map:^id _Nullable(NSString * _Nullable value) {
        
        // 当源信号发出，就会调用这个block，修改源信号的内容
        // 返回值：就是处理完源信号的内容。
        return [NSString stringWithFormat:@"hello:%@", value];
        
    }] subscribeNext:^(id  _Nullable x) {
        
        NSLog(@"%@", x); // hello: "x"
    }];
}

/*
 concat 合并
 按一定顺序拼接信号，当多个信号发出的时候，有顺序的接收信号
 */
- (void)testConcat
{
    // 创建两个信号 signalA 和 signalB
    RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [subscriber sendNext:@"第一个信号"];
        [subscriber sendCompleted];
        
        return nil;
    }];
    
    RACSignal *signalB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [subscriber sendNext:@"second signal"];
        return nil;
    }];
    
    // 把signalA拼接到signalB后，signalA发送完成，signalB才会被激活
    // *** 注意：第一个信号必须发送完成，第二个信号才会被激活
    [[signalA concat:signalB] subscribeNext:^(id  _Nullable x) {
        
        NSLog(@"%@", x);
    }];
}

/*
 then 下一个
 用于连接两个信号，当第一个信号完成，才会连接then返回的信号
 
 底层实现
 1.使用concat连接then返回的信号
 2.先过滤掉之前的信号发出的值
 */

- (void)testThen
{
    [[[RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        
        [subscriber sendNext:@"first"];
        [subscriber sendCompleted];
        
        return nil;
        
    }] then:^RACSignal * _Nonnull{
        
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            
            [subscriber sendNext:@"second"];
            
            return nil;
        }];
        
    }] subscribeNext:^(id  _Nullable x) {
        
        // 只能接收到第二个信号的值，也就是then返回信号的值
        NSLog(@"%@", x); // 2
    }];
}

/*
 merge 合并
 把多个信号合并为一个信号，任何一个信号有新值的时候就会调用
 
 *** 注意：只要有一个信号被发出就会被监听
 */
- (void)testMerge
{
    RACSignal *signalA = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        
        [subscriber sendNext:@"first"];
        
        return nil;
    }];
    
    RACSignal *signalB = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        
        [subscriber sendNext:@"second"];
        
        return nil;
    }];
    
    // 合并信号,任何一个信号发送数据，都能监听到.
    RACSignal *mergeSignal = [signalA merge:signalB];
    
    [mergeSignal subscribeNext:^(id  _Nullable x) {
        
        NSLog(@"%@", x);
    }];
}

/*
 zipWith 压缩
 
 把两个信号压缩成一个信号，只有当两个信号同时发出信号内容时，并且把两个信号的内容合并成一个元组，才会触发压缩流的next事件
 
 ***  注意：使用 zipWith 时，两个信号必须同时发出信号内容
 */
- (void)testZipWith
{
    RACSignal *signalA = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        
        [subscriber sendNext:@"first"];
        
        return nil;
    }];
    
    RACSignal *signalB = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        
        [subscriber sendNext:@"second"];
        
        return nil;
    }];
    
    // 压缩信号A，信号B，将会 构成一个元组
    RACSignal *zipSignal = [signalA zipWith:signalB];
    
    [zipSignal subscribeNext:^(id x) {
        
        // x 为元祖
        NSLog(@"%@", x); // (first, second)
    }];
}

/*
 combineLatest 结合
 将多个信号合并起来，并且拿到各个信号的最新的值,必须每个合并的signal至少都有过一次sendNext，才会触发合并的信号
 
 *** combineLatest 功能和 zipWith一样
 */

- (void)testCombineLatet
{
    RACSignal *signalA = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        
        [subscriber sendNext:@"first"];
        
        return nil;
    }];
    
    RACSignal *signalB = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        
        [subscriber sendNext:@"second"];
        
        return nil;
    }];
    
    // 结合信号A，信号B，将会 构成一个元组，combineLatest 功能和 zipWith一样
    RACSignal *zipSignal = [signalA combineLatestWith:signalB];
    
    [zipSignal subscribeNext:^(id x) {
        
        // x 为元祖
        NSLog(@"%@", x); // (first, second)
    }];
}

/*
 reduce 聚合
 用于信号发出的内容是元组，把信号发出元组的值聚合成一个值
 
 一般都是先组合在聚合
 */

- (void)testReduce
{
    RACSignal *signalA = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        
        [subscriber sendNext:@"first"];
        
        return nil;
    }];
    
    RACSignal *signalB = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        
        [subscriber sendNext:@"second"];
        
        return nil;
    }];
    
    // reduceblcok的返回值：聚合信号之后的内容。
    RACSignal *reduceSignal = [RACSignal combineLatest:@[signalA, signalB] reduce:^id (NSString *txt1, NSString *txt2) {
        
        return [NSString stringWithFormat:@"%@ %@", txt1, txt2];
    }];
    
    [reduceSignal subscribeNext:^(id x) {
        
        // x 为元祖
        NSLog(@"%@", x); // (first, second)
    }];
}

/*
 filter 过滤
 
 过滤信号，获取满足条件的信号
 */
- (void)testFilter
{
    [[_textField.rac_textSignal filter:^BOOL(NSString * _Nullable value) {
        
        // 过滤条件： 值位数大于6
        return value.length > 6;
        
    }] subscribeNext:^(NSString * _Nullable x) {
        
        // 只会输出位数大于 6 的 str 值
        NSLog(@"%@", x);
    }];
}

/*
 ignore 忽略
 
 忽略掉指定的值
 */

- (void)textIgnore
{
    // 忽略 666 的值
    [[_textField.rac_textSignal ignore:@"666"] subscribeNext:^(NSString * _Nullable x) {
        
        NSLog(@"%@", x);
    }];
}

/*
 interval 定时
 每隔一段时间发出信号
 
 类似于 NSTimer
 
 每隔1秒发送一次信号
 */
- (void)testInterval
{
    [[RACSignal interval:1 onScheduler:[RACScheduler currentScheduler]] subscribeNext:^(NSDate * _Nullable x) {
        
        NSLog(@"%@", x);
    }];
}

/*
 delay 延迟
 延迟执行，类似于 GCD 的 after
 
 这里的 delay作用主要是延迟发送next
 */
- (void)testDelay
{
    [[[RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        
        [subscriber sendNext:@"delay signal"];
        
        return nil;
        
    }] delay:2] subscribeNext:^(id  _Nullable x) {
        
        NSLog(@"%@", x);
    }];
}

@end
