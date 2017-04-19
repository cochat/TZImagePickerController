//
//  TZPhotoPreviewCell.h
//  TZImagePickerController
//
//  Created by 谭真 on 15/12/24.
//  Copyright © 2015年 谭真. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@class TZAssetModel;
@interface TZPhotoPreviewCell : UICollectionViewCell

@property (nonatomic, strong) TZAssetModel *model;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, copy) void (^singleTapGestureBlock)();

- (void)recoverSubviews;

@end
