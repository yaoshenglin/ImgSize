//
//  Share.m
//  MangaWorld
//
//  Created by Yin on 14-12-27.
//  Copyright (c) 2014年 caidan. All rights reserved.
//

#import "Share.h"
#import "CTB.h"
#import "Tools.h"
#import "EnumTypes.h"
//#import <Accounts/Accounts.h>

@interface WXShare ()
{
    enum WXScene wxScene;//微信分享类型
    ShareType shareType;
}

@end

@implementation WXShare

+ (void)registerApp
{
    //[WXApi registerApp:@"wxf51c8154f251195f"];//微信注册
    [WXApi registerApp:WX_AppId];//微信注册
    //[self.class sendAuthRequest];
}

//发起授权请求
+ (void)sendAuthRequest
{
    SendAuthReq* req = [[SendAuthReq alloc] init];
    req.scope = @"snsapi_message,snsapi_userinfo,snsapi_friend,snsapi_contact"; // @"post_timeline,sns"
    req.state = @"carea";
    req.openID = @"0c806938e2413ce73eef92cc3";
    
    //[WXApi sendAuthReq:req viewController:self.viewController delegate:self];
    [WXApi sendReq:req];
}

//#pragma mark 使用code获取用户信息
//+ (void)getUserInfoWithCode:(NSString *)code complete:(WXBlock)nextBlock
//{
//    //使用code获取access token
//    NSString *urlString =[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code",WX_AppId,WX_AppSecret,code];
//    NSURL *url = [NSURL URLWithString:urlString];
//    
//    __block NSData *data;
//    [CTB async:^{
//        NSString *dataStr = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
//        data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
//    } complete:^{
//        if (data)
//        {
//            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
//            
//            if ([dict objectForKey:@"errcode"])
//            {
//                //获取token错误
//            }else{
//                //存储AccessToken OpenId RefreshToken以便下次直接登陆
//                //AccessToken有效期两小时，RefreshToken有效期三十天
//                NSString *access_token = [dict objectForKey:@"access_token"];
//                NSString *openid = [dict objectForKey:@"openid"];
//                [self getUserInfoWithAccessToken:access_token andOpenId:openid complete:nextBlock];
//                //[[NSUserDefaults standardUserDefaults] setObject:access_token forKey:@"kWeiXinRefreshToken"];
//            }
//        }
//    }];
//    
//    /*
//     30      正确返回
//     31      "access_token" = “Oez*****8Q";
//     32      "expires_in" = 7200;
//     33      openid = ooVLKjppt7****p5cI;
//     34      "refresh_token" = “Oez*****smAM-g";
//     35      scope = "snsapi_userinfo";
//     36      */
//    
//    /*
//     39      错误返回
//     40      errcode = 40029;
//     41      errmsg = "invalid code";
//     42      */
//}

//#pragma mark 使用AccessToken获取用户信息
//+ (void)getUserInfoWithAccessToken:(NSString *)accessToken andOpenId:(NSString *)openId complete:(WXBlock)nextBlock
//{
//    NSString *urlString =[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@",accessToken,openId];
//    NSURL *url = [NSURL URLWithString:urlString];
//    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        
//        NSString *dataStr = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
//        NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            
//            if (data)
//            {
//                NSError *error = nil;
//                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
//                if (nextBlock) {
//                    nextBlock(dict,error);
//                }
//            }
//        });
//    });
//    
//    /*
//     29      city = ****;
//     30      country = CN;
//     31      headimgurl = "http://wx.qlogo.cn/mmopen/q9UTH59ty0K1PRvIQkyydYMia4xN3gib2m2FGh0tiaMZrPS9t4yPJFKedOt5gDFUvM6GusdNGWOJVEqGcSsZjdQGKYm9gr60hibd/0";
//     32      language = "zh_CN";
//     33      nickname = “****";
//     34      openid = oo*********;
//     35      privilege =     (
//     36      );
//     37      province = *****;
//     38      sex = 1;
//     39      unionid = “o7VbZjg***JrExs";
//     40      */
//    
//    /*
//     43      错误代码
//     44      errcode = 42001;
//     45      errmsg = "access_token expired";
//     46      */
//}

