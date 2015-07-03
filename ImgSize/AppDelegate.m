//
//  AppDelegate.m
//  ImgSize
//
//  Created by Yin on 14-5-17.
//  Copyright (c) 2014年 caidan. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()
{
    int count;
}

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    return YES;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    //本地通知
    UITabBarController *tabBar = (UITabBarController *)_window.rootViewController;
    NSArray *list = tabBar.viewControllers;
    UINavigationController *nav = list.firstObject;
    NSLog(@"%@",nav.visibleViewController);
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
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    count = 0;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"closeSocket" object:nil];
    [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(print) userInfo:nil repeats:YES];
    NSLog(@"程序终止");
}

-(void)print
{
    count ++ ;
    NSLog(@"count = %d",count);
}

@end
