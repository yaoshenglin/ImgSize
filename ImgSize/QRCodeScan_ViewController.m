//
//  QRCodeScan_ViewController.m
//  ScanQRCode
//
//  Created by Yin on 14-4-1.
//  Copyright © 2014年 caidan. All rights reserved.
//

#import "QRCodeScan_ViewController.h"
#import <UIKit/UIDevice.h>
#import "CTB.h"
#import "CustomDrawView.h"
#import "PhotoPreView.h"
#import "ZXingObjC.h"   //解析图片二维码

@interface QRCodeScan_ViewController ()<UIAlertViewDelegate>
{
    BOOL isDidShow;
    BOOL isFirstAppear;
    BOOL isPhoto;
    BOOL isOnLight;
}

@end

@implementation QRCodeScan_ViewController

@synthesize delegate;
@synthesize device,input,output,session,preview;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    isPhoto = NO;
    if (isFirstAppear) {
        isFirstAppear = NO;
        [self initCapacity];
    }
    
    if (isDidShow && session) {
        
        isCanScan = YES;
        [hudView show:YES];
        _line.hidden = YES;
        PaneImgView.hidden = YES;
        baseView.backgroundColor = [UIColor blackColor];
        [baseView changeFillColor:[UIColor blackColor]];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self enablePopGesture:NO];
    
    if (isDidShow && session) {
        [session performSelector:select(startRunning) withObject:nil afterDelay:0.1];
        [self performSelector:select(hiddenHudView) withObject:nil afterDelay:0.1];
    }
    
    if (![timer isValid]) {
        timer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(animation) userInfo:nil repeats:YES];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setIsCanScan:) name:@"Scan.isCanScan" object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //[self initCapacity];
    isFirstAppear = YES;
    if (iPhone >= 7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeSelfFromNav) name:@"Scan.removeScanVC" object:nil];
}

- (void)initCapacity
{
    self.title = @"扫描二维码";
#if TARGET_IPHONE_SIMULATOR
    //模拟器
    [self scanQRCodeWithZBar];
    [CTB duration:0.3 block:^{
        [self hiddenHudView];
        _line.hidden = YES;
    }];
#endif
    
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        isCanScan = NO;
        [CTB alertWithMessage:@"该设备不支持扫描功能" Delegate:nil tag:0];
        self.view.backgroundColor = [UIColor blackColor];
        UILabel *lblErrorExplain = [[UILabel alloc] initWithFrame:CGRectMake(0, 200, Screen_Width, 50)];
        lblErrorExplain.tag = 2;
        lblErrorExplain.text = @"该设备不支持扫描功能";
        lblErrorExplain.textColor = [UIColor whiteColor];
        lblErrorExplain.textAlignment = NSTextAlignmentCenter;
        lblErrorExplain.backgroundColor = [UIColor clearColor];
        [self.view addSubview:lblErrorExplain];
        return;
    }
    
    isCanScan = YES;
    [self scanQRCodeWithZBar];
    [self duration:0.1 action:select(setupCamera)];
    self.view.backgroundColor = [UIColor grayColor];
}

