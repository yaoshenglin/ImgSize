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
#import <sys/socket.h>
#import <netdb.h>
#import <QuartzCore/QuartzCore.h>
#import <ImageIO/ImageIO.h>


extern NSString *CTSettingCopyMyPhoneNumber(void);

static NSString *const JDButtonName = @"JDButtonName";
static NSString *const JDButtonInfo = @"JDButtonInfo";
static NSString *const JDNotificationText = @"JDNotificationText";

static NSString *const SBStyle1 = @"SBStyle1";
static NSString *const SBStyle2 = @"SBStyle2";

@interface ViewController ()<UITextViewDelegate,UITextFieldDelegate,UIDynamicAnimatorDelegate>
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
    
    UIView *baseView;
    UIImageView *gameView;
    UIDynamicAnimator *_animator;
}

@property (assign, nonatomic) CGSize size;

@end

@implementation ViewController

//static const CGSize BASE_SIZE = { 180, 20 };
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
    
    [self createUI];
}

- (void)createUI
{
    baseView = [[UIView alloc] initWithFrame:GetRect(20, 10, Screen_Width-40, 350)];
    baseView.backgroundColor = [[UIColor greenColor] colorWithAlpha:0.1];
    baseView.userInteractionEnabled = NO;
    [self.view addSubview:baseView];
    
    UIImage *image = [UIImage imageNamed:@"叶子大"];
    gameView = [[UIImageView alloc] initWithImage:image];
    [baseView addSubview:gameView];
    gameView.clipsToBounds = YES;
    gameView.layer.cornerRadius = GetVWidth(gameView)/2;
    gameView.center = GetPoint(GetVWidth(baseView)/2, GetVHeight(gameView)/2);
    
    _animator = [[UIDynamicAnimator alloc] initWithReferenceView:baseView];
    _animator.delegate = self;
}

- (void)PrintWord
{
    NSLog(@"按钮事件");
}

- (void)PrintResult:(NSString *)result
{
    NSLog(@"ViewController,result = %@",result);
}

//推动行为
//- (UIPushBehavior *)push
//{
//    if (!_push) {
//        _push = [[UIPushBehavior alloc]init];
//        [_push setAngle:1.57 magnitude:0.1];
//    }
//    
//    return _push;
//}

#pragma mark - ========ButtonEvents========================
-(void)ButtonEvents:(UIButton *)button
{
    if (button.tag==1) {
        [CTB alertWithMessage:@"你确定要退出吗" Delegate:self tag:1];
    }
    if (button.tag==2) {
        
        //[self.view bringSubviewToFront:ViewBlue];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请选择设备" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"门禁", @"主机",@"系统设置", nil];
        alert.tag = 2;
        [alert show];
    }
    if (button.tag == 3) {
        //NSString *urlString = @"http://dldir1.qq.com/qqfile/qq/QQ2013/QQ2013SP5/9050/QQ2013SP5.exe";
        //HTTPRequest *request = [[HTTPRequest alloc] initWithDelegate:self];
        //[request run:urlString body:nil];
        //[request start];
        
        UIGravityBehavior *gravityBeahvior = [[UIGravityBehavior alloc] init];
        gravityBeahvior.magnitude = 0.3;
        [gravityBeahvior addItem:gameView];//重力行为
        UICollisionBehavior *collider = [[UICollisionBehavior alloc] init];
        collider.translatesReferenceBoundsIntoBoundary = YES;
        collider.collisionMode = UICollisionBehaviorModeBoundaries;
        [collider addItem:gameView];//碰撞行为
//        UIPushBehavior *push = [[UIPushBehavior alloc]init];
//        [push setAngle:0 magnitude:0.1];
//        [push addItem:gameView];//推动行为
        CGPoint frogCenter = GetPoint(gameView.center.x, GetVHeight(baseView)-120);
        UIAttachmentBehavior *attach = [[UIAttachmentBehavior alloc] initWithItem:gameView attachedToAnchor:frogCenter];//弹性行为
        attach.frequency = 0.3;
        attach.damping = 0.1;
        attach.length = 10.0;
        gameView.transform = CGAffineTransformRotate(gameView.transform, 45);
        [_animator addBehavior:gravityBeahvior];
        [_animator addBehavior:collider];
//        [_animator addBehavior:attach];
//        [_animator addBehavior:push];
        
        [self playGifImg];
    }
}

- (void)playGifImg
{
    NSString *imagePath =[[NSBundle mainBundle] pathForResource:@"灯闪动画" ofType:@"gif"];
    CGImageSourceRef cImageSource = CGImageSourceCreateWithURL((__bridge CFURLRef)[NSURL fileURLWithPath:imagePath], NULL);
    size_t imageCount = CGImageSourceGetCount(cImageSource);//
    NSMutableArray *images = [NSMutableArray array];
    NSMutableArray *times = [NSMutableArray array];
    NSMutableArray *keyTimes = [NSMutableArray array];
    
    float totalTime = 0;
    for (size_t i = 0; i < imageCount; i++) {
        CGImageRef cgimage = CGImageSourceCreateImageAtIndex(cImageSource, i, NULL);
        [images addObject:(__bridge id)cgimage];
        CGImageRelease(cgimage);
        
        NSDictionary *properties = (__bridge NSDictionary *)CGImageSourceCopyPropertiesAtIndex(cImageSource, i, NULL);
        NSDictionary *gifProperties = [properties valueForKey:(__bridge NSString *)kCGImagePropertyGIFDictionary];
        NSString *gifDelayTime = [gifProperties valueForKey:(__bridge NSString* )kCGImagePropertyGIFDelayTime];
        [times addObject:gifDelayTime];
        totalTime += [gifDelayTime floatValue];
        
        _size.width = [[properties valueForKey:(NSString*)kCGImagePropertyPixelWidth] floatValue];
        _size.height = [[properties valueForKey:(NSString*)kCGImagePropertyPixelHeight] floatValue];
    }
    
    float currentTime = 0;
    for (size_t i = 0; i < times.count; i++) {
        float keyTime = currentTime / totalTime;
        [keyTimes addObject:[NSNumber numberWithFloat:keyTime]];
        currentTime += [[times objectAtIndex:i] floatValue];
    }
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"contents"];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
    [animation setValues:images];
    [animation setKeyTimes:keyTimes];
    animation.duration = totalTime;
    animation.repeatCount = HUGE_VALF;
    [baseView.layer addAnimation:animation forKey:@"gifAnimation"];
}

