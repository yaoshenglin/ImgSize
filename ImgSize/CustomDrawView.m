//
//  CustomDrawView.m
//  fafwaef
//
//  Created by Yin on 14-4-1.
//  Copyright © 2014年 caidan. All rights reserved.
//

#import "CustomDrawView.h"
#import "CTB.h"

@interface CustomDrawView ()
{
    UIBezierPath* bezier3Path;
}

@end

@implementation CustomDrawView

@synthesize lRect,fillColor;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

+ (CustomDrawView *)drawViewWithFrame:(CGRect)rect lRect:(CGRect)scanRect
{
    CustomDrawView *baseView = [[CustomDrawView alloc] initWithFrame:rect];
    baseView.backgroundColor = [UIColor clearColor];
    baseView.userInteractionEnabled = YES;
    baseView.lRect = scanRect;
    baseView.fillColor = [UIColor redColor];
    
    return baseView;
}

- (void)drawFill
{
    if (!bezier3Path) {
        CGRect frame = self.bounds;
        //// Bezier 3 Drawing
        bezier3Path = UIBezierPath.bezierPath;
        [bezier3Path moveToPoint: CGPointMake(GetMaxX(lRect), GetMinY(lRect))];     //第一个点
        [bezier3Path addLineToPoint: CGPointMake(GetMinX(lRect), GetMinY(lRect))];  //第二个点
        [bezier3Path addLineToPoint: CGPointMake(GetMinX(lRect), GetMaxY(lRect))];  //第三个点
        [bezier3Path addLineToPoint: CGPointMake(GetMaxX(lRect), GetMaxY(lRect))];  //第四个点
        [bezier3Path addLineToPoint: CGPointMake(GetMaxX(lRect), GetMinY(lRect))];  //回到原点
        [bezier3Path closePath];
        [bezier3Path moveToPoint: CGPointMake(GetMaxX(frame), GetMinY(frame))];
        [bezier3Path addCurveToPoint: CGPointMake(GetMaxX(frame), GetMaxY(frame)) controlPoint1: CGPointMake(GetMaxX(frame), GetMinY(frame)) controlPoint2: CGPointMake(GetMaxX(frame), GetMaxY(frame))];
        [bezier3Path addLineToPoint: CGPointMake(GetMinX(frame), GetMaxY(frame))];
        [bezier3Path addLineToPoint: CGPointMake(GetMinX(frame), GetMinY(frame))];
        [bezier3Path addLineToPoint: CGPointMake(GetMaxX(frame), GetMinY(frame))];
        [bezier3Path closePath];
        [fillColor setFill];
        [bezier3Path fill];
    }else{
        [fillColor setFill];
        [bezier3Path fill];
    }
}

- (void)changeFillColor:(UIColor *)color
{
    fillColor = color;
    [self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    [self drawFill];
}

@end
