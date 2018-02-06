//
//  SZRAC&NetworkViewController.m
//  SZ_ReactiveObjC_SimpleDemo
//
//  Created by yanl on 2018/1/29.
//  Copyright © 2018年 yanl. All rights reserved.
//

#import "SZRAC&NetworkViewController.h"

#import "SZRequestViewModel.h"
#import "SZBook.h"

/*
 
 需求：请求豆瓣图书信息，url:https://api.douban.com/v2/book/search?q=基础
 
 分析：请求一样，交给VM模型管理
 
 步骤:
 1.控制器提供一个视图模型（requesViewModel），处理界面的业务逻辑
 2.VM提供一个命令，处理请求业务逻辑
 3.在创建命令的block中，会把请求包装成一个信号，等请求成功的时候，就会把数据传递出去。
 4.请求数据成功，应该把字典转换成模型，保存到视图模型中，控制器想用就直接从视图模型中获取。
 5.假设控制器想展示内容到tableView，直接让视图模型成为tableView的数据源，把所有的业务逻辑交给视图模型去做，这样控制器的代码就非常少了。
 */

@interface SZRAC_NetworkViewController ()

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) SZRequestViewModel *requesViewModel;

@end

@implementation SZRAC_NetworkViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"RAC & Network Demo";
    
    [self setupUI];
    
    [self loadData];
}

- (void)setupUI
{
    // 创建tableView
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    
    tableView.dataSource = self.requesViewModel;
    tableView.delegate   = self.requesViewModel;
    
    self.tableView = tableView;
    
    [self.view addSubview:tableView];
}

- (void)loadData
{
    // 执行请求
    RACSignal *requesSiganl = [self.requesViewModel.reuqesCommand execute:nil];
    
    @weakify(self)
    // 获取请求的数据
    [requesSiganl subscribeNext:^(NSArray *x) {
        
        @strongify(self)
        self.requesViewModel.models = x;
        
        [self.tableView reloadData];
    }];
}

#pragma mark - lazy load

- (SZRequestViewModel *)requesViewModel
{
    if (_requesViewModel == nil) {
        
        _requesViewModel = [[SZRequestViewModel alloc] init];
    }
    
    return _requesViewModel;
}


@end














