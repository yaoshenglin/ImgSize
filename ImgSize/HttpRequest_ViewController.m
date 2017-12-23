//
//  HttpRequest_ViewController.m
//  ImgSize
//
//  Created by xy on 2017/12/12.
//  Copyright © 2017年 caidan. All rights reserved.
//

#import "HttpRequest_ViewController.h"
#import "MBProgressHUD.h"
#import "HTTPRequest.h"
#import "Tools.h"

#pragma mark - --------
@interface HttpRequest_ViewController ()<NSURLSessionDelegate>
{
    NSDate *receiveDate;
    NSMutableData *vData;
    
    MBProgressHUD *hudView;
    HTTPRequest *request;
}

@property int64_t totalLength;
@property (nonatomic, strong) NSData *resumData; // 续传数据
@property (nonatomic, strong) NSURLSession *session; // 会话
@property (nonatomic, strong) NSURLSessionTask *myDataTask; // 请求任务

@end

@implementation HttpRequest_ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupSubViews];
    [self initCapacity];
    // Do any additional setup after loading the view.
}

- (void)setupSubViews
{
    self.title = @"网络请求";
    self.navigationItem.rightBarButtonItem = [CTB BarButtonWithTitle:@"重来" target:self tag:1];
    
    UIButton *btnData = [CTB buttonType:UIButtonTypeCustom delegate:self to:self.view tag:2 title:@"Data" img:@""];
    btnData.frame = CGRectMake(0, 0, 60, 32);
    btnData.center = CGPointMake(Screen_Width/2, 50);
    
    UIButton *btnSend = [CTB buttonType:UIButtonTypeCustom delegate:self to:self.view tag:3 title:@"Send" img:@""];
    btnSend.frame = CGRectMake(0, 0, 70, 32);
    btnSend.center = CGPointMake(Screen_Width/3, 110);
    
    UIButton *btnReceive = [CTB buttonType:UIButtonTypeCustom delegate:self to:self.view tag:4 title:@"Receive" img:@""];
    btnReceive.frame = CGRectMake(0, 0, 70, 32);
    btnReceive.center = CGPointMake(Screen_Width*2/3, 110);
    
    [CTB setRadius:5 View:btnData,btnSend,btnReceive, nil];
    [CTB setBorderWidth:0.5 View:btnData,btnSend,btnReceive, nil];
}

- (void)initCapacity
{
    vData = [NSMutableData data];
    
    NSLog(@"%@",[[NSBundle mainBundle] bundleIdentifier]);
}

- (void)initHudView
{
    hudView = [MBProgressHUD showRuningView:self.view];
    hudView.taskInProgress = YES;
    hudView.mode = MBProgressHUDModeDeterminate;
    hudView.minSize = CGSizeMake(150, 37);
    hudView.removeFromSuperViewOnHide = YES;
}

- (void)dataRequest
{
    [self initHudView];
    hudView.labelText = @"加载中……";
    [hudView show:YES];
    NSInteger appVer = 33;//当前APP内部版本号
    NSInteger hwVer = 2;//当前固件内部版本号
    NSString *hwName = @"ModelName";
    NSDictionary *body = @{@"deviceType":@(4),//4
                           @"appVer":@(appVer),
                           @"hwName":hwName,
                           @"hwVer":@(hwVer)};
    request = [[HTTPRequest alloc] initWithDelegate:self];
    [request run:GetLastVersions body:body];
    [request start];
}

- (void)uploadRequest
{
    [self initHudView];
    hudView.labelText = @"上传中……";
    [hudView show:YES];
    NSDictionary *userInfo = getUserData(@"userInfo");
    NSString *token = [userInfo stringForKey:@"token"];
    token = token ?: @"301|E21CA9946944987340C1DA235AC2A73C";
    NSString *imgName = @"QQ_V6.2.0.dmg";
    NSString *dirPath = [@"~/Library" stringByExpandingTildeInPath];
    dirPath = [dirPath stringByAppendingPathComponent:@"Downloads"];
    NSString *path = [dirPath stringByAppendingPathComponent:imgName];
    NSData *data = [NSData dataWithContentsOfFile:path]?:[NSData data];
//    UIImage *image = [UIImage imageNamed:imgName];
    
    NSDictionary *body = @{@"file":data,@"fileName":imgName,@"path":path};
    request = [[HTTPRequest alloc] initWithDelegate:self];
    request.urlString = @"http://www.freeimagehosting.net/upl.php";
    request.taskType = SessionTaskType_Upload;
    [request run:UpdateSceneImg body:body delegate:self];
    [request setValue:token forHeader:@"token" encoding:NSUTF8StringEncoding];
    [request setValue:@(692).stringValue forHeader:@"SceneID" encoding:NSUTF8StringEncoding];
    [request start];
}

