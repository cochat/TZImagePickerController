//
//  TZEditPhotoViewController.m
//  EaseChat
//
//  Created by Mr. Chen on 2017/3/31.
//  Copyright © 2017年 Mr. Chen. All rights reserved.
//

#import "TZEditPhotoViewController.h"
#import "RHDrawsView.h"
#import "RHMosicaView.h"
#import "TKImageView.h"
#import "AddLabel.h"
#import "RHSliderView.h"
#import "TZImageManager.h"
#import <AssetsLibrary/ALAssetsLibrary.h>
#import <AssetsLibrary/ALAssetsGroup.h>
#import "RHTextVC.h"
#import "RHNavigationController.h"
#import "RHModifyDelegate.h"


static const int kBitsPerComponent = 8;
static const int kBitsPerPixel = 32;
static const int kPixelChannelCount = 4;
static const CGFloat rgb = 34 / 255.0;
static const CGFloat level = 20; //马赛克等级

@interface TZEditPhotoViewController ()<RHSliderViewDelegate,RHModifyDelegate,UIScrollViewDelegate>
{
    //显示颜色
    UILabel *displayColorLabel;
    
    BOOL isopen;//是否为展开状态
}

@property (retain, nonatomic) UIButton *buttonRevoke;//保存的图片
@property (assign, nonatomic) CGRect saveRect;//保存size 恢复用
@property (assign, nonatomic) CGSize size;//尺寸
@property (strong, nonatomic) UIImage *saveImage;//保存的图片
@property (strong, nonatomic) UIView *topView;//顶部的视图
@property (strong, nonatomic) UIView *bottomView;//底部的视图
@property (strong, nonatomic) UIImageView *imageViews;//图片
@property (strong, nonatomic) UIScrollView *saveImageScrollow;//图片的背景
@property (strong, nonatomic) RHDrawsView *drawView;//绘笔
@property (strong, nonatomic) UIView *container_drawView;//绘笔容器
@property (strong, nonatomic) RHMosicaView *mosaicView;//马赛克
@property (strong, nonatomic) AddLabel *addTextView;//添加文字
@property (strong, nonatomic) TKImageView *tkImageView;//裁剪画布
@property (strong, nonatomic) UIView *colorBackground;//颜色背景
@property (assign, nonatomic) BOOL color_background_hidden;//颜色背景是否显示
@property (strong, nonatomic) UIView *cutBackView;//裁剪控件背景
@property (strong, nonatomic) UIView *mosaicBackgroundView;//马赛克确认取消按钮背景
@property (strong, nonatomic) UIView *wordBackgroundView;//文字按钮背景
@property (assign, nonatomic) BOOL isMosaic;//是否已经处理了马赛克
@property (assign, nonatomic) BOOL isBush;//是否已经处理了毛刷
@property (retain, nonatomic) UIButton *deletedWordButton;//删除文字按钮

@end

@implementation TZEditPhotoViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    isopen = YES;
    
    //设置图片
    if (self.isRecentPhoto) {
        self.saveImage = self.image;
        self.size = self.image.size;
    } else {
        self.saveImage = self.model.image;
        self.size = self.model.image.size;
    }
    
    CGFloat size_height = self.size.height / self.size.width;
    
    self.saveRect = CGRectMake(0, (screenHeight - (screenWidth * size_height)) / 2.0  , screenWidth, (screenWidth * size_height ));
    self.saveImageScrollow.contentSize = CGSizeMake(screenWidth, (screenWidth * size_height ));
    
    if (screenWidth * size_height > screenHeight) {
        _saveImageScrollow.frame = CGRectMake(0, 0 , screenWidth, screenHeight );
    } else {
        _saveImageScrollow.frame = CGRectMake(0, (screenHeight - (screenWidth * size_height )) / 2 , screenWidth,(screenWidth * size_height ) );
    }
    
    _saveImageScrollow.alwaysBounceVertical = _saveImageScrollow.height <= self.view.height ? NO : YES;

    [self initView];//初始化视图
    
    self.view.backgroundColor = [UIColor blackColor];
}

#pragma mark 加载视图
- (UIImageView *)imageViews {
    
    if (!_imageViews) {
        _imageViews = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, (screenWidth * (self.size.height / self.size.width)))];
        [_saveImageScrollow addSubview:_imageViews];
    }
    return _imageViews;
}