- (void)scanQRCodeWithZBar
{
    float scanrect_wh = Screen_Width-110;
    
    CGFloat y = Screen_Height > 480 ? 100 : 70;
    scanRect = CGRectMake(55, y, scanrect_wh, scanrect_wh);//扫描区域
    cameraRect = CGRectMake(0, 0, Screen_Width, viewH);//相机区域
    
    //文字说明
    UILabel *labIntroudction = [[UILabel alloc] initWithFrame:CGRectMake(15, scanRect.origin.y-60, Screen_Width-30, 50)];
    labIntroudction.tag = 1;
    labIntroudction.backgroundColor = [UIColor clearColor];
    labIntroudction.numberOfLines = 0;
    labIntroudction.font = [UIFont systemFontOfSize:13];
    labIntroudction.textColor = [UIColor whiteColor];
    labIntroudction.alpha = 0.5;
    labIntroudction.layer.cornerRadius = 5;
    labIntroudction.text = @"将取景框对准二维码\n即可进行扫描";
    labIntroudction.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:labIntroudction];
    
   
    //中间(二维码扫描区)透明周围半透明的视图
    baseView = [[CustomDrawView alloc] initWithFrame:cameraRect];
    baseView.lRect = scanRect;
    baseView.fillColor = [UIColor blackColor];
    baseView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:baseView];
    
    [self moreFunction];//下面部分
    
    PaneImgView = [[UIImageView alloc] initWithFrame:scanRect];//四个白色的角
    PaneImgView.image = [UIImage imageNamed:@"扫码框"];//绿色的角
    PaneImgView.userInteractionEnabled = YES;
    [self.view addSubview:PaneImgView];
    
    upOrdown = NO;
    num = 0;
    _line = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, scanRect.size.width, 2)];//绿色线条
    _line.image = [UIImage imageNamed:@"扫描条"];
    _line.userInteractionEnabled = YES;
    [PaneImgView addSubview:_line];
    
    hudView = [[MBProgressHUD alloc] initWithView:self.view];
    hudView.labelText = @"正在初始化摄像头...";
    [self.view insertSubview:hudView aboveSubview:PaneImgView];
    [hudView show:YES];
    
    _line.hidden = YES;
    PaneImgView.hidden = YES;
    
    timer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(animation) userInfo:nil repeats:YES];
}

- (void)moreFunction
{
    CGFloat h = 110.0f;
    UIView *bigV = [[UIView alloc] initWithFrame:GetRect(0, GetVHeight(baseView)-h, GetVWidth(baseView), h)];
    bigV.backgroundColor = [[UIColor grayColor] colorWithAlpha:0.3];
    [baseView addSubview:bigV];
    
    UIImage *image = [UIImage imageNamed:@"相册"];
    UIButton *btnPhoto = [CTB buttonType:UIButtonTypeCustom delegate:self to:bigV tag:2 title:@"" img:@"相册"];
    [btnPhoto setNormalBackgroundImage:image];
    btnPhoto.frame = GetRect(0, 5, 70, 70);
    btnPhoto.layer.cornerRadius = GetVWidth(btnPhoto)/2;
    [btnPhoto setCenterX:Screen_Width/3-10 Y:GetVHeight(bigV)/2-10];
    UILabel *lblPhoto = [CTB labelTag:1 toView:bigV text:@"相册" wordSize:-1];
    lblPhoto.frame = GetRect(GetVMinX(btnPhoto), GetVHeight(bigV)-25, GetVWidth(btnPhoto), 20);
    lblPhoto.textColor = [UIColor whiteColor];
    
    UIButton *btnLight = [CTB buttonType:UIButtonTypeCustom delegate:self to:bigV tag:3 title:@"" img:@"开灯"];
    btnLight.frame = GetRect(0, 5, 70, 70);
    btnLight.layer.cornerRadius = GetVWidth(btnLight)/2;
    [btnLight setCenterX:Screen_Width*2/3+10 Y:GetVHeight(bigV)/2-10];
    UILabel *lblLight = [CTB labelTag:1 toView:bigV text:@"开灯" wordSize:-1];
    lblLight.frame = GetRect(GetVMinX(btnLight), GetVHeight(bigV)-25, GetVWidth(btnLight), 20);
    lblLight.textColor = [UIColor whiteColor];
}

- (void)animation
{
    if (upOrdown == NO) {
        num ++;
        upOrdown = 2*num>=scanRect.size.height ? YES : upOrdown;
    }
    else {
        num --;
        upOrdown = num<=0 ? NO : upOrdown;
    }
    
    _line.frame = CGRectMake(15, 2*num, scanRect.size.width-30, 2);
    
}

- (void)backAction
{
    
    [self dismissViewControllerAnimated:YES completion:^{
        if ([timer isValid]) {
            [timer invalidate];
        }
    }];
}