- (void)downRequest
{
    [self initHudView];
    hudView.labelText = @"下载中……";
    [hudView show:YES];
    request = [[HTTPRequest alloc] initWithDelegate:self];
    request.taskType = SessionTaskType_Download;
    request.urlString = @"http://dldir1.qq.com/qqfile/QQforMac/QQ_V6.2.0.dmg";
    //request.urlString = @"http://120.25.226.186:32812/resources/videos/minion_01.mp4";
    [request run:nil body:nil];
    [request start];
}

#pragma mark -
- (void)ButtonEvents:(UIButton *)button
{
    if (button.tag == 1) {
        if (request.myDataTask.state == NSURLSessionTaskStateRunning) {
            [request suspend];
        }
        else if (request.myDataTask.state == NSURLSessionTaskStateSuspended) {
            [request resume];
        }
    }
    else if (button.tag == 2) {
        [self dataRequest];
    }
    else if (button.tag == 3) {
        [self uploadRequest];
    }
    else if (button.tag == 4) {
        [self downRequest];
    }
}

#pragma mark - --------NSURLSessionDelegate------------------------
- (void)receiveProgress:(CGFloat)progress
{
    if (request.taskType != SessionTaskType_Download) {
        return;
    }
    NSString *speedString = [NSString stringWithFormat:@"下载 %.2f%%",progress/0.01];
    
    dispatch_block_t block = ^{
        hudView.labelText = speedString;
        hudView.progress = progress;
    };
    
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), block);
    }else{
        block();
    }
}

- (void)sendProgress:(CGFloat)progress
{
    if (request.taskType != SessionTaskType_Upload) {
        return;
    }
    NSString *speedString = [NSString stringWithFormat:@"上传 %.2f%%",progress/0.01];
    
    dispatch_block_t block = ^{
        hudView.labelText = speedString;
        hudView.progress = progress;
    };
    
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), block);
    }else{
        block();
    }
}

#pragma mark - --------WSDelegate----------------
- (void)wsOK:(HTTPRequest *)iWS
{
    [hudView hide:YES];
    NSDictionary *jsonDic = iWS.jsonDic;
    if ([iWS.method isEqualToString:UpdateSceneImg]) {
        NSString *imgUrl = [jsonDic stringForKey:@"data"];//新的图片地址
        NSLog(@"imgUrl = %@",imgUrl);
    }
    else if ([iWS.method isEqualToString:FileDownload]) {
        NSString *fileName = iWS.response.suggestedFilename;
        NSString *dirPath = [@"~/Library" stringByExpandingTildeInPath];
        dirPath = [dirPath stringByAppendingPathComponent:@"Downloads"];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:dirPath]) {
            NSError *error = nil;
            [fileManager createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:&error];
            if (error) {
                NSLog(@"%@",error.localizedDescription);
            }
        }
        NSString *path = [dirPath stringByAppendingPathComponent:fileName];
        BOOL result = [iWS.responseData writeToFile:path atomically:YES];
        if (!result) {
            NSLog(@"写入失败,%@",path);
            [self.view makeToast:@"文件保存失败"];
        }
    }
    else if ([iWS.method isEqualToString:GetLastVersions]) {
        NSLog(@"%@",[jsonDic customDescription]);
    }
}

- (void)wsFailed:(HTTPRequest *)iWS
{
    [hudView hide:YES];
    NSString *errMsg = iWS.errMsg;
    NSLog(@"%@,%d,%@",iWS.method,iWS.responseStatusCode,errMsg);
}

#pragma mark -
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [_myDataTask cancel];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [request cancel];
    
}

@end
