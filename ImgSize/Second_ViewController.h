//
//  Second_ViewController.h
//  ImgSize
//
//  Created by Yin on 14-5-20.
//  Copyright (c) 2014年 caidan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Second_ViewController : UIViewController<UIScrollViewDelegate>
{
    UIScrollView *myScrollView;
    UIImageView *myImageView;
}

@property(retain,nonatomic)UIScrollView *myScrollView;
@property(retain,nonatomic)UIImageView *myImageView;

@end
