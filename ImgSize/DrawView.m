//
//  DrawView.m
//  ImgSize
//
//  Created by xy on 16/4/19.
//  Copyright © 2016年 caidan. All rights reserved.
//

#import "DrawView.h"

@implementation DrawView

- (instancetype)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        self.backgroundColor = [UIColor whiteColor];
    }
    
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    //在view上面画了一个绿色填充，红色边框的三角形
    //Define a Path
    CGContextRef context = NULL;
    CGContextBeginPath(context);
    //Move around, add lines or arcs to the path
    CGContextMoveToPoint(context, 75, 10);
    CGContextAddLineToPoint(context, 160, 150);
    CGContextAddLineToPoint(context, 10, 150);
    //Close the path (connects the last point back to the first)
    CGContextClosePath(context); // not strictly required
    //Actually the above draws nothing (yet)!
    //You have to set the graphics state and then fill/stroke the above path to see anything.
    [[UIColor greenColor] setFill]; // object-oriented convenience method (more in a moment) [[UIColor redColor] setStroke];
    CGContextDrawPath(context, kCGPathFillStroke); //kCGPathFillStrokeisaconstant
}

@end
