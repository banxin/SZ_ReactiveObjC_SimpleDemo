//
//  SZRACBasicViewController.m
//  SZ_ReactiveObjC_SimpleDemo
//
//  Created by yanl on 2018/1/24.
//  Copyright © 2018年 yanl. All rights reserved.
//

#import "SZRACBasicViewController.h"
#import <ReactiveObjC/ReactiveObjC.h>

@interface SZRACBasicViewController ()

@end

@implementation SZRACBasicViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.title = @"RACSignal";
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    //    [self simpleTestRACSignal];
    
    [self testRACExplain];
}

- (void)simpleTestRACSignal
{
    // ------------------------创建信号---------------------------
    
    /*
     直接运行, 什么都不会发生！
     
     点进去看源码：
     
     + (RACSignal *)createSignal:(RACDisposable * (^)(id<RACSubscriber> subscriber))didSubscribe {
     return [RACDynamicSignal createSignal:didSubscribe];
     }
     他给我们返回了一个RACDynamicSignal
     
     @interface RACDynamicSignal : RACSignal
     
     + (RACSignal *)createSignal:(RACDisposable * (^)(id<RACSubscriber> subscriber))didSubscribe;
     原来他是RACSignal的一个子类, 它也重写了createSignal方法, 我们现在实际是调用了他的创建信号的方法. 那我们看看它这个方法都做了什么
     
     + (RACSignal *)createSignal:(RACDisposable * (^)(id<RACSubscriber> subscriber))didSubscribe {
     
     RACDynamicSignal *signal = [[self alloc] init];
     signal->_didSubscribe = [didSubscribe copy];
     return [signal setNameWithFormat:@"+createSignal:"];
     }
     
     它创建了一个RACDynamicSignal实例, 然后把didSubscribe复制了一份复制给创建的实例, 然后重命名后就直接返回给我们了.
     
     然后就结束了, 难怪我们什么效果都没有看到
     
     RAC里面有一个很重要的理念: 创建信号必须订阅, 订阅了信号才会被执行.
     
     没有订阅的信号是冷信号 不会产生任何效果, 订阅信号就从冷信号变成热信号, 就可以执行各种操作.
     */
    
    // 创建一个信号
    RACSignal *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        
        NSLog(@"创建一个信号！！！");
        
        [subscriber sendNext:@"发送一个信号！！！"];
        
        return nil;
    }];
    
    // ---------------------------------------------------------------
    
    // --------------------------订阅信号----------------------------
    
    /*
     运行看看
     
     2018-01-24 18:35:16.803935+0800 SZ_ReactiveObjC_SimpleDemo[69772:3543201] 创建一个信号！！！
     
     创建信号的block执行了,  但是订阅的信号没有执行, 我们看看点开subscribeNext看看为什么
     
     - (RACDisposable *)subscribeNext:(void (^)(id x))nextBlock {
     NSCParameterAssert(nextBlock != NULL);
     
     RACSubscriber *o = [RACSubscriber subscriberWithNext:nextBlock error:NULL completed:NULL];
        return [self subscribe:o];
     }
     它首先判断我们的block不会空, 然后创建了一个RACSubscriber订阅者, 并把我们的block给它了
     
     再点subscriber的创建方法看看它做了什么
     
     + (instancetype)subscriberWithNext:(void (^)(id x))next error:(void (^)(NSError *error))error completed:(void (^)(void))completed {
     RACSubscriber *subscriber = [[self alloc] init];
     
     subscriber->_next = [next copy];
     subscriber->_error = [error copy];
     subscriber->_completed = [completed copy];
     
     return subscriber;
     }
     它只是创建了一个subscriber实例, 然后把我们的block拷贝给它 还是什么都没有做
     
     我们再看看
     
     [self subscribe:o];
     
     做了什么
     
     - (RACDisposable *)subscribe:(id<RACSubscriber>)subscriber {
     NSCAssert(NO, @"This method must be overridden by subclasses");
     return nil;
     }
     它做了非空判断, 然后说这个方法必须被子类重写, 这里好像也啥都没干啊 怎么创建信号的block就执行了呢?
     
     大家想想, 我们刚才创建信号的时候, 是不是就是调用的是RACSignal的子类DynamicSignal, 所以这里实际上运行的也是这个DynamicSignal的subscribe方法, 我们去看看
     
     - (RACDisposable *)subscribe:(id<RACSubscriber>)subscriber {
     NSCParameterAssert(subscriber != nil);
     
     RACCompoundDisposable *disposable = [RACCompoundDisposable compoundDisposable];
     subscriber = [[RACPassthroughSubscriber alloc] initWithSubscriber:subscriber signal:self disposable:disposable];
     
     if (self.didSubscribe != NULL) {
     RACDisposable *schedulingDisposable = [RACScheduler.subscriptionScheduler schedule:^{
     RACDisposable *innerDisposable = self.didSubscribe(subscriber);
     [disposable addDisposable:innerDisposable];
     }];
     
     [disposable addDisposable:schedulingDisposable];
     }
     
     return disposable;
     }
     
     首先它也是先判断是否为空, 然后创建了一个RACCompoundDisposable实例
     
     接着有给我们的subscriber重新赋值, 我们看看这个RACPassthroughSubscriber
     
     // A private subscriber that passes through all events to another subscriber
     // while not disposed.
     @interface RACPassthroughSubscriber : NSObject <RACSubscriber>
     它是把事件从一个subscriber传递给另外一个subscriber, 所以这里就是它把我们原有的subscriber + 之前创建的signal + disposable加起来组成一个新的subscriber重新赋值给我们的subscriber,  相当于把我们创建的信号跟订阅绑定到一起了
     
     
     
     接着如果didsubscribe不为空的话, 及继续执行否则直接返回disposable
     
     我们的didsubscriber大家还记得是什么吗? 打印创建信号那段对吧
     
     然后我们看到它创建了一个RACDisposable实例, 但是它用的是一个RACScheduler来创建的
     
     我们看看这个RACScheduler是个啥
     
     /// Schedulers are used to control when and where work is performed.
     @interface RACScheduler : NSObject
     哦 它是一个类似Timer或者dispatch_after的东西, 控制事件在什么时候触发
     
     我们再看看这个subscriptionScheduler
     
     + (RACScheduler *)subscriptionScheduler {
     static dispatch_once_t onceToken;
     static RACScheduler *subscriptionScheduler;
     dispatch_once(&onceToken, ^{
     subscriptionScheduler = [[RACSubscriptionScheduler alloc] init];
     });
     
     return subscriptionScheduler;
     }
     它创建了一个RACScheduler单例, 不过是用RACSubscriptionScheduler来初始化的, 我们再看看它
     
     @interface RACSubscriptionScheduler : RACScheduler
     是一个RACSchedule的子类, 它重写的初始化和schedule , after...等等方法,  先记下一会看看是否用到了这些重写的方法
     
     这里我们先看看这个子类重写的初始化方法
     
     - (instancetype)init {
     self = [super initWithName:@"org.reactivecocoa.ReactiveObjC.RACScheduler.subscriptionScheduler"];
     
     _backgroundScheduler = [RACScheduler scheduler];
     
     return self;
     }
     重命名, 然后给持有的一个RACScheduler对象backgroundScheduler赋值, 我们看看RACScheduler的scheduler做了什么
     
     + (RACScheduler *)scheduler {
     return [self schedulerWithPriority:RACSchedulerPriorityDefault];
     }
     继续点
     
     + (RACScheduler *)schedulerWithPriority:(RACSchedulerPriority)priority {
     return [self schedulerWithPriority:priority name:@"org.reactivecocoa.ReactiveObjC.RACScheduler.backgroundScheduler"];
     }
     还是看不出来, 继续点
     
     + (RACScheduler *)schedulerWithPriority:(RACSchedulerPriority)priority name:(NSString *)name {
     return [[RACTargetQueueScheduler alloc] initWithName:name targetQueue:dispatch_get_global_queue(priority, 0)];
     }
     返回了一个RACTargetQueueScheduler实例, targetQueue是一个dispatch_get_global_queue全局队列
     
     /// A scheduler that enqueues blocks on a private serial queue, targeting an
     /// arbitrary GCD queue.
     @interface RACTargetQueueScheduler : RACQueueScheduler
     
     /// Initializes the receiver with a serial queue that will target the given
     /// `targetQueue`.
     ///
     /// name        - The name of the scheduler. If nil, a default name will be used.
     /// targetQueue - The queue to target. Cannot be NULL.
     ///
     /// Returns the initialized object.
     - (instancetype)initWithName:(nullable NSString *)name targetQueue:(dispatch_queue_t)targetQueue;
     一个类似队列的东西, 看看它的初始化方法
     
     - (instancetype)initWithName:(NSString *)name targetQueue:(dispatch_queue_t)targetQueue {
     NSCParameterAssert(targetQueue != NULL);
     
     if (name == nil) {
     name = [NSString stringWithFormat:@"org.reactivecocoa.ReactiveObjC.RACTargetQueueScheduler(%s)", dispatch_queue_get_label(targetQueue)];
     }
     
     dispatch_queue_t queue = dispatch_queue_create(name.UTF8String, DISPATCH_QUEUE_SERIAL);
     if (queue == NULL) return nil;
     
     dispatch_set_target_queue(queue, targetQueue);
     
     return [super initWithName:name queue:queue];
     }
     前面很清晰, 创建了一个队列
     
     看看super的初始化做了什么<
     
     - (instancetype)initWithName:(NSString *)name queue:(dispatch_queue_t)queue {
     NSCParameterAssert(queue != NULL);
     
     self = [super initWithName:name];
     
     _queue = queue;
     #if !OS_OBJECT_USE_OBJC
     dispatch_retain(_queue);
     #endif
     
     return self;
     }
     保存了这个队列, 就结束了
     
     还记得到哪里了吗, 我把代码再贴下
     
     - (RACDisposable *)subscribe:(id<RACSubscriber>)subscriber {
     NSCParameterAssert(subscriber != nil);
     
     RACCompoundDisposable *disposable = [RACCompoundDisposable compoundDisposable];
     subscriber = [[RACPassthroughSubscriber alloc] initWithSubscriber:subscriber signal:self disposable:disposable];
     
     if (self.didSubscribe != NULL) {
     RACDisposable *schedulingDisposable = [RACScheduler.subscriptionScheduler schedule:^{
     RACDisposable *innerDisposable = self.didSubscribe(subscriber);
     [disposable addDisposable:innerDisposable];
     }];
     
     [disposable addDisposable:schedulingDisposable];
     }
     
     return disposable;
     }
     现在到这个schedule了, 我们看看它做了什么, 注意哦这个时候要去看RACScheduler的子类RACSubscriptionScheduler中的方法
     
     - (RACDisposable *)schedule:(void (^)(void))block {
     NSCParameterAssert(block != NULL);
     
     if (RACScheduler.currentScheduler == nil) return [self.backgroundScheduler schedule:block];
     
     block();
     return nil;
     }
     看到了吗 block(), 是不是从来没有觉得这对括号这么可爱的, 我们看着这么半天终于看到一个执行block的地方了
     
     先不急, 我们看看它之前的代码
     
     首先判断block非空, 然后如果RACScheduler.currentScheduler为空的话, 就让backgroundscheduler去调用block
     
     这个backgroundscheduler看菜我们有看是一个RACScheduler的实例, 我们先看看如果为空要怎么样
     
     - (RACDisposable *)schedule:(void (^)(void))block {
     NSCAssert(NO, @"%@ must be implemented by subclasses.", NSStringFromSelector(_cmd));
     return nil;
     }
     啥都没干,  看起来这里我们就要期待它一定不为空了,  不然我们我们辛辛苦苦找到一个执行的地方就又白找了
     
     那么它到底是不是空呢, 我们先看看它的定义
     
     /// The current scheduler. This will only be valid when used from within a
     /// -[RACScheduler schedule:] block or when on the main thread.
     + (nullable RACScheduler *)currentScheduler;
     说是只要在主线程, 或者调用过[RACScheduler schedule]方法就不为空
     
     那么我们现在是在那个线程呢? 还记得吗 我们刚才创建了一个全局队列, 那么有没有切换队列呢
     
     好像没有, 对吧, 没关系我们看看这个currentScheduler的setter方法
     
     + (RACScheduler *)currentScheduler {
     RACScheduler *scheduler = NSThread.currentThread.threadDictionary[RACSchedulerCurrentSchedulerKey];
     if (scheduler != nil) return scheduler;
     if ([self.class isOnMainThread]) return RACScheduler.mainThreadScheduler;
     
     return nil;
     }
     看到没, 它首先创建了一个RACScheduler实例, 用的NSThread的threadDIctonary去找RACScheduleCurrentScheduleKey
     
     如果找到了就在返回这个队列, 否则如果是主线程就返回主线程队列,
     
     我们当前并没有切换队里, 这里应该是给其他情况下使用的
     
     好了, 我们再看看执行的是什么block
     
     RACDisposable *innerDisposable = self.didSubscribe(subscriber);
     [disposable addDisposable:innerDisposable];
     我们注意第一句话, 这里就执行了didSubscribe并把返回值赋给了一个RACDisposable
     
     记得didSubscribe里面有什么吗? 对就是打印创建信号的那个block
     
     到这里我们就看到为什么前面创建信号的时候没有调用那里的block, 原来是订阅的这个地方调用的.
     
     所以创建信号的block要订阅的时候才会去执行
     
     不过好像到这里都没有去执行我们订阅的block, 只是把信号跟订阅捆绑到了一起.
     
     那么要怎么执行订阅的block呢? 不知道大家注意到没, 我们订阅用的是subscribeNext, 看字面意思是订阅然后做去执行
     
     看字面理解我们现在只是完成了订阅的操作, 但没有触发next
     
     要怎么触发next呢?
     
     我们可以想想这个触发要什么时候做呢? 目前只有创建和订阅 那么肯定在创建的时候触发对不对
     
     我们看看创建信号的block里面的一个id格式的参数subscriber, 不过它有实现一个协议RACSubscriber
     
     我们看看里面有什么
     
     @protocol RACSubscriber <NSObject>
     @required
     
     /// Sends the next value to subscribers.
     ///
     /// value - The value to send. This can be `nil`.
     - (void)sendNext:(nullable id)value;
     
     /// Sends the error to subscribers.
     ///
     /// error - The error to send. This can be `nil`.
     ///
     /// This terminates the subscription, and invalidates the subscriber (such that
     /// it cannot subscribe to anything else in the future).
     - (void)sendError:(nullable NSError *)error;
     
     /// Sends completed to subscribers.
     ///
     /// This terminates the subscription, and invalidates the subscriber (such that
     /// it cannot subscribe to anything else in the future).
     - (void)sendCompleted;
     
     /// Sends the subscriber a disposable that represents one of its subscriptions.
     ///
     /// A subscriber may receive multiple disposables if it gets subscribed to
     /// multiple signals; however, any error or completed events must terminate _all_
     /// subscriptions.
     - (void)didSubscribeWithDisposable:(RACCompoundDisposable *)disposable;
     
     @end
     很清楚对不对, 原来在这里,
     */
    
    // 订阅一个信号
    [signal subscribeNext:^(id  _Nullable x) {
        
        NSLog(@"订阅一个信号！！！");
        
        NSLog(@"订阅到的信号：%@", x);
    }];
    
    // ---------------------------------------------------------------
}

