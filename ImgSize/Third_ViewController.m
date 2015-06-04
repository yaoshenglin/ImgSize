//
//  Third_ViewController.m
//  ImgSize
//
//  Created by Yin on 14-5-20.
//  Copyright (c) 2014年 caidan. All rights reserved.
//

#import "Third_ViewController.h"
#import "CTB.h"

@interface Third_ViewController ()<UIScrollViewDelegate,UIWebViewDelegate,UIActionSheetDelegate>
{
    UIScrollView *scrollview;
    UIPageControl *pageControl;
    
    NSString *imgUrl;
    UIImageView *imgView;
    
    BOOL isOriginal;
}

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

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [CTB setViewBounds:self];
    self.view.backgroundColor = [CTB colorWithHexString:@"#E5E5E5"];
    
    [self duration:2.0f action:select(removeFromSuperViewController)];
}

- (void)removeFromSuperViewController
{
//    UIViewController *Second = getControllerFor(self, @"Second_ViewController");
//    if (Second) {
//        NSMutableArray *viewControllers = [self.navigationController.viewControllers mutableCopy];
//        [viewControllers removeObject:Second];
//        [self.navigationController setViewControllers:viewControllers animated:YES];
//    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initCapacity];
    // Do any additional setup after loading the view.
}

-(void)initCapacity
{
    self.navigationItem.rightBarButtonItem = [CTB BarButtonWithImg:[UIImage imageNamed:@"二维码大"] target:self tag:2];
    
    iScrollView = [[UIScrollView alloc] initWithFrame:GetRect(0, 0, Screen_Width, Screen_Height-64-20)];
    iScrollView.contentSize = GetSize(Screen_Width, Screen_Height-64);
    [self.view addSubview:iScrollView];
}

-(void)ButtonEvents:(UIButton *)button
{
    if (button.tag==1) {
        
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"选择图片" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"相册", nil];
        sheet.tag = 1;
        [sheet showInView:self.view];
    }
    else if (button.tag==2) {
        //UIViewController *test = [CTB getControllerWithIdentity:@"Test" storyboard:nil];
        //[self.navigationController pushViewController:test animated:YES];
        
        UIViewController *Swift = [CTB getControllerWithIdentity:@"Swift" storyboard:@"Main"];
        [self.navigationController pushViewController:Swift animated:YES];
    }
    else if (button.tag == 3) {
        isOriginal = !isOriginal;
        if (isOriginal) {
            button.backgroundColor = [CTB colorWithHexString:@"#3DA606"];
        }else{
            button.backgroundColor = [UIColor clearColor];
        }
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
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
