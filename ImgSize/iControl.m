//
//  iUIControl.m
//  UIConrol
//
//  Created by Yin on 14-4-5.
//  Copyright © 2014年 caidan. All rights reserved.
//

#import "iControl.h"
#import "CTB.h"

@interface iControl ()
{
    UIColor *bgColor;
}

@end

@implementation iControl

@synthesize isRegistKeyboardNotice,childViewHidden;
@synthesize opacity;
@synthesize isArrayForBtn,listButton;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initCapacity];
    }
    return self;
}

- (void)initCapacity
{
    
}

+ (iControl *)initWithTitle:(NSString *)title tag:(int)tag mode:(UIDatePickerMode)mode delegate:(id)delegate toV:(UIView *)toView sel:(SEL)action
{
    iControl *myControl = [[iControl alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, Screen_Height-64)];
    myControl.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
    myControl.tag = tag;
    [myControl addTarget:delegate action:select(ButtonEvents:) forControlEvents:UIControlEventTouchDown];
    [toView addSubview:myControl];
    
    CGFloat y = (Screen_Height-64-300)/2;
    UIView *View = [[UIView alloc] initWithFrame:CGRectMake(15, y, Screen_Width-30, 300)];
    View.tag = 2;
    View.layer.masksToBounds = YES;
    View.layer.cornerRadius = 5;
    View.backgroundColor = [UIColor whiteColor];
    [myControl addSubview:View];
    
    //标题
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, GetVWidth(View), 40)];
    lblTitle.text = title;
    lblTitle.tag = 3;
    lblTitle.textAlignment = NSTextAlignmentCenter;
    lblTitle.textColor = [UIColor whiteColor];
    lblTitle.backgroundColor = MasterColor;
    [View addSubview:lblTitle];
    
    y = GetVMaxY(lblTitle);
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, y, GetVWidth(View), 1)];
    lineView.tag = 4;
    lineView.backgroundColor = MasterColor;
    [View addSubview:lineView];
    
    //时间选择器
    UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(-10, 40, GetVWidth(View), 220)];
    datePicker.tag = 5;
    datePicker.datePickerMode = mode;//UIDatePickerModeTime
    datePicker.minuteInterval = 1;
    datePicker.minimumDate = [NSDate date];
    [View addSubview:datePicker];
    
    //取消按钮
    UIButton *btnCancel = [UIButton buttonWithType:UIButtonTypeCustom];
    btnCancel.tag = 1;
    [btnCancel setTitle:@"取消" forState:UIControlStateNormal];
    [btnCancel setTitleColor:MasterColor forState:UIControlStateNormal];
    btnCancel.frame = CGRectMake(0, 260, GetVWidth(View)/2, 40);
    [btnCancel setBackgroundImage:[UIImage imageNamed:@"按钮-选中效果"] forState:UIControlStateHighlighted];
    [btnCancel setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [btnCancel addTarget:delegate action:action forControlEvents:UIControlEventTouchUpInside];
    [View addSubview:btnCancel];
    
    //确定按钮
    UIButton *btnOK = [UIButton buttonWithType:UIButtonTypeCustom];
    btnOK.tag = 2;
    [btnOK setTitle:@"确定" forState:UIControlStateNormal];
    [btnOK setTitleColor:MasterColor forState:UIControlStateNormal];
    btnOK.frame = CGRectMake(GetVWidth(View)/2, 260, GetVWidth(View)/2, 40);
    [btnOK setBackgroundImage:[UIImage imageNamed:@"按钮-选中效果"] forState:UIControlStateHighlighted];
    [btnOK setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [btnOK addTarget:delegate action:action forControlEvents:UIControlEventTouchUpInside];
    [View addSubview:btnOK];
    
    [CTB setBorderWidth:0.5 View:btnCancel,btnOK, nil];
    myControl.baseView = View;
    
    return myControl;
}

+ (UIButton *)CreateButtonWithImg:(NSString *)imgName title:(NSString *)title rect:(CGRect)rect tag:(int)tag toView:(UIView *)bottomView delegate:(id)delegate
{
    UIView *View = [[UIView alloc] initWithFrame:rect];
    View.backgroundColor = [UIColor clearColor];
    [bottomView addSubview:View];
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 8, 30, 27)];
    imgView.backgroundColor = [UIColor clearColor];
    imgView.image = [UIImage imageNamed:imgName];
    [View addSubview:imgView];
    
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, 70, 15)];
    lblTitle.backgroundColor = [UIColor clearColor];
    lblTitle.font = [UIFont systemFontOfSize:13];
    lblTitle.textColor = [UIColor blackColor];
    lblTitle.text = title;
    lblTitle.textAlignment = NSTextAlignmentCenter;
    lblTitle.lineBreakMode = NSLineBreakByWordWrapping;
    [View addSubview:lblTitle];
    
    //下面线条
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 63, 70, 1)];
    lineView.backgroundColor = [CTB colorWithHexString:@"#E7E7E7"];
    [View addSubview:lineView];
    
    UIButton *button = [CTB buttonType:UIButtonTypeCustom delegate:delegate to:View tag:tag title:nil img:@"绿色背景图/1"];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
    button.frame = CGRectMake(0, 0, 70, 63);
    return button;
}

