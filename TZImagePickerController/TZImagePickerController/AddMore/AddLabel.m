//
//  AddLabel.m
//  EaseChat
//
//  Created by Mr. Chen on 2017/4/10.
//  Copyright © 2017年 Mr. Chen. All rights reserved.
//

#import "AddLabel.h"
#import "RHAppDelegate.h"
@implementation AddLabel

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        self.font = [UIFont systemFontOfSize:40];
        self.textAlignment = NSTextAlignmentCenter;
        self.layer.borderColor = [UIColor whiteColor].CGColor;
        self.layer.borderWidth = 1;
        self.numberOfLines = 0;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.layer.borderColor = [UIColor clearColor].CGColor;
            self.layer.borderWidth = 0;
        });
        
        [self initGestures];
    }
    return self;
}

- (void)initGestures {
    self.userInteractionEnabled = YES;
    _pinchGes =[[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(pinchAct:)];
    
    [self addGestureRecognizer:_pinchGes];
    
    _rotGes =[[UIRotationGestureRecognizer alloc]initWithTarget:self action:@selector(rotAct:)];
    
    [self addGestureRecognizer:_rotGes];
    
    _panGes =[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panAct:)];
    
    [self addGestureRecognizer:_panGes];
    
    _tapGes = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAct:)];

    [self addGestureRecognizer:_tapGes];

    _rotGes.delegate=self;
    _pinchGes.delegate=self;
    _panGes.delegate=self;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    return YES;
}

- (void)panAct:(UIPanGestureRecognizer *)pan {
    
    UIScrollView *scrollow = (UIScrollView *)self.superview;//获取父视图滑动的位置
    
    CGPoint p = [pan translationInView:self.superview];
    
    RHAppDelegate * app = (RHAppDelegate *)[UIApplication sharedApplication].delegate;
    UIWindow * window2 = app.window;
    CGPoint p_screen = [pan locationInView:window2];
    
    if(pan.state == UIGestureRecognizerStateBegan) {
        _initialPoint = [self.superview convertPoint:self.center fromView:self.superview];
        self.layer.borderColor = [UIColor whiteColor].CGColor;
        self.layer.borderWidth = 1;
        if (self.beginBlock) { 
            self.beginBlock();
        }
    }
    
    self.center = CGPointMake(_initialPoint.x + p.x, _initialPoint.y + p.y);
    
    if(pan.state == UIGestureRecognizerStateEnded) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.layer.borderColor = [UIColor clearColor].CGColor;
            self.layer.borderWidth = 0;
        });
        
        if (self.endBlock) {
            self.endBlock(CGPointMake(p.x, p.y));
        }

        
        if (p_screen.y > screenHeight - 44) {
            if (self.deletedBlock) {
                self.deletedBlock(self.tag);
            }
        }
        
        self.center = CGPointMake(_initialPoint.x + p.x, _initialPoint.y + p.y);
        
        //超出当前视图距离的时候
        if (self.center.y  < self.frame.size.height / 2 || fabs(self.center.y) + self.frame.size.height / 2   >  scrollow.contentSize.height) {
            NSLog(@"超出当前的距离");
            [self currectFrame];
        }
    }
    
    if(pan.state == UIGestureRecognizerStateChanged) {
        
        //触摸改变的时候，隐藏其他视图
        if (self.otherButtonBlock) {
            self.otherButtonBlock();
        }
    
        if (p_screen.y > screenHeight - 44) {
            // 修改删除文字
            if (self.buttonBlock) {
                self.buttonBlock();
            }
        }
    }
}

- (void)tapAct:(UITapGestureRecognizer *)tap {
    
    if (self.tapBlock) {
        self.tapBlock(self.tag ,self.scrollowPoint_x,self.textColor);
    }
}

//旋转手势函数
-(void)rotAct:(UIRotationGestureRecognizer*)rot {
    
    UILabel *iView = (UILabel *)rot.view;
    iView.transform = CGAffineTransformRotate(iView.transform, rot.rotation);
    rot.rotation=0;
}

//捏合手势事件函数实现
-(void)pinchAct:(UIPinchGestureRecognizer*)pinch {
    
    UILabel *iView = (UILabel *)pinch.view;
    iView.transform = CGAffineTransformScale(iView.transform, pinch.scale, pinch.scale);
    pinch.scale = 1;
}

- (void)setTextString:(NSString *)textString {
    
    _textString = textString;
    self.text = textString;
    
    [self currectFrame];
}

- (void)currectFrame
{
    self.transform = CGAffineTransformIdentity;//重新设置文字之后,或超出当前视图，恢复缩放值
    CGSize size = [self sizeThatFits:CGSizeMake(screenWidth - 100, FLT_MAX)];
    self.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width - size.width - 32) / 2, (self.superview.frame.size.height - size.height - 32) / 2 + self.scrollowPoint, size.width + 32, size.height + 32);
}

- (void)setScrollowPoint_x:(CGFloat)scrollowPoint_x
{
    _scrollowPoint_x = scrollowPoint_x;
}

- (void)setFillColor:(UIColor *)fillColor {
    
    self.textColor = fillColor;
}

- (UIColor*)fillColor {
    
    return self.textColor;
}

@end
