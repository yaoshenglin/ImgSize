//
//  DownloadService.h
//  ImgSize
//
//  Created by Yin on 15/7/20.
//  Copyright (c) 2015年 caidan. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^DownloadServiceSuccess)(NSString *savePath);
typedef void (^DownloadServiceFailure)(NSError *error);

@interface DownloadService : NSObject

/**
 *  下载指定URL的资源到路径
 *
 *  @param urlStr   网络资源路径
 *  @param toPath   本地存储文件夹
 *  @param capacity 缓存大小，单位为Mb
 *  @param success  成功时回传本地存储路径
 *  @param failure  失败时回调的错误原因
 */
+ (void)downLoadWithURL:(NSString *)urlStr toDirectory:(NSString *)toDirectory cacheCapacity:(NSInteger)capacity  success:(DownloadServiceSuccess)success failure:(DownloadServiceFailure)failure;

@end
