//
//  AddLabel.h
//  EaseChat
//
//  Created by Mr. Chen on 2017/4/10.
//  Copyright © 2017年 Mr. Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^DisplayDeletedView) (NSInteger tag);
typedef void(^DisplayDeletedButton) ();
typedef void(^DisplayOtherButton) ();
typedef void(^TouchBeginButton) ();
typedef void(^TouchEndButton) (CGPoint point);
typedef void(^TapActionBlock) (NSInteger tag ,CGFloat scrollowPoint_x ,UIColor *textColor);


@interface AddLabel : UILabel<UIGestureRecognizerDelegate>{
    
    UIPinchGestureRecognizer * _pinchGes;
    
    UIRotationGestureRecognizer * _rotGes;
    
    UIPanGestureRecognizer *_panGes;
    
    UITapGestureRecognizer *_tapGes;
    
    CGPoint _initialPoint;
    
    CGFloat scale;
}

@property (nonatomic, strong) NSString *textString;
@property (nonatomic, strong) UIColor *fillColor;
@property (nonatomic, assign) CGFloat scrollowPoint_x;//颜色滑动的位置
@property (nonatomic, copy) DisplayDeletedView deletedBlock;
@property (nonatomic, copy) DisplayDeletedButton buttonBlock;
@property (nonatomic, copy) DisplayOtherButton otherButtonBlock;//触摸改变回调
@property (nonatomic, copy) TouchBeginButton beginBlock;//触摸改开始回调
@property (nonatomic, copy) TouchEndButton endBlock;//触摸结束回调
@property (nonatomic, copy) TapActionBlock tapBlock;//点击回调
@property (nonatomic, assign) CGFloat scrollowHeight;//传入图片的高度
@property (nonatomic, assign) CGFloat scrollowPoint;//传入滑动的位置

@end
