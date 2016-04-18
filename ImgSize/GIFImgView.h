//
//  GIFImgView.h
//  ImgSize
//
//  Created by Yin on 15/9/22.
//  Copyright © 2015年 caidan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GIFImgView : UIView

//- (instancetype)initWithImage:(UIImage *)image;
//- (instancetype)initWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage NS_AVAILABLE_IOS(3_0);

@property (retain, nonatomic) UIImage *image;
@property (assign, nonatomic) NSInteger count;
@property (assign, nonatomic) NSInteger repeatCount;
@property (assign, nonatomic) NSTimeInterval duration;

- (void)startAnimating;
- (void)stopAnimating;
- (BOOL)isAnimating;

@end
