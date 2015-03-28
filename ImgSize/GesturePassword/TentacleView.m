//
//  TentacleView.m
//  GesturePassword
//  触摸事件
//  Created by hb on 14-8-23.
//  Copyright (c) 2014年 黑と白の印记. All rights reserved.
//

#import "TentacleView.h"
#import "GesturePasswordButton.h"

@implementation TentacleView {
    CGPoint lineStartPoint;
    CGPoint lineEndPoint;
    
    NSMutableArray * touchesArray;
    NSMutableArray * touchedArray;
    BOOL success;
}
@synthesize buttonArray;
@synthesize rerificationDelegate;
@synthesize resetDelegate;
@synthesize touchBeginDelegate;
@synthesize style;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        touchesArray = [[NSMutableArray alloc]initWithCapacity:0];
        touchedArray = [[NSMutableArray alloc]initWithCapacity:0];
        [self setBackgroundColor:[UIColor clearColor]];
        [self setUserInteractionEnabled:YES];
        success = YES;
        lineC = [GesturePasswordButton colorWithHexString:defaultColor];
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint touchPoint;
    UITouch *touch = [touches anyObject];
    [touchesArray removeAllObjects];
    [touchedArray removeAllObjects];
    [touchBeginDelegate gestureTouchBegin];
    success = YES;
    if (touch) {
        touchPoint = [touch locationInView:self];
        for (int i=0; i<buttonArray.count; i++) {
            GesturePasswordButton * buttonTemp = ((GesturePasswordButton *)[buttonArray objectAtIndex:i]);
            [buttonTemp setSuccess:YES];
            [buttonTemp setSelected:NO];
            if (CGRectContainsPoint(buttonTemp.frame,touchPoint)) {
                CGPoint point = buttonTemp.center;//圆形按钮的中心点
                NSDictionary * dict = @{@"x":@(point.x),
                                        @"y":@(point.y)};
                [touchesArray addObject:dict];
                lineStartPoint = touchPoint;
            }
            [buttonTemp setNeedsDisplay];
        }
        
        [self setNeedsDisplay];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint touchPoint;
    UITouch *touch = [touches anyObject];
    if (touch) {
        touchPoint = [touch locationInView:self];
        for (int i=0; i<buttonArray.count; i++) {
            GesturePasswordButton * buttonTemp = ((GesturePasswordButton *)[buttonArray objectAtIndex:i]);
            if (CGRectContainsPoint(buttonTemp.frame,touchPoint)) {
                //如果该点在这个按钮所在区域
                if ([touchedArray containsObject:@(i)]) {
                    //如果数组中包含该点
                    lineEndPoint = touchPoint;
                    [self setNeedsDisplay];
                    return;
                }
                
                [touchedArray addObject:@(i)];
                [buttonTemp setSelected:YES];
                [buttonTemp setNeedsDisplay];
                CGPoint point = buttonTemp.center;//圆形按钮的中心点
                NSDictionary *dict = @{@"x":@(point.x),
                                       @"y":@(point.y),
                                       @"num":@(i)};
                [touchesArray addObject:dict];
                break;
            }
        }
        lineEndPoint = touchPoint;
        [self setNeedsDisplay];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSMutableString * resultString = [NSMutableString string];
    for ( NSDictionary * num in touchesArray ){
        if(![num objectForKey:@"num"]) break;
        NSString *string = [NSString stringWithFormat:@"%@",num[@"num"]];
        [resultString appendString:string];
    }
    if(style == Style_Verify){
        success = [rerificationDelegate verification:resultString];
    }
    else {
        success = [resetDelegate resetPassword:resultString];
    }
    
    for (int i=0; i<touchesArray.count; i++) {
        NSInteger selection = [touchesArray[i][@"num"] intValue];
        GesturePasswordButton *buttonTemp = ((GesturePasswordButton *)[buttonArray objectAtIndex:selection]);
        [buttonTemp setSuccess:success];
        [buttonTemp setNeedsDisplay];
    }
    [self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    //绘画线条
    for (int i=0; i<touchesArray.count; i++) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        if (![[touchesArray objectAtIndex:i] objectForKey:@"num"]) { //防止过快滑动产生垃圾数据
            [touchesArray removeObjectAtIndex:i];
            continue;
        }
        if (success) {
            //CGContextSetRGBStrokeColor(context, 2/255.f, 174/255.f, 240/255.f, 0.7);//线条颜色
            CGContextSetRGBStrokeColor(context, lineC[0], lineC[1], lineC[2], 0.7);
        }
        else {
            CGContextSetRGBStrokeColor(context, 208/255.f, 36/255.f, 36/255.f, 0.7);//红色
        }
        
        CGContextSetLineWidth(context,5);
        CGContextMoveToPoint(context, [[[touchesArray objectAtIndex:i] objectForKey:@"x"] floatValue], [[[touchesArray objectAtIndex:i] objectForKey:@"y"] floatValue]);
        if (i<touchesArray.count-1) {
            CGContextAddLineToPoint(context, [[[touchesArray objectAtIndex:i+1] objectForKey:@"x"] floatValue],[[[touchesArray objectAtIndex:i+1] objectForKey:@"y"] floatValue]);
        }
        else{
            if (success) {
                CGContextAddLineToPoint(context, lineEndPoint.x,lineEndPoint.y);
            }
        }
        CGContextStrokePath(context);
    }
}

- (void)enterArgin
{
    [touchesArray removeAllObjects];
    [touchedArray removeAllObjects];
    for (int i=0; i<buttonArray.count; i++) {
        GesturePasswordButton * buttonTemp = ((GesturePasswordButton *)[buttonArray objectAtIndex:i]);
        [buttonTemp setSelected:NO];
        [buttonTemp setSuccess:YES];
        [buttonTemp setNeedsDisplay];
    }
    
    [self setNeedsDisplay];
}

@end
