//
//  ViewController.h
//  ImgSize
//
//  Created by Yin on 14-5-17.
//  Copyright (c) 2014年 caidan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
{
//    UILabel *lblInput;
    
    UIButton *btnInput;
}

@property (retain, nonatomic) NSArray *data;
@property (nonatomic, assign) UIActivityIndicatorViewStyle indicatorStyle;

@end

@protocol MainDelegate <NSObject>

-(void)addDataFrom:(NSArray *)array;

@end
