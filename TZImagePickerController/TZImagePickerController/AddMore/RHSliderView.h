//
//  RHSliderView.h
//  EaseChat
//
//  Created by Mr. Chen on 2017/4/6.
//  Copyright © 2017年 Mr. Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RHSliderView;
@protocol RHSliderViewDelegate <NSObject>

- (void)CLSlider:(RHSliderView *)hySlider didScrollValue:(UIColor * )value scrollowPoint_x:(CGFloat) scrollowPoint_x;

@end

@interface RHSliderView : UIView

//是否显示触摸视图(圆形触摸视图)
@property (nonatomic) BOOL showTouchView;

//触摸视图颜色
@property (nonatomic) UIColor *touchViewColor;

//当前数值
 @property (nonatomic) CGFloat currentSliderValue;

//当前数值颜色
@property (nonatomic) UIColor *currentValueColor;

//数值显示颜色
@property (nonatomic) UIColor *showTextColor;

//滑块最大取值
@property (nonatomic) CGFloat maxValue;

//是否一直隐藏滑动数值显示视图
@property (nonatomic) BOOL showScrollTextView;

@property (nonatomic,weak) id <RHSliderViewDelegate> delegate;

@end
