//
//  XSChatMessageModel.h
//  TradeaiderQC
//
//  Created by shinyhub on 16/9/23.
//  Copyright © 2016年 shinyhub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EMClient.h>
@interface XSChatMessageModel : NSObject

@property (nonatomic, assign) BOOL isSender;    //是否是发送者
@property (nonatomic, assign) BOOL isRead;      //是否已读
@property (nonatomic, assign) BOOL isChatGroup;  //是否是群聊

@property (nonatomic, strong) NSString *messageId;
@property (nonatomic, strong) NSURL *headImageURL;
@property (nonatomic, strong) NSString *nickName;
@property (nonatomic, strong) NSString *username;

//text
@property (nonatomic, strong) NSString *content;

//image
@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) CGSize thumbnailSize;
@property (nonatomic, strong) NSURL *imageRemoteURL;
@property (nonatomic, strong) NSURL *thumbnailRemoteURL;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImage *thumbnailImage;

//audio
@property (nonatomic, strong) NSString *localPath;
@property (nonatomic, strong) NSString *remotePath;
@property (nonatomic, assign) NSInteger time;
@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic, assign) BOOL isPlayed;

//location
@property (nonatomic, strong) NSString *address;
@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;

@property (nonatomic, strong)EMMessage *message;

/* 上一条信息发送时间**/
@property(strong,nonatomic) NSString *lastTime;
@end