+ (UIButton *)createMoreBtn:(int)tag title:(NSString *)title toV:(UIView *)View
{
    UIButton *button = [CTB buttonType:UIButtonTypeCustom delegate:self to:View tag:tag title:title img:@"点击效果/1"];
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    button.titleLabel.font = [UIFont systemFontOfSize:13];
    button.frame = GetRect(0, 0, 70, 63);
    
    return button;
}

- (void)CreateButton
{
    if (isArrayForBtn) {
        
        CGFloat h = 55.0;
        rectStart = CGRectMake(Screen_Width-130, 0, 130, 0);
        rectEnd = CGRectMake(Screen_Width-130, 0, 130, h*listButton.count);
        
        self.baseView = [[UIView alloc] initWithFrame:rectStart];
        self.baseView.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.baseView];
        
        int count = 0;
        for (NSDictionary *dicData in listButton) {
            NSString *btnTitle = dicData[@"title"];
            //NSString *btnImgName = dicData[@"imgName"];
            
            UIButton *button = [CTB buttonType:UIButtonTypeCustom delegate:self to:self.baseView tag:2 title:btnTitle img:@"按钮-选中效果/1"];
            button.frame = CGRectMake(0, h*count, 130, h);
            if(count>0){
                UIView *view = [[UIView alloc] init];
                [view setBackgroundColor:[CTB colorWithHexString:@"#CCCCCC" ]];
                view.frame=CGRectMake(0, h*count, 130, 0.269999999);
                [self.baseView addSubview:view];
            }
            [button setTitleColor:[CTB colorWithHexString:@"#808080"] forState:UIControlStateNormal];
            [CTB setBorderWidth:0 View:button,nil];
            
            count++;
        }
    }
}

- (void)setAction:(SEL)action
{
    if (action) {
        [self addTarget:self.delegate action:action forControlEvents:UIControlEventTouchDown];
    }
}

- (void)setBackgroundColor:(UIColor *)color opacity:(CGFloat)alpha
{
    const CGFloat *cs=CGColorGetComponents(color.CGColor);
    size_t index = CGColorGetNumberOfComponents(color.CGColor);
    
    if (index==2) {
        opacity = alpha * cs[1];
        self.backgroundColor = [UIColor colorWithRed:cs[0] green:cs[0] blue:cs[0] alpha:opacity];
    }
    if (index==3) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请重新选择颜色" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
    }
    if (index==4) {
        opacity = alpha * cs[3];
        self.backgroundColor = [UIColor colorWithRed:cs[0] green:cs[1] blue:cs[2] alpha:opacity];
    }
}

#pragma mark 自定义隐藏方式
- (void)hidden:(BOOL)hidden animation:(BOOL)animation
{
    CGFloat delay = 0.0;
    if (animation) {
        delay = 0.2;
        [self backControlStatusWith:hidden];
        if (hidden) {
            [self setAnimationWithHidden];
        }else{
            self.hidden = NO;
            [self setStatusWithView:self hidden:YES];
            self.baseView.frame = rectStart;
            [CTB setAnimationWith:self.baseView rect:rectEnd complete:select(showTextView) delegate:self];
        }
    }else{
        self.hidden = hidden;
        self.baseView.hidden = hidden;
        if (![NSStringFromCGRect(rectEnd) isEqualToString:@"{{6.9532229757889145e-310, 0}, {0, 0}}"]) {
            self.baseView.frame = rectEnd;
        }
    }
    
    if (hidden && _removeFromSuperViewWhenHide) {
        [self duration:delay action:select(removeFromSuperview)];
    }
}

