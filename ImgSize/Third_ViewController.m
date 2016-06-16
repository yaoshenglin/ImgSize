//
//  Third_ViewController.m
//  ImgSize
//
//  Created by Yin on 14-5-20.
//  Copyright (c) 2014年 caidan. All rights reserved.
//

#import "Third_ViewController.h"
#import "CTB.h"
#import "Share.h"
#import "PhotoPreView.h"

@interface Third_ViewController ()<UIScrollViewDelegate,UIWebViewDelegate,UIActionSheetDelegate,PhotoPreViewDelegate>
{
    UIScrollView *scrollview;
    UIPageControl *pageControl;
    
    NSString *imgUrl;
    
    BOOL isOriginal;
}

@property (weak, nonatomic) UITextField *txtTitle;
@property (weak, nonatomic) UITextField *txtUrl;
@property (weak, nonatomic) UITextField *txtDepict;
@property (weak, nonatomic) UIImageView *imgView;

@end

@implementation Third_ViewController

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
    [CTB setViewBounds:self];
    self.view.backgroundColor = [CTB colorWithHexString:@"#E5E5E5"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initCapacity];
    // Do any additional setup after loading the view.
}

- (void)initCapacity
{
    self.title = @"自定义分享";
    self.navigationItem.rightBarButtonItem = [CTB BarButtonWithImg:[UIImage imageNamed:@"二维码大"] target:self tag:2];
    
    CGFloat x,y;
    iScrollView = [[UIScrollView alloc] initWithFrame:GetRect(0, 0, Screen_Width, viewH)];
    iScrollView.contentSize = GetSize(Screen_Width, viewH);
    iScrollView.delaysContentTouches = NO;
    [self.view addSubview:iScrollView];
    
    //缩略图
    x = (Screen_Width-100)/2, y = 80;
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, 100, 100)];
    imgView.image = [UIImage imageNamed:@"场景编辑_场景图片"];
    [iScrollView addSubview:imgView];
    UIButton *btnImg = [CTB buttonType:UIButtonTypeCustom delegate:self to:iScrollView tag:2 title:nil img:nil];
    btnImg.frame = imgView.frame;
    [iScrollView addSubview:btnImg];
    _imgView = imgView;
    
    //标题
    x = (Screen_Width-250)/2;
    UILabel *lblTitle = [CTB labelTag:1 toView:iScrollView text:@"标题" wordSize:-1];
    lblTitle.frame = CGRectMake(x, 200, 45, 30);
    UITextField *txtTitle = [CTB textFieldTag:1 holderTxt:@"标题" V:iScrollView delegate:self];
    txtTitle.frame = CGRectMake(CGRectGetMaxX(lblTitle.frame)+5, CGRectGetMinY(lblTitle.frame), 200, CGRectGetHeight(lblTitle.frame));
    _txtTitle = txtTitle;
    
    //Url
    UILabel *lblUrl = [CTB labelTag:1 toView:iScrollView text:@"Url" wordSize:-1];
    lblUrl.frame = CGRectMake(x, 240, 45, 30);
    UITextField *txtUrl = [CTB textFieldTag:1 holderTxt:@"Url" V:iScrollView delegate:self];
    txtUrl.frame = CGRectMake(CGRectGetMaxX(lblUrl.frame)+5, CGRectGetMinY(lblUrl.frame), 200, CGRectGetHeight(lblUrl.frame));
    _txtUrl = txtUrl;
    
    //描述description
    UILabel *lblDepict = [CTB labelTag:1 toView:iScrollView text:@"描述" wordSize:-1];
    lblDepict.frame = CGRectMake(x, 280, 45, 30);
    UITextField *txtDepict = [CTB textFieldTag:1 holderTxt:@"描述" V:iScrollView delegate:self];
    txtDepict.frame = CGRectMake(CGRectGetMaxX(lblDepict.frame)+5, CGRectGetMinY(lblDepict.frame), 200, CGRectGetHeight(lblDepict.frame));
    _txtDepict = txtDepict;
    
    x = (Screen_Width-80)/2;
    UIButton *btnSend = [CTB buttonType:UIButtonTypeCustom delegate:self to:iScrollView tag:3 title:@"发送" img:@"按钮-选中效果/1"];
    //btnSend.backgroundColor = MasterColor;
    btnSend.frame = CGRectMake(x, 330, 80, 38);
    
    [CTB setLeftViewWithWidth:5 textField:txtTitle,txtUrl,txtDepict, nil];
    [CTB setRadius:3.0 View:txtTitle,txtUrl,txtDepict,btnSend, nil];
    [CTB setBorderWidth:0.5 Color:MasterColor View:txtTitle,txtUrl,txtDepict,btnSend, nil];
    
    txtTitle.text = @"大神啊";
    txtUrl.text = @"http://www.html-js.com/article/1628";
    txtDepict.text = @"我是2010年8月份开始自学Android的，到现在已经快有6年的时间了。";
}

