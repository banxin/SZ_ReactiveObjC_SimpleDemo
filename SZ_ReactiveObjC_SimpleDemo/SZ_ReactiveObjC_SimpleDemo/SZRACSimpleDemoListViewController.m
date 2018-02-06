//
//  SZRACSimpleDemoListViewController.m
//  SZ_ReactiveObjC_SimpleDemo
//
//  Created by yanl on 2018/1/24.
//  Copyright © 2018年 yanl. All rights reserved.
//

#import "SZRACSimpleDemoListViewController.h"

@interface SZRACSimpleDemoListViewController ()

@property (nonatomic, strong) NSArray *titleAry;

@end

@implementation SZRACSimpleDemoListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.title = @"RAC 简单DEMO 列表";
}

#pragma - UITableViewDelegate & UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.titleAry.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellId"];
    
    if (!cell) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellId"];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    cell.textLabel.text = self.titleAry[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self push:[self getVCName:indexPath.row]];
}

- (NSString *)getVCName:(NSInteger)rowNum
{
    switch (rowNum) {
            
        case 0:
            
            return @"SZReactiveProgrammingViewController";
            
            break;
            
        case 1:
            
            return @"SZRACBasicViewController";
            
            break;
            
        case 2:
            
            return @"SZSimpleUseViewController";
            
            break;
            
        case 3:
            
            return @"SZEasyTestViewController";
            
            break;
            
        case 4:
            
            return @"SZCSDNDemoViewController";
            
            break;
            
        case 5:
            
            return @"SZSeemygoBasicViewController";
            
            break;
            
        case 6:
            
            return @"SZSeemygoAdvanceViewController";
            
            break;
            
        case 7:
            
            return @"SZRAC_MVVMViewController";
            
            break;
            
        case 8:
            
            return @"SZRAC_NetworkViewController";
            
            break;
            
        default:
            
            return nil;
            
            break;
    }
}

- (void)push:(NSString *)className
{
    [self.navigationController pushViewController:[NSClassFromString(className) new] animated:YES];
}

#pragma mark - getter / setter

- (NSArray *)titleAry
{
    if (!_titleAry) {
        
        _titleAry = @[@"1.响应式编程基本实现", @"2.RAC 基本概念", @"3.RAC 基本使用", @"4.RAC 简单使用", @"5.CSDN Demo 展示", @"6.小码哥 基础 Demo", @"6.小码哥 进阶 Demo", @"7.RAC & MVVM Demo", @"8.RAC & Network Demo"];
    }
    
    return _titleAry;
}

@end
