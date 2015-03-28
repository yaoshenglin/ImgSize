//
//  GesturePasswordController.m
//  GesturePassword
//
//  Created by hb on 14-8-23.
//  Copyright (c) 2014年 黑と白の印记. All rights reserved.
//

#import <Security/Security.h>
#import <CoreFoundation/CoreFoundation.h>

#import "GesturePasswordController.h"


#import "KeychainItemWrapper/KeychainItemWrapper.h"

@interface GesturePasswordController ()

@property (nonatomic,strong) GesturePasswordView * gesturePasswordView;

@end

@implementation GesturePasswordController
{
    NSString * previousString;
    NSString * password;
}

@synthesize gesturePasswordView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    previousString = [NSString string];
    KeychainItemWrapper *keychin = [[KeychainItemWrapper alloc] initWithIdentifier:@"Gesture" accessGroup:nil];
    password = [keychin objectForKey:(__bridge id)kSecValueData];
    if ([password isEqualToString:@""]) {
        
        [self reset];
    }
    else {
        [self verify];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - 验证手势密码
- (void)verify
{
    gesturePasswordView = [[GesturePasswordView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    gesturePasswordView.tentacleView.rerificationDelegate = self;
    gesturePasswordView.tentacleView.style = Style_Verify;
    gesturePasswordView.gesturePasswordDelegate = self;
    [self.view addSubview:gesturePasswordView];
}

#pragma mark - 重置手势密码
- (void)reset
{
    gesturePasswordView = [[GesturePasswordView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    gesturePasswordView.tentacleView.resetDelegate = self;
    gesturePasswordView.tentacleView.style = Style_Reset;
    //gesturePasswordView.imgView.hidden = YES;
    gesturePasswordView.forgetButton.hidden = YES;
    gesturePasswordView.changeButton.hidden = YES;
    [self.view addSubview:gesturePasswordView];
}

#pragma mark - 判断是否已存在手势密码
- (BOOL)exist
{
    KeychainItemWrapper * keychin = [[KeychainItemWrapper alloc]initWithIdentifier:@"Gesture" accessGroup:nil];
    password = [keychin objectForKey:(__bridge id)kSecValueData];
    BOOL result = ![password isEqualToString:@""];
    return result;
}

#pragma mark - 清空记录
- (void)clear
{
    KeychainItemWrapper * keychin = [[KeychainItemWrapper alloc]initWithIdentifier:@"Gesture" accessGroup:nil];
    [keychin resetKeychainItem];
}

#pragma mark - 改变手势密码
- (void)change
{
    NSLog(@"改变手势密码");
}

#pragma mark - 忘记手势密码
- (void)forget
{
    NSLog(@"忘记手势密码");
}

- (BOOL)verification:(NSString *)result
{
    if ([result isEqualToString:password]) {
        [gesturePasswordView.status setTextColor:[UIColor colorWithRed:2/255.f green:174/255.f blue:240/255.f alpha:1]];
        [gesturePasswordView.status setText:@"输入正确"];
        //[self presentViewController:(UIViewController) animated:YES completion:nil];
        return YES;
    }
    [gesturePasswordView.status setTextColor:[UIColor redColor]];
    [gesturePasswordView.status setText:@"手势密码错误"];
    return NO;
}

- (BOOL)resetPassword:(NSString *)result
{
    if ([previousString isEqualToString:@""]) {
        previousString=result;
        [gesturePasswordView.tentacleView enterArgin];
        [gesturePasswordView.status setTextColor:[UIColor colorWithRed:2/255.f green:174/255.f blue:240/255.f alpha:1]];
        [gesturePasswordView.status setText:@"请验证输入密码"];
        return YES;
    }
    else {
        if ([result isEqualToString:previousString]) {
            KeychainItemWrapper * keychin = [[KeychainItemWrapper alloc]initWithIdentifier:@"Gesture" accessGroup:nil];
            [keychin setObject:@"<帐号>" forKey:(__bridge id)kSecAttrAccount];
            [keychin setObject:result forKey:(__bridge id)kSecValueData];
            //[self presentViewController:(UIViewController) animated:YES completion:nil];
            [gesturePasswordView.status setTextColor:[UIColor colorWithRed:2/255.f green:174/255.f blue:240/255.f alpha:1]];
            [gesturePasswordView.status setText:@"已保存手势密码"];
            return YES;
        }
        else{
            previousString = @"";
            [gesturePasswordView.status setTextColor:[UIColor redColor]];
            [gesturePasswordView.status setText:@"两次密码不一致，请重新输入"];
            return NO;
        }
    }
}




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
