//
//  HTTPRequest.m
//  iFace
//
//  Created by Yin on 15-3-24.
//  Copyright (c) 2015年 caidan. All rights reserved.
//

#import "HTTPRequest.h"
//#import "GDataXMLNode.h"

@interface HTTPRequest ()<NSURLConnectionDataDelegate>
{
    NSDate *sendDate;//发送时间
    NSDate *receiveDate;//接收时间
    NSURLConnection *connect;//连接对象
}

@end

@implementation HTTPRequest

@synthesize request;

- (instancetype)init
{
    if ((self=[super init])) {
        _timeOut = 30.0f;
        activeDownload = [NSMutableData data];
    }
    
    return self;
}

- (void)setMethod:(NSString *)method
{
    _method = method;
}

- (void)setJsonDic:(NSDictionary *)jsonDic
{
    _jsonDic = jsonDic;
}

- (void)setErrMsg:(NSString *)errMsg
{
    _errMsg = errMsg;
}

- (void)setTimeOut:(NSTimeInterval)timeOut
{
    _timeOut = timeOut;
    if (request) {
        [request setTimeoutInterval:_timeOut];
    }
}

- (void)setResponseStatusCode:(int)responseStatusCode
{
    _responseStatusCode = responseStatusCode;
}

- (void)setResponseStatusMessage:(NSString *)responseStatusMessage
{
    _responseStatusMessage = responseStatusMessage;
}

#pragma mark - --------发送请求------------------------
- (void)run:(NSString *)method body:(NSDictionary *)body delegate:(id)thedelegate
{
    NSError *error;
    NSString *urlString = [NSString stringWithFormat:@"%@/%@/%@",k_host,k_action,method];
    if (!_urlString) {
        _urlString = urlString;
        if ([method hasPrefix:@"http:"] || [method hasPrefix:@"https:"])
            _urlString = method;
    }
    currentDelegate = thedelegate;
    NSRange range = [method rangeOfString:@"/"];
    if (range.location != NSNotFound) {
        NSArray *arr = [method componentsSeparatedByString:@"/"];
        _method = [arr firstObject];
    }else{
        _method = method;
    }
    
    NSURL *url = [NSURL URLWithString:_urlString];
    request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:_timeOut];
    if ([NSJSONSerialization isValidJSONObject:body]) {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:body options:NSJSONWritingPrettyPrinted error: &error];//利用系统自带 JSON 工具封装 JSON 数据
        _totalLength = jsonData.length;
        request.HTTPMethod = @"POST";//设置为 POST
        request.HTTPBody = jsonData;//把刚才封装的 JSON 数据塞进去
        [self setValue:@"application/json" forHeader:@"Accept"];
        [self setValue:@"application/json" forHeader:@"Content-Type"];
        [self setValue:@(_totalLength).stringValue forHeader:@"Content-length"];
    }
}

- (void)setValue:(NSString *)value forHeader:(NSString *)field
{
    [request setValue:value forHTTPHeaderField:field];
}

- (void)addValue:(NSString *)value forHeader:(NSString *)field
{
    [request addValue:value forHTTPHeaderField:field];
}

- (void)start
{
    connect = [[NSURLConnection alloc] initWithRequest: request delegate:self];
    [connect start];
}

- (void)cancel
{
    [connect cancel];
}

