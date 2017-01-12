//
//  CreateQRCode_ViewController.m
//  ImgSize
//
//  Created by xy on 16/10/25.
//  Copyright © 2016年 caidan. All rights reserved.
//

#import "CreateQRCode_ViewController.h"
#import "CTB.h"
#import "iControl.h"
#import "QRCodeGenerator.h"
#import "Toast+UIView.h"
#import "PhotoPreView.h"

@interface CreateQRCode_ViewController ()
{
    BOOL isShowMore;
    
    NSString *word;
    
    UIImageView *imgQRCodeView;
    iControl *myControl;
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
    
    word = _content;
    self.title = @"生成二维码";
    self.navigationItem.rightBarButtonItem = [CTB BarButtonWithBtnImgName:@"更多" target:self tag:2];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    UITextView *txtView = [[UITextView alloc] initWithFrame:CGRectMake(10, 10, Screen_Width-20, 50)];
    txtView.layer.cornerRadius = 5.0f;
    txtView.clipsToBounds = YES;
    txtView.text = _content;
    txtView.editable = NO;
    txtView.textColor = [UIColor blackColor];
    txtView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:txtView];
    
    CGFloat w = Screen_Width - 30;
    imgQRCodeView = [[UIImageView alloc] initWithFrame:GetRect(15, GetVMaxY(txtView)+15, w, w)];
    [self.view addSubview:imgQRCodeView];
    [CTB setBorderWidth:0.8 Color:[CTB colorWithHexString:@"#DADADA"] View:imgQRCodeView,txtView, nil];
    [CTB setRadius:5.0 View:imgQRCodeView,txtView, nil];
    
    UIButton *btnSave = [CTB buttonType:UIButtonTypeCustom delegate:self to:self.view tag:1 title:@"保存到相册" img:@"按钮-选中效果"];
    btnSave.frame = CGRectMake(80, viewH-50, Screen_Width-160, 38);
    [btnSave setNormalTitleColor:[UIColor whiteColor]];
    [CTB setRadius:5.0 View:btnSave, nil];
    
    imgQRCodeView.center = CGPointMake(Screen_Width/2, (CGRectGetMaxY(txtView.frame)+(CGRectGetMinY(btnSave.frame)))/2);
    
    UILongPressGestureRecognizer *longPressGR = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(txtViewLongPress:)];
    longPressGR.minimumPressDuration = 1;
    [imgQRCodeView addGestureRecognizer:longPressGR];
    imgQRCodeView.userInteractionEnabled = YES;
    
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
            [self.view makeToast:@"保存失败"];
            return;
        }
        /**
         *  将图片保存到iPhone本地相册
         *  UIImage *image            图片对象
         *  id completionTarget       响应方法对象
         *  SEL completionSelector    方法
         *  void *contextInfo
         */
        //UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        [PhotoPreView saveImageWithImage:imgQRCodeView.image albumName:@"二维码图片" completionHandler:^(BOOL success, NSError * _Nullable error) {
            if (error) {
                NSLog(@"添加图片到相册中失败");
                [self.view makeToast:error.localizedDescription];
                return;
            }
            
            NSLog(@"成功添加图片到相册中");
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self.view makeToast:@"图片保存成功"];
            }];
        }];
    }
    else if (button.tag == 2) {
        [self MoreOperation];//更多按钮
    }
}