#pragma mark - --------设置相机------------------------
- (void)setupCamera
{
    // 初始化捕捉设备(类型为AVMediaTypeVideo)
    device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDevicePosition position = device.position;
    if (position == AVCaptureDevicePositionBack) {
        NSLog(@"后置摄像头");
    }
    
    // 创建输入流
    input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    // 创建媒体数据输出流
    output = [[AVCaptureMetadataOutput alloc] init];
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    CGSize size = self.view.bounds.size;
    CGFloat p1 = size.height / size.width;
    CGFloat p2 = 1920./1080.;  //使用了1080p的图像输出(16:9)
    CGRect mediaScanRect = CGRectZero;
    if (p1 < p2) {
        CGFloat fixHeight = size.width * p2;
        CGFloat fixPadding = (fixHeight - size.height)/2;
        mediaScanRect = CGRectMake((scanRect.origin.y+fixPadding)/fixHeight,
                                   scanRect.origin.x/size.width,
                                   scanRect.size.height/fixHeight,
                                   scanRect.size.width/size.width);
    }else{
        CGFloat fixWidth = size.height / p2;
        CGFloat fixPadding = (fixWidth - size.width)/2;
        mediaScanRect = CGRectMake(scanRect.origin.y/size.height,
                                   (scanRect.origin.x+fixPadding)/fixWidth,
                                   scanRect.size.height/size.height,
                                   scanRect.size.width/fixWidth);
    }
    
    if (iPhone >= 7) {
        output.rectOfInterest = mediaScanRect;//设置扫描范围
    }
    
    // 实例化捕捉会话
    session = [[AVCaptureSession alloc] init];
    [session setSessionPreset:AVCaptureSessionPresetHigh];//AVCaptureSessionPresetHigh
    if ([session canAddInput:self.input])
    {
        [session addInput:self.input];//将输入流添加到会话
    }
    
    if ([session canAddOutput:self.output])
    {
        [session addOutput:self.output];//将媒体输出流添加到会话中
    }
    
    if (iPhone>=7) {
        // 条码类型 AVMetadataObjectTypeQRCode
        output.metadataObjectTypes = output.availableMetadataObjectTypes;
        if (iPhone >= 6) {
            NSString *mediaType = AVMediaTypeVideo;
            AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
            if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
                
                NSLog(@"相机权限受限");
                NSString *msg = @"请在设置->隐私->相机中设置访问权限";
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:msg delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
                alert.tag = 3;
                [alert show];
            }
            else if (authStatus == AVAuthorizationStatusAuthorized) {
                output.metadataObjectTypes = @[@"org.iso.QRCode"];
            }
        }
    }else{
        [CTB showMsg:@"暂不支持iOS6扫码功能"];
    }
    
    // 实例化预览图层
    preview = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    preview.frame = cameraRect;
    [self.view.layer insertSublayer:self.preview atIndex:0];
    
    // Start
    [session startRunning];
    isDidShow = YES;
    
    [self hiddenHudView];
}

- (void)hiddenHudView
{
    _line.hidden = NO;
    PaneImgView.hidden = NO;
    [hudView hide:YES];
    baseView.backgroundColor = [UIColor clearColor];
    [baseView changeFillColor:[UIColor colorWithWhite:0.0 alpha:0.5]];
    
    UILabel *lblErrorExplain = [self.view viewWithClass:[UILabel class] tag:2];
    lblErrorExplain.hidden = YES;
}

- (void)setIsCanScan:(NSNotification *)notice
{
    id obj = notice.object;
    if ([obj isKindOfClass:[NSNumber class]]) {
        isCanScan = [obj boolValue];
    }
}

#pragma mark - --------解析结果代理------------------------
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    NSString *stringValue = nil;
    
    if ([metadataObjects count] >0){
        AVMetadataMachineReadableCodeObject *metadataObject = [metadataObjects firstObject];
        stringValue = metadataObject.stringValue;
    }

    if (stringValue && isCanScan) {
        
        [self disposeResult:stringValue];
    }
}

