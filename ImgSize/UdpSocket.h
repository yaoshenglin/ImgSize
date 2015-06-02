//
//  UdpSocket.h
//  ImgSize
//
//  Created by Yin on 15-3-10.
//  Copyright (c) 2015年 caidan. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AsyncUdpSocket.h"

@interface UdpSocket : NSObject

@property (retain, nonatomic) id delegate;
@property (assign, nonatomic) UInt16 port;
@property (retain, nonatomic) NSString *host;
@property (retain, nonatomic) AsyncUdpSocket *udpSocket;

- (void)enableBroadcast:(BOOL)flag port:(UInt16)port;
- (void)sendData:(NSData *)data;
- (void)closeSocket;
- (void)closeCompletion:(void (^)(void)) handler;

@end

@interface UdpSocket (SockDelegate)

- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data withTag:(long)tag fromHost:(NSString *)host port:(UInt16)port;

@end