//#pragma mark 使用RefreshToken刷新AccessToken
////该接口调用后，如果AccessToken未过期，则刷新有效期，如果已过期，更换AccessToken。
//+ (void)getAccessTokenWithRefreshToken:(NSString *)refreshToken complete:(WXBlock)nextBlock
//{
//    NSString *urlString =[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/refresh_token?appid=%@&grant_type=refresh_token&refresh_token=%@",WX_AppId,refreshToken];
//    NSURL *url = [NSURL URLWithString:urlString];
//    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
//                   {
//                       NSError *error = nil;
//                       NSString *dataStr = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
//                       NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
//                       
//                       dispatch_async(dispatch_get_main_queue(), ^{
//                           
//                           if (data)
//                           {
//                               NSError *error = nil;
//                               NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
//                               if (nextBlock) {
//                                   nextBlock(dict,error);
//                               }
//                               
////                               if ([dict objectForKey:@"errcode"])
////                               {
////                                   //授权过期
////                               }else{
////                                   //重新使用AccessToken获取信息
////                                   [self.view makeToast:@"登录失败，请重新操作"];
////                               }
//                           }
//                       });
//                   });
//    
//    
//    /*
//     30      "access_token" = “Oez****5tXA";
//     31      "expires_in" = 7200;
//     32      openid = ooV****p5cI;
//     33      "refresh_token" = “Oez****QNFLcA";
//     34      scope = "snsapi_userinfo,";
//     35      */
//    /*
//     38      错误代码
//     39      "errcode":40030,
//     40      "errmsg":"invalid refresh_token"
//     41      */
//}

+ (BOOL)handleOpenURL:(NSURL *) url delegate:(id)delegate
{
    return [WXApi handleOpenURL:url delegate:delegate];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        wxScene = WXSceneTimeline;//设置分享到朋友圈
        shareType = ShareTypeWeixiTimeline;
    }
    
    return self;
}

//创建图片分享媒体
- (NSDictionary *)imgData:(NSData *)data title:(NSString *)title media:(NSString *)media
{
    if (!data || !title || !media) {
        return nil;
    }
    else if (![title isKindOfClass:[NSString class]] || ![media isKindOfClass:[NSString class]]) {
        return nil;
    }
    
    data = data ?: [NSData data];
    title = title.length > 0 ? title : @"";
    media = media.length > 0 ? media : @"";
    NSDictionary *result = @{@"imgData":data,
                             @"title":title,
                             @"media":media};
    return result;
}

#pragma mark - --------分享--------------------------------
//微信分享
- (void)ShareToWX:(NSString *)content data:(NSDictionary *)dicData
{
    if (![WXApi isWXAppInstalled]) {
        [CTB showMsg:@"分享失败,请确定您已安装微信!"];
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        wxScene = WXSceneTimeline;//设置分享到朋友圈
        SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
        NSString *ShareContents = content;
        NSData *imgData = dicData[@"imgData"];
        NSString *title = dicData[@"title"];
        NSString *media = dicData[@"media"];
        
        if(imgData && imgData.length > 0){
            //判断图片是否存在
            WXImageObject *ext = [WXImageObject object];
            ext.imageData = imgData;//装入图片
            
            WXMediaMessage *message = [WXMediaMessage message];//创建媒体消息
            message.mediaObject = ext;//设置媒体内容
            message.title = title;
            message.mediaTagName = media;
            message.description = ShareContents;//简介
            
            req.bText = NO;//请求的是否是文本信息
            req.message = message;
        }else{
            req.text = ShareContents;
            req.bText = YES;//请求的是否是文本信息
        }
        req.scene = WXSceneTimeline;
        shareType = ShareTypeWeixiTimeline;
        BOOL result = [WXApi sendReq:req];//发起分享请求
        dispatch_async(dispatch_get_main_queue(), ^{
            if(!result){
                [CTB showMsg:@"分享失败"];
            }
        });
        
    });
}

