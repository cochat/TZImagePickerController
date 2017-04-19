//
//  RHMosicaView.h
//  EaseChat
//
//  Created by Mr. Chen on 2017/4/6.
//  Copyright © 2017年 Mr. Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

//触摸开始的回调
typedef void (^TouchBeginMosicBlock)();
//触摸结束的回调
typedef void (^TouchEndMosicBlock)();

@interface RHMosicaView : UIView

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, strong) UIImage *surfaceImage;//表面的图

@property (nonatomic, copy) TouchEndMosicBlock endBlock;

@property (nonatomic, copy) TouchBeginMosicBlock beginBlock;

- (void)back;

@end
