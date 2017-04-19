//
//  RHMosicaView.m
//  EaseChat
//
//  Created by Mr. Chen on 2017/4/6.
//  Copyright © 2017年 Mr. Chen. All rights reserved.
//

#import "RHMosicaView.h"
@interface PathModel : NSObject
@property (nonatomic, assign) CGMutablePathRef path;
@property (nonatomic, copy) NSString *color;
@property (nonatomic, copy) NSString *width;

@end

@implementation PathModel

@end

@interface RHMosicaView ()
{
    NSMutableArray *pathArr;
}

@property (nonatomic, strong) UIImageView *surfaceImageView;

@property (nonatomic, strong) CALayer *imageLayer;

@property (nonatomic, strong) CAShapeLayer *shapeLayer;
//设置手指的涂抹路径
@property (nonatomic, assign) CGMutablePathRef path;

@end

@implementation RHMosicaView

static NSMutableArray *pointArray;

- (void)dealloc {
    
    if (self.path) {
        CGPathRelease(self.path);
    }
}

-(instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        //添加imageview（surfaceImageView）到self上
        self.surfaceImageView = [[UIImageView alloc]initWithFrame:self.bounds];
//        [self addSubview:self.surfaceImageView];
        self.backgroundColor = [UIColor clearColor];
        //添加layer（imageLayer）到self上
        self.imageLayer = [CALayer layer];
        self.imageLayer.frame = self.bounds;
        [self.layer addSublayer:self.imageLayer];
        
        self.shapeLayer = [CAShapeLayer layer];
        self.shapeLayer.frame = self.bounds;
        self.shapeLayer.lineCap = kCALineCapRound;
        self.shapeLayer.lineJoin = kCALineJoinRound;
        self.shapeLayer.lineWidth = 20.f;
        self.shapeLayer.strokeColor = [UIColor whiteColor].CGColor;
        self.shapeLayer.fillColor = nil;
        
        [self.layer addSublayer:self.shapeLayer];
        self.imageLayer.mask = self.shapeLayer;
        
        self.path = CGPathCreateMutable();
        pathArr = [[NSMutableArray alloc]init];
        
    }
    return self;
}

- (void)setImage:(UIImage *)image {
    //底图
    _image = image;
    self.imageLayer.contents = (id)image.CGImage;
}

- (void)setSurfaceImage:(UIImage *)surfaceImage {
    //顶图
    _surfaceImage = surfaceImage;
    self.surfaceImageView.image = surfaceImage;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [super touchesBegan:touches withEvent:event];
    
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    CGPathMoveToPoint(self.path, NULL, point.x, point.y);
    CGMutablePathRef path = CGPathCreateMutableCopy(self.path);
    self.shapeLayer.path = path;
    CGPathRelease(path);
    
    if (self.beginBlock) {
        self.beginBlock();
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [super touchesMoved:touches withEvent:event];
    
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    CGPathAddLineToPoint(self.path, NULL, point.x, point.y);
    CGMutablePathRef path = CGPathCreateMutableCopy(self.path);
    self.shapeLayer.path = path;
    CGPathRelease(path);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [super touchesEnded:touches withEvent:event];
    
    PathModel *model = [[PathModel alloc]init];
    model.path = self.path;
    [pathArr addObject:model];
    
    if (self.endBlock) {
        self.endBlock();
    }
}

- (void)drawRect:(CGRect)rect {
    
    //根据path,划线
    if (_path != nil) {
        CGMutablePathRef path = CGPathCreateMutableCopy(self.path);
        self.shapeLayer.path = path;
        CGPathRelease(path);
    }
    
    if (pathArr != nil) {
        for (int i = 0; i < pathArr.count; i ++) {
            //创建模型
            PathModel *model = [pathArr objectAtIndex:i];
            //去除模型中的数据
            CGMutablePathRef pa = model.path;
            
            //获取上下文，这里的上下文与前面获取的为同一个
            CGContextRef ctx = UIGraphicsGetCurrentContext();
            //添加路径到上下文
            CGContextAddPath(ctx, pa);
            CGContextSetLineWidth(ctx, 5);
            //画
            CGContextDrawPath(ctx, kCGPathStroke);
        }
    }
}

//删除数组里的最后一个model
- (void)back {
    
    [pathArr removeLastObject];
    
    [self setNeedsDisplay];
}
@end
