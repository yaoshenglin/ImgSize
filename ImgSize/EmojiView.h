//
//  EmojiView.h
//  AppCaidan
//
//  Created by Yin on 14-6-7.
//  Copyright (c) 2014年 caidan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EmojiView : UIView
{
    UIPageControl *iPageControl;
}

@property (weak, nonatomic) id delegate;
@property (retain, nonatomic) UIPageControl *iPageControl;

@end
