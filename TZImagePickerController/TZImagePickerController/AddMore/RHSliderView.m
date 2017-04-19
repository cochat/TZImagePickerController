//
//  RHSliderView.m
//  EaseChat
//
//  Created by Mr. Chen on 2017/4/6.
//  Copyright © 2017年 Mr. Chen. All rights reserved.
//

#import "RHSliderView.h"
#import "AMProgressViewGradient.h"
#import "UIView+ColorPoint.h"

@interface RHSliderView ()
@property (nonatomic, strong) UIView *touchView;
@property (nonatomic, strong) AMProgressViewGradient *slidsView;
@property (nonatomic, assign) CGFloat hyMaxValue;
@end

@implementation RHSliderView

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    
    self.layer.cornerRadius = self.frame.size.height / 2;
    
    _slidsView  = [[AMProgressViewGradient alloc]initWithFrame:CGRectMake(0, 15, self.frame.size.width, 10) andGradientColors:[NSArray arrayWithObjects:[UIColor redColor], [UIColor yellowColor], [UIColor blueColor], [UIColor greenColor], [UIColor purpleColor], [UIColor blackColor], nil] andVertical:NO];
    _slidsView.layer.cornerRadius = 10 / 2;
    _slidsView.layer.masksToBounds = YES;
    _slidsView.backgroundColor = [UIColor redColor];
    [self addSubview:_slidsView];
    
    //圆形触摸块
    _touchView  = [[UIView alloc]init];
    _touchView.frame = CGRectMake(self.currentSliderValue, 5, 10, 30);
    _touchView.layer.borderColor = [UIColor whiteColor].CGColor;
    _touchView.layer.cornerRadius = 5;
    _touchView.layer.masksToBounds = YES;
    _touchView.layer.borderWidth = 1;
    [self addSubview:_touchView];
    
    UIColor *color =  [_slidsView colorOfPoint:CGPointMake(10, 1)];
    _touchView.backgroundColor = color;
    
    //默认最大值
    _hyMaxValue = self.frame.size.width;
    
    UIPanGestureRecognizer *longGR = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(longGRAction:)];
    [self addGestureRecognizer:longGR];
    
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGRAction:)];
    [self addGestureRecognizer:tapGR];
    
}

- (void)setCurrentSliderValue:(CGFloat)currentSliderValue {
    _currentSliderValue = currentSliderValue;
    _touchView.frame = CGRectMake(self.currentSliderValue, 5, 10, 30);
}

- (void)setCurrentValueColor:(UIColor *)currentValueColor {
    _currentValueColor = currentValueColor;
    _touchView.backgroundColor = _currentValueColor;
}

//添加点击选颜色
- (void)tapGRAction:(UITapGestureRecognizer *)recognizer {
    CGPoint point = [recognizer locationInView:self];
    NSLog(@"%f",point.x);
    
    [UIView animateWithDuration:.35 animations:^{
        self->_touchView.frame = CGRectMake(point.x, 5, 10, 30);
    }];
    
    UIColor *color =  [_slidsView colorOfPoint:CGPointMake(point.x, 5)];
    _touchView.backgroundColor = color;
    
    //delegate
    if ([self.delegate respondsToSelector:@selector(CLSlider:didScrollValue:scrollowPoint_x:)]) {
        [self.delegate CLSlider:self didScrollValue:color scrollowPoint_x:point.x];
    }
}

- (void)longGRAction:(UIPanGestureRecognizer *)recognizer {
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        
    } else {
        
        CGPoint translation = [recognizer locationInView:self];
        
        if (translation.x >= 1 && translation.x <= _hyMaxValue - 10) {
            
            _touchView.frame = CGRectMake(translation.x, 5, 10, 30);
            UIColor *color =  [_slidsView colorOfPoint:CGPointMake(translation.x, 5)];
            _touchView.backgroundColor = color;
            
            //delegate
            if ([self.delegate respondsToSelector:@selector(CLSlider:didScrollValue:scrollowPoint_x:)]) {
                [self.delegate CLSlider:self didScrollValue:color scrollowPoint_x:translation.x];
            }
        } else if (translation.x < 0 ) {
            _touchView.frame = CGRectMake(0, 5, 10, 30);
            UIColor *color = [_slidsView colorOfPoint:CGPointMake(10, 1)];
            _touchView.backgroundColor = color;
            
            if ([self.delegate respondsToSelector:@selector(CLSlider:didScrollValue:scrollowPoint_x:)]) {
                [self.delegate CLSlider:self didScrollValue:color scrollowPoint_x:0];
            }
        } else if ((translation.x )  > self.frame.size.width - 10 ) {
            _touchView.frame = CGRectMake(self.frame.size.width - 12, 5, 10, 30);
            UIColor *color =  [_slidsView colorOfPoint:CGPointMake(self.frame.size.width - 1, 5)];
            _touchView.backgroundColor = color;
            
            if ([self.delegate respondsToSelector:@selector(CLSlider:didScrollValue:scrollowPoint_x:)]) {
                [self.delegate CLSlider:self didScrollValue:color scrollowPoint_x:self.frame.size.width - 18];
            }
        }
    }
}
@end
