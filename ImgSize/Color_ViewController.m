//
//  Color_ViewController.m
//  ImgSize
//
//  Created by Yin on 15-1-13.
//  Copyright (c) 2015年 caidan. All rights reserved.
//

#import "Color_ViewController.h"
#import "CTB.h"
#import "Tools.h"
#import "QRCodeGenerator.h"

@interface Color_ViewController ()<UITextFieldDelegate>
{
    UIButton *btnSelect;
    UILabel *lblSelect;
    UITextField *txtAccount;
    UIScrollView *iScrollView;
    UIImageView *imgQRCodeView;
    
    BOOL isSelect;
    NSInteger tag;
    NSMutableArray *listBtn;
}

@end

@implementation Color_ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initCapacity];
    // Do any additional setup after loading the view.
}

- (void)initCapacity
{
    tag = 1;
    listBtn = [@[] mutableCopy];
    //self.view.backgroundColor = [UIColor blackColor];
    iScrollView = [[UIScrollView alloc] initWithFrame:GetRect(0, 20, Screen_Width, Screen_Height-49-20)];
    [self.view addSubview:iScrollView];
    
    CGFloat x = 8;
    txtAccount = [CTB textFieldTag:1 holderTxt:@"请输入您的设备ID" V:iScrollView delegate:self];
    txtAccount.frame = GetRect(x, 15, Screen_Width-x*2-80, 44);
    txtAccount.layer.cornerRadius = 3;
    txtAccount.returnKeyType = UIReturnKeyNext;
    //txtAccount.keyboardType = UIKeyboardTypeNumberPad;
    UILabel *lblPhoneLeftView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 68, GetVHeight(txtAccount))];
    txtAccount.leftView = lblPhoneLeftView;
    txtAccount.leftViewMode = UITextFieldViewModeAlways;
    lblPhoneLeftView.text = @"设备ID :";
    lblPhoneLeftView.textAlignment = NSTextAlignmentCenter;
    lblPhoneLeftView.textColor = [UIColor blackColor];
    [CTB setBorderWidth:0.8 Color:[CTB colorWithHexString:@"#DADADA"] View:txtAccount, nil];
    
    //选择按钮
    isSelect = YES;
    btnSelect = [CTB buttonType:UIButtonTypeCustom delegate:self to:iScrollView tag:3 title:@"" img:@"单选_选中"];
    btnSelect.showsTouchWhenHighlighted = NO;
    btnSelect.frame = CGRectMake(GetVMaxX(txtAccount)+10, 0+15, 20, 20);
    btnSelect.center = GetPoint(btnSelect.center.x, txtAccount.center.y);
    
    lblSelect = [CTB labelTag:0 toView:iScrollView text:@"加密" wordSize:16];
    lblSelect.frame = CGRectMake(GetVMaxX(btnSelect), GetVMinY(btnSelect), 50, 20);
    
    UIButton *btnHostMac = [CTB buttonType:UIButtonTypeCustom delegate:self to:iScrollView tag:1 title:@"主机" img:@""];
    btnHostMac.frame = GetRect(20, GetVMaxY(txtAccount)+10, Screen_Width/2-40, 30);
    [btnHostMac setNormalBackgroundImage:[UIImage imageNamed:@"按钮-选中效果"]];
    [btnHostMac setNormalTitleColor:[UIColor whiteColor]];
    
    UIButton *btnSwitch = [CTB buttonType:UIButtonTypeCustom delegate:self to:iScrollView tag:2 title:@"开关" img:@""];
    btnSwitch.frame = GetRect(Screen_Width/2+20, GetVMinY(btnHostMac), Screen_Width/2-40, 30);
    [btnSwitch setNormalBackgroundImage:[UIImage imageNamed:@"选中背景图"]];
    listBtn.array = @[btnHostMac,btnSwitch];
    
    UIButton *btnConfirm = [CTB buttonType:UIButtonTypeCustom delegate:self to:iScrollView tag:4 title:@"生成二维码" img:@""];
    [btnConfirm setNormalTitleColor:[UIColor whiteColor]];
    btnConfirm.frame = GetRect(20, GetVMaxY(btnSwitch)+10, Screen_Width-40, 38);
    [btnConfirm setNormalBackgroundImage:[UIImage imageNamed:@"按钮-选中效果"]];
    
    [CTB setRadius:3.0 View:btnHostMac,btnSwitch,btnConfirm, nil];
    [CTB setRadius:1.0 View:btnSelect, nil];
    
    imgQRCodeView = [[UIImageView alloc] initWithFrame:GetRect(Screen_Width/2-100, GetVMaxY(btnConfirm)+40, 200, 200)];
    [self.view addSubview:imgQRCodeView];
    [CTB setBorderWidth:0.8 Color:[CTB colorWithHexString:@"#DADADA"] View:imgQRCodeView, nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)ButtonEvents:(UIButton *)button
{
    [txtAccount resignFirstResponder];
    
    if (button.tag == 1|| button.tag == 2) {
        tag = button.tag;
        for (UIButton *btn in listBtn) {
            UIImage *image;
            if (btn == button) {
                image = [UIImage imageNamed:@"按钮-选中效果"];
                [btn setNormalTitleColor:[UIColor whiteColor]];
            }else{
                image = [UIImage imageNamed:@"选中背景图"];
                [btn setNormalTitleColor:[UIColor blackColor]];
            }
            [btn setNormalBackgroundImage:image];
        }
    }
    else if (button.tag == 3) {
        UIImage *image;
        if (isSelect) {
            isSelect = NO;
            image = [UIImage imageNamed:@"单选_未选中"];
        }else{
            isSelect = YES;
            image = [UIImage imageNamed:@"单选_选中"];
        }
        
        [button setNormalBackgroundImage:image];
    }
    else if (button.tag == 4) {
        NSString *host_mac = txtAccount.text;
        if (host_mac.length <= 0) {
            [CTB showMsg:@"请输入设备ID"];
            return;
        }
        
        NSString *value = @"";
        if (tag == 1) {
            //主机
            value = [NSString format:@"device:host;content:%@;ver:1.0",host_mac];
        }
        else if (tag == 2) {
            //开关
            value = [NSString format:@"device:switch;id:%@",host_mac];
        }
        
        if (isSelect) {
            value = [Tools encryptFrom:value];
        }
        
        UIImage *image = [QRCodeGenerator qrImageForString:value imageSize:GetVWidth(imgQRCodeView)];
        imgQRCodeView.image = image;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
