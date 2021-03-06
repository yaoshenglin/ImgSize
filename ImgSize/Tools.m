//
//  Tools.m
//  ImgSize
//
//  Created by Yin on 14-6-11.
//  Copyright (c) 2014年 caidan. All rights reserved.
//

#import "Tools.h"
#import "CTB.h"
#include <sys/xattr.h>
//#import <SystemConfiguration/SystemConfiguration.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import "StringEncryption.h"

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

#pragma mark - --------解密字符串
+ (NSString *)decryptString:(NSString *)str
{
    return [StringEncryption decryptString:str];
}

+ (NSString *)decryptString:(NSString *)str encoding:(NSStringEncoding)encoding
{
    return [StringEncryption decryptString:str encoding:encoding];
}

+ (NSString *)decryptFrom:(NSString *)str
{
    NSString *Separate = @"/App/";
    NSArray *list = [str componentsSeparatedByString:Separate];
    if ([list count] == 2) {
        NSString *str = [list objectAtIndex:1];
        
        str = [str stringByReplacingOccurrencesOfString:@"~" withString:@"+"];
        str = [str stringByReplacingOccurrencesOfString:@"!" withString:@"/"];
        str = [str stringByReplacingOccurrencesOfString:@"|" withString:@"/"];
        NSString *content = [Tools decryptString:str];
        if (content.length > 0) {
            return content;
        }
    }
    
    return str;
}

#pragma mark 加密字符串
+ (NSString *)encryptString:(NSString *)str
{
    return [StringEncryption encryptString:str];
}

