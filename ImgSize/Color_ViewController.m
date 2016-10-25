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
    UILabel *lblDevice;
    UITextField *txtAccount;
    UIScrollView *iScrollView;
    UIImageView *imgQRCodeView;
    
    BOOL isSelect;
    int selectType;
    NSMutableArray *listDevice;
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
    selectType = 1;
    listDevice = [@[] mutableCopy];
    listDevice.array = @[@"主机",@"开关",@"插座",@"电动窗帘"];
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
    
    //选择按钮(加密)
    isSelect = YES;
    btnSelect = [CTB buttonType:UIButtonTypeCustom delegate:self to:iScrollView tag:3 title:@"" img:@"单选_选中"];
    btnSelect.showsTouchWhenHighlighted = NO;
    btnSelect.frame = CGRectMake(GetVMaxX(txtAccount)+10, 0+15, 20, 20);
    btnSelect.center = GetPoint(btnSelect.center.x, txtAccount.center.y);
    
    lblSelect = [CTB labelTag:0 toView:iScrollView text:@"加密" wordSize:16];
    lblSelect.frame = CGRectMake(GetVMaxX(btnSelect), GetVMinY(btnSelect), 50, 20);
    
    x = 30;
    UIView *DeviceView = [[UIView alloc] init];
    DeviceView.clipsToBounds = YES;
    DeviceView.frame = GetRect(x, GetVMaxY(txtAccount)+10, Screen_Width-x*2, 30);
    DeviceView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"按钮-选中效果"]];
    [iScrollView addSubview:DeviceView];
    
    lblDevice = [CTB labelTag:2 toView:DeviceView text:@"主机" wordSize:-1];
    lblDevice.frame = GetRect(0, 0, GetVWidth(DeviceView), 30);
    lblDevice.backgroundColor = [UIColor clearColor];
    lblDevice.textColor = [UIColor whiteColor];
    
    UIButton *btnSwitch = [CTB buttonType:UIButtonTypeCustom delegate:self to:iScrollView tag:2 title:@"" img:@""];
    btnSwitch.frame = GetRect(CGRectGetMaxX(DeviceView.frame)-30, GetVMinY(DeviceView), 30, 30);
    [btnSwitch setNormalImage:[UIImage imageNamed:@"向下图标"]];
    
    //生成二维码
    UIButton *btnConfirm = [CTB buttonType:UIButtonTypeCustom delegate:self to:iScrollView tag:4 title:@"生成二维码" img:@""];
    [btnConfirm setNormalTitleColor:[UIColor whiteColor]];
    btnConfirm.frame = GetRect(x, GetVMaxY(btnSwitch)+10, Screen_Width-x*2, 38);
    [btnConfirm setNormalBackgroundImage:[UIImage imageNamed:@"按钮-选中效果"]];
    
    [CTB setRadius:3.0 View:DeviceView,btnSwitch,btnConfirm, nil];
    [CTB setRadius:1.0 View:btnSelect, nil];
    
    imgQRCodeView = [[UIImageView alloc] initWithFrame:GetRect(Screen_Width/2-100, GetVMaxY(btnConfirm)+40, 200, 200)];
    [self.view addSubview:imgQRCodeView];
    [CTB setBorderWidth:0.8 Color:[CTB colorWithHexString:@"#DADADA"] View:imgQRCodeView, nil];
    
    x = CGRectGetMinX(DeviceView.frame);
    UITableView *tableView = [CTB tableViewStyle:UITableViewStylePlain delegate:self toV:iScrollView];
    tableView.frame = CGRectMake(x, GetVMaxY(DeviceView), Screen_Width-x*2, 0);
    tableView.backgroundColor = [[UIColor grayColor] colorWithAlpha:0.5];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - --------tableView------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger row_Count = listDevice.count;
    
    return row_Count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [NSString stringWithFormat:@"%d/%d/",(int)indexPath.section,(int)indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor whiteColor];
        [CTB setBottomLineAtTable:tableView dicData:@{@"indexPath":indexPath,@"cell":cell,@"borderColor":[[UIColor whiteColor] colorWithAlpha:0.5]}];
    }
    
    cell.textLabel.text = [listDevice objAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *wifiSSID = [listDevice objAtIndex:indexPath.row];
    lblDevice.text = wifiSSID;
    
    selectType = (int)indexPath.row + 1;
    
    [CTB animateWithDur:0.3 animations:^{
        [tableView setSizeToH:0];
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark - --------ButtonEvents------------------------
- (void)ButtonEvents:(UIButton *)button
{
    [txtAccount resignFirstResponder];
    
    if (button.tag == 1 || button.tag == 2) {
        //主机或者其它的设备切换
        UITableView *tableView = [iScrollView viewWithClass:[UITableView class]];
        if (GetVHeight(tableView) > 0) {
            [CTB animateWithDur:0.3 animations:^{
                [tableView setSizeToH:0];
            } completion:^(BOOL finished) {
                
            }];
        }else{
            [CTB animateWithDur:0.3 animations:^{
                [tableView setSizeToH:200];
            } completion:^(BOOL finished) {
                
            }];
        }
    }
    else if (button.tag == 3) {
        //是否加密
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
        //生成二维码
        NSString *host_mac = txtAccount.text;
        if (host_mac.length <= 0) {
            [CTB showMsg:@"请输入设备ID"];
            return;
        }
        
        //@"device:switch;id:01000001;tag:3";
        //@"device:plug;id:02000001;ver:1.0";
        //@"device:doorlock;id:03000001;tag:1;ver:1.0";
        
        NSString *value = @"";
        if (selectType == 1) {
            //主机
            value = [NSString format:@"device:host;content:%@;ver:1.0",host_mac];
        }
        else if (selectType == 2) {
            //开关(3目)
            value = [NSString format:@"device:switch;id:%@;tag:3",host_mac];
        }
        else if (selectType == 3) {
            //插座
            value = [NSString format:@"device:plug;id:%@",host_mac];
        }
        else if (selectType == 4) {
            //电动窗帘
            value = [NSString format:@"device:curtain;id:%@;tag:0;ver:1.0",host_mac];
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
