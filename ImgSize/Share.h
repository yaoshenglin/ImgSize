//
//  Share.h
//  MangaWorld
//
//  Created by Yin on 14-12-27.
//  Copyright (c) 2014年 caidan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WXApi.h"
#import "WechatAuthSDK.h"
#import <TencentOpenAPI/QQApi.h>
#import <TencentOpenAPI/TencentOAuth.h>
//#import "SinaWeibo.h"

#define WX_AppId        @"wxd4cb6799c74b3a0d"                   //WX登录ID
#define QQ_AppId        @"1105348434"                           //QQ登录ID

#pragma mark 门禁状态（Enum_DoorStatus）
typedef NS_ENUM(NSInteger,Enum_QQShareCode)
{
    QQShare_Success         =  0,    //分享成功(nil)
    QQShare_ParamError      = -1,    //参数错误(param error)
    QQShare_CodeInvalid     = -2,    //该群不在自己的群列表里面(group code is invalid)
    QQShare_UploadFailed    = -3,    //上传图片失败(upload photo failed)
    QQShare_GiveUp          = -4,    //用户放弃当前操作(user give up the current operation)
    QQShare_ClientInternalError     = -5,    //客户端内部处理错误(client internal error)
};

typedef void (^WXBlock)(NSDictionary *dict,NSError *error);

@interface WXShare : NSObject

@property (weak, nonatomic) id delegate;

+ (void)registerApp;
+ (void)sendAuthRequest;
//#pragma mark 使用code获取用户信息
//+ (void)getUserInfoWithCode:(NSString *)code complete:(WXBlock)nextBlock;
//#pragma mark 使用RefreshToken刷新AccessToken
//+ (void)getAccessTokenWithRefreshToken:(NSString *)refreshToken complete:(WXBlock)nextBlock;
+ (BOOL)handleOpenURL:(NSURL *) url delegate:(id)delegate;
- (NSDictionary *)imgData:(NSData *)data title:(NSString *)title media:(NSString *)media;
- (void)ShareToWX:(NSString *)content data:(NSDictionary *)imgData;
- (BOOL)sendTextContent:(NSString *)content;//只分享文本
- (BOOL)sendTextContent:(NSString *)content scene:(int)scene;//分享文本,选择场景
- (BOOL)sendMediaMessage:(WXMediaMessage *)message scene:(int)scene;
- (BOOL)sendTextTitle:(NSString *)title image:(UIImage *)image description:(NSString *)description webpageUrl:(NSString *)webpageUrl;

@end

@interface NSObject (WXShareDelegate)

- (void)onResp:(BaseResp*)resp share:(BOOL)isShare;
- (void)getShareResult:(BOOL)isShare;

@end

@interface QQShare : NSObject

@property (weak, nonatomic) id delegate;
@property (retain, nonatomic) TencentOAuth *OAuth;

+ (QQShare *)getInstance;
+ (BOOL)HandleOpenURL:(NSURL *)url;

+ (NSDictionary *)parseUrl:(NSURL *)url;

- (void)installQQ;
- (QQApiSendResultCode) sendTextContent:(NSString *)content;//只分享文本
- (QQApiSendResultCode) sendMessageWithObject:(QQApiObject*)obj andType:(QQApiMessageType)type;
- (QQApiSendResultCode) sendMsgWithURL:(NSURL*)url title:(NSString*)title description:(NSString*)description previewImageData:(NSData *)data;

@end

/*
@interface SinaShare : NSObject
{
    SinaWeibo *sina;
}

+ (SinaShare *)sharedInstance;
- (void)addWeiBo:(SinaWeibo *)aWeiBo;
- (void)sendBtnClicked:(NSString *)msg;

@end
 */
