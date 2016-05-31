//
//  sdkCall.h
//  sdkDemo
//
//  Created by xiaolongzhang on 13-3-29.
//  Copyright (c) 2013年 xiaolongzhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/TencentOAuthObject.h>
#import <TencentOpenAPI/TencentApiInterface.h>
#import "sdkDef.h"

@interface sdkCall : NSObject<TencentSessionDelegate, TencentApiInterfaceDelegate, TCAPIRequestDelegate>
{
    
}

+ (sdkCall *)getinstance;
+ (void)resetSDK;

+ (void)showInvalidTokenOrOpenIDMessage;

@property (retain, nonatomic)TencentOAuth *oauth;
@property (retain, nonatomic)NSMutableArray* photos;
@property (retain, nonatomic)NSMutableArray* thumbPhotos;

@end
