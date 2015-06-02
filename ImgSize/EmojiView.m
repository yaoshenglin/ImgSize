//
//  EmojiView.m
//  AppCaidan
//
//  Created by Yin on 14-6-7.
//  Copyright (c) 2014年 caidan. All rights reserved.
//

#import "EmojiView.h"
#import "CTB.h"

@interface EmojiView ()<UIScrollViewDelegate>
{
    UIScrollView *iScrollView;
}

@end

@implementation EmojiView

@synthesize iPageControl;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.userInteractionEnabled = YES;
        [self initCapacity:frame];
    }
    return self;
}

-(void)initCapacity:(CGRect)frame
{
    NSArray *arrData = [NSArray arrayWithObjects:@"Amazed.png", @"Angel.png", @"Angry.png", @"Beaten.png", @"Bored.png", @"Clown.png", @"Confused.png", @"Cool.png", @"Cry.png", @"Devil.png", @"Doubtful.png", @"Emo.png", @"Frozen.png", @"Grin.png", @"Indian.png", @"Karate.png", @"Kiss.png", @"Laugh.png", @"Love.png", @"Millionaire.png", @"Nerd.png", @"Ninja.png", @"Party.png", @"Pirate.png", @"Punk.png", @"Sad.png", @"Santa.png", @"Shy.png", @"Sick.png", @"Smile.png", @"Speechless.png", @"Sweating.png", @"Tongue.png", @"Vampire.png", @"Wacky.png", @"Wink.png",@"Amazed.png", @"Angel.png", @"Angry.png", @"Beaten.png", @"Bored.png", @"Clown.png", @"Confused.png", @"Cool.png", @"Cry.png", @"Devil.png", @"Doubtful.png", @"Emo.png", @"Frozen.png", @"Grin.png", @"Indian.png", @"Karate.png", @"Kiss.png", @"Laugh.png", @"Love.png", @"Millionaire.png", @"Nerd.png", @"Ninja.png", @"Party.png", @"Pirate.png", @"Punk.png", @"Sad.png", @"Santa.png", @"Shy.png", @"Sick.png", @"Smile.png", @"Speechless.png", @"Sweating.png", @"Tongue.png", @"Vampire.png", @"Wacky.png", @"Wink.png",@"Amazed.png", @"Angel.png", @"Angry.png", @"Beaten.png", @"Bored.png", @"Clown.png", @"Confused.png", @"Cool.png", @"Cry.png", @"Devil.png", @"Doubtful.png", @"Emo.png", @"Frozen.png", @"Grin.png", @"Indian.png", @"Karate.png", @"Kiss.png", @"Laugh.png", @"Love.png", @"Millionaire.png", @"Nerd.png", @"Ninja.png", @"Party.png", @"Pirate.png", @"Punk.png", @"Sad.png", @"Santa.png", @"Shy.png", @"Sick.png", @"Smile.png", @"Speechless.png", @"Sweating.png", @"Tongue.png", @"Vampire.png", @"Wacky.png", @"Wink.png", nil];//108个    
    //定义UIScrollView
    iScrollView = [[UIScrollView alloc] init];
    iScrollView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    iScrollView.showsVerticalScrollIndicator = NO;
    iScrollView.showsHorizontalScrollIndicator = NO;
    //myScrollView.clipsToBounds = YES;
    iScrollView.delegate = self;
    iScrollView.scrollEnabled = YES;
    iScrollView.pagingEnabled = YES; //使用翻页属性+
    [self addSubview:iScrollView];
    iScrollView.contentSize = CGSizeMake(self.frame.size.width*(arrData.count+49)/50, frame.size.height);  //scrollview的滚动范围
    
    CGFloat space = 31.0f;
    for (int i=0; i<arrData.count; i++) {
        int page = (i+50)/50;
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        CGFloat x = 10+space*(i%10) + (page-1)*self.frame.size.width;
        CGFloat y= 5+((i/10)%5)*space;
        btn.frame = CGRectMake(x, y, 20, 20);
        NSString *imgName = [arrData objectAtIndex:i];
        [btn setTitle:imgName forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor clearColor] forState:UIControlStateHighlighted];
        [btn setBackgroundImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
        [btn addTarget:self action:select(ButtonEvents:) forControlEvents:UIControlEventTouchUpInside];
        [iScrollView addSubview:btn];
    }
    
    if (arrData.count>50) {
        iPageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(self.frame.size.width/2-42.5, self.frame.size.height-30, 85, 36)];
        [iPageControl addTarget:self action:@selector(changePage:)forControlEvents:UIControlEventValueChanged];
        [self addSubview:iPageControl];
        iPageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
        iPageControl.currentPageIndicatorTintColor = [UIColor darkGrayColor];
        iPageControl.numberOfPages = (arrData.count+49)/50;
    }
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}

//scrollview的委托方法，当滚动时执行
- (void)scrollViewDidScroll:(UIScrollView *)sender {
    
    int page = iScrollView.contentOffset.x/320;//通过滚动的偏移量来判断目前页面所对应的小白点
    
    iPageControl.currentPage = page;//pagecontroll响应值的变化
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [CTB setAnimationWith:0.3 delegate:nil complete:nil];
    NSInteger page = iPageControl.currentPage;//获取当前pagecontroll的值
    
    [iScrollView setContentOffset:CGPointMake(320 * page, 0)];//根据pagecontroll的值来改变scrollview的滚动位置，以此切换到指定的页面
    [UIView commitAnimations];
}

//pagecontroll的委托方法
- (IBAction)changePage:(id)sender
{
    NSInteger page = iPageControl.currentPage;//获取当前pagecontroll的值
    
    [iScrollView setContentOffset:CGPointMake(320 * page, 0)];//根据pagecontroll的值来改变scrollview的滚动位置，以此切换到指定的页面
    
}

-(void)ButtonEvents:(UIButton *)button
{
    NSLog(@"%@",button.currentTitle);
}

@end
