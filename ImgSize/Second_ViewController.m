//
//  Second_ViewController.m
//  ImgSize
//
//  Created by Yin on 14-5-20.
//  Copyright (c) 2014年 caidan. All rights reserved.
//

#import "Second_ViewController.h"
#import "CTB.h"
#import "Tools.h"
#import "MBProgressHUD.h"
#import "UdpSocket.h"
#import "Access.h"
#import "Toast+UIView.h"

@interface Second_ViewController ()<UITextFieldDelegate,UIActionSheetDelegate,UITableViewDataSource,UITableViewDelegate,MBProgressHUDDelegate>
{
    BOOL isFirstAppear;
    BOOL isStop;
    int Type;
    
    NSMutableArray *listData;
    
    UIButton *btnDelete;
    UITextField *txtPassword;
    UITableView *myTableView;
    
    MBProgressHUD *hudView;
    UdpSocket *udpSocket;
}

@end

@implementation Second_ViewController

@synthesize myScrollView;
@synthesize myImageView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"叶子大"] style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [CTB setViewBounds:self];
    self.view.backgroundColor = [CTB colorWithHexString:@"#E5E5E5"];
    
    if (isFirstAppear) {
        isFirstAppear = NO;
    }
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initCapacity];
    isFirstAppear = YES;
    self.hidesBottomBarWhenPushed = YES;
    // Do any additional setup after loading the view.
}

- (void)initCapacity
{
    self.navigationItem.rightBarButtonItem = [CTB BarButtonWithTitle:@"相册" target:self tag:1];
    
    listData = [NSMutableArray array];
    
    myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, Screen_Height-64) style:UITableViewStyleGrouped];
    myTableView.dataSource = self;
    myTableView.delegate = self;
    [self.view addSubview:myTableView];
    
    Type = _tag;
    udpSocket = [[UdpSocket alloc] init];
    udpSocket.delegate = self;
    if (Type == 1) {
        [self searchAccessDevice];
    }
    else if (Type == 2) {
        [self searchHostDevice];
    }
    else if (Type == 3) {
        [self getHeadList];
        [myTableView reloadData];
    }
}

- (void)searchAccessDevice
{
    [udpSocket enableBroadcast:YES port:8101];
    [self duration:0.3 action:select(getDoorList)];
}

- (void)searchHostDevice
{
    [udpSocket enableBroadcast:YES port:8003];
    [listData removeAllObjects];
    [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:select(getHostList:) userInfo:nil repeats:NO];
}

- (void)getDoorList
{
    [listData removeAllObjects];
    
    NSString *SN = @"FF-FFFFFFFFFFFFF";
    NSString *PWD = @"FFFFFFFF";
    NSString *msg = @"030300D1";//开门
    NSString *value = [CTB getRandomByString:@"123456789ABCDEF" Length:4];//网络标识
    NSString *control = [Tools makeControl:@"01FE00" dataLen:2 value:value];
    NSData *buffer = [Tools makeDoorCommandWith:SN pwd:PWD msg:msg control:control];
    
    udpSocket.port = 8101;
    [udpSocket sendData:buffer];
    [udpSocket receiveWithTimeout:20.0 tag:0];
}

- (void)getHostList:(NSTimer *)timer
{
    if (isStop) {
        [timer invalidate];
        return;
    }
    NSString *host_mac = @"FFFFFFFFFFFF";
    NSData *data = [[NSString stringWithFormat:@"A6%@00000000",host_mac] dataByHexString];
    data = [Tools replaceCRCForSwitch:data];
    
    udpSocket.port = 8003;
    [udpSocket sendData:data];
    [udpSocket receiveWithTimeout:20.0 tag:0];
}

