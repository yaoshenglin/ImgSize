//
//  Tools.h
//  ImgSize
//
//  Created by Yin on 14-6-11.
//  Copyright (c) 2014年 caidan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Tools : NSObject

+(NSString *)getFilePath:(NSString *)fileName;
#pragma mark 通过文件名删除文件
+ (void)deleteFile:(NSString *)fileName;

#pragma mark 格式化手机号码（去除手机号码前缀 +86及中间空格）
+(NSString *) formatMobileForStorage:(NSString *) mobile;

#pragma mark 设置备份模式
+ (BOOL)addSkipBackupAttributeToItemAtFilePath:(NSString *)filePath;

#pragma mark 获取当前WIFI SSID信息
+(NSString*)getCurrentWifiSSID;
+ (NSData *)getHost;
+ (NSData *)getHost1:(BOOL)isOn;
+ (NSData *)getHost2:(BOOL)isOn;
+ (NSData *)getHostConfig;

#pragma mark - -------开关的CRC校验----------------
+(NSData*)replaceCRCForSwitch:(NSData *)buffer;

#pragma mark 构造开门动作
+ (NSData*)makeOpenDoorActionWithSN:(NSString*)SN parmsDoor:(NSString*)parmsDoor;

#pragma mark - -------组合门禁控制命令----------------
+ (NSString *)makeControl:(NSString *)control value:(NSString *)value;
+ (NSString *)makeControl:(NSString *)control dataLen:(int)len value:(NSString *)value;

+ (NSData *)makeDoorCommandWith:(NSString *)SN pwd:(NSString *)pwd msg:(NSString *)msg control:(NSString *)control;

@end
