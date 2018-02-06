//
//  SZPerson.h
//  SZ_ReactiveObjC_SimpleDemo
//
//  Created by yanl on 2018/1/24.
//  Copyright © 2018年 yanl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SZPerson : NSObject

- (SZPerson *)run;

- (SZPerson *)walk;

// ------------------------------------

- (SZPerson *(^)(void))runBlock;

- (SZPerson *(^)(void))walkBlock;

@end
