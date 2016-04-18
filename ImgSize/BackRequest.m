//
//  BackRequest.m
//  ImgSize
//
//  Created by Yin on 15-7-13.
//  Copyright (c) 2015年 caidan. All rights reserved.
//

#import "BackRequest.h"

@interface BackRequest ()<NSURLSessionDelegate,NSURLSessionDownloadDelegate,NSURLSessionDataDelegate>
{
    int responseStatusCode;
    long long contentLength;
    NSMutableDictionary *configDict;
    NSDate *sendDate;//发送时间
    NSDate *receiveDate;//接收时间
    NSMutableData *activeDownload;
}

@end

@implementation BackRequest

- (void)backgroundTask
{
    NSURL *downloadURL = [NSURL URLWithString:@"http://121.201.17.130:8100/Content/Uploads/58/face/20150710175341.jpg"];
    NSURLRequest *request = [NSURLRequest requestWithURL:downloadURL];
    NSURLSession *session = [self backgroundSession];
    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithRequest:request];
    [downloadTask resume];
}

#pragma mark 创建URLSession
- (NSURLSession *)backgroundSession

{
    //Use dispatch_once_t to create only one background session. If you want more than one session, do with different identifier
    
    static NSURLSession *session = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"session_id"];
        
        configuration.discretionary = YES;
        
        session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
        
    });
    
    [configDict setObject:@"session_id" forKey:@"session_id"];
    
    return session;
    
}

#pragma mark - --------NSURLSessionDownloadDelegate----------------
//获得上传进度
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    //发送数据回调
    CGFloat totalData = totalBytesExpectedToWrite * 1.0;
    CGFloat rate = totalBytesWritten / totalData;
    NSTimeInterval space = [[NSDate date] timeIntervalSinceDate:sendDate];
    sendDate = [NSDate date];
    if (space < 0.02 && rate != 1) {
        NSLog(@"----------发送进度没有更新--------------------");
        return;
    }
    
    NSLog(@"上传进度 : %.2f%%",rate/0.01);
}

//获得请求响应
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
    //收到服务器响应回调
    NSHTTPURLResponse *theResponse = (NSHTTPURLResponse *)response;
    NSDictionary *userInfo = theResponse.allHeaderFields;
    responseStatusCode = (int)theResponse.statusCode;
    contentLength = [userInfo[@"Content-Length"] longLongValue];
}

//获得下载进度
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data
{
    //接收数据回调
    [activeDownload appendData:data];
    if (responseStatusCode != 200) {
        return;
    }
    CGFloat totalLen = contentLength * 1.0;
    CGFloat rate = activeDownload.length / totalLen;
    NSTimeInterval space = [[NSDate date] timeIntervalSinceDate:receiveDate];
    if (space < 0.02 && rate != 1) {
        NSLog(@"----------接收进度没有更新--------------------");
        return;
    }
    
    receiveDate = [NSDate date];
    NSLog(@"下载进度 : %.2f%%",rate/0.01);
}

//成功下载之后调用
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    NSLog(@"下载完成");
    NSString *path = @"/Users/Yin-Mac/Desktop/Chaches/test1.dmg";
    [activeDownload writeToFile:path atomically:YES];
}

//文件下载失败的回调
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if (error) {
        NSLog(@"下载失败");
        NSLog(@"error,%@",error.localizedDescription);
    }
}

//一个session结束之后，会在后台调用
- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
    NSLog(@"session结束");
}

@end
