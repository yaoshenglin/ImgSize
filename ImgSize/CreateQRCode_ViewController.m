//
//  CreateQRCode_ViewController.m
//  ImgSize
//
//  Created by xy on 16/10/25.
//  Copyright © 2016年 caidan. All rights reserved.
//

#import "CreateQRCode_ViewController.h"
#import "CTB.h"
#import "QRCodeGenerator.h"
#import "Toast+UIView.h"

@interface CreateQRCode_ViewController ()
{
    UIImageView *imgQRCodeView;
}

@end

@implementation CreateQRCode_ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initCapacity];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)initCapacity
{
    if (iPhone >= 7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.navigationController.navigationBar.barTintColor = MasterColor;
    }else{
        self.navigationController.navigationBar.tintColor = MasterColor;
    }
    
    self.title = @"生成二维码";
    self.navigationItem.rightBarButtonItem = [CTB BarButtonWithTitle:@"保存到相册" target:self tag:1];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    UITextView *txtView = [[UITextView alloc] initWithFrame:CGRectMake(10, 10, Screen_Width-20, 50)];
    txtView.layer.cornerRadius = 5.0f;
    txtView.clipsToBounds = YES;
    txtView.text = _content;
    txtView.editable = NO;
    txtView.selectable = NO;
    txtView.textColor = [UIColor blackColor];
    txtView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:txtView];
    
    UILongPressGestureRecognizer *longPressGR = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(txtViewLongPress:)];
    longPressGR.minimumPressDuration = 1;
    [txtView addGestureRecognizer:longPressGR];
    
    CGFloat w = Screen_Width - 30;
    imgQRCodeView = [[UIImageView alloc] initWithFrame:GetRect(15, GetVMaxY(txtView)+15, w, w)];
    [self.view addSubview:imgQRCodeView];
    [CTB setBorderWidth:0.8 Color:[CTB colorWithHexString:@"#DADADA"] View:imgQRCodeView,txtView, nil];
    [CTB setRadius:5.0 View:imgQRCodeView,txtView, nil];
    imgQRCodeView.center = CGPointMake(Screen_Width/2, (CGRectGetMaxY(txtView.frame)+Screen_Height-64)/2);
    
    [CTB duration:0.5 block:^{
        self.navigationItem.rightBarButtonItem.enabled = YES;
        imgQRCodeView.clipsToBounds = NO;
        UIImage *image = [QRCodeGenerator qrImageForString:_content imageSize:GetVWidth(imgQRCodeView)];
        imgQRCodeView.image = image;
    }];
}

#pragma mark - --------ButtonEvents------------------------
- (void)ButtonEvents:(UIButton *)button
{
    if (button.tag == 1) {
        UIImage *image = imgQRCodeView.image;
        if (!image) {
            [self.view makeToast:@""];
            return;
        }
        /**
         *  将图片保存到iPhone本地相册
         *  UIImage *image            图片对象
         *  id completionTarget       响应方法对象
         *  SEL completionSelector    方法
         *  void *contextInfo
         */
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error == nil) {
        
        [self.view makeToast:@"已存入手机相册"];
        
    }else{
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"保存失败" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
        [self.view makeToast:@"保存失败"];
    }
    
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

#pragma mark - 长按事件
- (void)txtViewLongPress:(UIGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        
        //长按触发菜单
        UIMenuItem *menuItem0 = [[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(copyContent:)];
        
        NSArray *listArray = [NSArray arrayWithObjects:menuItem0, nil];
        
        [self.inputView setFrame:CGRectZero];
        [self becomeFirstResponder];
        
        UIMenuController *menu = [UIMenuController sharedMenuController];
        menu.menuItems = listArray;
        
        UITextView *txtView = [self.view viewWithClass:[UITextView class]];
        CGRect rect = [self.view convertRect:txtView.frame toView:self.view];
        [menu setTargetRect:rect inView:self.view];
        [menu setMenuVisible:YES animated:YES];
    }
}

//复制
- (void)copyContent:(id)sender
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = _content;
    
    [self.view makeToast:@"复制成功"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
