//
//  myKeyboardType.m
//  T
//
//  Created by Yinhaibo on 14-3-1.
//  Copyright (c) 2014年 Yinhaibo. All rights reserved.
//

#import "myKeyboardType.h"

@implementation myKeyboardType

@synthesize action,target,doneButton;
@synthesize isRegist,isShow;

+ (myKeyboardType *)sharedInstance
{
    static dispatch_once_t once;
    static myKeyboardType *sharedInstance;
    dispatch_once(&once, ^ {
        sharedInstance = [[myKeyboardType alloc] init];
    });
    return sharedInstance;
}

- (id)init
{
    keyboards = [super init];
    if (!self) {
        keyboards = [[myKeyboardType alloc] init];
    }
    return keyboards;
}

+(myKeyboardType *)init
{
    myKeyboardType *keyboard= [[myKeyboardType alloc] init];
    return keyboard;
}

+(UIKeyboardType)keyboardTypeTo:(id)delegate action:(SEL)action
{
    if (!delegate || !action) {
        return UIKeyboardTypeDefault;
    }
    
    myKeyboardType *keyboard = [myKeyboardType sharedInstance];
    keyboard.target = delegate;
    keyboard.action = action;
    return UIKeyboardTypeNumberPad;
}

+(void)addObserver
{
    myKeyboardType *keyboard = [myKeyboardType sharedInstance];
    if (!keyboard || keyboard.isRegist) {
        return;
    }
    
    //1. 先注册通知
    [[NSNotificationCenter defaultCenter] addObserver:keyboard selector:@selector(handleKeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:keyboard selector:@selector(handleKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    keyboard.isRegist = YES;
}

+(void)hidden
{
    myKeyboardType *keyboard = [myKeyboardType sharedInstance];
    if (!keyboard.doneButton.hidden)
    {
        keyboard.doneButton.hidden=YES;
    }
    //移除本类中的所有通知
    [[NSNotificationCenter defaultCenter] removeObserver:keyboard];
}

+(void)remove
{
    myKeyboardType *keyboard = [myKeyboardType sharedInstance];
    if (keyboard.doneButton.superview)
    {
        [keyboard.doneButton removeFromSuperview];
        keyboard.doneButton = nil;
    }
    //移除本类中的所有通知
    [[NSNotificationCenter defaultCenter] removeObserver:keyboard];
    keyboard.isRegist = NO;
}

//3.实现通知处理(点击完成按钮)
- (void)handleKeyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.325 animations:^{
        [myKeyboardType setRectWith:doneButton toY:Screen_Height];
    }completion:^(BOOL finished) {
        if (doneButton.superview)
        {
            [doneButton removeFromSuperview];
            doneButton = nil;
        }
    }];//
}

- (void)handleKeyboardWillShow:(NSNotification *)notification
{
    if (!target || !action || !isShow) {
        return;
    }
    //NSDictionary *info = [notification userInfo];
    //CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    //NSLog(@"%d,%@", keyboardType, info);
    //CGFloat normalKeyboardHeight = kbSize.height;//键盘高度
    
    // create custom button
    if (doneButton == nil)
    {
        doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [doneButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
        
        doneButton.frame = CGRectMake(0, Screen_Height, 106, 53);
        
        doneButton.adjustsImageWhenHighlighted = NO;
        [doneButton setTitle:@"完成" forState:UIControlStateNormal];
        [doneButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    }
    if (doneButton.hidden) {
        doneButton.hidden=NO;
    }
    
    // locate keyboard view
    UIWindow* tempWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:1];
    
    
    
    if (doneButton.superview == nil)
    {
        [tempWindow addSubview:doneButton];    // 注意这里直接加到window上
    }
    
    [UIView animateWithDuration:0.39
                     animations:^{
                         [myKeyboardType setRectWith:doneButton toY:Screen_Height - 53];
                     }
                     completion:^(BOOL finish) {
                         //
                     }];
}

+(void)setRectWith:(UIView *)View toY:(CGFloat)y
{
    View.frame = CGRectMake(View.frame.origin.x, y, View.frame.size.width, View.frame.size.height);
}

@end
