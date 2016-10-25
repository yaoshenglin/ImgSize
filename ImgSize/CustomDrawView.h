//
//  CustomDrawView.h
//  fafwaef
//
//  Created by Yin on 14-4-1.
//  Copyright © 2014年 caidan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface CustomDrawView : UIView

@property (assign ,nonatomic) CGRect lRect;
@property (retain ,nonatomic) UIColor *fillColor;

+ (CustomDrawView *)drawViewWithFrame:(CGRect)rect lRect:(CGRect)scanRect;

- (void)changeFillColor:(UIColor *)color;

@end
