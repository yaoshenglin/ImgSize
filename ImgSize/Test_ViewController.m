//
//  Test_ViewController.m
//  ImgSize
//
//  Created by Yin on 14-7-11.
//  Copyright (c) 2014年 caidan. All rights reserved.
//

#import "Test_ViewController.h"
#import "CTB.h"
#import "Tools.h"
#import "Access.h"
#import "MBProgressHUD.h"
#import "AsyncSocket.h"

@interface Test_ViewController ()
{
    UILabel *myLabel;
    BOOL isFirstAppear;
    NSTimeInterval TimeOut_Never;
    NSString *SN;
    NSString *PWD;
    
    AsyncSocket *tcpSocket;
    MBProgressHUD *hudView;
    
}

@end

@implementation Test_ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (isFirstAppear) {
        isFirstAppear = NO;
        [self initCapacity];
        [CTB setViewBounds:self];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    isFirstAppear = YES;
    // Do any additional setup after loading the view.
}

-(void)initCapacity
{
    self.navigationItem.rightBarButtonItem = [CTB BarButtonWithTitle:@"开门" target:self tag:1];
    TimeOut_Never = -1;
    SN = @"KF-9040T43060016";
    PWD = @"FFFFFFFF";
    NSString *host = @"192.168.11.244";
    if (_dicAccess) {
        SN = _dicAccess[@"SN"];
        PWD = _dicAccess[@"PWD"];
        host = _dicAccess[@"IP"];
    }
    tcpSocket = [[AsyncSocket alloc] initWithDelegate:self];
    NSError *error = nil;
    [tcpSocket connectToHost:host onPort:8000 error:&error];
    [tcpSocket readDataWithTimeout:-1 tag:8];
    if (error) {
        NSLog(@"连接BUG,%@",error.localizedDescription);
    }
    
    myLabel = [CTB labelTag:1 toView:self.view text:@"" wordSize:17];
    myLabel.frame = GetRect(30, 70, Screen_Width-60, 30);
}

-(void)buttonAction
{
    hudView = [MBProgressHUD showRuningView:self.view];
    NSString *msg = @"010E00D1";
    NSString *control = [Tools makeControl:@"010E00" dataLen:0 value:nil];
    NSData *buffer = [Tools makeDoorCommandWith:SN pwd:PWD msg:msg control:control];
    [tcpSocket writeData:buffer withTimeout:-1 tag:8];
}

- (void)showMsg:(NSString *)msg
{
    myLabel.text = msg;
}

#pragma mark 当socket连接正准备读和写的时候调用
/**
 * host属性是一个IP地址，而不是一个DNS 名称
 **/
- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    NSLog(@"TcpSocket 已连接！ %@:%hu", host, port);
    [self showMsg:@"已连接"];
}

#pragma mark 当一个socket已完成请求数据的写入时候调用
- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    NSLog(@"TcpSocket 发送数据成功");
    [self showMsg:@"发送数据成功"];
}

#pragma mark 当socket已完成所要求的数据读入内存时调用，如果有错误则不调用
- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    if (!data) {
        NSLog(@"TcpSocket 数据接收失败！");
        [self showMsg:@"数据接收失败"];
        return;
    }
    
    NSLog(@"TcpSocket 接收到的数据: %@",data);
    [self onSocket:sock parseResult:data];
    
    [sock readDataWithTimeout:TimeOut_Never tag:tag];
    
    [self showMsg:[@"接收到的数据" AppendString:data.description]];
}

#pragma mark 发生错误，socket关闭
- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
    NSLog(@"TcpSocket 连接失败! 错误信息：%@",[err localizedDescription]);
    [self showMsg:@"连接失败"];
}

#pragma mark 当socket由于或没有错误而断开连接
/**
 * 如果你想要在断开连接后release socket，在此方法工作，而在onSocket:willDisconnectWithError 释放则不安全
 **/
- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
    NSLog(@"TcpSocket 已断开连接");
    [self showMsg:@"已断开连接"];
}

#pragma mark 解析结果
- (void)onSocket:(AsyncSocket *)sock parseResult:(NSData *)data
{
    NSString *err = nil;
    BOOL flag = NO;
    Access *door = [[Access alloc] init];
    [door parseData:data];
    if (door.type == 0x21) {
        //预定义
        if (door.commond == 0x01)
            // 正确
            flag = YES;
        else if (door.commond == 0x02) {
            // 密码错
            flag = NO;
            err = @"密码错误！";
        } else if (door.commond == 0x03) {
            // 校验错
            flag = NO;
            err = @"校验失败！";
        }else{
            err = @"操作失败";
        }
        
        if (flag) {
            NSString *result = door.msg;
            for (int i=0; i<4; i++) {
                NSString *doorMsg = [NSString format:@"030300D%d",i+1];
                if ([result isEqualToString:doorMsg]) {
                    NSLog(@"开门状态：门%d打开成功!",i+1);
                }
            }
            
            [hudView hide:YES];
            
        }else{
            //NSLog(@"开门状态：错误信息：%@",err);
            [hudView showDetailMsg:err delay:1.8f yOffset:100];
        }
    }
    else if (door.type == 0x31) {
        //门状态
        NSLog(@"读取状态 : %@",data);
        
        if (door.status[0] == 0x01) {
            NSLog(@"门1打开成功");
        }
        
        [hudView hide:YES];
    }
    else{
        [hudView hide:YES];
        NSLog(@"parseResult : %@",data);
    }
}

#pragma mark - --------ButtonEvents------------------------
- (void)ButtonEvents:(UIButton *)button
{
    if (button.tag == 1) {
        [self buttonAction];
    }
    if (button.tag == 2) {
        UIViewController *Second = self.navigationController.viewControllers[1];
        [self.navigationController popToViewController:Second animated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (![CTB isExistSelf:self]) {
        [tcpSocket disconnect];
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
