//
//  ChatBottomView.h
//  AppCaidan
//
//  Created by Yin on 14-5-22.
//  Copyright (c) 2014年 caidan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iButton.h"

//typedef NS_ENUM(NSInteger, UIGestureRecognizerState) {
//    UIGestureRecognizerStatePossible = 0,
//    UIGestureRecognizerStateBegan = 1,
//    UIGestureRecognizerStateChanged = 2,
//    UIGestureRecognizerStateEnded = 3,
//    UIGestureRecognizerStateCancelled = 4,
//    UIGestureRecognizerStateFailed = 5,
//    UIGestureRecognizerStateRecognized = 3
//};

@interface ChatBottomView : UIView<UITextFieldDelegate>

@property (nonatomic) BOOL isSendVoice;
@property (weak, nonatomic) id delegate;
@property (retain, nonatomic) UITextField *txtInputMsg;//信息输入框
@property (retain, nonatomic) UIButton *btnBrow;//表情
@property (retain, nonatomic) iButton *btnVoice;//语音
@property (retain, nonatomic) UILabel *lblRecordTime;//录音计时

@end

@protocol ChatBottomDelegate <NSObject>

- (void)showEmojiView;
- (void)SendWordMsg:(UIButton *)button;

@end
