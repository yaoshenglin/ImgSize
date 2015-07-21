//
//  HTTPRequest.h
//  iFace
//
//  Created by Yin on 15-3-24.
//  Copyright (c) 2015年 caidan. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HTTPRequest;
@protocol RequestDelegate
@optional

- (void)sendProgress:(CGFloat)progress;
- (void)receiveProgress:(CGFloat)progress;
- (void)ws:(HTTPRequest *)iWS sendProgress:(CGFloat)progress;
- (void)ws:(HTTPRequest *)iWS receiveProgress:(CGFloat)progress;
- (void)wsOK:(HTTPRequest *)iWS;
- (void)wsFailed:(HTTPRequest *)iWS;

@end

@interface HTTPRequest : NSObject
{
    long long contentLength;
    __weak id currentDelegate;
    NSMutableData *activeDownload;
}

@property (retain, nonatomic) NSMutableURLRequest *request;
@property (nonatomic) NSTimeInterval timeOut;
@property (retain, nonatomic) NSString *host;//主服务器域名
@property (retain, nonatomic) NSString *hostPort;//端口
@property (retain, nonatomic) NSString *action;//根路径
@property (retain, nonatomic) NSString *dataType;//返回的数据类型
@property (retain, nonatomic) NSString *urlString;
@property (retain, nonatomic) NSString *tag;
@property (retain, nonatomic) NSString *tagString;
@property (assign, nonatomic) NSInteger totalLength;

@property (retain, nonatomic) NSDictionary *dicTag;//标签
@property (retain, nonatomic,readonly) NSString *method;//接口名
@property (retain, nonatomic,readonly) NSData *responseData;//原数据
@property (retain, nonatomic,readonly) NSString *responseString;//原解析数据
@property (retain, nonatomic,readonly) NSDictionary *jsonDic;//json解析
@property (retain, nonatomic,readonly) NSString *errMsg;//错误信息(解析)

@property (assign, nonatomic,readonly) int responseStatusCode;//请求响应码
@property (retain, nonatomic,readonly) NSString *responseStatusMessage;//请求响应信息

+ (HTTPRequest *)run:(NSString *)method body:(NSDictionary *)body delegate:(id)thedelegate;
+ (void)run:(NSString *)method body:(NSDictionary *)body completionHandler:(void (^)(NSURLResponse* response, NSData* data, NSError* error)) handler NS_AVAILABLE(10_7, 5_0);
- (void)run:(NSString *)method body:(NSDictionary *)body delegate:(id)thedelegate;
- (void)setValue:(NSString *)value forHeader:(NSString *)field;
- (void)addValue:(NSString *)value forHeader:(NSString *)field;
- (void)start;
- (void)cancel;
- (void)run:(NSString *)method body:(NSDictionary *)body completionHandler:(void (^)(NSURLResponse* response, NSData* data, NSError* error)) handler NS_AVAILABLE(10_7, 5_0);

@end
