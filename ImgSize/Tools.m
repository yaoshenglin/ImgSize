//
//  Tools.m
//  ImgSize
//
//  Created by Yin on 14-6-11.
//  Copyright (c) 2014年 caidan. All rights reserved.
//

#import "Tools.h"
#include <sys/xattr.h>

@implementation Tools

#pragma mark 拿取文件路径
+(NSString *)getFilePath:(NSString *)fileName {
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    if ([fileName hasSuffix:@".txt"]) {
        documentsDirectory = [documentsDirectory stringByAppendingPathComponent:@"documents"];
    }
    if ([fileName hasSuffix:@".png"]||[fileName hasSuffix:@".jpg"]||[fileName hasSuffix:@".gif"]) {
        documentsDirectory = [documentsDirectory stringByAppendingPathComponent:@"images"];
    }
    if ([fileName hasSuffix:@".amr"]||[fileName hasSuffix:@".wav"]) {
        documentsDirectory = [documentsDirectory stringByAppendingPathComponent:@"audio"];
    }
    [Tools PathExistsAtPath:documentsDirectory];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
    return filePath;
}

+(void)PathExistsAtPath:(NSString *)Path
{
    NSError *error = nil;
    if (![[NSFileManager defaultManager] fileExistsAtPath:Path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:Path withIntermediateDirectories:YES attributes:Nil error:&error];
        if (error) {
            NSLog(@"路径创建失败:%@",error.localizedDescription);
        }
    }
}

+(UIImage *)getImgWithName:(NSString *)imgName
{
    NSString *filePath = [Tools getFilePath:imgName];
    return [[UIImage alloc] initWithContentsOfFile:filePath];
}

#pragma mark 判断文件是否存在
+(BOOL)fileExist:(NSString *)fileName {
	
	if(!fileName || fileName == nil || [fileName length]<=0)
		return NO;
	
	NSString *filePath = [Tools getFilePath:fileName];
	NSFileManager* fileManager = [NSFileManager defaultManager];
	return [fileManager fileExistsAtPath:filePath];
}

#pragma mark 格式化手机号码（去除手机号码前缀 +86及中间空格）
+(NSString *) formatMobileForStorage:(NSString *) mobile
{
    NSString *formatMobile = @"";
    
    formatMobile = [mobile stringByReplacingOccurrencesOfString:@"+86" withString:@""];
    formatMobile = [formatMobile stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    return formatMobile;
}

#pragma mark 设置备份模式
+ (BOOL)addSkipBackupAttributeToItemAtFilePath:(NSString *)filePath
{
    const char* charFilePath = [filePath fileSystemRepresentation];
    
    const char* attrName = "com.apple.MobileBackup";
    u_int8_t attrValue = 1;
    
    int result = setxattr(charFilePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
    return result == 0;
}


#pragma mark 通过文件名删除文件
+ (void)deleteFile:(NSString *)fileName {
	
	if(fileName == nil || [fileName length]<=0)
		return;
	
	NSString *filePath = [Tools getFilePath:fileName];
	NSFileManager* fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath]) {
        
        [fileManager removeItemAtPath:filePath error:nil];
    }
}

@end