#pragma mark - --------请求回调------------------------
- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    //发送数据回调
    CGFloat totalData = totalBytesExpectedToWrite * 1.0;
    CGFloat rate = totalBytesWritten / totalData;
    NSTimeInterval space = [[NSDate date] timeIntervalSinceDate:sendDate];
    sendDate = [NSDate date];
    if (space < 0.02 && rate != 1) {
        NSString *msg = @"----------发送进度没有更新--------------------";
        [self.class printDebugMsg:msg];
        return;
    }
    if ([currentDelegate respondsToSelector:@selector(ws:sendProgress:)]) {
        [currentDelegate ws:self sendProgress:rate];
    }
    else if ([currentDelegate respondsToSelector:@selector(sendProgress:)]) {
        [currentDelegate sendProgress:rate];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    //收到服务器响应回调
    NSHTTPURLResponse *theResponse = (NSHTTPURLResponse *)response;
    NSDictionary *userInfo = theResponse.allHeaderFields;
    _responseStatusCode = (int)theResponse.statusCode;
    contentLength = [userInfo[@"Content-Length"] longLongValue];
    _dataType = userInfo[@"Content-Type"];
    //NSLog(@"File Size:%lld",contentLength);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    //接收数据回调
    [activeDownload appendData:data];
    if (_responseStatusCode != 200) {
        return;
    }
    CGFloat totalLen = contentLength * 1.0;
    CGFloat rate = activeDownload.length / totalLen;
    NSTimeInterval space = [[NSDate date] timeIntervalSinceDate:receiveDate];
    receiveDate = [NSDate date];
    if (space < 0.02 && rate != 1) {
        NSString *msg = @"----------接收进度没有更新--------------------";
        [self.class printDebugMsg:msg];
        return;
    }
    if ([currentDelegate respondsToSelector:@selector(ws:receiveProgress:)]) {
        [currentDelegate ws:self receiveProgress:rate];
    }
    else if ([currentDelegate respondsToSelector:@selector(receiveProgress:)]) {
        [currentDelegate receiveProgress:rate];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    //请求失败
    NSDictionary *userInfo = error.userInfo;
    NSLog(@"错误码:%d, %@, %@",_responseStatusCode,_method,error.localizedDescription);
    //NSString *path = [[NSBundle mainBundle] pathForResource:@"errDic" ofType:@"txt"];
    //NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:path];
    //NSLog(@"%@",dic[@(error.code).stringValue]);
    _errMsg = error.localizedDescription;
    if ([_errMsg hasSuffix:@"。"]) {
        _errMsg = [_errMsg substringToIndex:_errMsg.length-1];
    }
    _urlString = userInfo[@"NSErrorFailingURLStringKey"];
    [self wsFailedWithDelegate:currentDelegate];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    //请求完成
    if (_responseStatusCode != 200) {
        //请求失败
        [self wsFailedWithDelegate:currentDelegate];
    }else{
        _responseData = activeDownload;
        if ([_dataType hasPrefix:@"application/"]) {
            [self parseData:activeDownload];
        }else{
            _method = @"fileDownload";
            if ([currentDelegate respondsToSelector:@selector(wsOK:)]) {
                [currentDelegate wsOK:self];
            }
        }
    }
}

#pragma mark 解析数据
- (void)parseData:(NSData *)data
{
    if ([data length]>0) {
        NSString *stringL = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (!stringL) {
            NSStringEncoding GBEncoding = 0x80000632;
            stringL = [[NSString alloc] initWithData:activeDownload encoding: GBEncoding];
        }
        
        if ([stringL hasPrefix:@"\""] && [stringL hasSuffix:@"\""]) {
            stringL = [stringL substringWithRange:NSMakeRange(1, stringL.length-2)];
        }
        
        if (stringL) {
            _responseString = stringL;
        }
        
        NSError *error1 = nil;
        NSData *data = [stringL dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *jsonDic = nil;
        if (data) {
            jsonDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error1];
        }
        //NSLog(@"%@",resultsDictionary);
        
        BOOL isSuccess = [[jsonDic objectForKey:@"flag"] boolValue];
        if (isSuccess && !error1) {
            _jsonDic = jsonDic;
            if ([currentDelegate respondsToSelector:@selector(wsOK:)]) {
                @try {
                    [currentDelegate wsOK:self];
                }
                @catch (NSException *exception) {
                    NSLog(@"RequestOK,%@,%@,%@",_method,exception.name,exception.reason);
                    _errMsg = @"解析错误";
                    [self wsFailedWithDelegate:currentDelegate];
                }
                @finally {
                }
            }
        }
        else if (jsonDic) {
            NSString *msg = [jsonDic objectForKey:@"msg"];
            msg = (msg && [msg isKindOfClass:[NSString class]]) ? msg : @"请求错误";
            _jsonDic = jsonDic;
            _errMsg = msg;
            [self wsFailedWithDelegate:currentDelegate];
        }else{
            //NSString *msg = [GDataXMLNode getBody:stringL];
            NSString *msg = nil;
            msg = msg ?: @"服务暂时不可用";
            _errMsg = msg;
            [self wsFailedWithDelegate:currentDelegate];
        }
    }
}

- (void)wsFailedWithDelegate:(id)delegate
{
    NSString *stringL = [[NSString alloc] initWithData:activeDownload encoding:NSUTF8StringEncoding];
    if (!stringL) {
        NSStringEncoding GBEncoding = 0x80000632;
        stringL = [[NSString alloc] initWithData:activeDownload encoding: GBEncoding];
    }
    NSLog(@"请求失败,%d,%@",_responseStatusCode,stringL);
    if ([delegate respondsToSelector:@selector(wsFailed:)]) {
        @try {
            [delegate wsFailed:self];
        }
        @catch (NSException *exception) {
            NSLog(@"RequestFailed,%@,%@,%@",_method,exception.name,exception.reason);
        }
        @finally {
        }
    }
}

#pragma mark - -------HTTPRequest--------------------
#pragma mark 创建请求体
- (void)run:(NSString *)method body:(NSDictionary *)body completionHandler:(void (^)(NSURLResponse* response, NSData* data, NSError* error)) handler
{
    if ([NSJSONSerialization isValidJSONObject:body])//判断是否有效
    {
        NSError* error;
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:body options:NSJSONWritingPrettyPrinted error: &error];//利用系统自带 JSON 工具封装 JSON 数据
        NSString *urlString = [NSString stringWithFormat:@"%@/%@/%@",k_host,k_action,method];
        _urlString = _urlString ?: urlString;
        if ([method hasPrefix:@"http:"]) {
            _urlString = method;
        }
        NSURL* url = [NSURL URLWithString:_urlString];
        request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:_timeOut];
        [request setHTTPMethod:@"POST"];//设置为 POST
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:[NSString stringWithFormat:@"%ld",(long)[jsonData length]] forHTTPHeaderField:@"Content-length"];
        [request setTimeoutInterval:_timeOut];
        [request setHTTPBody:jsonData];//把刚才封装的 JSON 数据塞进去
        //NSURLConnection *connect = [[NSURLConnection alloc] initWithRequest: request delegate:self];
        //[connect start];
        
        /*
         *发起异步访问网络操作 并用 block 操作回调函数
         */
        //[NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:handler];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
            NSURLResponse *response = nil;
            NSError *error = nil;
            NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(response,data,error);
            });
        });
    }
}

+ (HTTPRequest *)run:(NSString *)method body:(NSDictionary *)body delegate:(id)thedelegate
{
    HTTPRequest *result = [[HTTPRequest alloc] init];
    [result setMethod:method];
    [result run:method body:body delegate:thedelegate];
    [result start];
    
    return result;
}

+ (void)run:(NSString *)method body:(NSDictionary *)body completionHandler:(void (^)(NSURLResponse* response, NSData* data, NSError* error)) handler
{
    HTTPRequest *result = [[HTTPRequest alloc] init];
    [result setMethod:method];
    [result run:method body:body completionHandler:handler];
}

#pragma mark 打印调试信息
+ (void)printDebugMsg:(NSString *)msg
{
#if DEBUG
    NSLog(@"%@",msg);
#endif
}

@end
