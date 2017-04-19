//
//  TZEditPhotoViewController.h
//  EaseChat
//
//  Created by Mr. Chen on 2017/3/31.
//  Copyright © 2017年 Mr. Chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TZAssetModel.h"


@interface TZEditPhotoViewController : UIViewController

@property (nonatomic, retain) NSDictionary *option;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) TZAssetModel *model;

//最近的照片
@property (nonatomic, assign) BOOL isRecentPhoto;

//传入图片对象的位置
@property (nonatomic, assign) NSInteger currentIndex;

@property (nonatomic, assign) NSInteger  indexPathRow;

@end