+ (NSString *)encryptFrom:(NSString *)str
{
    NSString *string = [Tools encryptString:str];
    NSString *Separate = @"/App/";
    string = [NSString format:@"%@%@%@",k_host,Separate,string];
    
    return string;
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

#pragma mark 获取crc校验码
+(NSData*)getCRC:(NSMutableData*)dataBytes
{
    Byte sum = 0x00;
    Byte *bytes = (Byte *)[dataBytes bytes];
    NSUInteger length = dataBytes.length;
    for (int i = 0; i < length; i++) {
        sum += bytes[i];
    }
    
    return [NSData dataWithBytes:&sum length:1];
}

+ (NSData *)getCRCWith:(NSArray *)listData
{
    NSMutableData *result = [NSMutableData data];
    for (NSData *data in listData) {
        [result appendData:data];
    }
    
    if (result.length > 0) {
        NSData *data = [self getCRC:result];
        return data;
    }
    
    return nil;
}

#pragma mark 获取当前WIFI SSID信息
+(NSString*)getCurrentWifiSSID
{
    NSString *ssid = nil;
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    //NSLog(@"Supported interfaces: %@", ifs);
    for (NSString *ifnam in ifs) {
        NSDictionary *info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        //NSLog(@"dici：%@",[info  allKeys]);
        if (info[@"SSID"]) {
            ssid = info[@"SSID"];
            break;
        }
    }
    return ssid;
}

+ (NSData *)getHost
{
    Byte byte[] = {0xa6,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0x00,0x00,0x00,0x00,0xA0,0xA6};
    NSData *data = [NSData dataWithBytes:byte length:sizeof(byte)];
    return data;
}

+ (NSData *)getHost1:(BOOL)isOn
{
    NSData *data = nil;
    if (isOn) {
        Byte byte[] = {0xA1,0x44,0x33,0x4C,0xCE,0x07,0x2C,0x00,0x00,0x00,0x01,0x66,0x7E};
        
        data = [NSData dataWithBytes:byte length:sizeof(byte)];
    }else{
        Byte byte[] = {0xA0,0x44,0x33,0x4C,0xCE,0x07,0x2C,0x00,0x00,0x00,0x01,0x65,0x7F};
        data = [NSData dataWithBytes:byte length:sizeof(byte)];
    }
    return data;
}

+ (NSData *)getHost2:(BOOL)isOn
{
    Byte byte[] = {0xA1,0xAC,0xA2,0x13,0xA2,0x85,0xA4,0x00,0x00,0x00,0x01,0x66,0x7E};
    NSData *data = [NSData dataWithBytes:byte length:sizeof(byte)];
    return data;
}

#pragma mark 构造主机上传配置信息
+(NSData*)makeUploadConfig:(NSString*)ssid password:(NSString*)password serverip:(NSString*)serverip serverport:(UInt16)serverport
{
    NSString *CMD_UploadConfig = [NSString stringWithFormat:@"Cmd=WIFIConfig\\%@\\%@\\auto\\1\\192.168.11.220\\255.255.255.0\\192.168.11.1\\114.114.114.114\\%@\\%d\\",ssid,password,serverip,serverport];
    
    NSData *buffer = [CMD_UploadConfig dataUsingEncoding:NSASCIIStringEncoding];
    
    return buffer;
}

+ (NSData *)getHostConfig
{
    NSData *buffer = [Tools makeUploadConfig:@"iFace" password:@"iFace2015" serverip:@"112.125.95.30" serverport:8001];
    return buffer;
}

#pragma mark - -------开关的CRC校验----------------
+(NSData*)replaceCRCForSwitch:(NSData *)buffer
{
    if (!buffer) {
        return nil;
    }
    NSMutableData *result = [[NSMutableData alloc] init];
    [result appendData:buffer];
    
    Byte crc1 = 0x00;
    Byte crc2 = 0x00;
    Byte *value = (Byte *)[buffer bytes];
    
    for (int i=0; i<buffer.length; i++) {
        crc1 += value[i];
        crc2 ^= value[i];
    }
    
    Byte crc[] = {crc1, crc2};
    [result appendBytes:crc length:sizeof(crc)];
    
    return result;
    
}

#pragma mark 构造开门动作
+ (NSData*)makeOpenDoorActionWithSN:(NSString*)SN parmsDoor:(NSString*)parmsDoor
{
    Byte byte[] = {0x7E};
    NSData *dataSign = [NSData dataWithBytes:byte length:1];
    NSData *dataSN = [SN dataUsingEncoding:NSASCIIStringEncoding];
    NSData *dataContent = [parmsDoor dataByHexString];
    
    // 检验码：除标志码和检验码，命令中所有字节都相加然后取尾子节。
    NSData *dataCRC = [Tools getCRCWith:@[dataSN,dataContent]];//检验码
    
    //输出拼接格式 SIGN, content, CRC, SIGN
    NSMutableData *result =[[NSMutableData alloc] init];
    [result appendData:dataSign];//标志码
    [result appendData:dataSN];//门系列号
    [result appendData:dataContent];//控制命令
    [result appendData:dataCRC];//检验码
    [result appendData:dataSign];//标志码
    
    return result;
}

#pragma mark - -------组合门禁控制命令----------------
+ (NSString *)makeControl:(NSString *)control value:(NSString *)value
{
    NSString *result = [self makeControl:control dataLen:4 value:value];
    
    return result;
}

+ (NSString *)makeControl:(NSString *)control dataLen:(int)len value:(NSString *)value
{
    if (len != value.length/2) {
        [CTB showMsg:@"创建指令有误"];
        return nil;
    }
    NSString *result = [control stringByAppendingFormat:@"%08x%@",len,value];
    if (len == 0) {
        result = [control stringByAppendingFormat:@"%08x",len];
    }
    
    return result;
}

+ (NSData *)makeDoorCommandWith:(NSString *)SN pwd:(NSString *)pwd msg:(NSString *)msg control:(NSString *)control
{
    NSData *dataSign = [@"\x7e" dataUsingEncoding:NSUTF8StringEncoding];
    NSData *dataSN = [SN dataUsingEncoding:NSASCIIStringEncoding];
    
    if (SN.length <= 0) {
        SN = @"FFFFFFFF FFFFFFFF FFFFFFFF FFFFFFFF";
        dataSN = [SN dataUsingEncoding:NSASCIIStringEncoding];
    }
    
    if (pwd.length < 8) {
        pwd = @"FFFFFFFF";
    }
    
    if (msg.length < 8) {
        msg = @"00000000";
    }
    
    if (control.length <= 0) {
        return nil;
    }
    
    NSString *parmsDoor = [NSString stringWithFormat:@"%@%@%@",pwd,msg,control];
    NSData *dataContent = [parmsDoor dataByHexString];
    
    // 检验码：除标志码和检验码，命令中所有字节都相加然后取尾子节。
    NSData *dataCRC = [Tools getCRCWith:@[dataSN,dataContent]];//检验码
    
    //输出拼接格式 SIGN, content, CRC, SIGN
    NSMutableData *result =[[NSMutableData alloc] init];
    [result appendData:dataSign];   //标志码
    [result appendData:dataSN];     //门系列号
    [result appendData:dataContent];//控制命令
    [result appendData:dataCRC];    //检验码
    [result appendData:dataSign];   //标志码
    
    return result;
}

@end
