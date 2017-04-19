//
//  TZPhotoPreviewController.h
//  TZImagePickerController
//
//  Created by 谭真 on 15/12/24.
//  Copyright © 2015年 谭真. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TZAssetModel.h"
typedef void(^DismissUpViewController)();

typedef void(^photoResultClickBlock)(UIImage *);

typedef void(^ResultClickBlock)(TZAssetModel *model,NSString *currentNumber);
@interface TZPhotoPreviewController : UIViewController

@property (nonatomic, strong) NSMutableArray *models;                  ///< All photo models / 所有图片模型数组
@property (nonatomic, strong) NSMutableArray *photos;                  ///< All photos  / 所有图片数组
@property (nonatomic, assign) NSInteger currentIndex;           ///< Index of the photo user click / 用户点击的图片的索引
@property (nonatomic, assign) BOOL isSelectOriginalPhoto;       ///< If YES,return original photo / 是否返回原图
@property (nonatomic, assign) BOOL isCropImage;

/// Return the new selected photos / 返回最新的选中图片数组
@property (nonatomic, copy) void (^backButtonClickBlock)(BOOL isSelectOriginalPhoto);
@property (nonatomic, copy) void (^doneButtonClickBlock)(BOOL isSelectOriginalPhoto);
@property (nonatomic, copy) void (^doneButtonClickBlockCropMode)(UIImage *cropedImage,id asset);
@property (nonatomic, copy) void (^doneButtonClickBlockWithPreviewType)(NSArray<UIImage *> *photos,NSArray *assets,BOOL isSelectOriginalPhoto);
@property (nonatomic, assign) BOOL isRecentPhoto;                //最近的照片

@property (nonatomic, copy) photoResultClickBlock resultClickBlock;

@property (nonatomic, copy) DismissUpViewController dismissVCBlock;
@property (nonatomic, copy) ResultClickBlock block;

@property (nonatomic, assign) NSInteger  indexPathRow;
@property (nonatomic, assign) BOOL  allow;//允许直接跳转编辑页面
@end