#pragma mark - --------更多----------------
- (void)MoreOperation
{
    if (!isShowMore) {
        isShowMore = YES;
        CGRect rectStart = CGRectMake(Screen_Width-90, 0, 90, 0);
        CGRect rectEnd = CGRectMake(Screen_Width-90, 0, 90, 63*2);
        
        if (!myControl) {
            myControl = [[iControl alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, viewH)];
            [myControl setBackgroundColor:[UIColor blackColor] opacity:0.3];
            [myControl addTarget:self action:select(MoreButtonEvents:) forControlEvents:UIControlEventTouchDown];
            [self.view addSubview:myControl];
            
            UIView *baseView = [[UIView alloc] initWithFrame:CGRectZero];
            myControl.baseView = baseView;
            [myControl addSubview:myControl.baseView];
            baseView.frame = rectEnd;
            baseView.backgroundColor = [UIColor whiteColor];
            
            //[iControl CreateButtonWithImg:@"" title:LocalizedSingle(@"EditDevice") rect:CGRectMake(0, 0, 70, 63) tag:5 toView:baseView delegate:self];
            UIButton *btnEdit = [CTB buttonType:UIButtonTypeCustom delegate:self to:baseView tag:1 title:@"复制文字" img:@"点击效果/1" action:select(MoreButtonEvents:)];
            [btnEdit setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            [btnEdit setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
            btnEdit.titleLabel.font = [UIFont systemFontOfSize:13];
            btnEdit.frame = GetRect(0, 0, 90, 63);
            
            UIButton *btnSelect = [CTB buttonType:UIButtonTypeCustom delegate:self to:baseView tag:2 title:@"复制图片" img:@"点击效果/1" action:select(MoreButtonEvents:)];[UIColor grayColor];
            [btnSelect setNormalTitleColor:[UIColor grayColor]];
            [btnSelect setHighlightedTitleColor:[UIColor grayColor]];
            btnSelect.titleLabel.font = [UIFont systemFontOfSize:13];
            btnSelect.frame = GetRect(0, 63, 90, 63);
            
            UIButton *btnModify = [CTB buttonType:UIButtonTypeCustom delegate:self to:baseView tag:3 title:@"修改文字" img:@"点击效果/1" action:select(MoreButtonEvents:)];[UIColor grayColor];
            [btnModify setNormalTitleColor:[UIColor grayColor]];
            [btnModify setHighlightedTitleColor:[UIColor grayColor]];
            btnModify.titleLabel.font = [UIFont systemFontOfSize:13];
            btnModify.frame = GetRect(0, 63*2, 90, 63);
            
            [CTB setBottomLineHigh:0.5 Color:[UIColor grayColor] toV:btnEdit,btnSelect, nil];
            
            rectEnd.size.height = GetVMaxY(btnModify);
            [myControl setStartRect:rectStart endRect:rectEnd];
        }else{
            myControl.hidden = NO;
        }
        
        [myControl hidden:NO animation:YES];
    }else{
        isShowMore = NO;
        [myControl hidden:YES animation:YES];
    }
}

- (void)MoreButtonEvents:(UIButton *)button
{
    isShowMore = NO;
    [myControl hidden:YES animation:YES];
    
    if (button.tag == 1) {
        //复制文字
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = _content;
        
        [self.view makeToast:@"复制成功"];
    }
    else if (button.tag == 2) {
        //复制图片
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.image = imgQRCodeView.image;
        
        [self.view makeToast:@"复制成功"];
    }
    else if (button.tag == 3) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"修改文字" message:@"修改显示图片上方的文字" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        UITextField *textField = [alert textFieldAtIndex:0];
        textField.text = word;
        alert.tag = 1;
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *btnTitle = [alertView buttonTitleAtIndex:buttonIndex];
    if (alertView.tag == 1) {
        if ([btnTitle isEqualToString:@"确定"]) {
            UITextField *textField = [alertView textFieldAtIndex:0];
            word = textField.text;
            
            UIImage *image = [QRCodeGenerator qrImageForString:_content imageSize:GetVWidth(imgQRCodeView) text:word];
            imgQRCodeView.image = image;
        }
    }
}

#pragma mark - 保存图片
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
        
        //UITextView *txtView = [self.view viewWithClass:[UITextView class]];
        CGRect rect = [self.view convertRect:imgQRCodeView.frame toView:self.view];
        [menu setTargetRect:rect inView:self.view];
        [menu setMenuVisible:YES animated:YES];
    }
}

//复制
- (void)copyContent:(id)sender
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    //pasteboard.string = _content;
    pasteboard.image = imgQRCodeView.image;
    
    [self.view makeToast:@"复制成功"];
}

#pragma mark -
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
