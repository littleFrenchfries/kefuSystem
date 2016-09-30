
//
//  XSChatHelper.m
//  TradeaiderQC
//
//  Created by shinyhub on 16/9/22.
//  Copyright © 2016年 shinyhub. All rights reserved.
//

#import "XSChatHelper.h"

@interface XSChatHelper ()<EMClientDelegate, EMContactManagerDelegate, EMChatManagerDelegate, EMGroupManagerDelegate, EMClientDelegate>

@property (copy, nonatomic) void (^block)(EMGroup *group);

@end

@implementation XSChatHelper

+ (instancetype)sharedChatHelper{
    static XSChatHelper *chatHelper;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        chatHelper = [[XSChatHelper alloc] init];
    });
    return chatHelper;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}
#pragma mark -----上传devicetoken
+ (void)commitDeviceToken:(NSData *)deviceToken{
    [[EMClient sharedClient] bindDeviceToken:deviceToken];
}
#pragma mark 设置环信
+ (void)registEMCirle{
    EMOptions *options = [EMOptions optionsWithAppkey:@"wangxu19921004#tradeaiderqc"];
    options.apnsCertName = apnsCertN;
    [[EMClient sharedClient] initializeSDKWithOptions:options];
}
+ (void)applicationDidEnterBackground:(UIApplication *)application {
    [[EMClient sharedClient] applicationDidEnterBackground:application];
}

+ (void)applicationWillEnterForeground:(UIApplication *)application {
    application.applicationIconBadgeNumber = 0;
    [[EMClient sharedClient] applicationWillEnterForeground:application];
}
+ (void)logIM {
    [[self sharedChatHelper] logIM];
}
- (void)logIM {
    dispatch_async(global_quque, ^{
        UserModel *account = [UserModel sareAcount];
        NSString *userID = [NSString stringWithFormat:@"%@", account.userAcount];
        NSString *password = [NSString stringWithFormat:@"%@", account.passwd];
        EMError *error = [[EMClient sharedClient] loginWithUsername:userID password:password];
        if (!error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                //自动登录属性默认是关闭的，需要您在登录成功后设置
                [[EMClient sharedClient].options setIsAutoLogin:YES];
                [[EMClient sharedClient] setApnsNickname:apnsCertN];
                SHLog(@"IM登录成功");
            });
        }else{
            SHLog(@"环信:%@", error.errorDescription);
        }
    });
}
+ (void)logOutIM {
    [[self sharedChatHelper]logOutIM];
}
- (void)logOutIM {
    dispatch_async(global_quque, ^{
        EMError *error = [[EMClient sharedClient] logout:YES];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error) {
                SHLog(@"退出IM成功");
            }
        });
    });
}
#pragma mark 注册
/**
 *   注册模式分两种，开放注册和授权注册。
 
 只有开放注册时，才可以客户端注册。开放注册是为了测试使用，正式环境中不推荐使用该方式注册环信账号。
 授权注册的流程应该是您服务器通过环信提供的 REST API 注册，之后保存到您的服务器或返回给客户端。

 */
+ (void)registerIM {
    EMError *error = [[EMClient sharedClient] registerWithUsername:[UserModel sareAcount].userAcount password:[UserModel sareAcount].passwd];
    if (error==nil) {
        SHLog(@"注册成功");
    }else{
        SHLog(@"环信注册失败:%@", error.errorDescription);
    }
}
- (void)setup{
    //自动登录回调监听代理
    [[EMClient sharedClient] addDelegate:self delegateQueue:nil];
    //注册好友回调
    [[EMClient sharedClient].contactManager addDelegate:self delegateQueue:nil];
    [[EMClient sharedClient] addDelegate:self delegateQueue:nil];
    [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
}
- (void)dealloc{
    //移除好友回调
    [[EMClient sharedClient].contactManager removeDelegate:self];
    [[EMClient sharedClient].chatManager removeDelegate:self];
    [[EMClient sharedClient] removeDelegate:self];
}
#pragma mark 重连
- (void)didConnectionStateChanged:(EMConnectionState)aConnectionState {
    if (aConnectionState == EMConnectionConnected) {
        SHLog(@"已连接");
    }else {
        SHLog(@"未连接");
    }
}
#pragma mark 自动登录返回结果
- (void)didAutoLoginWithError:(EMError *)aError{
    SHLog(@"登录失败");
}

#pragma mark 当前登录账号在其它设备登录时会接收到该回调
- (void)didLoginFromOtherDevice{
    SHLog(@"当前登录账号在其它设备登录");
}

#pragma mark 当前登录账号已经被从服务器端删除时会收到该回调
- (void)didRemovedFromServer{
    SHLog(@"当前登录账号已经被从服务器端");
}
#pragma mark 会话列表发生变化
- (void)didUpdateConversationList:(NSArray *)aConversationList{
    
}
#pragma mark 收到消息
- (void)messagesDidReceive:(NSArray *)aMessages{
    
}

#pragma mark 接收消息
- (void)didReceiveMessages:(NSArray *)aMessages{
    EMMessage *message = aMessages.firstObject;
    EMMessageBody *msgBody = message.body;
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    switch (state) {
        case UIApplicationStateActive:
            break;
        case UIApplicationStateInactive:
            break;
        case UIApplicationStateBackground:
            break;
        default:
            break;
    }
}
#pragma mark 查找群组信息
+ (void)searchGroup:(NSString *)groupID  groupBlock:(void (^)(EMGroup *group))block{
    [[self sharedChatHelper]searchGroup:groupID groupBlock:block];
}
- (void)searchGroup:(NSString *)groupID  groupBlock:(void (^)(EMGroup *group))block{
    self.block = block;
    NSArray *groupArray = [[EMClient sharedClient].groupManager getAllGroups];
    if (groupArray.count == 0) {
        //从服务器获群组列表
        [self getGroupDataFromService:groupID];
    }else{
        [self changDataType:groupID dataArray:groupArray];
    }
}

#pragma mark 从服务器获群组列表
- (void)getGroupDataFromService:(NSString *)groupID{
    dispatch_async(global_quque, ^{
        NSArray *dataArray = [[EMClient sharedClient].groupManager getMyGroupsFromServerWithError:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self changDataType:groupID dataArray:dataArray];
        });
    });
}