- (void)dynamicAnimatorWillResume:(UIDynamicAnimator*)animator
{
    btnTest.enabled = NO;
}

- (void)dynamicAnimatorDidPause:(UIDynamicAnimator*)animator
{
    [animator removeAllBehaviors];
    gameView.center = GetPoint(GetVWidth(baseView)/2, GetVHeight(gameView)/2);
    gameView.transform = CGAffineTransformRotate(gameView.transform, 0);
    btnTest.enabled = YES;
}

- (void)performLongRunningTaskForIteration:(id)iteration
{
    NSNumber *item = iteration;
    NSMutableArray *list = [@[] mutableCopy];
    
    for (int i=0; i<10; i++) {
        NSString *str = [NSString format:@"Item %@-%d",item,i];
        [list addObject:str];
        
        [NSThread sleep:.1];
        
        NSLog(@"Background Added %@-%d",item,i);
    }
}

- (void)socketCommunication
{
    NSURL *url = [NSURL URLWithString:@"http://121.201.17.130:8100/api_V2/GetLastVersions"];
    NSThread * backgroundThread = [[NSThread alloc] initWithTarget:self
                                                          selector:@selector(loadDataFromServerWithURL:)
                                                            object:url];
    [backgroundThread start];
    
    [self performSelector:select(loadAndReturnError:) withObject:nil];
}

- (void)loadDataFromServerWithURL:(NSURL *)url
{
    NSString * host = [url host];
    NSNumber * port = [url port];
    
    // Create socket
    //
    int socketFileDescriptor = socket(AF_INET, SOCK_STREAM, 0);
    if (-1 == socketFileDescriptor) {
        NSLog(@"Failed to create socket.");
        return;
    }
    
    // Get IP address from host
    //
    struct hostent * remoteHostEnt = gethostbyname([host UTF8String]);
    if (NULL == remoteHostEnt) {
        close(socketFileDescriptor);
        
        [self networkFailedWithErrorMessage:@"Unable to resolve the hostname of the warehouse server."];
        return;
    }
    
    struct in_addr * remoteInAddr = (struct in_addr *)remoteHostEnt->h_addr_list[0];
    
    // Set the socket parameters
    //
    struct sockaddr_in socketParameters;
    socketParameters.sin_family = AF_INET;
    socketParameters.sin_addr = *remoteInAddr;
    socketParameters.sin_port = htons([port intValue]);
    
    // Connect the socket
    //
    int ret = connect(socketFileDescriptor, (struct sockaddr *) &socketParameters, sizeof(socketParameters));
    if (-1 == ret) {
        close(socketFileDescriptor);
        
        NSString * errorInfo = [NSString stringWithFormat:@" >> Failed to connect to %@:%@", host, port];
        [self networkFailedWithErrorMessage:errorInfo];
        return;
    }
    
    NSLog(@" >> Successfully connected to %@:%@", host, port);
    
    NSMutableData * data = [[NSMutableData alloc] init];
    BOOL waitingForData = YES;
    
    NSError *error = nil;
    NSDictionary *body = @{@"deviceType":@(4),
                           @"appVer":@(6),
                           @"hwName":@"iFace SP1",
                           @"hwVer":@(1)};
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:body options:NSJSONWritingPrettyPrinted error: &error];
    int value = send(socketFileDescriptor, [jsonData bytes], jsonData.length, 0);
    if (value < 0) {
        NSLog(@"发送数据失败");
    }
    
    // Continually receive data until we reach the end of the data
    //
    int maxCount = 5;   // just for test.
    int i = 0;
    while (waitingForData && i < maxCount) {
        const char * buffer[1024];
        int length = sizeof(buffer);
        
        // Read a buffer's amount of data from the socket; the number of bytes read is returned
        //
        int result = recv(socketFileDescriptor, &buffer, length, 0);
        if (result > 0) {
            [data appendBytes:buffer length:result];
        }
        else {
            // if we didn't get any data, stop the receive loop
            //
            waitingForData = NO;
        }
        
        ++i;
    }
    
    // Close the socket
    //
    close(socketFileDescriptor);
    
    [self networkSucceedWithData:data];
}

- (void)networkFailedWithErrorMessage:(NSString *)message
{
    // Update UI
    //
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        NSLog(@"%@", message);
    }];
}

- (void)networkSucceedWithData:(NSData *)data
{
    // Update UI
    //
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        NSString * resultsString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@" >> Received string: '%@'", resultsString);
    }];
}

#pragma mark - --------WSDelegate------------------------
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

#pragma mark - --------alertView------------------------
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
        }
        else if ([btnTitle isEqualToString:@"主机"]) {
            [Second setValue:@(2) forKey:@"tag"];
            [self.navigationController pushViewController:Second animated:YES];
        }
        else if ([btnTitle isEqualToString:@"系统设置"]) {
            [Second setValue:@(3) forKey:@"tag"];
            [self.navigationController pushViewController:Second animated:YES];
        }
        self.hidesBottomBarWhenPushed = NO;
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
