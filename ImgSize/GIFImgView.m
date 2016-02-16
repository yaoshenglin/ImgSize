//
//  GIFImgView.m
//  ImgSize
//
//  Created by Yin on 15/9/22.
//  Copyright © 2015年 caidan. All rights reserved.
//

#import "GIFImgView.h"

CGRect CGRectWith(CGPoint point, CGSize size)
{
    CGRect rect;
    rect.origin.x = point.x; rect.origin.y = point.y;
    rect.size.width = size.width; rect.size.height = size.height;
    return rect;
}

@interface GIFImgView ()
{
    NSInteger i;
    NSTimer *timer;
    UIImageView *imageView;
}

@end

@implementation GIFImgView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        imageView = [[UIImageView alloc] init];
        imageView.frame = self.bounds;
        [self addSubview:imageView];
    }
    
    return self;
}

- (instancetype)initWithImage:(UIImage *)image
{
    self = [super init];
    if (self) {
        if (image) {
            //CGSize size = image.size;
            self.frame = CGRectWith(CGPointZero, image.size);
            imageView = [[UIImageView alloc] init];
            imageView.frame = self.bounds;
            imageView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
            [self addSubview:imageView];
        }
    }
    
    return self;
}

- (BOOL)isAnimating
{
    BOOL isValid = [timer isValid];
    return isValid;
}

- (void)startAnimating
{
    if (![timer isValid] && _count > 0) {
        NSTimeInterval ti = _duration/_count;//时间间隔
        timer = [NSTimer scheduledTimerWithTimeInterval:ti target:self selector:@selector(playAnimation) userInfo:nil repeats:YES];
    }
}

- (void)stopAnimating
{
    if ([timer isValid]) {
        [timer invalidate];
    }
}

- (void)playAnimation
{
    if (i < _count-1) {
        i++;
    }else{
        i = 0;
    }
    CGFloat w = _image.size.width/_count;
    CGFloat h = _image.size.height;
    CGFloat scale = _image.scale;
    CGRect rect = CGRectMake(w*i*scale, 0, w*scale, h*scale);//截取位置尺寸
    UIImage *img = [self getSubImage:_image rect:rect];//截取图像
    [UIView animateWithDuration:0.1 animations:^{
        imageView.image = img;
    }];
}

#pragma mark 截取部分图像
- (UIImage *)getSubImage:(UIImage *)image rect:(CGRect)rect
{
    if (!image) return nil;
    CGImageRef cgImage = CGImageCreateWithImageInRect(image.CGImage, rect);
    UIImage *newImage = [UIImage imageWithCGImage:cgImage scale:image.scale orientation:UIImageOrientationUp];
    CGImageRelease(cgImage);
    return newImage;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
