//
//  Color_ViewController.m
//  ImgSize
//
//  Created by Yin on 15-1-13.
//  Copyright (c) 2015年 caidan. All rights reserved.
//

#import "Color_ViewController.h"
#import "CTB.h"

@interface Color_ViewController ()<UITextFieldDelegate>
{
    UIView *baseView;
    UILabel *lblWhite;
    UILabel *lblAlpha;
    UITextField *txtHexValue;
    UIScrollView *iScrollView;
    
    UILabel *lblR;
    UILabel *lblG;
    UILabel *lblB;
    UILabel *lblA;
    
    CGFloat white;
    CGFloat alpha;
}

@end

@implementation Color_ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initCapacity];
    // Do any additional setup after loading the view.
}

- (void)initCapacity
{
    CGFloat y = 20;
    white = alpha = 0.5;
    baseView = [[UIView alloc] initWithFrame:CGRectMake(Screen_Width/2-40, 140+y, 80, 80)];
    baseView.clipsToBounds = YES;
    baseView.backgroundColor = [UIColor colorWithWhite:white alpha:alpha];
    baseView.layer.cornerRadius = baseView.frame.size.width/2;
    [self.view addSubview:baseView];
    
    UISlider *colorSlider = [[UISlider alloc] initWithFrame:CGRectMake(20, 20+y, Screen_Width-40, 20)];
    colorSlider.tag = 1;
    colorSlider.value = white;
    [colorSlider addTarget:self action:select(switchEvents:) forControlEvents:UIControlEventValueChanged];
    colorSlider.center = CGPointMake(Screen_Width/2, 30+y);
    [self.view addSubview:colorSlider];
    
    UISlider *alphaSlider = [[UISlider alloc] initWithFrame:CGRectMake(20, 40+y, Screen_Width-40, 20)];
    alphaSlider.tag = 2;
    alphaSlider.value = alpha;
    [alphaSlider addTarget:self action:select(switchEvents:) forControlEvents:UIControlEventValueChanged];
    alphaSlider.center = CGPointMake(Screen_Width/2, 80+y);
    [self.view addSubview:alphaSlider];
    
    lblWhite = [CTB labelTag:1 toView:self.view text:@"white:" wordSize:15 alignment:NSTextAlignmentLeft];
    lblWhite.frame = GetRect(20, GetVMaxY(alphaSlider)+20, Screen_Width/2-20, 20);
    
    lblAlpha = [CTB labelTag:1 toView:self.view text:@"alpha:" wordSize:15 alignment:NSTextAlignmentLeft];
    lblAlpha.frame = GetRect(Screen_Width/2, GetVMaxY(alphaSlider)+20, Screen_Width/2-20, 20);
    
    [self switchEvents:colorSlider];
    [self switchEvents:alphaSlider];
    
    txtHexValue = [CTB textFieldTag:1 holderTxt:@"输入颜色二进制值" V:self.view delegate:self];
    txtHexValue.font = [UIFont systemFontOfSize:13];
    txtHexValue.layer.cornerRadius = 5;
    txtHexValue.frame = GetRect(50, GetVMaxY(baseView)+30, 130, 30);
    UIButton *btnUpdate = [CTB buttonType:UIButtonTypeCustom delegate:self to:self.view tag:1 title:@"Set" img:@""];
    btnUpdate.layer.cornerRadius = 5;
    btnUpdate.frame = GetRect(GetVMaxX(txtHexValue)+5, GetVMinY(txtHexValue), 50, 30);
    [CTB setBorderWidth:0.5 View:txtHexValue,btnUpdate, nil];
    [CTB setLeftViewWithWidth:5 textField:txtHexValue, nil];
    
    CGFloat x = Screen_Width/3;
    lblR = [CTB labelTag:1 toView:self.view text:@"R:0" wordSize:15 alignment:NSTextAlignmentLeft];
    lblR.frame = GetRect(10, GetVMaxY(txtHexValue)+5, x-20, 20);
    lblG = [CTB labelTag:1 toView:self.view text:@"G:0" wordSize:15 alignment:NSTextAlignmentLeft];
    lblG.frame = GetRect(10+x, GetVMaxY(txtHexValue)+5, x-20, 20);
    lblB = [CTB labelTag:1 toView:self.view text:@"B:0" wordSize:15 alignment:NSTextAlignmentLeft];
    lblB.frame = GetRect(10+x*2, GetVMaxY(txtHexValue)+5, x-20, 20);
    
    lblA = [CTB labelTag:1 toView:self.view text:@"alpha:0" wordSize:15 alignment:NSTextAlignmentLeft];
    lblA.frame = GetRect(20, GetVMaxY(lblB)+5, x*2, 20);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [txtHexValue resignFirstResponder];
}

- (void)switchEvents:(UISlider *)theSlider
{
    [txtHexValue resignFirstResponder];
    
    if (theSlider.tag == 1) {
        white = theSlider.value;
        lblWhite.text = [NSString stringWithFormat:@"white:%.6f",white];
    }
    else if (theSlider.tag == 2) {
        alpha = theSlider.value;
        lblAlpha.text = [NSString stringWithFormat:@"alpha:%.6f",alpha];
    }
    
    baseView.backgroundColor = [UIColor colorWithWhite:white alpha:alpha];
}

- (void)ButtonEvents:(UIButton *)button
{
    [txtHexValue resignFirstResponder];
    
    if (button.tag == 1) {
        NSString *colorString = txtHexValue.text;
        if (colorString.length > 0) {
            UIColor *color = [CTB colorWithHexString:colorString];
            const CGFloat *cs = CGColorGetComponents(color.CGColor);
            size_t index = CGColorGetNumberOfComponents(color.CGColor);
            CGFloat r,g,b,a;
            if (index == 4) {
                baseView.backgroundColor = color;
                r = cs[0],g = cs[1],b = cs[2],a = cs[3];
            }else{
                r = g = b = 0;
                baseView.backgroundColor = color;
            }
            
            lblR.text = [NSString stringWithFormat:@"R:%.3f",r];
            lblG.text = [NSString stringWithFormat:@"G:%.3f",g];
            lblB.text = [NSString stringWithFormat:@"B:%.3f",b];
            lblA.text = [NSString stringWithFormat:@"A:%.3f",a];
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
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