- (void)ButtonEvents:(UIButton *)button
{
    if (button.tag==1) {
        
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"选择图片" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"相册", nil];
        sheet.tag = 1;
        [sheet showInView:self.view];
    }
    else if (button.tag==2) {
        //UIViewController *test = [CTB getControllerWithIdentity:@"Test" storyboard:nil];
        //[self.navigationController pushViewController:test animated:YES];
        
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"添加头像" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"拍照" otherButtonTitles:@"从相册选择", nil];
        sheet.tag = 1;
        [sheet showInView:self.navigationController.navigationBar];
    }
    else if (button.tag == 3) {
        NSString *format = @"(http|ftp|https):\\/\\/[\\w\\-_]+(\\.[\\w\\-_]+)+([\\w\\-\\.,@?^=%&amp;:/~\\+#]*[\\w\\-\\@?^=%&amp;/~\\+#])?";
        if (!_txtTitle.text.isNonEmpty) {
            [self.view makeToast:@"请输入标题"];
        }
        else if (!_txtUrl.text.isNonEmpty) {
            [self.view makeToast:@"请输入网址"];
        }
        else if (![_txtUrl.text evaluateWithFormat:format]) {
            [self.view makeToast:@"网址格式不对"];
        }else{
            UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"选择分享类型" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"微信分享" otherButtonTitles:@"QQ分享", nil];
            sheet.tag = 2;
            [sheet showInView:self.navigationController.navigationBar];
        }
    }
}

#pragma mark - --------UIAlertView------------------------
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *btnTitle = [alertView buttonTitleAtIndex:buttonIndex];
    if (alertView.tag == 1) {
        if ([btnTitle isEqualToString:@"确定"]) {
            NSString *wxUrl = [WXApi getWXAppInstallUrl];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:wxUrl]];
        }
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *btnTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if (actionSheet.tag == 1) {
        if ([btnTitle isEqualToString:@"拍照"]) {
            
            if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                
                [CTB showMsg:@"设备不支持拍照功能"];
                return;
            }
            
            [CTB imagePickerType:UIImagePickerControllerSourceTypeCamera delegate:self];
        }
        else if([btnTitle isEqualToString:@"从相册选择"]) {
            
            if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                
                [CTB showMsg:@"设备不支持选择相片功能"];
                return;
            }
            
            [CTB imagePickerType:UIImagePickerControllerSourceTypePhotoLibrary delegate:self];
        }
    }
    else if (actionSheet.tag == 2) {
        NSString *title = _txtTitle.text;
        UIImage *image = _imgView.image;
        NSString *description = _txtDepict.text;
        NSString *urlString = _txtUrl.text;
        if ([btnTitle isEqualToString:@"微信分享"]) {
            
            //微信分享
            if ([WXApi isWXAppInstalled]) {
                WXShare *share = [[WXShare alloc] init];
                share.delegate = self;
                [share sendTextTitle:title image:image description:description webpageUrl:urlString];
            }else{
                [CTB alertWithMessage:@"你还没有安装微信,是否现在安装" Delegate:self tag:1];
            }
        }
        else if([btnTitle isEqualToString:@"QQ分享"]) {
            
            //QQ分享
            if ([TencentOAuth iphoneQQInstalled]) {
                
                NSData *data = UIImagePNGRepresentation(image);
                NSURL *url = [NSURL URLWithString:urlString];
                QQShare *share = [QQShare getInstance];
                share.delegate = self;
                QQApiSendResultCode code = [share sendMsgWithURL:url title:title description:description previewImageData:data];
                if (code != EQQAPISENDSUCESS) {
                    [self.view makeToast:@"分享失败"];
                }
            }else{
                QQShare *share = [QQShare getInstance];
                [share installQQ];
            }
        }
    }
}

#pragma mark - --------获取图片实例------------------------
- (void)imagePickerController: (UIImagePickerController *)picker didFinishPickingMediaWithInfo: (NSDictionary *)info
{
    UIImage* image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];//原始图片
    //UIImage* image = [info objectForKey: @"UIImagePickerControllerEditedImage"]; //编辑过的图片
    
    PhotoPreView *photoPreView = [[PhotoPreView alloc] init:image cropSize:GetSize(100, 100) isOnlyRead:NO delegate:self];
    photoPreView.Tag = picker;
    // 显示状态栏
    [[UIApplication sharedApplication] setStatusBarHidden:FALSE];
    [picker presentViewController:photoPreView animated:YES completion:nil];
    
    //***********获取图片名字*******************
}

//取消选择相处时调用
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)photoPreView:(PhotoPreView *)photoPreView didSelectImage:(UIImage *)image
{
    _imgView.image = image;
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - --------分享结果------------------------
- (void)onResp:(BaseResp*)resp share:(BOOL)isSuccess
{
    if (isSuccess) {
        [self.view makeToast:@"分享成功"];
    }else{
        [self.view makeToast:@"分享失败"];
    }
}

- (void)HandleOpenURL:(NSURL *)url
{
    NSDictionary *dic = [QQShare parseUrl:url];
    Enum_QQShareCode code = [dic[@"error"] intValue];
    if (code == QQShare_Success) {
        [self.view makeToast:@"分享成功"];
    }else{
        [self.view makeToast:@"分享失败"];
    }
}

#pragma mark -
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