- (UIScrollView *)saveImageScrollow {
    
    if (!_saveImageScrollow) {
        _saveImageScrollow = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
        _saveImageScrollow.bounces = YES;
        _saveImageScrollow.multipleTouchEnabled = YES;
        _saveImageScrollow.clipsToBounds = NO;//因为文字拖拽的时候，可能移出视图范围，如果剪切了，就会造成文字看不到。
        _saveImageScrollow.delaysContentTouches = YES;
        _saveImageScrollow.canCancelContentTouches = NO;
        _saveImageScrollow.delegate = self;
        _saveImageScrollow.scrollsToTop = NO;
        _saveImageScrollow.showsHorizontalScrollIndicator = NO;
        _saveImageScrollow.showsVerticalScrollIndicator = NO;
        _saveImageScrollow.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _saveImageScrollow.alwaysBounceVertical = NO;
        _saveImageScrollow.alwaysBounceHorizontal = NO;
        [self.view addSubview:_saveImageScrollow];
        
        //单击
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
        [_saveImageScrollow addGestureRecognizer:tap];
        
        //双击 搁置
        UITapGestureRecognizer *tap_twoFiger = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
        tap_twoFiger.numberOfTapsRequired = 2;
        [tap requireGestureRecognizerToFail:tap_twoFiger];
//        [_saveImageScrollow addGestureRecognizer:tap_twoFiger];

    }
    return _saveImageScrollow;
}

- (void)doubleTap:(UITapGestureRecognizer *)tap
{
    if (_saveImageScrollow.zoomScale > 1.0) {
        [_saveImageScrollow setZoomScale:1.0 animated:YES];
    } else {
        CGPoint touchPoint = [tap locationInView:self.imageViews];
        CGFloat newZoomScale = _saveImageScrollow.maximumZoomScale;
        CGFloat xsize = _saveImageScrollow.frame.size.width / newZoomScale;
        CGFloat ysize = _saveImageScrollow.frame.size.height / newZoomScale;
        [_saveImageScrollow zoomToRect:CGRectMake(touchPoint.x - xsize/2, touchPoint.y - ysize/2, xsize, ysize) animated:YES];
   
        NSLog(@"%f",_saveImageScrollow.zoomScale);
    }
}

#pragma mark - UIScrollViewDelegate

- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageViews;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGFloat offsetX = (scrollView.width > scrollView.contentSize.width) ? (scrollView.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.height > scrollView.contentSize.height) ? (scrollView.height - scrollView.contentSize.height) * 0.5 : 0.0;
    self.imageViews.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX, scrollView.contentSize.height * 0.5 + offsetY);
}


//删除文字按钮
- (UIButton *)deletedWordButton {
    
    if (!_deletedWordButton) {
        _deletedWordButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _deletedWordButton.frame = CGRectMake(0, screenHeight - 44, screenWidth, 44);
        [_deletedWordButton setTitle:@"拖动到此处删除" forState:UIControlStateNormal];
        _deletedWordButton.backgroundColor = [UIColor colorWithRed:rgb green:rgb blue:rgb alpha:1.0];
        _deletedWordButton.alpha = 0.9;
        _deletedWordButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [self.view addSubview:_deletedWordButton];
        [self.view bringSubviewToFront:_deletedWordButton];
    }
    return _deletedWordButton;
}

//颜色背景
- (UIView *)colorBackground {
    
    if (!_colorBackground) {
        //颜色背景
        _colorBackground = [[UIView alloc]initWithFrame:CGRectMake(0, screenHeight - 104, screenWidth, 60)];
        _colorBackground.backgroundColor = [UIColor clearColor];
        
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 60)];
        [_colorBackground addSubview:view];
        view.backgroundColor = [UIColor colorWithRed:rgb green:rgb blue:rgb alpha:1.0];
        view.alpha = 0.7;
        
        //撤销
        _buttonRevoke = [UIButton buttonWithType:UIButtonTypeCustom];
        _buttonRevoke.frame = CGRectMake(screenWidth - 70, 10, 60, 30);
        [_buttonRevoke setImage:[UIImage imageNamed:@"EditImageRevokeBtn"] forState:UIControlStateNormal];
        _buttonRevoke.enabled = NO;
        [_colorBackground addSubview:_buttonRevoke];
        [_buttonRevoke addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
        
        //显示颜色
        displayColorLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 18, 20, 20)];
        displayColorLabel.layer.cornerRadius = 10;
        displayColorLabel.layer.masksToBounds = YES;
        [_colorBackground addSubview:displayColorLabel];
        //初始值
        displayColorLabel.backgroundColor = [UIColor redColor];
        
        RHSliderView *slider = [[RHSliderView alloc]initWithFrame:CGRectMake(50, 8, screenWidth - 140 , 40)];
        slider.delegate = self;
        [_colorBackground addSubview:slider];
    }
    return _colorBackground;
}

