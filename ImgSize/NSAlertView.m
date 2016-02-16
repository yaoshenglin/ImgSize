//
//  NSAlertView.m
//  AppCaidan
//
//  Created by Yin on 14-9-27.
//  Copyright (c) 2014年 caidan. All rights reserved.
//

#import "NSAlertView.h"
#import "CTB.h"

@interface NSAlertView ()
{
    UILabel *lblTitle;
    UILabel *lblMsg;
    UIButton *btnCancel;
    UIButton *btnOK;
    UITextField *txtPlain;//普通
    UITextField *txtPW;//密码
    UIView *baseView;
}

@end

@implementation NSAlertView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //[self addTarget:self action:select(ButtonEvents:) forControlEvents:UIControlEventTouchDown];
        self.backgroundColor = [UIColor colorWithWhite:0.35 alpha:0.35];
    }
    
    return self;
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles
{
    UIWindow *window = [[UIApplication sharedApplication] windows].lastObject;
    CGRect frame = window.bounds;
    if ((self = [self initWithFrame:frame])) {
        _delegate = delegate;
        baseView = [[UIView alloc] initWithFrame:CGRectMake(20, Screen_Height/2-80, Screen_Width-40, 160)];
        baseView.backgroundColor = [UIColor whiteColor];
        baseView.layer.cornerRadius = 8;
        baseView.layer.masksToBounds = YES;
        [self addSubview:baseView];
        
        lblTitle = [CTB labelTag:1 toView:baseView text:title wordSize:18];
        lblTitle.frame = CGRectMake(0, 0, GetVWidth(baseView), 40);
        lblTitle.textColor = [UIColor whiteColor];
        lblTitle.backgroundColor = [CTB colorWithHexString:@"#00BD9E"];
        CGSize size = [CTB getSizeWith:lblTitle.text font:lblTitle.font size:CGSizeMake(GetVWidth(lblTitle), 2000)];
        CGFloat msgH = MAX(30.0, MIN(size.height+20, Screen_Height-110));
        [lblTitle setSizeToH:msgH];
        
        //UIView *maskView = [[UIView alloc] initWithFrame:lblTitle.bounds];
        //maskView.backgroundColor = [UIColor redColor];
        //lblTitle.maskView = maskView;
        
        lblMsg = [CTB labelTag:2 toView:baseView text:message wordSize:17];
        CGFloat lblTitle_h = GetVMaxY(lblTitle);
        lblMsg.frame = CGRectMake(20, lblTitle_h+5, GetVWidth(baseView)-40, 70);
        size = [CTB getSizeWith:message font:lblMsg.font size:CGSizeMake(GetVWidth(lblMsg), 2000)];
        msgH = MAX(30.0, MIN(size.height, Screen_Height-110));
        [lblMsg setSizeToH:msgH];
        
        CGFloat w = GetVWidth(baseView)/2;
        CGFloat y = GetVMaxY(lblMsg)+5;
        btnCancel = [CTB buttonType:UIButtonTypeCustom delegate:self to:baseView tag:0 title:cancelButtonTitle img:@"按钮-选中效果/1"];
        btnCancel.frame = CGRectMake(0, y, w, 40);
        [btnCancel setNormalTitleColor:[CTB colorWithHexString:@"#00BD9E"]];
        
        btnOK = [CTB buttonType:UIButtonTypeCustom delegate:self to:baseView tag:1 title:otherButtonTitles img:@"按钮-选中效果/1"];
        btnOK.frame = CGRectMake(w, y, w, 40);
        [btnOK setNormalTitleColor:[CTB colorWithHexString:@"#00BD9E"]];
        [CTB setBorderWidth:0.5 View:btnCancel, nil];
        [CTB setBorderWidth:0.5 View:btnOK, nil];
        [baseView setSizeToH:GetVMaxY(btnOK)];
        
        BOOL isExistBtn = YES;
        if (!cancelButtonTitle && !otherButtonTitles) {
            isExistBtn = NO;
            [baseView setSizeToH:GetVHeight(baseView)-40];
            [btnOK removeFromSuperview];
            [btnCancel removeFromSuperview];
        }
        else if (!cancelButtonTitle) {
            [btnOK setSizeToW:w*2];
            [btnCancel removeFromSuperview];
        }
        else if (!otherButtonTitles) {
            [btnCancel setSizeToW:w*2];
            [btnOK removeFromSuperview];
        }
        
        if (!title && !message) {
            [baseView setSizeToH:40];
            [lblMsg removeFromSuperview];
            if (isExistBtn) {
                [lblTitle removeFromSuperview];
            }else{
                lblTitle.text = @"";
                lblTitle.backgroundColor = [UIColor whiteColor];
            }
        }
        else if (!title) {
            [lblMsg removeFromSuperview];
            lblTitle.text = title ?: message;
            lblTitle.textColor = [UIColor blackColor];
            lblTitle.backgroundColor = [UIColor whiteColor];
            size = [CTB getSizeWith:lblTitle.text font:lblTitle.font size:CGSizeMake(GetVWidth(lblTitle), 2000)];
            msgH = MAX(30.0, MIN(size.height+20, Screen_Height-110));
            lblTitle.frame = GetRect(10, 0, GetVWidth(baseView)-20, msgH);
            [baseView setSizeToH:GetVHeight(lblTitle)];
        }
    }
    return self;
}

