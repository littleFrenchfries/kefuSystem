//
//  XSChatHelper.h
//  TradeaiderQC
//
//  Created by shinyhub on 16/9/22.
//  Copyright © 2016年 shinyhub. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XSChatHelper : NSObject
@property (strong, nonatomic) EMConversation * conversation;
//设置环信
+ (void)registEMCirle;
+ (void)applicationDidEnterBackground:(UIApplication *)application;
+ (void)applicationWillEnterForeground:(UIApplication *)application;
//上传devicetoken
+ (void)commitDeviceToken:(NSData *)deviceToken;

//创建一个客服会话
+ (EMConversation *)createConversation;
//查找群组信息
+ (void)searchGroup:(NSString *)groupID  groupBlock:(void (^)(EMGroup *group))block;
//加载本地聊天记录
+ (void)loadLocationChatDataList:(NSString *)messageId success:(void(^)(NSArray *))block;
//登录
+ (void)logIM;
//退出IM
+ (void)logOutIM;
//注册模式分两种，开放注册和授权注册。
+ (void)registerIM;
//发送文本消息
+ (EMMessage *)commitTextMessage:(NSString *)text conversationType:(EMChatType)type;
//录音上传
+ (EMMessage *)commitRecord:(NSString *)recordPath duration:(NSInteger)duration conversationType:(EMChatType)type;
//发送图片
+ (EMMessage *)commitImageMessage:(UIImage *)image conversationType:(EMChatType)type;
//发送视频
+ (EMMessage *)commitVideoMessage:(NSString *)videoPath conversationType:(EMChatType)type;
@end