- (void)getHeadList
{
    NSArray *list = @[@"General&path=About",
                      @"General&path=ACCESSIBILITY",
                      @"AIRPLANE_MODE",
                      @"General&path=AUTOLOCK",
                      @"General&path=USAGE/CELLULAR_USAGE",
                      @"Brightness",
                      @"Bluetooth",
                      @"General&path=DATE_AND_TIME",
                      @"FACETIME",
                      @"General",
                      @"General&path=Keyboard",
                      @"CASTLE",
                      @"CASTLE&path=STORAGE_AND_BACKUP",
                      @"General&path=INTERNATIONAL",
                      @"LOCATION_SERVICES",
                      @"ACCOUNT_SETTINGS",
                      @"MUSIC",
                      @"MUSIC&path=EQ",
                      @"MUSIC&path=VolumeLimit",
                      @"General&path=Network",
                      @"NIKE_PLUS_IPOD",
                      @"NOTES",
                      @"NOTIFICATIONS_ID",
                      @"Phone",
                      @"Photos",
                      @"General&path=ManagedConfigurationList",
                      @"General&path=Reset",
                      @"Sounds&path=Ringtone",
                      @"Safari",
                      @"General&path=Assistant",
                      @"Sounds",
                      @"General&path=SOFTWARE_UPDATE_LINK",
                      @"STORE",
                      @"TWITTER",
                      @"General&path=USAGE",
                      @"VIDEO",
                      @"General&path=Network/VPN",
                      @"Wallpaper",
                      @"WIFI",
                      @"INTERNET_TETHERING"];
    listData.array = list;
}

- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data withTag:(long)tag fromHost:(NSString *)host port:(UInt16)port
{
    [sock receiveWithTimeout:-1 tag:tag];
    if ([host hasPrefix:@"::ffff:"]) {
        return NO;
    }
    
    if (Type == 1 && data.length < 28) {
        //门禁
        return NO;
    }
    else if (Type == 2 && data.length < 12) {
        //主机
        return NO;
    }
    
    if (Type == 1) {
        NSString *lenString = [data stringWithRange:NSMakeRange(25, 3)];
        if (![lenString isEqualToString:@"31FE00"]) {
            //如果不是读取门禁IP信息
            return NO;
        }
    }
    else if (Type == 2) {
        Byte *data_bytes = (Byte*)[data bytes];
        Byte data_byte = data_bytes[0];
        if (data_byte == 0xE6) {
            NSString *hexStr = [data hexString];
            NSString *host_mac = [hexStr substringWithRange:NSMakeRange(2, 12)];
            if (![host_mac isEqualToString:@"FFFFFFFFFFFF"]) {
                NSDictionary *dic = @{@"SN":host_mac,
                                      @"PWD":@"",
                                      @"IP":host,
                                      @"Port":@(port)};
                NSString *result = [dic convertToString];
                if (![listData containsObject:result]) {
                    [listData addObject:result];
                    [myTableView reloadData];
                }
            }
        }
        
        return NO;
    }
    
    Access *door = [[Access alloc] init];
    NSString *result = @"";
    long len = -1;
    BOOL isSuccess = YES;
    @try {
        [door parseData:data];
        NSData *value = [data subdataWithRange:NSMakeRange(59, 2)];
        NSString *lenString = [value hexString];
        len = strtoul([lenString UTF8String],nil,16);//TCP端口
        NSDictionary *dic = @{@"SN":door.SN,
                              @"PWD":door.PWD,
                              @"IP":host,
                              @"Port":@(len)};
        result = [dic convertToString];
        if (![listData containsObject:result]) {
            [listData addObject:result];
            [myTableView reloadData];
        }
    }
    @catch (NSException *exception) {
        isSuccess = NO;
        NSString *errMsg = [NSString format:@"IP信息解析失败,%@,%@,%@",host,exception.name,exception.reason];
        hudView = [MBProgressHUD showRuningView:self.view];
        [hudView showDetailMsg:errMsg delay:1.8f];
        NSLog(@"********************");
        NSLog(@"%@",errMsg);
    }
    @finally {
        if (isSuccess) {
            NSLog(@"--------------");
            NSLog(@"%@",result);
        }
    }
    return YES;
}

