//
//  BackRequest.h
//  ImgSize
//
//  Created by Yin on 15-7-13.
//  Copyright (c) 2015年 caidan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BackRequest : NSObject

- (void)backgroundTask;
#pragma mark 创建URLSession
- (NSURLSession *)backgroundSession;

@end
