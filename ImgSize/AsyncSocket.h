//
//  AsyncSocket.h
//  ImgSize
//
//  Created by Yin on 15-3-10.
//  Copyright (c) 2015年 caidan. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AsyncUdpSocket.h"

@interface AsyncSocket : NSObject

@property (retain, nonatomic) AsyncUdpSocket *udpSocket;

- (void)enableBroadcast:(BOOL)flag port:(UInt16)port;
- (void)sendData;
- (void)closeSocket;

@end
