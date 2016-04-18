//
//  MyDrawView.h
//  ImgSize
//
//  Created by Yin on 14-10-24.
//  Copyright (c) 2014年 caidan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CTB.h"

@interface MyDrawView : UIView

@property (assign ,nonatomic) CGRect lRect;
@property (retain ,nonatomic) UIColor *fillColor;

- (void)changeFillColor:(UIColor *)color;

@end