//裁剪底部视图
- (UIView *)cutBackView {
    
    if (!_cutBackView) {
        _cutBackView = [[UIView alloc]initWithFrame:CGRectMake(0, screenHeight - 44, screenWidth, 44)];
        _cutBackView.backgroundColor = [UIColor colorWithRed:rgb green:rgb blue:rgb alpha:1.0];

        UIButton *cutDone = [UIButton buttonWithType:UIButtonTypeCustom];
        cutDone.frame = CGRectMake(screenWidth -  75, 0, 60, 44);
        [cutDone setTitle:@"完成" forState:UIControlStateNormal];
        cutDone.titleLabel.font = [UIFont systemFontOfSize:16];
        [cutDone setTitleColor:[UIColor colorWithRed:(83 / 255.0) green:(179 / 255.0) blue:(17 / 255.0) alpha:1.0] forState:UIControlStateNormal];
        [cutDone addTarget:self action:@selector(cutButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_cutBackView addSubview:cutDone];
        
        UIButton *cutCancel = [UIButton buttonWithType:UIButtonTypeCustom];
        cutCancel.frame = CGRectMake(15, 0, 60, 44);
        cutCancel.titleLabel.font = [UIFont systemFontOfSize:16];
        [cutCancel setTitle:@"取消" forState:UIControlStateNormal];
        [_cutBackView addSubview:cutCancel];
        [cutCancel addTarget:self action:@selector(cancelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cutBackView;
}

//马赛克确认取消按钮背景
- (UIView *)mosaicBackgroundView {
    
    if (!_mosaicBackgroundView) {
        _mosaicBackgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, screenHeight - 88, screenWidth, 44)];
        _mosaicBackgroundView.backgroundColor = [UIColor darkGrayColor];
        UIButton *mosaicCancel = [UIButton buttonWithType:UIButtonTypeCustom];
        mosaicCancel.frame = CGRectMake(0, 0, screenWidth, 44);
        [mosaicCancel setTitle:@"撤销" forState:UIControlStateNormal];
        [mosaicCancel setImage:[UIImage imageNamed:@"EditImageRevokeBtn"] forState:UIControlStateNormal];
        [_mosaicBackgroundView addSubview:mosaicCancel];
        [mosaicCancel addTarget:self action:@selector(mosaicDoneButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _mosaicBackgroundView;
}

//文字按钮背景
- (UIView *)wordBackgroundView {
    
    if (!_wordBackgroundView) {
        _wordBackgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, screenHeight - 44, screenWidth, 44)];
        _wordBackgroundView.backgroundColor = [UIColor darkGrayColor];
        [self.view addSubview:_wordBackgroundView];
        
        UIButton *wordDone = [UIButton buttonWithType:UIButtonTypeCustom];
        wordDone.frame = CGRectMake(screenWidth -  75, 0, 60, 44);
        [wordDone setTitle:@"完成" forState:UIControlStateNormal];
        [_wordBackgroundView addSubview:wordDone];
        
        UIButton *wordCancel = [UIButton buttonWithType:UIButtonTypeCustom];
        wordCancel.frame = CGRectMake(15, 0, 60, 44);
        [wordCancel setTitle:@"取消" forState:UIControlStateNormal];
        [_wordBackgroundView addSubview:wordCancel];
    }
    return _wordBackgroundView;
}

//笔刷容器
- (UIView *)container_drawView
{
    if (!_container_drawView) {
        _container_drawView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, (screenWidth * (self.size.height / self.size.width)))];
        _container_drawView.clipsToBounds = YES;
        [_saveImageScrollow addSubview:_container_drawView];
        [_container_drawView addSubview:self.drawView];
    }
    return _container_drawView;
}

// 笔刷
- (RHDrawsView *)drawView {
    
    if (!_drawView) {
        //添加画布
        _drawView=[[RHDrawsView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, (screenWidth * (self.size.height / self.size.width)))];
        [_drawView setBackgroundColor:[UIColor clearColor]];
        _drawView.color = [UIColor redColor];
        WEAKSELF
        _drawView.endBlock = ^(NSMutableArray *array) {
            
            //结束绘画的回调
            weakSelf.buttonRevoke.enabled = YES;
            weakSelf.isBush = YES;
            weakSelf.colorBackground.hidden = NO;
            weakSelf.bottomView.hidden = NO;
            weakSelf.topView.hidden = NO;
        };
        
        _drawView.beginBlock = ^(NSMutableArray *array) {
            
            //开始绘画的回调
            weakSelf.isBush = YES;
            weakSelf.colorBackground.hidden = YES;
            weakSelf.bottomView.hidden = YES;
            weakSelf.topView.hidden = YES;
        };
        
        _drawView.clearBlock = ^(NSMutableArray *array) {
            if (array.count > 0) {
                weakSelf.buttonRevoke.enabled = YES;
            } else {
                weakSelf.buttonRevoke.enabled = NO;
            }
        };
    }
    return _drawView;
}

// 裁剪
- (TKImageView *)tkImageView {
    
    if (!_tkImageView) {
        
        CGFloat widthFloat = self.size.width / (self.size.height + self.size.width);
        
        CGFloat heightFloat = self.size.height / (self.size.height + self.size.width);
        
        //缩放值
        CGFloat scalValue;
        
        if (heightFloat > widthFloat) {
            //长图 缩小到当前屏幕高度的比例  图片总的长度：固定值
            scalValue =  (screenHeight - 140) / self.size.height;
            
        } else {
            //宽图 或者 方图
            scalValue =  (screenWidth  - 40) / self.size.width;
        }

        _tkImageView = [[TKImageView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, (screenWidth * (self.size.height / self.size.width)))];
        
        //截图
        UIImage *image = [self getCutImage];
        NSData *imageData = UIImageJPEGRepresentation(image, 1);
        
        _tkImageView.toCropImage = [UIImage imageWithData:imageData];
        _tkImageView.showMidLines = YES;
        _tkImageView.needScaleCrop = YES;
        _tkImageView.showCrossLines = YES;
        _tkImageView.cornerBorderInImage = NO;
        _tkImageView.cropAreaCornerWidth = 40;
        _tkImageView.cropAreaCornerHeight = 40;
        _tkImageView.minSpace = 30;
        _tkImageView.cropAreaCornerLineColor = [UIColor whiteColor];
        _tkImageView.cropAreaBorderLineColor = [UIColor whiteColor];
        _tkImageView.cropAreaCornerLineWidth = 5;
        _tkImageView.cropAreaBorderLineWidth = 1;
        _tkImageView.cropAreaMidLineWidth = level;
        _tkImageView.cropAreaMidLineHeight = 1;
        _tkImageView.cropAreaMidLineColor = [UIColor whiteColor];
        _tkImageView.cropAreaCrossLineColor = [UIColor whiteColor];
        _tkImageView.cropAreaCrossLineWidth = 1;
        _tkImageView.initialScaleFactor = .8f;
    }
    return _tkImageView;
}

// 马赛克
- (RHMosicaView *)mosaicView {
    
    if (!_mosaicView) {
        _mosaicView = [[RHMosicaView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, (screenWidth * (self.size.height / self.size.width)))];
        
        //低图，此函数为马赛克算法
        _mosaicView.surfaceImage = self.saveImage;
        
        //保存第一次进来虚化的马赛克
        _mosaicView.image = [self transToMosaicImage:self.saveImage blockLevel:20];
        
        //触摸开始以及结束
        WEAKSELF
        _mosaicView.endBlock = ^() {
            
            //结束绘画的回调
            weakSelf.colorBackground.hidden = YES;
            weakSelf.bottomView.hidden = NO;
            weakSelf.topView.hidden = NO;
        };
        
        _mosaicView.beginBlock = ^() {
            
            //开始绘画的回调
            weakSelf.colorBackground.hidden = YES;
            weakSelf.bottomView.hidden = YES;
            weakSelf.topView.hidden = YES;
        };
    }
    return _mosaicView;
}

//初始化视图
- (void)initView {
    
    [self.view addSubview:self.topView];
    [self.view addSubview:self.bottomView];

    //底部图片
    self.imageViews.image = self.saveImage;

    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (UIView *)bottomView {
    
    if (!_bottomView) {
        //底部的视图
        _bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, screenHeight - 44, screenWidth, 44)];
        _bottomView.backgroundColor = [UIColor colorWithRed:rgb green:rgb blue:rgb alpha:1.0];
        _bottomView.alpha = 0.7;
        
        NSArray *imageArrayHL = @[@"EditImagePenToolBtn_HL",@"EditImageMosaicToolBtn_HL",@"EditImageTextToolBtn_HL",@"EditImageCropBtn_HL",@"EditImageEmotionBtn_HL"];
        NSArray *imageArray = @[@"EditImagePenToolBtn",@"EditImageMosaicToolBtn",@"EditImageTextToolBtn",@"EditImageCropBtn",@"EditImageEmotionBtn"];
        
        for (int i = 0; i < imageArray.count; i++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(i * (screenWidth / imageArray.count), 0, screenWidth / imageArray.count, 44);
            button.tag = i + 1;
            if (i < 4) {
                [button setImage:[UIImage imageNamed:imageArray[i]] forState:UIControlStateNormal];
                [button setImage:[UIImage imageNamed:imageArrayHL[i]] forState:UIControlStateSelected];
            }
            [button addTarget:self action:@selector(bottomButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            [_bottomView addSubview:button];
        }
    }
    return _bottomView;
}

- (UIView *)topView {
    
    if (!_topView) {
        //顶部按钮
        _topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 64)];
        _topView.backgroundColor = [UIColor colorWithRed:rgb green:rgb blue:rgb alpha:1.0];
        _topView.alpha = 0.7;
        
        UIButton *topDone = [UIButton buttonWithType:UIButtonTypeCustom];
        topDone.frame = CGRectMake(screenWidth -  60, 20, 50, 30);
        [topDone setTitle:@"完成" forState:UIControlStateNormal];
        [_topView addSubview:topDone];
        topDone.titleLabel.font = [UIFont systemFontOfSize:16];
        [topDone setTitleColor:[UIColor colorWithRed:(83 / 255.0) green:(179 / 255.0) blue:(17 / 255.0) alpha:1.0] forState:UIControlStateNormal];
        [topDone addTarget:self action:@selector(saveBtn:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *topCancel = [UIButton buttonWithType:UIButtonTypeCustom];
        topCancel.frame = CGRectMake(10, 20, 50, 30);
        [topCancel setTitle:@"取消" forState:UIControlStateNormal];
        [_topView addSubview:topCancel];
        topCancel.titleLabel.font = [UIFont systemFontOfSize:16];
        [topCancel addTarget:self action:@selector(cancelBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _topView;
}

#pragma mark 按钮事件
// 取消按钮
- (void)cancelBtn:(UIButton *)btn {
    [self dismissViewControllerAnimated:NO completion:nil];
}

// 保存按钮
- (void)saveBtn:(UIButton *)btn {
    
    //截图
    UIImage *image = [self getCutImage];
    NSData *imageData = UIImageJPEGRepresentation(image, 0.3);
    
    TZAssetModel *model = [[TZAssetModel alloc]init];
    model.image = [UIImage imageWithData:imageData];
    model.isEdit = YES;
    model.indexPathRowCurrent = [NSString stringWithFormat:@"%ld",(long)self.indexPathRow];
    model.currentNumber = [NSString stringWithFormat:@"%ld",(long)self.currentIndex];
    model.recodcurrentNumber = self.model.recodcurrentNumber;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeNotifiacation" object:model];
    
    [self dismissViewControllerAnimated:NO completion:^{

    }];
}

// 剪切确认
- (void)cutButtonAction:(UIButton *)button {
    self.saveImageScrollow.scrollEnabled = YES;

    [self reScale];
    
    [self dismissAllButtonView];
    
    self.topView.hidden = NO;//显示头部按钮
    
    //设置新的图片
    UIImage *image = _tkImageView.currentCroppedImage;
    
    //设置新的图片
    self.imageViews.image = image;
    
    self.size = image.size;
    self.saveImage = image;
    
    CGRect newRect = CGRectMake(0, (screenHeight - (screenWidth * (image.size.height / image.size.width))) / 2.0 + 2 , screenWidth, (screenWidth * (image.size.height / image.size.width) - 1));
    
    CGFloat scrollowHeigh;
    if (newRect.size.height > screenHeight) {
        scrollowHeigh = screenHeight;
    }else
    {
        scrollowHeigh = newRect.size.height;
    }
    
    self.saveImageScrollow.frame = CGRectMake(0, (screenHeight - scrollowHeigh) / 2 , newRect.size.width, scrollowHeigh);
    self.saveImageScrollow.contentSize = newRect.size;
    
    self.imageViews.frame = CGRectMake(0, 0, self.saveImageScrollow.width, newRect.size.height);//为背景图设置新的图片
    self.container_drawView.frame = CGRectMake(0, 0, self.saveImageScrollow.width, newRect.size.height);


    if (_mosaicView != nil) {
        self.mosaicView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    }
    
    if (_drawView != nil) {
        _drawView.frame = CGRectMake(0, 0, self.saveImageScrollow.width, newRect.size.height);
    }
    
    
    [self.mosaicView removeFromSuperview];
    self.mosaicView = nil;
    
    [self.drawView removeFromSuperview];
    self.drawView = nil;
    
    [self.container_drawView removeFromSuperview];
    self.container_drawView = nil;
    
    for (UIView *view in _saveImageScrollow.subviews) {
        if ([view isKindOfClass:[AddLabel class]]) {
            [view removeFromSuperview];
        }
    }
    
    [self.tkImageView removeFromSuperview];
    self.tkImageView = nil;
}

//剪切取消
- (void)cancelButtonAction:(UIButton *)button {
    self.saveImageScrollow.scrollEnabled = YES;
    
    //恢复缩放
    [UIView animateWithDuration:.35 animations:^{
        self.saveImageScrollow.transform = CGAffineTransformIdentity;
        if (self.imageViews.height > screenHeight) {
            self.saveImageScrollow.y = 0;
        } else {
            
        }

    } completion:^(BOOL finished) {
        if (self.imageViews.height > screenHeight) {
            self.saveImageScrollow.height = screenHeight;
        } else {
            
        }
    }];
    
   
    [self dismissAllButtonView];
    [self.tkImageView removeFromSuperview];
    _tkImageView = nil;
    self.topView.hidden = NO;//显示头部按钮
}

//剪切取消确定恢复缩放
- (void)reScale
{
    //恢复缩放
    [UIView animateWithDuration:.35 animations:^{
        self.saveImageScrollow.transform = CGAffineTransformIdentity;
  
    } completion:^(BOOL finished) {
        
    }];
}

- (void)mosaicDoneButtonAction:(UIButton *)button {
    [self.mosaicView back];
}

//收起所有的背景按钮视图
- (void)dismissAllButtonView {
    
    if (_drawView != nil) {
        _container_drawView.userInteractionEnabled = NO;//关闭绘图手势
    }
    if (_mosaicView != nil) {
        _mosaicView.userInteractionEnabled = NO;//关闭马赛克
    }
    _colorBackground.hidden = YES;
    _cutBackView.hidden = YES;
    _mosaicBackgroundView.hidden = YES;
    _wordBackgroundView.hidden = YES;
}

//笔刷选择颜色
- (void)bruchSelectColor {
    
    [self.view addSubview:self.colorBackground];
}

//获取滑动的颜色值
- (void)CLSlider:(RHSliderView *)hySlider didScrollValue:(UIColor * )value scrollowPoint_x:(CGFloat)scrollowPoint_x {
    displayColorLabel.backgroundColor = value;
    [self.drawView setColor:value];
}

#pragma mark 屏幕单击收起视图
- (void)tapAction:(UITapGestureRecognizer *)tap {
    
    if (isopen == YES) {
        isopen = NO;
        self.bottomView.hidden = YES;
        self.topView.hidden = YES;
        self.colorBackground.hidden = YES;

    } else {
        isopen = YES;
        self.bottomView.hidden = NO;
        self.topView.hidden = NO;
        self.colorBackground.hidden = self.color_background_hidden?YES:NO;
    }
}

//撤销
- (void)cancelAction:(UIButton *)button {
    
    [self.drawView clearup];
}

#pragma mark 按钮切换
- (void)bottomButtonAction:(UIButton *)button {
    
    self.isMosaic = NO;
    self.color_background_hidden = YES;

    //反选，隐藏所有控件视图
    [self dismissAllButtonView];
    
    for (UIView *subView in _bottomView.subviews ) {
        
        if ([subView isKindOfClass:[UIButton class]]) {
            
            UIButton *subBtn = (UIButton *)subView;
            
            if (subBtn.tag == button.tag) {
                
                if (subBtn.selected == YES) {
                    subBtn.selected = NO;
                    
                    self.saveImageScrollow.scrollEnabled = YES;
                    
                } else {
                    if (button.tag == 1) {
                        
                        //画笔
                        self.color_background_hidden = NO;
                        subBtn.selected = YES;
                        self.isBush = YES;
                        self.saveImageScrollow.scrollEnabled = NO;
                        self.container_drawView.userInteractionEnabled = YES;
                        self.mosaicView.userInteractionEnabled = NO;
                        
                        [self.view addSubview:self.colorBackground];//添加笔刷按钮背景
                        self.colorBackground.hidden = NO;//显示笔刷按钮背景
                        self.topView.hidden = NO;//显示头部按钮
                        
                        [_saveImageScrollow insertSubview:self.container_drawView belowSubview:self.colorBackground];//显示笔刷按钮，始终放在工具条的下面
                        
                        if (self.isMosaic) {
                            [self.container_drawView bringSubviewToFront:self.mosaicView];
                        }
                    }
                    
                    if (button.tag == 2) {
                        
                        //马赛克
                        self.isMosaic = YES;
                        subBtn.selected = YES;
                        self.saveImageScrollow.scrollEnabled = NO;
                        self.container_drawView.userInteractionEnabled = NO;
                        self.mosaicView.userInteractionEnabled = YES;
                        self.topView.hidden = NO;//显示头部按钮
                        
                        if (self.isBush) {
                            [_saveImageScrollow insertSubview:self.mosaicView belowSubview:self.container_drawView];
                        } else {
                            [_saveImageScrollow insertSubview:self.mosaicView belowSubview:self.colorBackground];
                        }
                        
                        [_saveImageScrollow bringSubviewToFront:_addTextView];
                    }
                    if (button.tag == 3) {
                        
                        //文字
                        self.isMosaic = YES;
                        subBtn.selected = NO;
                        [self addText:@"" tag:@"" scrollowPoint_x:0 labelTextColor:[UIColor redColor]];
                    }
                    if (button.tag == 4) {
                        
 
                        //缩放值
                        CGFloat scalValue;
                        
                        //计算缩小的比例
                        CGFloat scal;
                        if (self.imageViews.height > screenHeight) {
                            //长图 缩小到当前屏幕高度的比例  图片总的长度：固定值
                            scalValue =  (screenHeight - 140) / self.size.height;
                            NSLog(@"a");
                            scal = (self.imageViews.width   -  self.size.width  * scalValue) / self.imageViews.width;
                        } else {
                            //宽图 或者 方图
                            scalValue =  (screenWidth  - 40) / self.size.width;
                            NSLog(@"b");
                            scal = (self.imageViews.height   -  self.size.height  * scalValue) / self.imageViews.height;
                        }

                        [self.view addSubview:self.cutBackView];
                        
                        //缩小当前视图
                        [UIView animateWithDuration:.35 animations:^{
                            
                            //根据当前图片的大小进行缩放
                            self.saveImageScrollow.transform = CGAffineTransformMakeScale(1 - scal, 1 - scal);
                            if (self.saveImageScrollow.contentSize.height > screenHeight) {
                                self.saveImageScrollow.y = 60;
                            }
                            
                        } completion:^(BOOL finished) {
                            subBtn.selected = NO;
                            self.saveImageScrollow.height = screenHeight - 140;

                            //显示裁剪确认取消按钮
                            [self.saveImageScrollow addSubview:self.tkImageView];
                            
                            //设置剪切的frame
                            self.cutBackView.hidden = NO;
                            self.topView.hidden = YES;//显示头部按钮
                        }];

                    }
                    if (button.tag == 5) {


                    }
                }
            } else {
                
                subBtn.selected = NO;

            }
        }
    }
}

#pragma mark 添加文字
- (void)addText:(NSString *)text tag:(NSString *)tag scrollowPoint_x:(CGFloat)scrollowPoint_x labelTextColor:(UIColor *)labelTextColor{
    
    //如果text有值 ，只做修改
    //如果没有值，创建新的视图
    RHTextVC * textVC = [[RHTextVC alloc] init];
    textVC.option = @{@"placeholder":@"请输入内容",@"inputType":@(1),@"contentType":@"1",@"maxLength":@(100),@"itemName":@"输入内容",@"itemValue":text, @"isNeedColorSelect":@YES,@"fontSize":@"20",@"textColor":labelTextColor,@"changeText":text.length>0?@YES:@NO,@"changeText_tag":text.length>0?tag:@"99999999",@"scrollowPoint_x":text.length>0?@(scrollowPoint_x):@0};
    textVC.delegate = self;
    RHNavigationController * navi = [[RHNavigationController alloc] initWithRootViewController:textVC];
    [self presentViewController:navi animated:YES completion:nil];
}

- (void)save:(NSDictionary *)option {

    //循环取出addlabel的类
    NSMutableArray *array = [NSMutableArray array];
    for (UIView *view in _saveImageScrollow.subviews) {
        if ([view isKindOfClass:[AddLabel class]]) {
            [array addObject:view];
        }
    }
    
    //修改文字
    if ([option[@"changeText"] intValue] == 1) {
        
        AddLabel *changeLabel = (AddLabel *)[self.saveImageScrollow viewWithTag:[option[@"changeText_tag"] intValue]];
        
        NSString *content = option[@"itemValue"];
        UIColor *textColor = option[@"textColor"];
        changeLabel.scrollowPoint_x = [option[@"scrollowPoint_x"]floatValue];
        changeLabel.textString = content;
        changeLabel.textColor = textColor;
        return;
    }
    
    //修改添加多个文字
    _addTextView = [[AddLabel alloc]init];
    _addTextView.tag = array.count + 10;
    _addTextView.fillColor = [UIColor orangeColor];
    
    [_saveImageScrollow bringSubviewToFront:self.addTextView];
    
    WEAKSELF
    _addTextView.deletedBlock = ^(NSInteger tag) {
        
        AddLabel *tag_view = (AddLabel *)[weakSelf.saveImageScrollow viewWithTag:tag];
        
        [tag_view removeFromSuperview];
        tag_view = nil;
        weakSelf.deletedWordButton.hidden = YES;
    };
    
    //修改删除按钮
    _addTextView.buttonBlock = ^() {
        [weakSelf.deletedWordButton setTitle:@"松手即可删除" forState:UIControlStateNormal];
        [weakSelf.deletedWordButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        
    };
    
    //隐藏其他按钮
    _addTextView.otherButtonBlock = ^() {
        [weakSelf.deletedWordButton setTitle:@"拖动到此处删除" forState:UIControlStateNormal];
        [weakSelf.deletedWordButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        //隐藏其他按钮，显示删除按钮
        weakSelf.deletedWordButton.hidden = NO;
        weakSelf.colorBackground.hidden = YES;
        weakSelf.bottomView.hidden = YES;
        weakSelf.topView.hidden = YES;
    };
    
    //触摸结束
    _addTextView.endBlock = ^(CGPoint point) {
        weakSelf.deletedWordButton.hidden = YES;
        weakSelf.bottomView.hidden = NO;
        weakSelf.topView.hidden = NO;
        weakSelf.saveImageScrollow.scrollEnabled = YES;
    };
    
    _addTextView.beginBlock = ^(){
        weakSelf.saveImageScrollow.scrollEnabled = NO;
    };
    
    //点击回调
    _addTextView.tapBlock = ^(NSInteger tag ,CGFloat scrollowPoint_x,UIColor *textColora) {
        //弹出输入界面
        [weakSelf addText:weakSelf.addTextView.text tag:[NSString stringWithFormat:@"%ld",(long)tag] scrollowPoint_x:scrollowPoint_x labelTextColor:textColora];
    };
    
    [_saveImageScrollow addSubview: _addTextView];
    _addTextView.scrollowHeight = _saveImageScrollow.contentSize.height;
    _addTextView.scrollowPoint = _saveImageScrollow.contentOffset.y;
    NSString *content = option[@"itemValue"];
    UIColor *textColor = option[@"textColor"];
    _addTextView.scrollowPoint_x = [option[@"scrollowPoint_x"]floatValue];
    _addTextView.textString = content;
    _addTextView.textColor = textColor;
}

//获取截屏
- (UIImage *)getCutImage {
    
    return [self captureCurrentView:self.saveImageScrollow];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 *转换成马赛克,level代表一个点转为多少level*level的正方形
 */
- (UIImage *)transToMosaicImage:(UIImage*)orginImage blockLevel:(NSUInteger)level {
    //获取BitmapData
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGImageRef imgRef = orginImage.CGImage;
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    CGContextRef context = CGBitmapContextCreate (nil,
                                                  width,
                                                  height,
                                                  kBitsPerComponent,        //每个颜色值8bit
                                                  width*kPixelChannelCount, //每一行的像素点占用的字节数，每个像素点的ARGB四个通道各占8个bit
                                                  colorSpace,
                                                  kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imgRef);
    unsigned char *bitmapData = CGBitmapContextGetData (context);
    
    //这里把BitmapData进行马赛克转换,就是用一个点的颜色填充一个level*level的正方形
    unsigned char pixel[kPixelChannelCount] = {0};
    NSUInteger index,preIndex;
    for (NSUInteger i = 0; i < height - 1; i++) {
        for (NSUInteger j = 0; j < width - 1; j++) {
            index = i * width + j;
            if (i % level == 0) {
                if (j % level == 0) {
                    memcpy(pixel, bitmapData + kPixelChannelCount*index, kPixelChannelCount);
                } else {
                    memcpy(bitmapData + kPixelChannelCount*index, pixel, kPixelChannelCount);
                }
            } else {
                preIndex = (i-1)*width +j;
                memcpy(bitmapData + kPixelChannelCount*index, bitmapData + kPixelChannelCount*preIndex, kPixelChannelCount);
            }
        }
    }
    
    NSInteger dataLength = width*height* kPixelChannelCount;
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, bitmapData, dataLength, NULL);
    //创建要输出的图像
    CGImageRef mosaicImageRef = CGImageCreate(width, height,
                                              kBitsPerComponent,
                                              kBitsPerPixel,
                                              width*kPixelChannelCount ,
                                              colorSpace,
                                              kCGBitmapByteOrder32Big,
                                              provider,
                                              NULL, NO,
                                              kCGRenderingIntentDefault);
    CGContextRef outputContext = CGBitmapContextCreate(nil,
                                                       width,
                                                       height,
                                                       kBitsPerComponent,
                                                       width*kPixelChannelCount,
                                                       colorSpace,
                                                       kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(outputContext, CGRectMake(0, 2, width, height), mosaicImageRef);
    CGImageRef resultImageRef = CGBitmapContextCreateImage(outputContext);
    UIImage *resultImage = nil;
    if([UIImage respondsToSelector:@selector(imageWithCGImage:scale:orientation:)]) {
        float scale = [[UIScreen mainScreen] scale];
        resultImage = [UIImage imageWithCGImage:resultImageRef scale:scale orientation:UIImageOrientationUp];
    } else {
        resultImage = [UIImage imageWithCGImage:resultImageRef];
    }
    //释放
    if(resultImageRef){
        CFRelease(resultImageRef);
    }
    if(mosaicImageRef){
        CFRelease(mosaicImageRef);
    }
    if(colorSpace){
        CGColorSpaceRelease(colorSpace);
    }
    if(provider){
        CGDataProviderRelease(provider);
    }
    if(context){
        CGContextRelease(context);
    }
    if(outputContext){
        CGContextRelease(outputContext);
    }
    return resultImage;
}

//获取当前View的截图
-(UIImage *)captureCurrentView :(UIScrollView *)view {
    
    _colorBackground.hidden = YES;
    _bottomView.hidden = YES;
    _topView.hidden = YES;
    
    CGPoint savedContentOffset = _saveImageScrollow.contentOffset;
    CGRect savedFrame = _saveImageScrollow.frame;
    _saveImageScrollow.contentOffset = CGPointZero;
    _saveImageScrollow.frame = CGRectMake(0, 0, _saveImageScrollow.contentSize.width, _saveImageScrollow.contentSize.height);
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(_saveImageScrollow.contentSize.width, _saveImageScrollow.contentSize.height), YES, 0);
    
    CGContextRef contextRef =UIGraphicsGetCurrentContext();
    
    [_saveImageScrollow.layer renderInContext:contextRef];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    _saveImageScrollow.contentOffset = savedContentOffset;
    
    _saveImageScrollow.frame = savedFrame;
    
    UIGraphicsEndImageContext();
    
    _bottomView.hidden = NO;
    _topView.hidden = NO;
    
    return image;
}

- (void)dealloc {
    NSLog(@"edit_dealloc");
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