- (void)disposeResult:(NSString *)content
{
    isCanScan = NO;
    if (delegate) {
        
        if ([delegate respondsToSelector:select(getScanResult:)]) {
            [delegate getScanResult:content];
        }
        
        if ([delegate respondsToSelector:select(getScanResult:controller:)]) {
            [delegate getScanResult:content controller:self];
        }
    }else{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ScanEvents" object:content];
    }
}

#pragma mark - --------其它操作------------------------
- (void)enablePopGesture:(BOOL)enabled
{
    //手势返回动作启用
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = enabled;
    }
}

#pragma mark - --------ButtonEvents------------------------
- (void)ButtonEvents:(UIButton *)button
{
    if (button.tag == 1) {
        
        self.navigationItem.rightBarButtonItem.enabled = NO;
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"选择设备类型" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"开关", @"插座", @"门锁", @"电动窗帘",@"红外转发器",@"远程视频",nil];
        alert.tag = 1;
        [alert show];
    }
    else if (button.tag == 2) {
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            
            [CTB showMsg:@"设备不支持选择相片功能"];
            return;
        }
        
        isPhoto = YES;
        [CTB imagePickerType:UIImagePickerControllerSourceTypePhotoLibrary delegate:self];
    }
    else if (button.tag == 3) {
        // Start session configuration
        [session beginConfiguration];
        [device lockForConfiguration:nil];
        if (!isOnLight) {
            isOnLight = YES;
            [device setTorchMode:AVCaptureTorchModeOn];//开打闪光灯
        }else{
            isOnLight = NO;
            [device setTorchMode:AVCaptureTorchModeOff];//关闭闪光灯
        }
        
        [device unlockForConfiguration];
        [session commitConfiguration];
    }
}

#pragma mark - --------获取图片实例------------------------
- (void)imagePickerController: (UIImagePickerController *)picker didFinishPickingMediaWithInfo: (NSDictionary *)info
{
    UIImage* image = [info objectForKey:UIImagePickerControllerOriginalImage];//原始图片
    //image = [info objectForKey: UIImagePickerControllerEditedImage]; //编辑过的图片
    
    CGFloat w = 250;
    PhotoPreView *photoPreView = [[PhotoPreView alloc] init:image cropSize:GetSize(w, w) isOnlyRead:NO delegate:self];
    photoPreView.Tag = picker;
    // 显示状态栏
    [[UIApplication sharedApplication] setStatusBarHidden:FALSE];
    [picker presentViewController:photoPreView animated:YES completion:nil];
}

