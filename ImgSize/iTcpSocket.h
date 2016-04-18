//
//  TcpSocket.h
//  ImgSize
//
//  Created by Yin on 15-4-2.
//  Copyright (c) 2015年 caidan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface iTcpSocket : NSObject
{
    BOOL isConnect;
}

@property (weak, nonatomic) id delegate;
@property (assign, nonatomic, readonly) UInt16 port;
@property (retain, nonatomic, readonly) NSString *host;

- (instancetype)initWithDelegate:(id)theDelegate;

- (void)connectToHost:(NSString *)host port:(UInt16)port;

- (BOOL)isConnect;

- (void)reconnectToHost;

- (void)sendData:(NSData *)data;

- (void)receiveData;

- (void)close;

@end

#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface NSObject (AsyncTcpSocketDelegate)

- (void)didConnectToHost:(iTcpSocket *)sock;

/**
 * Called when the datagram with the given tag has been sent.
 **/
- (void)onSocketDidSendData:(iTcpSocket *)sock;

/**
 * Called if an error occurs while trying to send a datagram.
 * This could be due to a timeout, or something more serious such as the data being too large to fit in a sigle packet.
 **/
- (void)onSocket:(iTcpSocket *)sock didNotSendDataWithError:(NSError *)error;

/**
 * Called when the socket has received the requested datagram.
 *
 * Due to the nature of UDP, you may occasionally receive undesired packets.
 * These may be rogue UDP packets from unknown hosts,
 * or they may be delayed packets arriving after retransmissions have already occurred.
 * It's important these packets are properly ignored, while not interfering with the flow of your implementation.
 * As an aid, this delegate method has a boolean return value.
 * If you ever need to ignore a received packet, simply return NO,
 * and AsyncUdpSocket will continue as if the packet never arrived.
 * That is, the original receive request will still be queued, and will still timeout as usual if a timeout was set.
 * For example, say you requested to receive data, and you set a timeout of 500 milliseconds, using a tag of 15.
 * If rogue data arrives after 250 milliseconds, this delegate method would be invoked, and you could simply return NO.
 * If the expected data then arrives within the next 250 milliseconds,
 * this delegate method will be invoked, with a tag of 15, just as if the rogue data never appeared.
 *
 * Under normal circumstances, you simply return YES from this method.
 **/
- (BOOL)onSocket:(iTcpSocket *)sock didReceiveData:(NSData *)data;

/**
 * Called if an error occurs while trying to receive a requested datagram.
 * This is generally due to a timeout, but could potentially be something else if some kind of OS error occurred.
 **/
- (void)onSocket:(iTcpSocket *)sock didNotReceiveDataWithError:(NSError *)error;

/**
 * Called when the socket is closed.
 * A socket is only closed if you explicitly call one of the close methods.
 **/
- (void)onSocketDidClose:(iTcpSocket *)sock;

@end
