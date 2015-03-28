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
#import "AddressBook.h"

static NSString *const JDButtonName = @"JDButtonName";
static NSString *const JDButtonInfo = @"JDButtonInfo";
static NSString *const JDNotificationText = @"JDNotificationText";

static NSString *const SBStyle1 = @"SBStyle1";
static NSString *const SBStyle2 = @"SBStyle2";

@interface ViewController ()<CTBDelegate,UITextViewDelegate,UITextFieldDelegate>
{
    UILabel *lblPlaceholder;
    UIView *BGView;
    UIActivityIndicatorView *activity;
    NSTimer *timer;
    bool isShow;
    
    int count;
    NSString *status;
    
    CGFloat progress;
    
    UIImageView *imgView;
    
    UIButton *btnTest;
    
    MBProgressHUD *hudView;
    NSDate *date;
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
    
    btnTest = [CTB buttonType:UIButtonTypeCustom delegate:self to:self.view tag:3 title:@"" img:@""];
    btnTest.frame = GetRect(0, 0, 22.5, 22.5);
    [btnTest setImage:[UIImage imageNamed:@"底部表情"] forState:UIControlStateNormal];
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
        
        UIViewController *Second = [CTB getControllerWithIdentity:@"Second" storyboard:nil];
        self.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:Second animated:YES];
        //[self presentViewController:Second animated:YES completion:nil];
        self.hidesBottomBarWhenPushed = NO;
        
        [CTB getLocalIPAddress:^(NSDictionary *dicIP){
            NSArray *list = dicIP.allKeys;
            
            NSMutableArray *listResult = [NSMutableArray array];
            
            for (NSString *key in list) {
                NSString *result = [NSString stringWithFormat:@"%@ : %@",key,dicIP[key]];
                [listResult addObject:result];
            }
            
            if ([Second respondsToSelector:select(addDataFrom:)]) {
                [(id)Second addDataFrom:listResult];
            }
        }];
    }
    if (button.tag == 3) {
        
        //[self PasswordButton];
        //return;
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *btnTitle = [alertView buttonTitleAtIndex:buttonIndex];
    if ([alertView.title isEqualToString:@"提示"]) {
        if ([btnTitle isEqualToString:@"OK"]) {
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

@end
