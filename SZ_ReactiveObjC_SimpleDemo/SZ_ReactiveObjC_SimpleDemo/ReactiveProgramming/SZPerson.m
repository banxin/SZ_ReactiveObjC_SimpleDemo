//
//  SZPerson.m
//  SZ_ReactiveObjC_SimpleDemo
//
//  Created by yanl on 2018/1/24.
//  Copyright © 2018年 yanl. All rights reserved.
//

#import "SZPerson.h"

@implementation SZPerson

- (SZPerson *)run
{
    NSLog(@"跑步");
    
    // 延时2s
    [NSThread sleepForTimeInterval:2];
    
    return self;
}

- (SZPerson *)walk
{    
    NSLog(@"走路");
    
    // 延时2s
    [NSThread sleepForTimeInterval:2];
    
    return self;
}

- (SZPerson *(^)(void))runBlock
{
    SZPerson *(^block)(void) = ^() {
        
        NSLog(@"run");
        // 延时2s
        [NSThread sleepForTimeInterval:2];
        return self;
    };
    
    return block;
}

- (SZPerson *(^)(void))walkBlock
{
    SZPerson *(^block)(void) = ^() {
        
        NSLog(@"walk");
        // 延时2s
        [NSThread sleepForTimeInterval:2];
        return self;
    };
    
    return block;
}

@end
