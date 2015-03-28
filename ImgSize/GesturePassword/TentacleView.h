//
//  TentacleView.h
//  GesturePassword
//
//  Created by hb on 14-8-23.
//  Copyright (c) 2014年 黑と白の印记. All rights reserved.
//
#import <UIKit/UIKit.h>

NS_INLINE CGPoint frameCenter(CGRect rect) { return CGPointMake(rect.origin.x+rect.size.width/2,rect.origin.y+rect.size.height/2); }

typedef NS_ENUM(NSInteger, Enum_Style)
{
    Style_Verify     = 1,    //验证
    Style_Reset      = 2,    //重设
};


@protocol ResetDelegate <NSObject>

- (BOOL)resetPassword:(NSString *)result;

@end

@protocol VerificationDelegate <NSObject>

- (BOOL)verification:(NSString *)result;

@end

@protocol TouchBeginDelegate <NSObject>

- (void)gestureTouchBegin;

@end



@interface TentacleView : UIView
{
    CGFloat *lineC;
}

@property (nonatomic,strong) NSArray * buttonArray;

@property (nonatomic,assign) id<VerificationDelegate> rerificationDelegate;

@property (nonatomic,assign) id<ResetDelegate> resetDelegate;

@property (nonatomic,assign) id<TouchBeginDelegate> touchBeginDelegate;

/*
 1: Verify
 2: Reset
 */
@property (nonatomic,assign) Enum_Style style;

- (void)enterArgin;

@end