- (BOOL)sendTextContent:(NSString *)content
{
    return [self sendTextContent:content scene:WXSceneSession];
}

- (BOOL)sendTextContent:(NSString *)content scene:(int)scene
{
    AppDelegate *app = [UIApplication sharedApplicationDelegate];
    app.delegate = self;
    
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.text = content;
    req.bText = YES;
    req.scene = scene;
    
    return [WXApi sendReq:req];
}

- (BOOL)sendTextTitle:(NSString *)title image:(UIImage *)image description:(NSString *)description webpageUrl:(NSString *)webpageUrl
{
    WXMediaMessage* message = [WXMediaMessage message];
    message.title = title;
    [message setThumbImage:image];
    message.description = description;
    
    //创建多媒体对象
    WXWebpageObject *webObj = [WXWebpageObject object];
    webObj.webpageUrl = webpageUrl;//分享链接
    message.mediaObject = webObj;
    
    return [self sendMediaMessage:message scene:WXSceneSession];
}

- (BOOL)sendMediaMessage:(WXMediaMessage *)message scene:(int)scene
{
    AppDelegate *app = [UIApplication sharedApplicationDelegate];
    app.delegate = self;
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    //req.text = content;
    req.bText = NO;
    req.scene = scene;
    req.message = message;
    
    return [WXApi sendReq:req];
}

//+ (void)shareToService:(NSString *)shareService
//{
//    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
//    
//    // 指定账号类型
//    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierSinaWeibo];
//    
//    // 获取帐号列表
//    NSArray *accountArray = [accountStore accountsWithAccountType:accountType];
//    
//    
//    //申请访问帐号
//    [accountStore requestAccessToAccountsWithType:accountType options:@{} completion:^(BOOL granted,NSError *error)
//    {
//        //授权访问
//        //提示用户程序需要访问帐号
//        if (granted) {
//            // 如果添加了帐号
//            if ([accountArray count] > 0) {
//                ACAccount *account = accountArray[0];
//                NSLog(@"账号信息：%@",account);
//            } else {
//                // 没有添加账号分2种情况，已经授权，没有账号走这里
//                // 没有授权，不管有没有账号都走！granted
//                NSLog(@"没有添加帐号");
//            }
//        } else {
//            // 当到设设置--新浪--关闭授权。（即使你删除程序再安装也是未授权）。
//            // 用户选择“不允许”访问账号。除非用户到设置--新浪--开启授权，否则不会再弹出“提示用户程序需要访问帐号”
//            NSLog(@"未授权");
//        }
//    }];
//}

#pragma mark - --------微信------------------------
- (void) onReq:(BaseReq*)req
{
    
}

- (void) onResp:(BaseResp*)resp
{
    if([resp isKindOfClass:[SendMessageToWXResp class]]) {
        
        if ([_delegate respondsToSelector:select(onResp:share:)]) {
            [_delegate onResp:resp share:resp.errCode == WXSuccess];
            return;
        }
        
        NSString *strTitle ;// [NSString stringWithFormat:@"朋友圈分享"];
        if(resp.errCode == WXSuccess){
            strTitle = @"分享成功";
        }else{
            strTitle = @"分享失败";
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"好", nil];
        [alert show];
    }
}

@end

@interface QQShare ()

@end

@implementation QQShare

+ (QQShare *)getInstance
{
    static dispatch_once_t once;
    static QQShare *sharedInstance;
    dispatch_once(&once, ^ {
        sharedInstance = [[QQShare alloc] init];
        id delegate = sharedInstance;
        sharedInstance.OAuth = [[TencentOAuth alloc] initWithAppId:QQ_AppId andDelegate:delegate];
    });
    return sharedInstance;
}

