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

@interface Second_ViewController ()<CTBDelegate,UITextFieldDelegate,UIActionSheetDelegate,UITableViewDataSource,UITableViewDelegate,MBProgressHUDDelegate>
{
    BOOL isFirstAppear;
    
    NSMutableArray *listData;
    
    UIButton *btnDelete;
    UITextField *txtPassword;
    UITableView *myTableView;
    
    MBProgressHUD *hudView;
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

-(void)loadView
{
    [super loadView];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"叶子大"] style:UIBarButtonItemStylePlain target:nil action:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [CTB setViewBounds:self];
    self.view.backgroundColor = [CTB colorWithHexString:@"#E5E5E5"];
    
    if (isFirstAppear) {
        isFirstAppear = NO;
    }
}

-(void)back
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

-(void)initCapacity
{
    self.navigationItem.rightBarButtonItem = [CTB BarButtonWithTitle:@"相册" target:self tag:1];
    
    listData = [NSMutableArray array];
    [listData addObjectsFromArray:[[self getDic] allValues]];
    
    myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, Screen_Height-64) style:UITableViewStyleGrouped];
    myTableView.dataSource = self;
    myTableView.delegate = self;
    [self.view addSubview:myTableView];
    
    [self performSelector:select(getKeyboardBy:) withObject:nil afterDelay:0.3];
}

-(NSString *)getKeyboardBy:(UIKeyboardType)type
{
    NSDictionary *dic = [self getDic];
    
    if (type == 11) {
        type = UIKeyboardTypeAlphabet;
    }
    
    NSString *result = dic[@(type)];
    return result;
}

-(NSDictionary *)getDic
{
    NSDictionary *dic = @{@(UIKeyboardTypeDefault):@"UIKeyboardTypeDefault",
                          @(UIKeyboardTypeASCIICapable):@"UIKeyboardTypeASCIICapable",
                          @(UIKeyboardTypeNumbersAndPunctuation):@"UIKeyboardTypeNumbersAndPunctuation",
                          @(UIKeyboardTypeURL):@"UIKeyboardTypeURL",
                          @(UIKeyboardTypeNumberPad):@"UIKeyboardTypeNumberPad",
                          @(UIKeyboardTypePhonePad):@"UIKeyboardTypePhonePad",
                          @(UIKeyboardTypeNamePhonePad):@"UIKeyboardTypeNamePhonePad",
                          @(UIKeyboardTypeEmailAddress):@"UIKeyboardTypeEmailAddress",
                          @(UIKeyboardTypeDecimalPad):@"UIKeyboardTypeDecimalPad",
                          @(UIKeyboardTypeTwitter):@"UIKeyboardTypeTwitter",
                          @(UIKeyboardTypeWebSearch):@"UIKeyboardTypeWebSearch",
                          @(UIKeyboardTypeAlphabet):@"UIKeyboardTypeAlphabet",};
    return dic;
}

-(void)addDataFrom:(NSArray *)array
{
    [listData addObjectsFromArray:array];
    [myTableView reloadData];
}

#pragma mark - ======tableView========================
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger row_Count = 0;
    
    row_Count = listData.count;
    
    return row_Count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identify = [NSString stringWithFormat:@"%d/%d",(int)indexPath.section,(int)indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
    }
    
    cell.textLabel.text = listData[indexPath.row];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self showWord:10*indexPath.row];
    [self performSelector:select(test:with:) withObject:@"OK" afterDelay:0.5];
}

-(void)test:(NSString *)aString with:(NSString *)bString
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

-(void)showWord:(CGFloat)y
{
    NSString *msg = @"您好！您好！您好！您好！您好?您好?您好?您好?您好?您好?您好?您好?";
    [CTB showMessageWithString:msg to:self];
}

-(UILabel *)getLabelWith:(NSString *)msg
{
    UILabel *label = [[UILabel alloc] initWithFrame:GetRect(0, 0, 280, 80)];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:17];
    label.backgroundColor = [UIColor clearColor];
    label.text = @"您好！您好！您好！您好！您好?您好?您好?您好?您好?您好?您好?您好?";
    label.numberOfLines = 0;
    
    return label;
}

-(void)setScrollViewToHigh:(CGFloat)height
{
    //[CTB setAnimationWith:0.3 delegate:nil complete:nil];
    //[CTB setRectWith:myTableView toHeight:height];
    //[CTB commitAnimations];
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         
                     }
                     completion:^(BOOL finished) {
                         //动画完成,可为空
                         [CTB setRectWith:myTableView toHeight:height];
                     }];
}

-(void)setScrollViewToPoint:(NSValue *)value
{
    CGPoint point;
    [value getValue:&point];
    [CTB setAnimationWith:myTableView Offset:point];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - ======ButtonEvents========================
-(void)ButtonEvents:(UIButton *)button
{
    if (button.tag==1) {
        
        UIViewController *Third = [CTB getControllerWithIdentity:@"Third" storyboard:@"Main"];
        [self.navigationController pushViewController:Third animated:YES];
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

-(void)backPage
{
    [self.navigationController popViewControllerAnimated:YES];
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

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    NSArray *list = self.navigationController.childViewControllers;
    if (![list containsObject:self]) {
        //self.hidesBottomBarWhenPushed = NO;
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
