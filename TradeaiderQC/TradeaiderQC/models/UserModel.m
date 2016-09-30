//
//  UserModel.m
//  TradeaiderQC
//
//  Created by shinyhub on 16/9/22.
//  Copyright © 2016年 shinyhub. All rights reserved.
//

#import "UserModel.h"

@implementation UserModel

+ (instancetype)sareAcount {
    static UserModel * manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[UserModel alloc]init];
    });
    return manager;
}

@end
