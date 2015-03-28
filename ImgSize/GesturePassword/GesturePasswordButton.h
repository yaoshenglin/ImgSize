//
//  GesturePasswordButton.h
//  GesturePassword
//
//  Created by hb on 14-8-23.
//  Copyright (c) 2014年 黑と白の印记. All rights reserved.
//

#import <UIKit/UIKit.h>

#define defaultColor @"#1EAFEB"

@interface GesturePasswordButton : UIView
{
    CGFloat *lineColor;
}

@property (nonatomic,assign) BOOL selected;

@property (nonatomic,assign) BOOL success;

+ (CGFloat *)colorWithHexString:(NSString *)stringToConvert;

@end
