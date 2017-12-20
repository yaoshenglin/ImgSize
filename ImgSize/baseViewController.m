//
//  baseViewController.m
//  ImgSize
//
//  Created by xy on 2017/12/13.
//  Copyright © 2017年 caidan. All rights reserved.
//

#import "baseViewController.h"

@interface baseViewController ()

@end

@implementation baseViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [CTB setViewBounds:self];
    [CTB setNavigationBarBackground:@"section2" to:self];
    self.view.backgroundColor = [CTB colorWithHexString:@"#E5E5E5"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupSubViews];
    // Do any additional setup after loading the view.
}

- (void)setupSubViews
{
    self.edgesForExtendedLayout = UIRectEdgeNone;//原点移动到导航栏下方
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor = MasterColor;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    NSLog(@"%@ dealloc",self.className);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
