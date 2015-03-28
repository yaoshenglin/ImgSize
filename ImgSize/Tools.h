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

@end
