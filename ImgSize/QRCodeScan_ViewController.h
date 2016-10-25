//
//  QRCodeScan_ViewController.h
//  ScanQRCode
//
//  Created by Yin on 14-4-1.
//  Copyright © 2014年 caidan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "MBProgressHUD.h"
@protocol QRDelegate <NSObject>
@optional

- (void)getScanResult:(NSString *)result;
- (void)getScanResult:(NSString *)result controller:(UIViewController *)controller;

@end

@class CustomDrawView;
@interface QRCodeScan_ViewController : UIViewController<AVCaptureMetadataOutputObjectsDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
{
    int num;
    BOOL isCanScan;
    BOOL upOrdown;
    NSTimer * timer;
    CGRect scanRect;
    CGRect cameraRect;
    
    UIImageView * PaneImgView;
    
    CustomDrawView *baseView;
    MBProgressHUD *hudView;
}

@property (strong,nonatomic) AVCaptureDevice * device;
@property (strong,nonatomic) AVCaptureDeviceInput * input;
@property (strong,nonatomic) AVCaptureMetadataOutput * output;
@property (strong,nonatomic) AVCaptureSession * session;
@property (strong,nonatomic) AVCaptureVideoPreviewLayer * preview;
@property (retain, nonatomic) UIImageView * line;

@property (weak, nonatomic) id delegate;
@property (retain, nonatomic) NSString *content;
@property (assign, nonatomic) NSInteger tag;

@end


