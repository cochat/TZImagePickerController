//
//  RHDrawsView.h
//  EaseChat
//
//  Created by Mr. Chen on 2017/4/6.
//  Copyright © 2017年 Mr. Chen. All rights reserved.
//

#import <UIKit/UIKit.h>
//触摸开始的回调
typedef void (^TouchBeginBlock)(NSMutableArray *array);
//触摸结束的回调
typedef void (^TouchEndBlock)(NSMutableArray *array);
//清除回调
typedef void (^TouchEndClearBlock)(NSMutableArray *array);

@interface RHDrawsView : UIView

- (void)clearAll;//清除全部
- (void)clearup;//返回上一步
@property (nonatomic, strong) UIColor *color;//设置颜色

@property (nonatomic, copy) TouchEndBlock endBlock;  
@property (nonatomic, copy) TouchBeginBlock beginBlock;
@property (nonatomic, copy) TouchEndClearBlock clearBlock;
@end
