//
//  DownloadService.m
//  ImgSize
//
//  Created by Yin on 15/7/20.
//  Copyright (c) 2015年 caidan. All rights reserved.
//

#import "DownloadService.h"

static DownloadService *_download;
static NSMutableDictionary *_dictPath;
static NSMutableDictionary *_dictBlock;
static NSMutableDictionary *_dictHandle;
static unsigned long long _cacheCapacity; // 缓存
static NSMutableData *_cacheData;

typedef void (^myBlcok)(NSString *savePath, NSError *error);

@interface DownloadService ()<NSURLConnectionDataDelegate>

@end

@implementation DownloadService

+ (void)initialize
{
    _download = [[DownloadService alloc] init];
    _dictPath = [NSMutableDictionary dictionary]; // 存储文件路径
    _dictBlock = [NSMutableDictionary dictionary]; // 存储block
    _dictHandle = [NSMutableDictionary dictionary]; // 存储NSFileHandle对象
    _cacheData = [NSMutableData data]; // 存放缓存
}

+ (void)downLoadWithURL:(NSString *)urlStr toDirectory:(NSString *)toDirectory cacheCapacity:(NSInteger)capacity success:(DownloadServiceSuccess)success failure:(DownloadServiceFailure)failure
{
    // 1. 创建文件
    NSString *fileName = [urlStr lastPathComponent];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", toDirectory, fileName];
    
    // 记录文件起始位置
    unsigned long long from = 0;
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]){
        // 已经存在
        from = [[NSData dataWithContentsOfFile:filePath] length];
    }else{
        // 不存在，直接创建
        [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
    }
    
    // url
    NSURL *url = [NSURL URLWithString:urlStr];
    // 请求
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5.0f];
    
    // 设置请求头文件
    NSString *rangeValue = [NSString stringWithFormat:@"bytes=%llu-", from];
    [request addValue:rangeValue forHTTPHeaderField:@"Range"];
    
    // 创建连接
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:_download];
    
    // 保存文章连接
    _dictPath[connection.description] = filePath;
    
    // 保存block,用于回调
    myBlcok block = ^(NSString *savePath, NSError *error){
        if (error) {
            if (failure) {
                failure(error);
            }
        }else{
            if (success) {
                success(savePath);
            }
        }
    };
    _dictBlock[connection.description] = block;
    
    // 保存缓存大小
    _cacheCapacity = capacity * 1024 * 1024;
    
    // 开始连接
    [connection start];
}

/**
 *  接收到服务器响应
 *
 *  @param connection 哪一个连接
 *  @param response   响应对象
 */
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // 取出文章地址
    NSString *filePath = _dictPath[connection.description];
    
    // 打开文件准备输入
    NSFileHandle *outFile = [NSFileHandle fileHandleForWritingAtPath:filePath];
    
    // 保存文件操作对象
    _dictHandle[connection.description] = outFile;
}

/**
 *  开始接收数据
 *
 *  @param connection 哪一个连接
 *  @param data       二进制数据
 */
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // 取出文件操作对象
    NSFileHandle *outFile = _dictHandle[connection.description];
    
    // 移动到文件结尾
    [outFile seekToEndOfFile];
    
    // 保存数据
    [_cacheData appendData:data];
    
    if (_cacheData.length >= _cacheCapacity) {
        // 写入文件
        [outFile writeData:data];
        
        // 清空数据
        [_cacheData setLength:0];
    }
}

/**
 *  连接出错
 *
 *  @param connection 哪一个连接出错
 *  @param error      错误信息
 */
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    // 取出文件操作对象
    NSFileHandle *outFile = _dictHandle[connection.description];
    
    // 关闭文件操作
    [outFile closeFile];
    
    // 回调block
    myBlcok block = _dictBlock[connection.description];
    
    if (block) {
        block(nil, error);
    }
    
    // 移除字典中
    [_dictHandle removeObjectForKey:connection.description];
    [_dictPath removeObjectForKey:connection.debugDescription];
    [_dictBlock removeObjectForKey:connection.description];
}

/**
 *  结束加载
 *
 *  @param connection 哪一个连接
 */
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // 取出文件操作对象
    NSFileHandle *outFile = _dictHandle[connection.description];
    
    // 关闭文件操作
    [outFile closeFile];
    
    // 取出路径
    NSString *savePath = [_dictPath objectForKey:connection.description];
    
    // 取出block
    myBlcok block = _dictBlock[connection.description];
    
    // 回调
    if (block) {
        block(savePath, nil);
    }
    
    // 移除字典中
    [_dictHandle removeObjectForKey:connection.description];
    [_dictPath removeObjectForKey:connection.debugDescription];
    [_dictBlock removeObjectForKey:connection.description];
}

#pragma mark -
+ (NSArray *)getLoadlist
{
    NSArray *onlineBooksUrl =
    @[@"http://219.239.26.20/download/53546556/76795884/2/dmg/232/4/1383696088040_516/QQ_V3.0.1.dmg",
      @"http://219.239.26.11/download/46280417/68353447/3/dmg/105/192/1369883541097_192/KindleForMac._V383233429_.dmg",
      @"http://free2.macx.cn:81/Tools/Office/UltraEdit-v4-0-0-7.dmg",
                               
      @"http://124.254.47.46/download/53349786/76725509/1/exe/13/154/53349786_1/QQ2013SP4.exe",
      @"http://dldir1.qq.com/qqfile/qq/QQ2013/QQ2013SP5/9050/QQ2013SP5.exe",
                                
      @"http://dldir1.qq.com/qqfile/tm/TM2013Preview1.exe",
      @"http://dldir1.qq.com/invc/tt/QQBrowserSetup.exe",
      @"http://dldir1.qq.com/music/clntupate/QQMusic_Setup_100.exe",
      @"http://dl_dir.qq.com/invc/qqpinyin/QQPinyin_Setup_4.6.2028.400.exe"];
    
    NSArray *names = @[@"MacQQ", @"KindleForMac",@"UltraEdit",@"QQ2013SP4",@"QQ2013SP5",@"TM2013",@"QQBrowser",@"QQMusic",@"QQPinyin"];
    (void)names;
    
    return onlineBooksUrl;
}

@end