#pragma mark 中间缩放隐藏方式
- (void)setHidden:(BOOL)isHidden animation:(BOOL)animation
{
    CGFloat delay = 0.0;
    if (animation) {
        delay = 0.2;
        if (isHidden) {
            NSArray *listValue = [CTB getAnimationData:false];
            [CTB exChangeOut:self.baseView dur:delay values:listValue];
            [CTB duration:delay block:^{
                self.hidden = YES;
            }];
        }else{
            self.hidden = NO;
            [CTB exChangeOut:self.baseView dur:delay values:nil];
        }
    }else{
        self.hidden = isHidden;
    }
    
    if (isHidden && _removeFromSuperViewWhenHide) {
        [self duration:delay action:select(removeFromSuperview)];
    }
}

- (void)removeFromSuperview
{
    [super removeFromSuperview];
}

- (void)backControlStatusWith:(BOOL)hidden
{
    if (hidden) {
        if ([self.delegate respondsToSelector:select(iControlWillHidden:)]) {
            [self.delegate iControlWillHidden:self];
        }
    }else{
        if ([self.delegate respondsToSelector:select(iControlWillShow:)]) {
            [self.delegate iControlWillShow:self];
        }
    }
}

- (void)setStartRect:(CGRect)startRect endRect:(CGRect)endRect
{
    rectStart = startRect;
    rectEnd = endRect;
}

- (void)setStatusWithView:(UIView *)View hidden:(BOOL)hidden
{
    self.baseView.hidden = NO;
    for (UIView *v in self.baseView.subviews) {
        if (childViewHidden) {
            //如果该值为YES,则子视图也隐藏状态也会改变
            v.hidden = hidden;
        }
    }
}

- (void)setAnimationWithHidden
{
    [self setStatusWithView:self hidden:YES];
    CGRect rect = rectStart;
    [CTB setAnimationWith:self.baseView rect:rect complete:select(hiddenTextView) delegate:self];
}

- (void)hiddenTextView
{
    self.hidden = YES;
    if (isRegistKeyboardNotice) {
        [self removeKeyboardNotifications];
    }
}

- (void)showTextView
{
    [self setStatusWithView:self hidden:NO];
    if (isRegistKeyboardNotice) {
        [self registerForKeyboardNotifications];
    }
}

- (void)setAnimationWith:(UIView *)View rect:(CGRect)aRect complete:(SEL)action
{
    if (childViewHidden) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        [UIView beginAnimations:nil context:context];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDuration:0.3];
        View.frame = aRect;
        [UIView setAnimationDidStopSelector:action];
        [UIView commitAnimations];
    }else{
        
    }
}

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector(keyboardWasHidden:) name:UIKeyboardDidHideNotification object:nil];
}

- (void)removeKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) keyboardWasShown:(NSNotification *) notif
{
    NSDictionary *info = [notif userInfo];
    NSValue *value = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGSize keyboardSize = [value CGRectValue].size;
    
    int height = keyboardSize.height;
    [self setAnimationWith:self.baseView rect:CGRectMake(self.baseView.frame.origin.x, self.frame.size.height-self.baseView.frame.size.height-height, self.baseView.frame.size.width, self.baseView.frame.size.height) complete:nil];
}

- (void) keyboardWasHidden:(NSNotification *) notif
{
//    NSDictionary *info = [notif userInfo];
//    
//    NSValue *value = [info objectForKey:UIKeyboardFrameBeginUserInfoKey];
//    CGSize keyboardSize = [value CGRectValue].size;
//    NSLog(@"keyboardWasHidden keyBoard:%f", keyboardSize.height);
//    // keyboardWasShown = NO;
}

- (void)ButtonEvents:(UIButton *)button
{
    if ([self.delegate respondsToSelector:select(MoreBtnEvents:)]) {
        [self.delegate MoreBtnEvents:button];
    }
}

//编辑状态将要改变时(return)
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        
        [textView resignFirstResponder];
    }
    return YES;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    self.baseView.layer.masksToBounds = YES;
}

@end