#pragma mark - ======tableView========================
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger row_Count = listData.count;
    
    return row_Count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identify = [NSString stringWithFormat:@"%d/%d",(int)indexPath.section,(int)indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
    }
    
    NSString *msg = @"";
    if (Type != 3) {
        NSDictionary *dic = [listData[indexPath.row] convertToDic];
        msg = [NSString format:@"SN:%@,PWD:%@,IP:%@,Port:%@",dic[@"SN"],dic[@"PWD"],dic[@"IP"],dic[@"Port"]];
    }
    else if (Type == 3) {
        msg = listData[indexPath.row];
    }
    cell.textLabel.text = msg;
    cell.textLabel.font = [UIFont systemFontOfSize:14.0];
    cell.textLabel.numberOfLines = 0;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *msg = listData[indexPath.row];
    [self.view makeToast:msg];
    
    if (Type == 1) {
        NSDictionary *dic = [msg convertToDic];
        NSString *host = dic[@"IP"] ?: @"";
        UInt16 port = [dic[@"Port"] intValue];
        [_tcpSocket connectToHost:host port:port];
        
        UIViewController *Test = getController(@"Test", nil);
        [Test setValue:dic forKey:@"dicAccess"];
        [self.navigationController pushViewController:Test animated:YES];
    }
    else if (Type == 2) {
        
    }
    else if (Type == 3) {
        NSString *head = @"prefs:root=";
        NSString *content = listData[indexPath.row];
        NSString *urlStr = [head AppendString:content];
        NSURL *url = [NSURL URLWithString:urlStr];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
        }
    }
}

- (void)test:(NSString *)aString with:(NSString *)bString
{
    NSLog(@"a = %@,b = %@",aString,bString);
    if ([bString isKindOfClass:[NSTimer class]]) {
        NSTimer *timer = (NSTimer *)bString;
        if ([timer isValid]) {
            [timer invalidate];
            NSLog(@"End");
        }
    }
}

- (void)showWord:(CGFloat)y
{
    NSString *msg = @"您好！您好！您好！您好！您好?您好?您好?您好?您好?您好?您好?您好?";
    [self.view makeToast:msg];
}

- (UILabel *)getLabelWith:(NSString *)msg
{
    UILabel *label = [[UILabel alloc] initWithFrame:GetRect(0, 0, 280, 80)];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:17];
    label.backgroundColor = [UIColor clearColor];
    label.text = @"您好！您好！您好！您好！您好?您好?您好?您好?您好?您好?您好?您好?";
    label.numberOfLines = 0;
    
    return label;
}

- (void)setScrollViewToHigh:(CGFloat)height
{
    //[CTB setAnimationWith:0.3 delegate:nil complete:nil];
    //[CTB setRectWith:myTableView toHeight:height];
    //[CTB commitAnimations];
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         
                     }
                     completion:^(BOOL finished) {
                         //动画完成,可为空
                         [myTableView setSizeToH:height];
                     }];
}

- (void)setScrollViewToPoint:(NSValue *)value
{
    CGPoint point;
    [value getValue:&point];
    [CTB setAnimationWith:myTableView Offset:point];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - ======ButtonEvents========================
- (void)ButtonEvents:(UIButton *)button
{
    if (button.tag==1) {
        
//        [listData removeAllObjects];
        [listData removeObjectAtIndex:0];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [myTableView deleteAtIndexPath:indexPath rowCount:0];
        
        //UIViewController *Third = [CTB getControllerWithIdentity:@"Third" storyboard:@"Main"];
        //[self.navigationController pushViewController:Third animated:YES];
        //[self.navigationController presentViewController:Third animated:YES completion:nil];
    }
    if (button.tag==2) {
        
    }
    if (button.tag==3) {
    }
    
    if (button.tag == 5) {
        NSLog(@"按钮事件");
    }
}

- (void)backPage
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)closeSocket
{
    [udpSocket closeSocket];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    NSArray *list = self.navigationController.childViewControllers;
    if (![list containsObject:self]) {
        //self.hidesBottomBarWhenPushed = NO;
        isStop = YES;
        [udpSocket closeCompletion:^{
            udpSocket = nil;
            NSLog(@"关闭UDP连接");
            [self.view makeToast:@"关闭UDP连接"];
        }];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