/*
 RAC是提供事件流，通过信号源和信号源提供者（产生者），信号接受者协和来完成。
 借用面向对象的一句话，万物皆是流的形式，通过一方发出信号，一方接受信号来完成不同事件。
 
 ReactiveCocoa作用
 
 代理方法
 block 回调
 通知
 行为控制和事件的响应链
 协议
 KVO
 ……
 主要作用：
 高内聚，低耦合，使代码更加内聚，也便于代码的读取
 
 响应式编程思想：
 不需要考虑调用顺序，只需要知道考虑结果，类似于蝴蝶效应，产生一个事件，会影响很多东西，这些事件像流一样的传播出去，然后影响结果，借用面向对象的一句话，万物皆是流。
 
 函数式编程思想：
 是把操作尽量写成一系列嵌套的函数或者方法调用。
 特点：每个方法必须有返回值（本身对象）,把函数或者Block当做参数,block参
 数（需要操作的值）block返回值（操作结果）。
 
 ReactiveCocoa编程风格：
 ReactiveCocoa结合了 函数式编程（Functional Programming）和 响应式编程（Reactive Programming）各自的优点，产生一种新的语法
 */
- (void)testRACExplain
{
    /*
     ReactiveCocoa常见类。
     
     01.RACSiganl ，在RAC中最核心的类
     
     RACSiganl:信号类,一般表示将来有数据传递，只要有数据改变，信号内部接收到数据，就会马上发出数据。
     
     只是表示当数据改变时，信号内部会发出数据，它本身不具备发送信号的能力，而是交给内部一个订阅者去发出。
     
     默认一个信号都是冷信号，也就是值改变了，也不会触发，只有订阅了这个信号，这个信号才会变为热信号，值改变了才会触发。
     
     如何订阅信号：调用信号RACSignal的subscribeNext就能订阅。
     */
    
    // 1.创建信号
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        // block调用时刻：每当有订阅者订阅信号，就会调用block。
        
        // 2.发送信号
        [subscriber sendNext:@"我是一个信号类"];
        // 如果不在发送数据，最好发送信号完成，内部会自动调用[RACDisposable disposable]取消订阅信号。
        [subscriber sendCompleted];
        // block调用时刻：当信号发送完成或者发送错误，就会自动执行这个block,取消订阅信号。
        return [RACDisposable disposableWithBlock:^{
            // 执行完Block后，当前信号就不在被订阅了。
            NSLog(@"信号被销毁");
        }];
    }];
    //    self.signal = signal;
    
    // 3.订阅信号,才会激活信号
    [signal subscribeNext:^(id x) {
        NSLog(@"接收的数据：%@",x);
    }];
    
    /*
     02.RACSubscriber:
     表示订阅者的意思，用于发送信号，这是一个协议，不是一个类，只要遵守这个协议，并且实现方法才能成为订阅者。通过create创建的信号，都有一个订阅者，帮助他发送数据.
     */
    
    /*
     03.RACDisposable:
     用于取消订阅或者清理资源，当信号发送完成或者发送错误的时候，就会自动触发它。
     */
    
    [RACDisposable disposableWithBlock:^{
        // 执行完Block后，当前信号就不在被订阅了。
        NSLog(@"信号被销毁");
    }];
    
    /*
     04.RACSubject:
     RACSubject:信号提供者，自己可以充当信号，又能发送信号。
     RACSubject使用步骤：
     
     1.创建信号 [RACSubject subject]，跟RACSiganl不一样，创建信号时没有block。
     2.订阅信号 - (RACDisposable *)subscribeNext:(void (^)(id x))nextBlock
     3.发送信号 sendNext:(id)value
     */
    
    // 1.创建信号
    RACSubject *subject = [RACSubject subject];
    // 2.订阅信号
    [subject subscribeNext:^(id x) {
        // block调用时刻：当信号发出新值，就会调用.
        NSLog(@"第一个订阅者：%@",x);
    }];
    [subject subscribeNext:^(id x) {
        // block调用时刻：当信号发出新值，就会调用.
        NSLog(@"第二个订阅者：%@",x);
    }];
    // 3.发送信号
    [subject sendNext:@"发送信号"];
    
    /*
     ReactiveCocoa在开发中常见的用法:
     
     Event(按钮的点击)
     // 监听事件
     // 把按钮点击事件转换为信号，点击按钮，就会发送信号
     [[button rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
     NSLog(@"按钮被点击");
     }];
     
     KVO观察者
     // 监听对象的属性值改变，转换成信号，只要值改变就会发送信号
     [[View rac_valuesAndChangesForKeyPath:@"x" options:NSKeyValueObservingOptionNew observer:nil] subscribeNext:^(id x) {
     NSLog(@"view的x值发生了改变");
     }];
     
     Notification通知
     // 代替通知
     // 把监听到的通知转换信号
     [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillShowNotification object:nil] subscribeNext:^(id x) {
     NSLog(@"键盘将要出现");
     }];
     
     // 通过RAC提供的宏快速实现观察者模式
     // RACObserve(self, name):监听某个对象的某个属性,返回的是信号。
     [RACObserve(self.greenView,x) subscribeNext:^(id x) {
     NSLog(@"绿色view的x方向发生改变");
     }];
     
     
     textField的文字信号
     // 监听文本框的文字改变
     [[_textField rac_textSignal] subscribeNext:^(NSString *x) {
     NSLog(@"文本框文字发生了改变：%@",x);
     }];
     
     // 通过RAC提供的宏快速实现textSingel的监听
     // RAC(TARGET, [KEYPATH, [NIL_VALUE]]):用于给某个对象的某个属性绑定。
     // 当textField的文字发生改变时，label的文字也发生改变
     RAC(self.textLabel,text) = self.textField.rac_textSignal;
     
     
     手势信号
     // 监听手势
     UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
     [[tapGesture rac_gestureSignal] subscribeNext:^(id x) {
     NSLog(@"view被触发tap手势");
     }];
     [self.view addGestureRecognizer:tapGesture];
     
     
     过滤器filter方法的使用
     // 过滤器
     [[self.textField.rac_textSignal filter:^BOOL(NSString *value) {
     return value.length >= 3;
     }] subscribeNext:^(id x) {
     NSLog(@"%@",x);
     }];
     
     */
}

@end
