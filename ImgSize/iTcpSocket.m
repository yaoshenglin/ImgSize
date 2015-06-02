//
//  TcpSocket.m
//  ImgSize
//
//  Created by Yin on 15-4-2.
//  Copyright (c) 2015年 caidan. All rights reserved.
//

#import "iTcpSocket.h"

#include <stdio.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <string.h>

@interface iTcpSocket ()
{
    BOOL isReady;
    struct sockaddr_in server_addr;
    int server_socket;
}

@end

@implementation iTcpSocket

- (instancetype)initWithDelegate:(id)theDelegate
{
    if (self = [super init]) {
        _delegate = theDelegate;
    }
    
    return self;
}

- (void)connectToHost:(NSString *)host port:(UInt16)port
{
    _host = host, _port = port;
    const char *addr = host.UTF8String;
    server_addr.sin_len = sizeof(struct sockaddr_in);
    server_addr.sin_family = AF_INET;//IP4
    server_addr.sin_port = htons(port);
    server_addr.sin_addr.s_addr = inet_addr(addr);
    bzero(&(server_addr.sin_zero),8);
    
    int my_protocol = IPPROTO_TCP;
    server_socket = socket(AF_INET, SOCK_STREAM, my_protocol);
    if (server_socket == -1) {
        NSLog(@"socket error");
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        int value = connect(server_socket, (struct sockaddr *)&server_addr, sizeof(struct sockaddr_in));
        dispatch_async(dispatch_get_main_queue(), ^{
            if (value == 0) {
                isConnect = YES;
                //connect 成功之后，其实系统将你创建的socket绑定到一个系统分配的端口上，且其为全相关，包含服务器端的信息，可以用来和服务器端进行通信。
                struct timeval timeoutSend = {5,0};//5s
                setsockopt(server_socket,SOL_SOCKET,SO_SNDTIMEO,(const char*)&timeoutSend,sizeof(timeoutSend));
                struct timeval timeoutRev = {15,0};//15s
                setsockopt(server_socket,SOL_SOCKET,SO_RCVTIMEO,(const char*)&timeoutRev,sizeof(timeoutRev));
                //listen(server_socket, 5);//服务器端侦听客户端的请求
                
                if ([_delegate respondsToSelector:@selector(didConnectToHost:)]) {
                    [_delegate didConnectToHost:self];
                }
            }else{
                [self close];
            }
        });
    });
}

- (BOOL)isConnect
{
    BOOL result = isConnect;
    if (result) {
        return result;
    }
    int optval;
    int optlen = sizeof(int);
    getsockopt(server_socket, SOL_SOCKET, SO_ERROR,(char*) &optval, (socklen_t *)&optlen);
    
    switch(optval){
            
        case 0:
            
            //“处于连接状态“
            result = YES;
            break;
            
        case ECONNREFUSED:
            break;
    }
    
    return result;
}

- (void)reconnectToHost
{
    if (![self isConnect]) {
        [self connectToHost:_host port:_port];
    }
}

- (void)sendData:(NSData *)data
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        long result = send(server_socket, [data bytes], 1024, 0);
        dispatch_async(dispatch_get_main_queue(), ^{
            int code = errno;
            if (result == -1) {
                if ([_delegate respondsToSelector:@selector(onSocket:didNotSendDataWithError:)]) {
                    NSString *errMsg = @"发送错误";
                    if (code == EAGAIN) {
                        errMsg = @"发送超时";
                    }
                    else if (code == ESRCH) {
                        errMsg = @"没有连接或已取消连接";
                    }
                    NSDictionary *info = [NSDictionary dictionaryWithObject:errMsg forKey:NSLocalizedDescriptionKey];
                    NSError *error = [NSError errorWithDomain:@"发送错误" code:code userInfo:info];
                    [_delegate onSocket:self didNotSendDataWithError:error];
                }
            }else{
                
                if ([_delegate respondsToSelector:@selector(onSocketDidSendData:)]) {
                    [_delegate onSocketDidSendData:self];
                }
                
                [self receiveData];
            }
        });
    });
}

- (void)receiveData
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        char *msg = malloc(sizeof(char)*1024);
        long result = recv(server_socket, msg, 1024, 0);
        dispatch_async(dispatch_get_main_queue(), ^{
            int code = errno;
            if(result==-1)
            {
                NSString *errMsg = @"接收失败";
                if (code == EAGAIN) {
                    errMsg = @"接收超时";
                }
                else if (code == ESRCH) {
                    errMsg = @"";
                }
                NSDictionary *info = [NSDictionary dictionaryWithObject:errMsg forKey:NSLocalizedDescriptionKey];
                NSError *error = [NSError errorWithDomain:@"接收超时" code:code userInfo:info];
                if ([_delegate respondsToSelector:@selector(onSocket:didNotReceiveDataWithError:)]) {
                    [_delegate onSocket:self didNotReceiveDataWithError:error];
                }
            }
            else if (result == 0) {
                printf("Connection has been interrupted\n");
            }
            else{
                
                if (strlen(msg) > 0) {
                    NSData *data = [NSData dataWithBytes:msg length:result];
                    
                    if ([_delegate respondsToSelector:@selector(onSocket:didReceiveData:)]) {
                        [_delegate onSocket:self didReceiveData:data];
                    }
                }
            }
            
            free(msg);
        });
    });
}

- (void)close
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        shutdown(server_socket, 2);
        int result = close(server_socket);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (result == 0) {
                isConnect = NO;
                if ([_delegate respondsToSelector:@selector(onSocketDidClose:)]) {
                    [_delegate onSocketDidClose:self];
                }
            }
        });
    });
}

@end
