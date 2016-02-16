//
//  MyDrawView.m
//  ImgSize
//
//  Created by Yin on 14-10-24.
//  Copyright (c) 2014年 caidan. All rights reserved.
//

#import "MyDrawView.h"

@interface MyDrawView ()
{
    UIBezierPath* bezier3Path;
}

@end

@implementation MyDrawView

@synthesize lRect,fillColor;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        fillColor = fillColor ?: [UIColor grayColor];
    }
    
    return self;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    backgroundColor = [UIColor clearColor];
    [super setBackgroundColor:backgroundColor];
}

- (void)changeFillColor:(UIColor *)color
{
    fillColor = color;
    [self setNeedsDisplay];
}

- (void)initCapacity:(CGRect)frame
{
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
    
//    //***************
//    CGContextRef content = UIGraphicsGetCurrentContext();
//    //获取画板
//    CGContextSetLineCap(content, kCGLineCapSquare);
//    //设置线条样式
//    CGContextSetLineWidth(content, 3.0);
//    //设置线条宽度
//    CGContextBeginPath(content);
//    //开始路径
//    CGContextMoveToPoint(content, 100, 100);
//    //起点
//    CGContextAddLineToPoint(content, 200, 100);
//    //移动到点
//    CGContextAddLineToPoint(content, 200, 200);
//    CGContextAddLineToPoint(content, 100, 200);
//    CGContextAddLineToPoint(content, 100, 100);
//    CGFloat color[] = {1.0,0,0,1.0};
//    //颜色数组，四个值
//    CGContextSetStrokeColor(content, color);
//    CGContextSetStrokeColorWithColor(content, [UIColor greenColor].CGColor);
//    //设置画笔颜色的两种方法
//    CGContextSetRGBFillColor(content, 1.0, 0, 0, 1.0);
//    //CGContextSetFillColorWithColor(line, [UIColor greenColor].CGColor);
//    //设置填充色的两种方法,先填充颜色，后调用画笔。
//    CGContextFillPath(content);
//    //填充
//    CGContextStrokePath(content);
//    //连接画笔
//    CGContextFillRect(content, CGRectMake(0, 0, 50, 50));
//    //用一个CGRect填充出一个矩形；
//    CGContextFillEllipseInRect(content, CGRectMake(100, 0, 50, 50));
//    //用一个CGRect填充一个圆形出来，x不等于y就是椭圆形了。
//    //得到上下文
//    CGContextRef ref = UIGraphicsGetCurrentContext();
//    //线宽设定
//    CGContextSetLineWidth(ref, 10.0);
//    //线的边角样式（圆角型）
//    CGContextSetLineCap(ref, kCGLineCapRound);
//    CGContextSetLineJoin(ref, kCGLineJoinRound);
}

- (void)drawFill
{
    if (!bezier3Path) {
        [self initCapacity:self.bounds];
    }else{
        [fillColor setFill];
        [bezier3Path fill];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
*/
- (void)drawRect:(CGRect)rect {
    // Drawing code
    [self drawFill];
}


@end
