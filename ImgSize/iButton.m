//
//  iButton.m
//  ImgSize
//
//  Created by Yin on 14-6-10.
//  Copyright (c) 2014年 caidan. All rights reserved.
//

#import "iButton.h"
#import "CTB.h"

@implementation iButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        imgViewNormal = [[UIImageView alloc] init];
        imgViewNormal.userInteractionEnabled = YES;
        [self addSubview:imgViewNormal];
        
        imgViewHighlighted = [[UIImageView alloc] init];
        imgViewHighlighted.userInteractionEnabled = YES;
        [self addSubview:imgViewHighlighted];
        
        [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:select(refreshState) userInfo:nil repeats:YES];
    }
    return self;
}

- (void)setImage:(UIImage *)image forState:(UIControlState)state
{
    if (state == UIControlStateNormal) {
        imgViewNormal.image = image;
        [imgViewNormal setSizeToW:image.size.width height:image.size.height];
        imgViewNormal.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    }
    else if (state == UIControlStateHighlighted) {
        imgViewHighlighted.image = image;
        [imgViewHighlighted setSizeToW:image.size.width height:image.size.height];
        imgViewHighlighted.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    }
}

- (void)setBackgroundImage:(UIImage *)image forState:(UIControlState)state
{
    if (state == UIControlStateNormal) {
        imgViewNormal.image = image;
        [imgViewNormal setSizeToW:image.size.width height:image.size.height];
        imgViewNormal.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    }
    else if (state == UIControlStateHighlighted) {
        imgViewHighlighted.image = image;
        [imgViewHighlighted setSizeToW:image.size.width height:image.size.height];
        [imgViewHighlighted setToParentCenter];
    }
}

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents
{
    delegate = target;
    actionMethod = action;
    [super addTarget:self action:select(DownEvents:) forControlEvents:UIControlEventTouchDown];
    [super addTarget:self action:select(UpInsideEvents:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)DownEvents:(UIButton *)button
{
    imgViewNormal.hidden = YES;
    imgViewHighlighted.hidden = NO;
}

- (void)UpInsideEvents:(UIButton *)button
{
    imgViewNormal.hidden = NO;
    imgViewHighlighted.hidden = YES;
    
    UIEvent *event = [[UIEvent alloc] init];
    [self sendAction:actionMethod to:delegate forEvent:event];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    [self refreshState];
    [self reSetImgSize];
}

- (void)refreshState
{
    if (self.highlighted) {
        imgViewNormal.hidden = YES;
        imgViewHighlighted.hidden = NO;
    }else{
        imgViewNormal.hidden = NO;
        imgViewHighlighted.hidden = YES;
    }
}

- (void)reSetImgSize
{
    UIImage *imgNormal = imgViewNormal.image;
    UIImage *imgHighlighted = imgViewHighlighted.image;
    if (imgNormal.size.width>self.frame.size.width || imgNormal.size.height>self.frame.size.height) {
        CGSize size = [self getSizeBy:imgNormal];
        [imgViewNormal setSizeToW:size.width height:size.height];
        [imgViewNormal setToParentCenter];
    }
    if (imgHighlighted.size.width>self.frame.size.width || imgHighlighted.size.height>self.frame.size.height) {
        CGSize size = [self getSizeBy:imgHighlighted];
        [imgViewHighlighted setSizeToW:size.width height:size.height];
        [imgViewHighlighted setToParentCenter];
    }
}

- (CGSize)getSizeBy:(UIImage *)image
{
    if (image.size.width*self.frame.size.height>image.size.height*self.frame.size.width) {
        return CGSizeMake(self.frame.size.width, self.frame.size.width*image.size.height/image.size.width);
    }
    
    return CGSizeMake(self.frame.size.height*image.size.width/image.size.height, self.frame.size.height);
}

@end