- (void)setAlertViewStyle:(UIAlertViewStyle)alertViewStyle
{
    _alertViewStyle = alertViewStyle;
    
    CGFloat h = MAX(GetVHeight(btnOK), GetVHeight(btnCancel));
    CGFloat y = GetVHeight(lblTitle);
    CGFloat w = GetVWidth(baseView);
    if (alertViewStyle == UIAlertViewStylePlainTextInput) {
        if (!txtPlain) {
            [baseView setSizeToH:y+h+40];
            UIView *bottom = [[UIView alloc] initWithFrame:CGRectMake(0, y, w, 60)];
            bottom.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
            txtPlain = [CTB textFieldTag:1 holderTxt:@"" V:bottom delegate:self];
            txtPlain.frame = CGRectMake(10, 15, w-20, 30);
            CGFloat value = 10.0f;
            [txtPlain addTarget:self action:@selector(textFieldEditingDidBegin:) forControlEvents:UIControlEventEditingDidBegin];
            [txtPlain addTarget:self action:@selector(textFieldEditingDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
            [CTB setLeftViewWithWidth:value textField:txtPlain, nil];
            [CTB setBorderWidth:0.5 View:txtPlain, nil];
            [self addOtherView:bottom];
        }
        
        [txtPlain becomeFirstResponder];
        
        lblMsg.hidden = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    }
    else if (alertViewStyle == UIAlertViewStyleDefault) {
        [baseView setSizeToH:y+h+GetVHeight(lblMsg)];
        lblMsg.hidden = NO;
    }
}

- (void)addOtherView:(UIView *)subView
{
    CGFloat h = MAX(GetVHeight(btnOK), GetVHeight(btnCancel));
    CGFloat y = GetVHeight(lblTitle);
    [baseView setSizeToH:y+h+GetVHeight(subView)];
    [btnOK setOriginY:GetVHeight(baseView)-h];
    [btnCancel setOriginY:GetVHeight(baseView)-h];
    [baseView addSubview:subView];
}

- (NSInteger)addButtonWithTitle:(NSString *)title
{
    return 1;
}

- (void)show
{
    [baseView setCenterX:Screen_Width/2 Y:Screen_Height/2];
    NSArray *listWindows = [[UIApplication sharedApplication] windows];
    UIWindow *window = listWindows.lastObject;
    [window addSubview:self];
    self.alpha = 0.05;
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.alpha = 1.0;
                     }
                     completion:^(BOOL finished) {
                         //动画完成,可为空
                     }];
}

- (void)keyboardWasShown:(NSNotification *) notif
{
    NSDictionary *info = [notif userInfo];
    NSValue *value = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGSize keyboardSize = [value CGRectValue].size;
    
    //NSLog(@"keyBoard:%f", keyboardSize.height);  //216
    CGFloat centerY = Screen_Height/2-keyboardSize.height/2;
    ///keyboardWasShown = YES;
    [UIView animateWithDuration:0.3
                     animations:^{
                         [baseView setCenterY:centerY];
                     }
                     completion:^(BOOL finished) {
                         //动画完成,可为空
                         [self setSizeToH:Screen_Height-keyboardSize.height];
                     }];
}

- (void)textFieldEditingDidBegin:(UITextField *)textField
{
    
}

- (void)textFieldEditingDidEnd:(UITextField *)textField
{
    [self setSizeToH:Screen_Height];
    [UIView animateWithDuration:0.3
                     animations:^{
                         [baseView setCenterY:GetVHeight(self)/2];
                     }
                     completion:^(BOOL finished) {
                         //动画完成,可为空
                     }];
}

- (UITextField *)textFieldAtIndex:(NSInteger)textFieldIndex
{
    UITextField *textField = nil;
    if (textFieldIndex == 0) {
        textField = txtPlain;
    }
    else if (textFieldIndex == 1) {
        textField = txtPW;
    }
    
    return textField;
}

- (NSString *)buttonTitleAtIndex:(NSInteger)buttonIndex
{
    NSString *title = nil;
    if (buttonIndex == 0) {
        title = btnCancel.currentTitle;
    }
    else if (buttonIndex == 1) {
        title = btnOK.currentTitle;
    }
    
    return title;
}

- (void)ButtonEvents:(UIButton *)button
{
    if (button == btnCancel || button == btnOK || [button isEqual:self]) {
        [self removeFromSuperview];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    }
    
    if (![button isEqual:self]) {
        if ([_delegate respondsToSelector:@selector(alertView:clickedButtonAtIndex:)]) {
            [_delegate alertView:(UIAlertView *)self clickedButtonAtIndex:button.tag];
        }
    }
}

- (void)removeFromSuperview
{
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.alpha = 0.05;
                     }
                     completion:^(BOOL finished) {
                         //动画完成,可为空
                         [super removeFromSuperview];
                     }];
}

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated
{
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
