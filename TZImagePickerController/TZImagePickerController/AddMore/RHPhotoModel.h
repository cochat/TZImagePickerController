//
//  RHPhotoModel.h
//  EaseChat
//
//  Created by Rock on 16/1/18.
//  Copyright © 2016年 Rock. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TZAssetModel.h"

@interface RHPhotoModel : NSObject

@property (nonatomic, copy) NSString *name;         // 图片名
@property (nonatomic, assign) NSInteger size;       // 图片大小
@property (nonatomic, strong) UIImage *image;       // 图片资源
@property (nonatomic, copy) NSString *photoPath;    // 图片路径
@property (nonatomic, strong) UIImage *thumbImage;  // 缩略图
@property (nonatomic, strong) NSData  *imageData;
@property (nonatomic, assign) BOOL isEdit;
@end