+ (NSDictionary *)parseUrl:(NSURL *)url
{
    NSString *urlString = url.query;//host、path、query
    NSArray *list = [urlString componentSeparatedByString:@"&"];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    for (NSString *str in list) {
        NSArray *array = [str componentSeparatedByString:@"="];
        [dic setObject:array.lastObject forKey:array.firstObject];
    }
    
    return dic;
}

+ (BOOL)HandleOpenURL:(NSURL *)url
{
    return [TencentOAuth HandleOpenURL:url];
}

- (void)installQQ
{
    _OAuth.redirectURI = @"web2.qq.com";//这里需要填写注册APP时填写的域名。默认可以不用填写。建议不用填写。
    NSArray *permissions = [NSArray arrayWithObjects:
                            kOPEN_PERMISSION_GET_USER_INFO,//读取用户信息
                            kOPEN_PERMISSION_GET_SIMPLE_USER_INFO,//读取移动端信息
                            kOPEN_PERMISSION_ADD_SHARE,//同步分享空间及微博
                            nil];
    [_OAuth authorize:permissions inSafari:YES];//发起登录
}

- (QQApiSendResultCode) sendTextContent:(NSString *)content //只分享文本
{
    AppDelegate *app = [UIApplication sharedApplicationDelegate];
    app.delegate = self;
    
    //TencentOAuth *OAuth = [QQShare getInstance].OAuth;//授权类
    //[OAuth getUserInfo];
    
    QQApiTextObject *obj = [QQApiTextObject objectWithText:content];
    
    QQApiMessageType type = kShareMsgToGroupTribe;
    QQApiMessage *msg = [[QQApiMessage alloc] initWithObject:obj andType:type];
    QQApiSendResultCode code = [QQApi sendMessage:msg];
    return code;
}

- (QQApiSendResultCode) sendMessageWithObject:(QQApiObject*)obj andType:(QQApiMessageType)type
{
    AppDelegate *app = [UIApplication sharedApplicationDelegate];
    app.delegate = self;
    
    QQApiMessage *msg = [[QQApiMessage alloc] initWithObject:obj andType:type];
    QQApiSendResultCode code = [QQApi sendMessage:msg];
    return code;
}

- (QQApiSendResultCode) sendMsgWithURL:(NSURL*)url title:(NSString*)title description:(NSString*)description previewImageData:(NSData *)data
{
    QQApiURLObject *urlObje = [QQApiURLObject objectWithURL:url title:title description:description previewImageData:data targetContentType:QQApiURLTargetTypeNews];
    
    QQApiMessageType type = kShareMsgToGroupTribe;
    QQApiSendResultCode code = [self sendMessageWithObject:urlObje andType:type];
    return code;
}

#pragma mark - --------QQ登录时网络有问题的回调--------
- (void)tencentDidNotNetWork
{
    if ([_delegate respondsToSelector:select(tencentDidNotNetWork)]) {
        [_delegate tencentDidNotNetWork];
    }
}

#pragma mark QQ退出登录的回调
- (void)tencentDidLogout
{
    if ([_delegate respondsToSelector:select(tencentDidLogout)]) {
        [_delegate tencentDidLogout];
    }
}

- (void)tencentDidLogin
{
    if ([_delegate respondsToSelector:select(tencentDidLogin)]) {
        [_delegate tencentDidLogin];
    }
}

- (void)tencentDidNotLogin:(BOOL)cancelled
{
    if ([_delegate respondsToSelector:select(tencentDidNotLogin:)]) {
        [_delegate tencentDidNotLogin:cancelled];
    }
}

- (void)getUserInfoResponse:(APIResponse *)response
{
    if ([_delegate respondsToSelector:select(getUserInfoResponse:)]) {
        [_delegate getUserInfoResponse:response];
    }
}

- (void)HandleOpenURL:(NSURL *)url
{
    if ([_delegate respondsToSelector:select(HandleOpenURL:)]) {
        [_delegate HandleOpenURL:url];
    }
}

@end

