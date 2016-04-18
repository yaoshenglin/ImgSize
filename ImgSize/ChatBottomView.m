//
//  ChatBottomView.m
//  AppCaidan
//
//  Created by Yin on 14-5-22.
//  Copyright (c) 2014年 caidan. All rights reserved.
//  Tap（点一下）、Pinch（二指往內或往外拨动）、Rotation（旋转）、Swipe（滑动，快速移动）、Pan （拖移，慢速移动）以及 LongPress（长按）

#import "ChatBottomView.h"
#import "CTB.h"
#import <AVFoundation/AVFoundation.h>

@interface ChatBottomView ()
{
    AVAudioPlayer *mp3;
}

@end

@implementation ChatBottomView

@synthesize isSendVoice;
@synthesize btnBrow,btnVoice;
@synthesize txtInputMsg,lblRecordTime;
@synthesize delegate;

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
    //底部输入信息框
    txtInputMsg=[[UITextField alloc]initWithFrame:CGRectMake(45,7, Screen_Width-90, 30)];
    txtInputMsg.delegate = self;
    [txtInputMsg setBorderStyle:UITextBorderStyleRoundedRect];
    [self addSubview:txtInputMsg];
    
    //表情
    btnBrow=[[UIButton alloc]initWithFrame:CGRectMake(7, 7, 30, 30)];
    btnBrow.tag = 1;
    [btnBrow addTarget:self action:@selector(SendBrow:) forControlEvents:UIControlEventTouchUpInside];
    [btnBrow setImage:[UIImage imageNamed:@"底部表情"] forState:(UIControlStateNormal)];
    [self addSubview:btnBrow];
    
    //语音
    btnVoice = [iButton buttonWithType:UIButtonTypeCustom];
    btnVoice.frame = CGRectMake(Screen_Width-44, 0, 44, 44);
    [btnVoice setImage:[UIImage imageNamed:@"底部语音图标"] forState:UIControlStateNormal];
    [btnVoice setImage:[UIImage imageNamed:@"语音-绿"] forState:UIControlStateHighlighted];
    [btnVoice setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    
    [btnVoice addTarget:self action:@selector(startRecord:) forControlEvents:UIControlEventTouchDown];
    [btnVoice addTarget:self action:@selector(stopRecord:) forControlEvents:UIControlEventTouchUpInside];
    
//    btnVoice.backgroundColor = [CTB colorWithHexString:@"#E5E5E5"];
    [self addSubview:btnVoice];
    isSendVoice = YES;
    
    //录音计时
    lblRecordTime = [CTB labelTag:1 toView:self text:@"00:00" wordSize:15];
    lblRecordTime.textAlignment = NSTextAlignmentLeft;
    lblRecordTime.frame = CGRectMake(50, 7, Screen_Width-95, 30);
    lblRecordTime.hidden = YES;
    lblRecordTime.userInteractionEnabled = YES;
    lblRecordTime.backgroundColor = [CTB colorWithHexString:@"#E5E5E5"];
    
    UIPanGestureRecognizer *panPress = [[UIPanGestureRecognizer alloc] initWithTarget:self action:select(PanEvents:)];
    [self addGestureRecognizer:panPress];
}

- (void)SendBrow:(UIButton *)button
{
    [self setPlayFromFile:@"voice_note_error.wav"];
    if ([delegate respondsToSelector:select(showEmojiView)]) {
        [delegate showEmojiView];
    }
}

- (void)startRecord:(UIButton *)button
{
    NSLog(@"按下");
    if (!isSendVoice) {
        return;
    }
    
    lblRecordTime.hidden = NO;
    txtInputMsg.hidden = YES;
    
    [btnBrow setImage:[UIImage imageNamed:@"语音-红"] forState:UIControlStateNormal];
    [btnVoice setImage:[UIImage imageNamed:@"语音-绿"] forState:UIControlStateNormal];
    
    if ([delegate respondsToSelector:select(startRecord:)]) {
        [delegate startRecord:button];
    }
}

