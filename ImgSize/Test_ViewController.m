//
//  Test_ViewController.m
//  ImgSize
//
//  Created by Yin on 14-7-11.
//  Copyright (c) 2014年 caidan. All rights reserved.
//

#import "Test_ViewController.h"
#import "CTB.h"

@interface Test_ViewController ()
{
    UILabel *myLabel;
    BOOL isFirstAppear;
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
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:select(ButtonEvents:)];
    self.navigationItem.leftBarButtonItem.tag = 1;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"添加" style:UIBarButtonItemStylePlain target:self action:select(ButtonEvents:)];
    self.navigationItem.rightBarButtonItem.tag = 2;
    
    myLabel = [[UILabel alloc]initWithFrame:CGRectMake(110, 100, 100, 30 )];
    myLabel.textColor = [UIColor redColor];
    [self.view addSubview:myLabel];
    
    UIButton * b = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    b.frame = CGRectMake(110, 20, 100, 30);
    [b setBackgroundImage:[UIImage imageNamed:@"section2"] forState:UIControlStateNormal];
    [b addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:b];
    [CTB setBorderWidth:0.5 View:myLabel,b, nil];
}

-(void)buttonAction:(UIButton *)button
{
    
}

-(void)ButtonEvents:(UIButton *)button
{
    if (button.tag == 1) {
        [self.navigationController popToRootViewControllerAnimated:YES];
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
