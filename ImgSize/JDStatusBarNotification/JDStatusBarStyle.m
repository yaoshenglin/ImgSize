//
//  JDStatusBarStyle.m
//  JDStatusBarNotificationExample
//
//  Created by Markus on 04.12.13.
//  Copyright (c) 2013 Markus. All rights reserved.
//

#import "JDStatusBarStyle.h"

NSString *const JDStatusBarStyleError   = @"JDStatusBarStyleError";//红色
NSString *const JDStatusBarStyleWarning = @"JDStatusBarStyleWarning";//黄色
NSString *const JDStatusBarStyleSuccess = @"JDStatusBarStyleSuccess";//绿色
NSString *const JDStatusBarStyleMatrix  = @"JDStatusBarStyleMatrix";//白色
NSString *const JDStatusBarStyleDefault = @"JDStatusBarStyleDefault";//白色
NSString *const JDStatusBarStyleDark    = @"JDStatusBarStyleDark";//黑色

@implementation JDStatusBarStyle

- (instancetype)copyWithZone:(NSZone*)zone;
{
    JDStatusBarStyle *style = [[[self class] allocWithZone:zone] init];
    style.barColor = self.barColor;
    style.textColor = self.textColor;
    style.textShadow = self.textShadow;
    style.font = self.font;
    style.textVerticalPositionAdjustment = self.textVerticalPositionAdjustment;
    style.animationType = self.animationType;
    style.progressBarColor = self.progressBarColor;
    style.progressBarHeight = self.progressBarHeight;
    style.progressBarPosition = self.progressBarPosition;
    return style;
}

+ (NSArray*)allDefaultStyleIdentifier;
{
    return @[[UIColor redColor], [UIColor yellowColor],
             [UIColor greenColor], [UIColor whiteColor],
             [UIColor whiteColor]];
}

+ (NSArray*)allDefaultStyleByColor;
{
    return @[JDStatusBarStyleError, JDStatusBarStyleWarning,
             JDStatusBarStyleSuccess, JDStatusBarStyleMatrix,
             JDStatusBarStyleDark];
}

+ (JDStatusBarStyle*)defaultStyleWithName:(NSString*)styleName;
{
    // setup default style
    JDStatusBarStyle *style = [[JDStatusBarStyle alloc] init];
    style.barColor = [UIColor whiteColor];
    style.progressBarColor = [UIColor greenColor];
    style.progressBarHeight = 1.0;
    style.progressBarPosition = JDStatusBarProgressBarPositionBottom;
    style.textColor = [UIColor grayColor];
    style.font = [UIFont systemFontOfSize:12.0];
    style.animationType = JDStatusBarAnimationTypeMove;
    
    // JDStatusBarStyleDefault
    if ([styleName isEqualToString:JDStatusBarStyleDefault]) {
        return style;
    }
    
    // JDStatusBarStyleError
    else if ([styleName isEqualToString:JDStatusBarStyleError]) {
        style.barColor = [UIColor colorWithRed:0.588 green:0.118 blue:0.000 alpha:1.000];
        style.textColor = [UIColor whiteColor];
        style.progressBarColor = [UIColor redColor];
        style.progressBarHeight = 2.0;
        return style;
    }
    
    // JDStatusBarStyleWarning
    else if ([styleName isEqualToString:JDStatusBarStyleWarning]) {
        style.barColor = [UIColor colorWithRed:0.900 green:0.734 blue:0.034 alpha:1.000];
        style.textColor = [UIColor darkGrayColor];
        style.progressBarColor = style.textColor;
        return style;
    }
    
    // JDStatusBarStyleSuccess
    else if ([styleName isEqualToString:JDStatusBarStyleSuccess]) {
        style.barColor = [UIColor colorWithRed:0.588 green:0.797 blue:0.000 alpha:1.000];
        style.textColor = [UIColor whiteColor];
        style.progressBarColor = [UIColor colorWithRed:0.106 green:0.594 blue:0.319 alpha:1.000];
        style.progressBarHeight = 1.0+1.0/[[UIScreen mainScreen] scale];
        return style;
    }
    
    // JDStatusBarStyleDark
    else if ([styleName isEqualToString:JDStatusBarStyleDark]) {
        style.barColor = [UIColor colorWithRed:0.050 green:0.078 blue:0.120 alpha:1.000];
        style.textColor = [UIColor colorWithWhite:0.95 alpha:1.0];
        style.progressBarHeight = 1.0+1.0/[[UIScreen mainScreen] scale];
        return style;
    }
    
    // JDStatusBarStyleMatrix
    else if ([styleName isEqualToString:JDStatusBarStyleMatrix]) {
        style.barColor = [UIColor blackColor];
        style.textColor = [UIColor greenColor];
        style.font = [UIFont fontWithName:@"Courier-Bold" size:14.0];
        style.progressBarColor = [UIColor greenColor];
        style.progressBarHeight = 2.0;
        return style;
    }
    
    return nil;
}