//取消选择相处时调用
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)photoPreView:(PhotoPreView *)photoPreView didSelectImage:(UIImage *)image
{
    [hudView show:YES];
    _line.hidden = YES;
    hudView.labelText = @"正在处理中...";
    NSString *content = [self getContentWith:image];
    [CTB duration:1.5 block:^{
        if (content) {
            [self disposeResult:content];
        }else{
            NSString *msg = @"未能识别的二维码";
            [CTB showMsg:msg tag:2 delegate:self];
        }
        
        [hudView hide:YES];
    }];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark 解析图片二维码
- (NSString *)getContentWith:(UIImage *)image
{
    CGImageRef cgImage = image.CGImage;
    ZXLuminanceSource *source = [[ZXCGImageLuminanceSource alloc] initWithCGImage:cgImage];
    ZXBinaryBitmap *bitmap = [ZXBinaryBitmap binaryBitmapWithBinarizer:[ZXHybridBinarizer binarizerWithSource:source]];
    
    NSError *error = nil;
    
    // There are a number of hints we can give to the reader, including
    // possible formats, allowed lengths, and the string encoding.
    ZXDecodeHints *hints = [ZXDecodeHints hints];
    
    ZXMultiFormatReader *reader = [ZXMultiFormatReader reader];
    ZXResult *result = [reader decode:bitmap
                                hints:hints
                                error:&error];
    if (result) {
        // The coded result as a string. The raw data can be accessed with
        // result.rawBytes and result.length.
        NSString *contents = result.text;
        
        // The barcode format, such as a QR code or UPC-A
        //ZXBarcodeFormat format = result.barcodeFormat;
        
        //NSLog(@"format=%d,%@",format,contents);
        
        return contents;
    } else {
        // Use error to determine why we didn't get a result, such as a barcode
        // not being found, an invalid checksum, or a format inconsistency.
    }
    
    return nil;
}

#pragma mark - --------alertView------------------------
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *btnTitle = [alertView buttonTitleAtIndex:buttonIndex];
    if (alertView.tag == 1) {
        if ([btnTitle isEqualToString:@"开关"]) {
            _content = @"device:switch;id:01000001;tag:3";
            [self returnResult];
        }
        else if ([btnTitle isEqualToString:@"插座"]) {
            _content = @"device:plug;id:020000F7;ver:1.0";
            [self returnResult];
        }
        else if ([btnTitle isEqualToString:@"门锁"]) {
            //tag > 0则是蓝牙门锁
            _content = @"device:doorlock;id:03000001;tag:1;ver:1.0";
            [self returnResult];
        }
        else if ([btnTitle isEqualToString:@"电动窗帘"]){
            //暂时不确定
            _content = @"device:curtain;id:040000F7;ver:1.0";
            [self returnResult];
        }
        else if ([btnTitle isEqualToString:@"红外转发器"]){
            //红外转发器
            //device:ledlamp;id:1A61A7;tag:1;ver:1.0  LED灯  tag是灯光的类型
            _content = @"device:irrelay;id:06000011;tag:1;ver:1.0";//tag:1为分控器（LED灯，红外）;tag:0 为分控器（红外）
            [self returnResult];
        }
        else if ([btnTitle isEqualToString:@"远程视频"]){
            //远程视频
            _content = @"device:remoteVideo;id:097265848;ver:1.0";//摄像头比较特殊,非自制品,故需要分开
            [self returnResult];
        }
        
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    else if (alertView.tag == 2) {
        [NotificationCenter postNotificationName:@"Scan.isCanScan" object:@YES];
        _line.hidden = NO;
    }
    else if (alertView.tag == 3) {
        if ([btnTitle isEqualToString:@"确定"]) {
            //[self.navigationController popViewControllerAnimated:YES];
            NSURL *url = [NSURL URLWithString:@"prefs:root=Privacy&path=CAMERA"];
            [[UIApplication sharedApplication] openURL:url];
        }
    }
}

- (void)returnResult
{
    //device:gate;sn:9020T20921083  门禁
    //device:switch;id:00000001  开关
    //device:plug;id:02000084  插座
    //device:doorlock;id:03000001  门锁
    NSString *result = @"device:doorlock;id:03000001";
    
    if (_tag == 2) {
        result = @"device:gate;content:KF-9020T20921083";//254
        //result = @"device:gate;content:KF-9020T25020001";//250
        //result = @"device:gate;content:KF-9020T23100005";//150
    }
    else if (_tag == 3) {
        //主机
        result = @"device:host;content:82E17B13A2AC;ver:1.0";
    }
    
    if (_content) {
        result = _content;
    }
    
    if (delegate) {
        
        if ([delegate respondsToSelector:select(getScanResult:)]) {
            [delegate getScanResult:result];
        }
        
        if ([delegate respondsToSelector:select(getScanResult:controller:)]) {
            [delegate getScanResult:result controller:self];
        }
    }else{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ScanEvents" object:result];
    }
}

#pragma mark - --------从导航中移除该类------------------------
- (void)removeSelfFromNav
{
    [session stopRunning];
    session = nil;
    [preview removeFromSuperlayer];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [CTB removeController:self];
    NSLog(@"结束扫描");
}

#pragma mark -
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self enablePopGesture:YES];
    isCanScan = NO;
    [session stopRunning];
    [timer destroy];
}

- (void)dealloc
{
    isCanScan = NO;
    [session stopRunning];
    session = nil;
    [timer destroy];
    [preview removeFromSuperlayer];
    
    NSString *className = NSStringFromClass(self.class);
#if DEBUG
    NSLog(@"%@ dealloc",className);
#endif
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
