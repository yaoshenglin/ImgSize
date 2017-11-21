//
//  AppDelegate.m
//  ImgSize
//
//  Created by Yin on 14-5-17.
//  Copyright (c) 2014年 caidan. All rights reserved.
//

#import "AppDelegate.h"
#import "CTB.h"
#import "Share.h"
#import "BackRequest.h"
#import "HTTPRequest.h"

@interface AppDelegate ()
{
    int count;
    BackRequest *backRequest;
}

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //backRequest = [[BackRequest alloc] init];
    //[WXShare registerApp];//微信注册
    // Override point for customization after application launch.
    
    if(iPhone >= 7) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];//状态栏样式
        [UINavigationBar appearance].tintColor = [UIColor whiteColor];//导航栏控件颜色
        [UINavigationBar appearance].titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};//导航栏控件字体颜色
        [UINavigationBar appearance].barTintColor = MasterColor;//导航栏背景颜色
    }
    
    return YES;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    //本地通知
    UITabBarController *tabBar = (UITabBarController *)_window.rootViewController;
    NSArray *list = tabBar.viewControllers;
    UINavigationController *nav = list.firstObject;
    NSLog(@"本地通知,%@",nav.visibleViewController);
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    NSString *Path = @"~/Documents";
    NSString *FilePath = [Path stringByExpandingTildeInPath];
    NSLog(@"Path : %@",FilePath);
    //复制内容
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = FilePath;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    count = 0;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"closeSocket" object:nil];
    [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(print) userInfo:nil repeats:YES];
    NSLog(@"程序终止");
}

- (void)print
{
    count ++ ;
    NSLog(@"count = %d",count);
}

#pragma mark 后台获取回调事件（Background Fetch）暂时不启用
- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    NSLog(@"后台执行任务");
    [self backgroundTask];
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)backgroundTask
{
    [CTB sendLocalNotice];//发送本地通知
    
    //[backRequest backgroundTask];
    NSString *urlString = @"http://121.201.17.130:8100/Content/Uploads/58/face/20150710175341.jpg";
    [HTTPRequest run:urlString body:nil delegate:self];
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:select(testDate:) userInfo:nil repeats:YES];
}

- (void)testDate:(NSTimer *)timer
{
    count ++ ;
    NSLog(@"后台操作已经用时 %d s",count);
}

- (void)wsOK:(HTTPRequest *)iWS
{
    if ([iWS.method isEqualToString:@"fileDownload"]) {
        NSLog(@"下载成功");
        NSData *imageData = iWS.responseData;
        NSString *path = @"/Users/Yin-Mac/Desktop/Chaches/test1.jpg";
        [imageData writeToFile:path atomically:YES];
    }
}

- (void)wsFailed:(HTTPRequest *)iWS
{
    NSLog(@"请求失败");
}

#ifdef __IPHONE_11_0
//在这个函数中检查是否传输已经完成
- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)(void))completionHandler
{
    //UIBackgroundFetchResultNewData
    completionHandler();
    NSLog(@"传输已经完成");
}
#else
- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler
{
    //UIBackgroundFetchResultNewData
    completionHandler();
    NSLog(@"传输已经完成");
}
#endif

#pragma mark - --------QQ------------------------
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    id delegate = _delegate;
    _delegate = nil;
    NSString *URL = [NSString stringWithFormat:@"%@",url];
    if ([URL hasPrefix:@"wx"]) {
        //微信
        return [WXShare handleOpenURL:url delegate:delegate];
    }
    else if ([URL hasPrefix:@"QQ"]) {
        //QQ
        if ([delegate respondsToSelector:select(HandleOpenURL:)]) {
            [delegate HandleOpenURL:url];
        }
        return [QQShare HandleOpenURL:url];
    }
    
    return [QQShare HandleOpenURL:url];
}

@end
