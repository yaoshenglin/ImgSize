//
//  test.h
//  AppCaidan
//
//  Created by zzx on 13-10-23.
//  Copyright (c) 2013年 zzx. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PhotoPreViewDelegate;
@class PhotoMaskView;
@interface PhotoPreView : UIViewController<UIScrollViewDelegate>
{
    UIScrollView *myScrollView;
    UIImageView *myImageView;
    PhotoMaskView *myMaskView;
    UIImage *myImage;
    UIEdgeInsets myImageInset;
    CGSize cropSize;
    UIActivityIndicatorView *activity;
    
    BOOL isCroped;
    __weak id<PhotoPreViewDelegate> myDelegate;
    BOOL isOnlyRead;
}

@property (weak, nonatomic) id Tag;

- (id)init:(UIImage *)image cropSize:(CGSize)size isOnlyRead:(BOOL)onlyRead delegate:(id)delegate;

@end


@protocol PhotoPreViewDelegate <NSObject>

@optional
- (void)photoPreView:(PhotoPreView*)photoPreView didSelectImage:(UIImage *)image;
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker;

@end