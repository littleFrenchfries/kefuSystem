//
//  XSChatMessageTool.m
//  TradeaiderQC
//
//  Created by shinyhub on 16/9/30.
//  Copyright © 2016年 shinyhub. All rights reserved.
//

#import "XSChatMessageTool.h"

@implementation XSChatMessageTool
+ (instancetype)toolBar
{
    return [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil].lastObject;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
