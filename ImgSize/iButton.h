//
//  iButton.h
//  ImgSize
//
//  Created by Yin on 14-6-10.
//  Copyright (c) 2014年 caidan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface iButton : UIButton
{
    __weak id delegate;
    SEL actionMethod;
    UIImageView *imgViewNormal;
    UIImageView *imgViewHighlighted;
}

- (void)setImage:(UIImage *)image forState:(UIControlState)state;
- (void)setBackgroundImage:(UIImage *)image forState:(UIControlState)state;
- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;

@end