- (void)changDataType:(NSString *)groupID dataArray:(NSArray *)dataArray{
    for (EMGroup *group in dataArray) {
        if ([group.groupId isEqualToString:groupID]) {
            if (self.block) {
                self.block(group);
            }
            break;
        }
        
    }
}

#pragma mark ----创建客服会话
+ (EMConversation *)createConversation {
    return [[self sharedChatHelper] createConversation];
}
- (EMConversation *)createConversation {
    EMConversation *conversation = [[EMClient sharedClient].chatManager getConversation:@"wx" type:EMConversationTypeChat createIfNotExist:YES];
    //将所有消息都设为已读
    [conversation markAllMessagesAsRead:nil];
    self.conversation = conversation;
    return conversation;
}
#pragma mark ----加载本地数据库的聊天记录
+ (void)loadLocationChatDataList:(NSString *)messageId success:(void(^)(NSArray *))block {
    [[self sharedChatHelper] loadLocationChatDataList:messageId success:block];
}
- (void)loadLocationChatDataList:(NSString *)messageId success:(void(^)(NSArray *))block {
    dispatch_async(global_quque, ^{
        [self.conversation loadMessagesStartFromId:messageId count:10 searchDirection:EMMessageSearchDirectionUp completion:^(NSArray *aMessages, EMError *aError) {
            dispatch_async(main_queue, ^{
                if (block) {
                    block(aMessages);
                }
            });
        }];
    });
}
#pragma mark ------发送文本消息
+ (EMMessage *)commitTextMessage:(NSString *)text conversationType:(EMChatType)type {
    EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithText:text];
    return [[self sharedChatHelper] sendMessage:body conversationType:type];
}
#pragma mark ------录音上传
+ (EMMessage *)commitRecord:(NSString *)recordPath duration:(NSInteger)duration conversationType:(EMChatType)type{
    EMVoiceMessageBody *body = [[EMVoiceMessageBody alloc] initWithLocalPath:recordPath displayName:@"[语言]"];
    body.duration = (int)duration;
    return [[self sharedChatHelper] sendMessage:body conversationType:type];
}
#pragma mark --------发送图片
+ (EMMessage *)commitImageMessage:(UIImage *)image conversationType:(EMChatType)type {
    EMImageMessageBody *body = [[EMImageMessageBody alloc] initWithData:UIImagePNGRepresentation(image) displayName:@"[图片]"];
    body.size = image.size;
    body.compressionRatio = 0.8;
    return [[self sharedChatHelper] sendMessage:body conversationType:type];
}
#pragma mark -------发送视频
+ (EMMessage *)commitVideoMessage:(NSString *)videoPath conversationType:(EMChatType)type{
    EMVideoMessageBody *video = [[EMVideoMessageBody alloc] initWithLocalPath:videoPath displayName:@"[视频]"];
    return [[self sharedChatHelper] sendMessage:video conversationType:type];
}
#pragma mark -------发送位置
+(EMMessage *)sendLocationLatitude:(double)latitude
                         longitude:(double)longitude
                           address:(NSString *)address
                  conversationType:(EMChatType)type

{
    EMLocationMessageBody *body = [[EMLocationMessageBody alloc] initWithLatitude:latitude longitude:longitude address:address];
    return [[self sharedChatHelper] sendMessage:body conversationType:type];
}
#pragma 发送消息
- (EMMessage *)sendMessage:(EMMessageBody *)body conversationType:(EMChatType)type{
    NSString *from = [[EMClient sharedClient] currentUsername];
    EMMessage *message = nil;
//    if (self.isService) {
//        message = [[EMMessage alloc] initWithConversationID:self.conversation.conversationId from:from to:self.conversation.conversationId body:body ext:[self getWeiChat]];
//    }else{
        message = [[EMMessage alloc] initWithConversationID:self.conversation.conversationId from:from to:self.conversation.conversationId body:body ext:nil];
//    }
    message.chatType = type;
    [[EMClient sharedClient].chatManager sendMessage:message progress:^(int progress) {
        SHLog(@"上传进度：%d", progress);
    } completion:^(EMMessage *message, EMError *error) {
        if (!error) {
            SHLog(@"发送文件成功");
        }
    }];
    return message;
}

@end
