//
//  ViewController.m
//  ImgSize
//
//  Created by Yin on 14-5-17.
//  Copyright (c) 2014年 caidan. All rights reserved.
//

#import "ViewController.h"
#import "MBProgressHUD.h"
#import "JDStatusBarNotification.h"
#import "CTB.h"
#import "Tools.h"
#import "AddressBook.h"
#import "Toast+UIView.h"
#import "Brands.h"
#import "HTTPRequest.h"
#import "BackRequest.h"
#import <CoreTelephony/CTCall.h>
#import <CoreTelephony/CTSubscriber.h>


extern NSString *CTSettingCopyMyPhoneNumber(void);

static NSString *const JDButtonName = @"JDButtonName";
static NSString *const JDButtonInfo = @"JDButtonInfo";
static NSString *const JDNotificationText = @"JDNotificationText";

static NSString *const SBStyle1 = @"SBStyle1";
static NSString *const SBStyle2 = @"SBStyle2";

@interface ViewController ()<UITextViewDelegate,UITextFieldDelegate>
{
    UILabel *lblPlaceholder;
    UIView *BGView;
    UIActivityIndicatorView *activity;
    NSTimer *timer;
    bool isShow;
    BOOL isOn;
    BOOL isConnect;
    BOOL isAnimating;
    
    int count;
    NSString *status;
    NSMutableDictionary *dicAccess;
    
    CGFloat progress;
    
    UIImageView *imgView;
    
    UIButton *btnTest;
    
    MBProgressHUD *hudView;
    //NSDate *date;
    UILabel *lblInstantSpeed;
    UILabel *lblPeakSpeed;
}

@end

@implementation ViewController

//@synthesize earthquakeList;

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [CTB setViewBounds:self];
    [CTB setNavigationBarBackground:@"section2" to:self];
    self.view.backgroundColor = [CTB colorWithHexString:@"#E5E5E5"];
}

-(void)loadView
{
    [super loadView];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"叶子大"] style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initCapacity];
	// Do any additional setup after loading the view, typically from a nib.
}

-(void)initCapacity
{
    self.navigationItem.leftBarButtonItem = [CTB BarButtonWithTitle:@"退出" target:self tag:1];
    self.navigationItem.rightBarButtonItem = [CTB BarButtonWithTitle:@"更多" target:self tag:2];
    dicAccess = [NSMutableDictionary dictionary];
    
    btnTest = [CTB buttonType:UIButtonTypeCustom delegate:self to:self.view tag:3 title:@"" img:@""];
    btnTest.frame = GetRect(0, 0, 22.5, 22.5);
    //[btnTest setImage:[UIImage imageNamed:@"底部表情"] forState:UIControlStateNormal];
    [btnTest setBackgroundImage:[UIImage imageNamed:@"底部表情"] forState:UIControlStateNormal];
    btnTest.center = CGPointMake(Screen_Width/2, 200);
    [self.view addSubview:btnTest];
    
    self.title = @"哈哈";
}

-(void)PrintWord
{
    NSLog(@"按钮事件");
}

-(void)PrintResult:(NSString *)result
{
    NSLog(@"ViewController,result = %@",result);
}

#pragma mark - ========ButtonEvents========================
-(void)ButtonEvents:(UIButton *)button
{
    if (button.tag==1) {
        [CTB alertWithMessage:@"你确定要退出吗" Delegate:self tag:1];
    }
    if (button.tag==2) {
        
        //[self.view bringSubviewToFront:ViewBlue];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请选择设备" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"门禁", @"主机", nil];
        alert.tag = 2;
        [alert show];
    }
    if (button.tag == 3) {
        //NSString *urlString = @"http://dldir1.qq.com/qqfile/qq/QQ2013/QQ2013SP5/9050/QQ2013SP5.exe";
        //HTTPRequest *request = [[HTTPRequest alloc] initWithDelegate:self];
        //[request run:urlString body:nil];
        //[request start];
        
        //BackRequest *backRequest = [[BackRequest alloc] init];
        //[backRequest backgroundTask];
        
        NSString *result = CTSettingCopyMyPhoneNumber();
        NSLog(@"result = %@",result);
    }
}

- (void)wsOK:(HTTPRequest *)iWS
{
    if ([iWS.method isEqualToString:@"fileDownload"]) {
        NSLog(@"下载成功");
        NSData *imageData = iWS.responseData;
        NSString *path = @"/Users/Yin-Mac/Desktop/Chaches/test1.jpg";
        if ([NSFileManager fileExistsAtPath:path]) {
            if (![NSFileManager removeItemAtPath:path]) {
                NSLog(@"删除文件失败");
            }
        }
        [imageData writeToFile:path atomically:YES];
    }
}

- (void)wsFailed:(HTTPRequest *)iWS
{
    NSLog(@"请求失败");
}

- (void)clearCacheSuccess
{
    NSLog(@"清理成功");
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *btnTitle = [alertView buttonTitleAtIndex:buttonIndex];
    if (alertView.tag == 1) {
        if ([btnTitle isEqualToString:@"确定"]) {
            exit(1);
        }else{
            //[imgView startAnimating];
            //UIDevice* device = [UIDevice currentDevice];
            //BOOL backgroundSupported = NO;
            //if ([device respondsToSelector:@selector(isMultitaskingSupported)]) {
            //    backgroundSupported = device.multitaskingSupported;
            //}
            
//            NSArray *listContacts = [AddressBook getDataFromAddressBook];
//            
//            if (listContacts.count > 1000) {
//                [AddressBook deleteContactsWithPartName:@"测试"];
//            }else{
//                [self addContacts];
//            }
        }
    }
    else if (alertView.tag == 2) {
        UIViewController *Second = [CTB getControllerWithIdentity:@"Second" storyboard:nil];
        self.hidesBottomBarWhenPushed = YES;
        if ([btnTitle isEqualToString:@"门禁"]) {
            [Second setValue:@(1) forKey:@"tag"];
            [self.navigationController pushViewController:Second animated:YES];
            self.hidesBottomBarWhenPushed = NO;
        }
        else if ([btnTitle isEqualToString:@"主机"]) {
            [Second setValue:@(2) forKey:@"tag"];
            [self.navigationController pushViewController:Second animated:YES];
            self.hidesBottomBarWhenPushed = NO;
        }
    }
}

-(void)addContacts
{
    ABAddressBookRef addressBook = [AddressBook getAddressBookRef];
    for (int i=0; i<1000; i++) {
        NSString *name = [NSString stringWithFormat:@"测试%d号",i+1];
        NSString *mobile = [NSString stringWithFormat:@"13213038%03d",i];
        NSDictionary *dicMobile = @{@"iphone":mobile,@"home":@"123"};
        ABRecordRef person = [AddressBook AddContactsWithFirstName:name lastName:@"" mobile:dicMobile nickname:@"嘿嘿" birthday:[NSDate date]];
        [AddressBook AddContactsWithPerson:person to:addressBook];
    }
    
    // 保存通讯录数据
    ABAddressBookSave(addressBook, NULL);
    // 释放通讯录对象的引用
    if (addressBook) {
        CFRelease(addressBook);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

@end
