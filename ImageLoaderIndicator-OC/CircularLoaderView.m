//
//  CircularLoaderView.m
//  ImageLoaderIndicator-OC
//
//  Created by Alpha Yu on 8/13/15.
//  Copyright (c) 2015 tlm group. All rights reserved.
//

#import "CircularLoaderView.h"

@implementation CircularLoaderView {
    CAShapeLayer *_circlePathLayer;
    CGFloat _circleRadius;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _circlePathLayer = [CAShapeLayer layer];
        _circleRadius = 20.0;
        [self configure];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        _circlePathLayer = [CAShapeLayer layer];
        _circleRadius = 20.0;
        [self configure];
    }
    return self;
}

- (void)configure {
    _circlePathLayer.frame = self.bounds;
    _circlePathLayer.lineWidth = 2;
    _circlePathLayer.fillColor = [UIColor clearColor].CGColor;
    _circlePathLayer.strokeColor = [UIColor redColor].CGColor;
    [self.layer addSublayer:_circlePathLayer];
    self.backgroundColor = [UIColor whiteColor];
    
    self.progress = 0;
}

- (CGRect)circleFrame {
    CGRect circleFrame = CGRectMake(0, 0, 2.0 * _circleRadius, 2.0 * _circleRadius);
    circleFrame.origin.x = CGRectGetMidX(_circlePathLayer.bounds) - CGRectGetMidX(circleFrame);
    circleFrame.origin.y = CGRectGetMidY(_circlePathLayer.bounds) - CGRectGetMidY(circleFrame);
    return circleFrame;
}

- (UIBezierPath *)circlePath {
    return [UIBezierPath bezierPathWithOvalInRect:[self circleFrame]];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _circlePathLayer.frame = self.bounds;
    _circlePathLayer.path = [self circlePath].CGPath;
}

- (CGFloat)progress {
    return _circlePathLayer.strokeEnd;
}

- (void)setProgress:(CGFloat)progress {
    if (progress > 1) {
        _circlePathLayer.strokeEnd = 1;
    } else if (progress < 0) {
        _circlePathLayer.strokeEnd = 0;
    } else {
        _circlePathLayer.strokeEnd = progress;
    }
}

- (void)reveal {
    //1
    self.backgroundColor = [UIColor clearColor];
    self.progress = 1;
    
    [_circlePathLayer removeAnimationForKey:@"strokeEnd"];
    [_circlePathLayer removeFromSuperlayer];
    
    self.superview.layer.mask = _circlePathLayer;
    
    //2
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    CGFloat finalRadius = sqrt((center.x*center.x) + (center.y*center.y));
    CGFloat radiusInset = finalRadius - _circleRadius;
    CGRect outerRect = CGRectInset([self circleFrame], -radiusInset, -radiusInset);
    CGPathRef toPath = [UIBezierPath bezierPathWithOvalInRect:outerRect].CGPath;
    
    CGPathRef fromPath = _circlePathLayer.path;
    CGFloat fromLineWidth = _circlePathLayer.lineWidth;
    
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    _circlePathLayer.lineWidth = 2 * finalRadius;
    _circlePathLayer.path = toPath;
    [CATransaction commit];
    
    CABasicAnimation *lineWidthAnimation = [CABasicAnimation animationWithKeyPath:@"lineWidth"];
    lineWidthAnimation.fromValue = @(fromLineWidth);
    lineWidthAnimation.toValue = @(2 * finalRadius);
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
    pathAnimation.fromValue = (__bridge id)fromPath;
    pathAnimation.toValue = (__bridge id)toPath;
    
    CAAnimationGroup *groupAnimation = [CAAnimationGroup animation];
    groupAnimation.duration = 1;
    groupAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    groupAnimation.animations = @[pathAnimation, lineWidthAnimation];
    groupAnimation.delegate = self;
    [_circlePathLayer addAnimation:groupAnimation forKey:@"strokeWidth"];
}

#pragma mark - animation delegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    self.superview.layer.mask = nil;
}
@end
