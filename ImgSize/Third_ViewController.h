//
//  Third_ViewController.h
//  ImgSize
//
//  Created by Yin on 14-5-20.
//  Copyright (c) 2014年 caidan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Third_ViewController : UIViewController<UITextFieldDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
{
    UIImageView *iImgView;
    UIScrollView *iScrollView;
}

@property (retain, nonatomic) NSString *imgName;//图片名
@property (retain, nonatomic) NSString *ImgURL;//图片链接
@property (retain, nonatomic) UIImage *bigImg;//
@property (retain, nonatomic) UIImageView *bigImgView;//图像视图
@property (retain, nonatomic) NSArray *listImg;

@end

@protocol ThirdDelegate <NSObject>

- (void)backPage;

@end