+ (JDStatusBarStyle*)defaultStyleWith:(NSDictionary *)dicData
{
    UIColor *barColor = dicData[@"barColor"];
    UIColor *progressBarColor = dicData[@"progressBarColor"];
    UIColor *textColor = dicData[@"textColor"];
    CGFloat progressBarHeight = dicData[@"progressBarHeight"] ? [dicData[@"progressBarHeight"] floatValue] : 1.0f;
    JDStatusBarProgressBarPosition position = dicData[@"ProgressBarPosition"] ? [dicData[@"ProgressBarPosition"] intValue] : JDStatusBarProgressBarPositionBottom;
    CGFloat txtSize = dicData[@"txtSize"] ? [dicData[@"txtSize"] floatValue] : 12.0f;
    JDStatusBarAnimationType animationType = dicData[@"animationType"] ? [dicData[@"animationType"] intValue] : JDStatusBarAnimationTypeFade;
    JDStatusBarStyle *style = [[JDStatusBarStyle alloc] init];
    style.barColor = barColor ? barColor : [UIColor whiteColor];
    style.progressBarColor = progressBarColor ? progressBarColor : [UIColor greenColor];
    style.progressBarHeight = progressBarHeight;
    style.progressBarPosition = position;
    style.textColor = textColor ? textColor : [UIColor blackColor];
    style.font = [UIFont systemFontOfSize:txtSize];
    style.animationType = animationType;
    
    return style;
}

+ (JDStatusBarStyle*)defaultStyleWithColor:(UIColor *)color
{
    // setup default style
    JDStatusBarStyle *style = [[JDStatusBarStyle alloc] init];
    style.barColor = [UIColor whiteColor];
    style.progressBarColor = [UIColor greenColor];
    style.progressBarHeight = 1.0;
    style.progressBarPosition = JDStatusBarProgressBarPositionBottom;
    style.textColor = [UIColor blackColor];
    style.font = [UIFont systemFontOfSize:12.0];
    style.animationType = JDStatusBarAnimationTypeFade;
    
    // JDStatusBarStyleError
    if ([color isEqual:[UIColor redColor]]) {
        style.barColor = [UIColor colorWithRed:0.588 green:0.118 blue:0.000 alpha:1.000];
        style.textColor = [UIColor whiteColor];
        style.progressBarColor = [UIColor redColor];
        style.progressBarHeight = 2.0;
        return style;
    }
    
    // JDStatusBarStyleWarning
    else if ([color isEqual:[UIColor yellowColor]]) {
        style.barColor = [UIColor colorWithRed:0.900 green:0.734 blue:0.034 alpha:1.000];
        style.textColor = [UIColor darkGrayColor];
        style.progressBarColor = style.textColor;
        return style;
    }
    
    // JDStatusBarStyleSuccess
    else if ([color isEqual:[UIColor greenColor]]) {
        style.barColor = [UIColor colorWithRed:0.588 green:0.797 blue:0.000 alpha:1.000];
        style.textColor = [UIColor whiteColor];
        style.progressBarColor = [UIColor colorWithRed:0.106 green:0.594 blue:0.319 alpha:1.000];
        style.progressBarHeight = 1.0+1.0/[[UIScreen mainScreen] scale];
        return style;
    }
    
    // JDStatusBarStyleDark
    else if ([color isEqual:[UIColor darkGrayColor]]) {
        style.barColor = [UIColor colorWithRed:0.050 green:0.078 blue:0.120 alpha:1.000];
        style.textColor = [UIColor colorWithWhite:0.95 alpha:1.0];
        style.progressBarHeight = 1.0+1.0/[[UIScreen mainScreen] scale];
        return style;
    }
    
    // JDStatusBarStyleMatrix
    else if ([color isEqual:[UIColor colorWithWhite:0.5 alpha:0.5]]) {
        style.barColor = [UIColor blackColor];
        style.textColor = [UIColor greenColor];
        style.font = [UIFont fontWithName:@"Courier-Bold" size:14.0];
        style.progressBarColor = [UIColor greenColor];
        style.progressBarHeight = 2.0;
        return style;
    }else{
        // JDStatusBarStyleDefault
        color = color ?: [UIColor whiteColor];
        style.barColor = color;
        return style;
    }
    
    return nil;
}

@end
