//
//  iUIControl.h
//  UIConrol
//
//  Created by Yin on 14-4-5.
//  Copyright © 2014年 caidan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface iControl : UIControl
{
    CGRect rectStart;
    CGRect rectEnd;
}

@property (nonatomic,weak) id delegate;////sss
@property (nonatomic,assign) SEL action;
@property (nonatomic) BOOL isRegistKeyboardNotice;
@property (nonatomic) BOOL isArrayForBtn;
@property (nonatomic) BOOL removeFromSuperViewWhenHide;
@property (retain, nonatomic) NSArray *listButton;
@property (retain, nonatomic) id userInfo;//自定义变量

@property (nonatomic,readonly) CGFloat opacity;
@property (nonatomic,retain) UIView *baseView;

- (void)CreateButton;
- (void)setBackgroundColor:(UIColor *)backgroundColor opacity:(CGFloat)alpha;

@property (nonatomic) BOOL childViewHidden;//default is NO,if is YES,the subviews will is hidden
- (void)setStartRect:(CGRect)startRect endRect:(CGRect)endRect;//设置动画开始的位置到结束时的位置
- (void)hidden:(BOOL)hidden animation:(BOOL)animation;//使用该方法时必须设置上面的方法
- (void)setHidden:(BOOL)isHidden animation:(BOOL)animation;

- (void)registerForKeyboardNotifications;
- (void)removeKeyboardNotifications;

+ (iControl *)initWithTitle:(NSString *)title tag:(int)tag mode:(UIDatePickerMode)mode delegate:(id)delegate toV:(UIView *)toView sel:(SEL)action;
+ (UIButton *)CreateButtonWithImg:(NSString *)imgName title:(NSString *)title rect:(CGRect)rect tag:(int)tag toView:(UIView *)bottomView delegate:(id)delegate;
+ (UIButton *)createMoreBtn:(int)tag title:(NSString *)title toV:(UIView *)View;

@end

@protocol iControlDelegate <NSObject>

- (void)MoreBtnEvents:(UIButton *)button;
- (void)iControlWillShow:(iControl *)control;
- (void)iControlWillHidden:(iControl *)control;
- (void)datePickEvents:(UIButton *)button;

@end