- (void)stopRecord:(UIButton *)button
{
    NSLog(@"弹起");
    [self textFieldShouldReturn:txtInputMsg];
    
    if (isSendVoice) {
        lblRecordTime.hidden = YES;
        txtInputMsg.hidden = NO;
        
        [btnVoice setImage:[UIImage imageNamed:@"底部语音图标"] forState:UIControlStateNormal];
        [btnBrow setImage:[UIImage imageNamed:@"底部表情"] forState:UIControlStateNormal];
        
        if ([delegate respondsToSelector:select(stopRecord:)]) {
            [delegate stopRecord:button];
        }
    }else{
        isSendVoice = YES;
        [btnVoice setImage:[UIImage imageNamed:@"底部语音图标"] forState:UIControlStateNormal];
        [btnVoice setImage:[UIImage imageNamed:@"语音-绿"] forState:UIControlStateHighlighted];
        if (txtInputMsg.text.length<=0) {
            [CTB showMsg:@"不能发送内容"];
            return;
        }
        if ([delegate respondsToSelector:select(SendWordMsg:)]) {
            [delegate SendWordMsg:button];
        }
        txtInputMsg.text = @"";
    }
}

- (void)PanEvents:(UIPanGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        NSLog(@"拖动开始");
    }
    else if (gesture.state == UIGestureRecognizerStateEnded) {
        NSLog(@"取消录音");
        
        CGPoint point = [gesture translationInView:lblRecordTime];
        NSLog(@"x = %f",point.x);
        
        lblRecordTime.hidden = YES;
        txtInputMsg.hidden = NO;
        
        [btnVoice setImage:[UIImage imageNamed:@"底部语音图标"] forState:UIControlStateNormal];
        [btnBrow setImage:[UIImage imageNamed:@"底部表情"] forState:UIControlStateNormal];
        
        if ([delegate respondsToSelector:select(stopRecord:)]) {
            [delegate stopRecord:nil];
        }
    }
}

#pragma mark - =======textField===================
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if ([delegate respondsToSelector:select(textFieldShouldBeginEditing:)]) {
        return [delegate textFieldShouldBeginEditing:textField];
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (range.length==0) {
        if (textField.text.length>0 || string.length>0) {
            isSendVoice = NO;
            [btnVoice setImage:[UIImage imageNamed:@"发送"] forState:UIControlStateNormal];
            [btnVoice setImage:[UIImage imageNamed:@"发送"] forState:UIControlStateHighlighted];
        }else{
            isSendVoice = YES;
            [btnVoice setImage:[UIImage imageNamed:@"底部语音图标"] forState:UIControlStateNormal];
            [btnVoice setImage:[UIImage imageNamed:@"语音-绿"] forState:UIControlStateHighlighted];
        }
    }
    if (range.length==1) {
        if (string.length==0 && textField.text.length==1) {
            isSendVoice = YES;
            [btnVoice setImage:[UIImage imageNamed:@"底部语音图标"] forState:UIControlStateNormal];
            [btnVoice setImage:[UIImage imageNamed:@"语音-绿"] forState:UIControlStateHighlighted];
        }else{
            isSendVoice = NO;
            [btnVoice setImage:[UIImage imageNamed:@"发送"] forState:UIControlStateNormal];
            [btnVoice setImage:[UIImage imageNamed:@"发送"] forState:UIControlStateHighlighted];
        }
    }
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return [delegate textFieldShouldEndEditing:textField];
}

//点击return执行的方法
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //取消键盘的第一响应者，就会实现键盘自动下去
    [txtInputMsg resignFirstResponder];
    
    if (txtInputMsg.text.length>0) {
        isSendVoice = NO;
        [btnVoice setImage:[UIImage imageNamed:@"发送"] forState:UIControlStateNormal];
        [btnVoice setImage:[UIImage imageNamed:@"发送"] forState:UIControlStateHighlighted];
    }else{
        isSendVoice = YES;
        [btnVoice setImage:[UIImage imageNamed:@"底部语音图标"] forState:UIControlStateNormal];
        [btnVoice setImage:[UIImage imageNamed:@"语音-绿"] forState:UIControlStateHighlighted];
    }
    
    return [delegate textFieldShouldReturn:textField];
}

#pragma mark 准备播放
- (void)setPlayFromFile:(NSString *)fileName
{
    NSString *currentSoundFilePath = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
    NSURL *currentFileURL = [NSURL fileURLWithPath:currentSoundFilePath];
    mp3 = [[AVAudioPlayer alloc] initWithContentsOfURL:currentFileURL error:nil];
    //mp3.numberOfLoops = 1;//播放次数 0为1次 1为两次
    mp3.volume = 1;//播放音量
    [mp3 prepareToPlay];
    NSString *totalTime = [NSString stringWithFormat:@"%.0fs",mp3.duration];
    NSLog(@"%@",totalTime);
    [mp3 play];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}

@end
