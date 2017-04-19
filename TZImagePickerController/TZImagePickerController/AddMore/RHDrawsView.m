//
//  RHDrawsView.m
//  EaseChat
//
//  Created by Mr. Chen on 2017/4/6.
//  Copyright © 2017年 Mr. Chen. All rights reserved.
//

#import "RHDrawsView.h"

@interface RHDrawsView ()
@property (nonatomic, strong, nullable) NSMutableArray * drawPaths;
@property (nonatomic, strong, nullable) NSMutableArray * drawLayers;

@end
@implementation RHDrawsView

- (id)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        self.color = [UIColor blackColor];
    }
    return self;
}

- (void)setColor:(UIColor *)color {
    
    _color = color;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [super touchesBegan:touches withEvent:event];
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:[[touches anyObject] locationInView:self]];
    
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.backgroundColor = [UIColor clearColor].CGColor;
    layer.frame = self.bounds;
    layer.path = path.CGPath;
    layer.lineWidth = 5.0f;
    layer.strokeColor = self.color.CGColor;
    layer.miterLimit = 2.0f;
    layer.lineDashPhase = 10;
    layer.lineDashPattern = @[@1 , @0];
    layer.fillColor = [UIColor clearColor].CGColor;
    layer.fillRule = kCAFillRuleEvenOdd;
    layer.lineCap = kCALineCapRound;
    layer.lineJoin = kCALineJoinRound;
    
    // 将layer添加进图层
    [self.layer addSublayer:layer];
    [self.drawPaths addObject:path];
    [self.drawLayers addObject:layer];
    
    if (self.beginBlock) {
        self.beginBlock(self.drawPaths);
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [super touchesMoved:touches withEvent:event];
    UIBezierPath *path = self.drawPaths.lastObject;
    CAShapeLayer *layer = self.drawLayers.lastObject;
    [path addLineToPoint:[[touches anyObject] locationInView:self]];
    layer.path = path.CGPath;
}

- (NSMutableArray *)drawPaths {
    
    if (_drawPaths == nil) {
        _drawPaths = [NSMutableArray array];
    }
    return _drawPaths;
}

- (NSMutableArray *)drawLayers {
    
    if (_drawLayers == nil) {
        _drawLayers = [NSMutableArray array];
    }
    return _drawLayers;
}

- (void)clearAll {
    for (CAShapeLayer * layer in self.drawLayers) {
        [layer removeFromSuperlayer];
    }
    self.drawLayers = nil;
    [self.drawPaths removeAllObjects];
    
    if (self.clearBlock) {
        self.clearBlock(self.drawPaths);
    }
}

- (void)clearup {
    
    CAShapeLayer *layer = self.drawLayers.lastObject;
    
    [layer removeFromSuperlayer];
    [self.drawLayers removeLastObject];
    if (self.clearBlock) {
        self.clearBlock(self.drawLayers);
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (self.endBlock) {
        self.endBlock(self.drawPaths);
    }
}

@end