/*
#pragma mark -
#pragma mark -------------新浪--------------------
@interface SinaShare ()<SinaWeiboRequestDelegate,SinaWeiboDelegate>
{
    NSString *content;
}

@end

#define kAppKey             @"589890824"
#define kAppSecret          @"1fb8e8fad1a47c42a9e1b4e2acd9b527"
#define kAppRedirectURL     @"http://www.sina.com"

@implementation SinaShare

+ (SinaShare *)sharedInstance
{
    static dispatch_once_t once;
    static SinaShare *sharedInstance;
    dispatch_once(&once, ^ {
        sharedInstance = [[SinaShare alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        sina = [[SinaWeibo alloc] initWithAppKey:kAppKey appSecret:kAppSecret appRedirectURI:kAppRedirectURL andDelegate:self];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        NSDictionary *sinaWeiboInfo = [defaults objectForKey:@"SinaWeiboAutoData"];
        
        if ([sinaWeiboInfo objectForKey:@"AccessTokenKey"] && [sinaWeiboInfo objectForKey:@"ExpirationDateKey"] && [sinaWeiboInfo objectForKey:@"UserIDKey"])
        {
            sina.accessToken = [sinaWeiboInfo objectForKey:@"AccessTokenKey"];
            
            sina.expirationDate = [sinaWeiboInfo objectForKey:@"ExpirationDateKey"];
            
            sina.userID = [sinaWeiboInfo objectForKey:@"UserIDKey"];
        }
    }
    
    return self;
}

- (void)sinaweiboDidLogOut:(SinaWeibo *)sinaweibo
{
    NSLog(@"DidLogOut,%@",sinaweibo.userID);
}
- (void)sinaweiboLogInDidCancel:(SinaWeibo *)sinaweibo
{
    NSLog(@"LogInDidCancel,%@",sinaweibo.userID);
}
- (void)sinaweibo:(SinaWeibo *)sinaweibo logInDidFailWithError:(NSError *)error
{
    NSLog(@"logInDidFail,error : %@",error.localizedDescription);
}
- (void)sinaweibo:(SinaWeibo *)sinaweibo accessTokenInvalidOrExpired:(NSError *)error
{
    NSLog(@"accessToken,error : %@",error.localizedDescription);
}
- (void)addWeiBo:(SinaWeibo *)aWeiBo
{
    sina = aWeiBo;
}

//登陆成功后回调方法
- (void) sinaweiboDidLogIn:(SinaWeibo *)sinaweibo
{
    [self sendBtnClicked:content];
}

//发送按钮响应方法
- (void)sendBtnClicked:(NSString *)msg
{
    BOOL authValid = sina.isAuthValid;
    if (!authValid) {
        content = msg;
        [sina logIn];
        return;
    }
    if (msg.length <= 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"未输入信息，不能发送！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }else{
        // post status
        [sina requestWithURL:@"statuses/update.json"
                           params:[NSMutableDictionary dictionaryWithObjectsAndKeys:msg, @"status", nil]
                       httpMethod:@"POST"
                         delegate:self];
    }
}

#pragma mark - SinaWeiboRequest Delegate

//请求成功回调方法
- (void)request:(SinaWeiboRequest *)request didFinishLoadingWithResult:(id)result{
    if ([request.url hasSuffix:@"users/show.json"]){
        //登录
        NSLog(@"请先登录");
        [self showMsg:@"请先登录"];
    }else if ([request.url hasSuffix:@"statuses/update.json"]){
        [self showMsg:@"发送微博成功！"];
    }
}

//请求失败回调方法
- (void)request:(SinaWeiboRequest *)request didFailWithError:(NSError *)error{
    if ([request.url hasSuffix:@"users/show.json"]){
        //登录
        NSLog(@"请先登录");
        [self showMsg:@"请先登录"];
    }else if ([request.url hasSuffix:@"statuses/update.json"]){
        [self showMsg:@"发送微博失败！"];
    }
}

- (void)showMsg:(NSString *)msg
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    [alertView show];
}

@end
 */
