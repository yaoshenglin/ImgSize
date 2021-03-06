//
//  UdpSocket.m
//  ImgSize
//
//  Created by Yin on 15-3-10.
//  Copyright (c) 2015年 caidan. All rights reserved.
//

#import "UdpSocket.h"
#import "Tools.h"
#import "CTB.h"
#import "Access.h"

typedef void (^myBlock)(AsyncUdpSocket *sock);

@interface UdpSocket ()
{
    BOOL isOn;
    
    myBlock iBlock;
}

@end

@implementation UdpSocket

@synthesize udpSocket;

- (instancetype)init
{
    if (self = [super init]) {
        _port = 8001;
        _host = @"255.255.255.255";
        udpSocket = [[AsyncUdpSocket alloc] initWithDelegate:self];
    }
    
    return self;
}

- (void)enableBroadcast:(BOOL)flag port:(UInt16)port
{
    NSError *error = nil;
    [udpSocket enableBroadcast:flag error:&error];
    if (error) {
        NSLog(@"Broadcast : %@",error.localizedDescription);
    }
    [udpSocket bindToPort:port error:&error];
    if (error) {
        NSLog(@"Port : %@",error.localizedDescription);
    }
    
    _port = port;
}

- (void)sendData:(NSData *)data
{
    [udpSocket sendData:data toHost:_host port:_port withTimeout:15.0 tag:0];
    //[udpSocket sendData:data toHost:_host port:_port withTimeout:-1 tag:0];
}

- (void)receiveWithTimeout:(NSTimeInterval)timeout tag:(long)tag
{
    [udpSocket receiveWithTimeout:timeout tag:tag];
}

#pragma mark - --------AsyncUdpSocket-------------------------
- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
    NSLog(@"没有发送数据:%@",error.localizedDescription);
}

- (void)onUdpSocket:(AsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
    NSLog(@"已经发送数据");
}

- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data withTag:(long)tag fromHost:(NSString *)host port:(UInt16)port
{
    Access *door = [[Access alloc] init];
    [door parseData:data];
    NSDictionary *dic = [CTB getLocalIPAddress];
    NSString *localIP = dic[dic.allKeys.firstObject];
    if (![host hasSuffix:localIP]) {
        //NSLog(@"已经接收来自%@数据,端口:%d",host,port);
        //NSLog(@"data : %@",data);
        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (str) {
            NSLog(@"str : %@",str);
        }else{
            [self pasreData:data host:host];
        }
        
        if ([_delegate respondsToSelector:select(onUdpSocket:didReceiveData:withTag:fromHost:port:)]) {
            [_delegate onUdpSocket:sock didReceiveData:data withTag:tag fromHost:host port:port];
        }
    }
    [sock receiveWithTimeout:-1 tag:0];
    return YES;
}

- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotReceiveDataWithTag:(long)tag dueToError:(NSError *)error
{
    NSLog(@"没有接收数据:%@",error.localizedDescription);
}

#pragma mark 已断开连接
- (void)onUdpSocketDidClose:(AsyncUdpSocket *)sock
{
    NSLog(@"UdpSocket 已断开连接");
    
    if ([_delegate respondsToSelector:@selector(onUdpSocketDidClose:)]) {
        [_delegate onUdpSocketDidClose:sock];
    }
    
    iBlock(sock);
}

- (void)closeSocket
{
    [udpSocket close];
}

- (void)closeCompletion:(void (^)(void)) handler
{
    [udpSocket close];
    iBlock = ^(AsyncUdpSocket *sock) {
        handler();
    };
}

- (void)pasreData:(NSData *)data host:(NSString *)host
{
    NSString *hexStr = [data hexString];
    
    Byte *data_bytes = (Byte*)[data bytes];
    Byte data_byte = data_bytes[0];
    
    switch (data_byte) {
        case (Byte) 0xE6 : // 读取主机ID返回
        {
            NSLog(@"UdpSocket,来自IP消息:%@, 读取主机ID返回",host);
            
            NSString *host_mac = [hexStr substringWithRange:NSMakeRange(2, 12)];
            if ([host_mac isEqualToString:@"FFFFFFFFFFFF"]) {
                NSLog(@"UdpSocket 主机不在线!");
            }else{
                NSLog(@"UdpSocket 主机在线!  当前主机ID -> %@",host_mac);
            }
        }
            break;
        case (Byte) 0XE0 : // 关闭从机返回
        {
            isOn = NO;
            NSLog(@"UdpSocket 关闭从机返回");
        }
            break;
        case (Byte) 0XE1 : // 开启从机返回
        {
            isOn = YES;
            NSLog(@"UdpSocket 开启从机返回");
        }
            break;
        case (Byte) 0XD4 : // 读状态为关机返回
        {
            isOn = NO;
            NSLog(@"UdpSocket 读状态为关机返回");
        }
            break;
        case (Byte) 0xE4 : // 读状态为开机返回
        {
            isOn = YES;
            NSLog(@"UdpSocket 读状态为开机返回");
        }
            break;
        case (Byte) 0xAA : // 主机心跳包
        {
            NSLog(@"UdpSocket 主机心跳包返回");
            NSString *host_mac = [hexStr substringWithRange:NSMakeRange(2, 12)];
            if ([host_mac isEqualToString:@"FFFFFFFFFFFF"]) {
                NSLog(@"UdpSocket 主机不在线!");
            }else{
                NSLog(@"UdpSocket 主机在线!  当前主机ID -> %@",host_mac);
                //setUserData(host_mac, @"host_mac");
            }
        }
            break;
        case (Byte) 0xD8 : // 下发学习指令成功
        {
            //dialog.show();
            NSLog(@"UdpSocket 下发学习指令成功");
        }
            break;
        case (Byte) 0xE8 : // 接收到遥控编码返回
        {
            NSLog(@"UdpSocket 接收到遥控编码返回");
        }
            break;
        case (Byte) 0xD9: // 执行摇控指令成功
        {
            NSLog(@"UdpSocket 执行摇控指令成功");
        }
            break;
        case (Byte)0xE7:// 接收到上传配置成功返回
        {
            NSLog(@"UdpSocket 上传配置成功！正在切换WIFI...");
        }
            break;
    }
}

@end
