//
//  AXBarChartCell.m
//  AXChartKits
//
//  Created by devedbox on 16/8/15.
//  Copyright © 2016年 AiXing. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

#import "AXBarChartCell.h"

@interface AXBarChartCell ()
/// Shape layer.
@property(readonly, nonatomic) CAShapeLayer *shapeLayer;
/// Gradient layer.
@property(strong, nonatomic) CAGradientLayer *gradientLayer;
/// Drawing box rect.
@property(readonly, nonatomic) CGRect drawingBox;
@end

@implementation AXBarChartCell
@synthesize shapeLayer = _shapeLayer;
#pragma mark - Initializer
- (instancetype)init {
    if (self = [super init]) {
        [self initializer];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initializer];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initializer];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self initializer];
}

- (void)initializer {
    _duration = 1.2;
    _strokeColor = [UIColor orangeColor];
    _strokeEndColor = [UIColor redColor];
    _style = AXBarChartCellStyleCornerRadius;
    _direction = AXBarChartCellHorizontal;
    _cornerRadius = 3.0;
    
    
    // Add shape layer to the super layer.s
    [self.layer addSublayer:self.gradientLayer];
}
#pragma mark - Override
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    [super drawRect:rect];
    // ...
    NSAssert(_value <= 1.0, @"Value of bar chart cell cannot larger than 1.0.");
    // Quit if it is not visible.
    if (!_visible) {
        return;
    }
    // Get the drawing box.
    CGRect drawingBox = self.drawingBox;
    if (_style == AXBarChartCellStyleCornerRadius) {
        if (_direction == AXBarChartCellHorizontal) {
            if (CGRectGetHeight(drawingBox) > CGRectGetWidth(drawingBox)) {
                return;
            }
        } else {
            if (CGRectGetWidth(drawingBox) > CGRectGetHeight(drawingBox)) {
                return;
            }
        }
    }
    // Init the path.
    UIBezierPath *path = [UIBezierPath bezierPath];
    if (_style == AXBarChartCellStyleCornerRadius) {
        if (_direction == AXBarChartCellHorizontal) {
            [path moveToPoint:CGPointMake(CGRectGetMinX(drawingBox), CGRectGetHeight(drawingBox)*.5)];
            [path addLineToPoint:CGPointMake(CGRectGetMinX(drawingBox) + CGRectGetWidth(drawingBox)*_value, CGRectGetHeight(drawingBox)*.5)];
        } else {
            [path moveToPoint:CGPointMake(CGRectGetWidth(drawingBox)*.5, CGRectGetMaxY(drawingBox))];
            [path addLineToPoint:CGPointMake(CGRectGetWidth(drawingBox)*.5, CGRectGetMinY(drawingBox) + CGRectGetHeight(drawingBox) * (1-_value))];
        }
    } else {
        if (_direction == AXBarChartCellHorizontal) {
            // Get bounds to fill.
            CGRect bounds = CGRectMake(CGRectGetMinX(drawingBox), CGRectGetMinY(drawingBox), CGRectGetWidth(drawingBox)*_value, CGRectGetHeight(drawingBox));
            // Get path.
            path = [UIBezierPath bezierPathWithRoundedRect:bounds byRoundingCorners:UIRectCornerTopRight|UIRectCornerBottomRight cornerRadii:CGSizeMake(_cornerRadius, _cornerRadius)];
        } else {
            // Get bounds to fill.
            CGRect bounds = CGRectMake(CGRectGetMinX(drawingBox), CGRectGetMinY(drawingBox) + CGRectGetHeight(drawingBox)*(1-_value), CGRectGetWidth(drawingBox), CGRectGetHeight(drawingBox)*_value);
            // Get path.
            path = [UIBezierPath bezierPathWithRoundedRect:bounds byRoundingCorners:UIRectCornerTopLeft|UIRectCornerTopRight cornerRadii:CGSizeMake(_cornerRadius, _cornerRadius)];
        }
        
        [path closePath];
    }
    if (_style == AXBarChartCellStyleCornerRadius) {
        _shapeLayer.strokeColor = self.tintColor.CGColor;
        // Set up line width of shape layer.
        if (_direction == AXBarChartCellHorizontal) {
            _shapeLayer.lineWidth = CGRectGetHeight(drawingBox);
        } else {
            _shapeLayer.lineWidth = CGRectGetWidth(drawingBox);
        }
        _shapeLayer.lineCap = kCALineCapRound;
        // Set up value of shape layer.
        _shapeLayer.strokeStart = .0;
        _shapeLayer.strokeEnd = _value;
    } else {
        _shapeLayer.lineWidth = .0;
        _shapeLayer.strokeEnd = .0;
    }
    // Set up gradient layer.
    if (_direction == AXBarChartCellHorizontal) {
        _gradientLayer.startPoint = CGPointMake(.0, .5);
        _gradientLayer.endPoint = CGPointMake(1.0, .5);
    } else {
        _gradientLayer.startPoint = CGPointMake(.5, .0);
        _gradientLayer.endPoint = CGPointMake(.5, 1.0);
    }
    _gradientLayer.colors = @[(id)_strokeColor.CGColor, (id)_strokeEndColor.CGColor];
    
    // Set up shape layer.
    _shapeLayer.path = path.CGPath;
}

- (void)layoutSublayersOfLayer:(CALayer *)layer {
    [super layoutSublayersOfLayer:layer];
    _shapeLayer.frame = self.layer.bounds;
    _gradientLayer.frame = self.layer.bounds;
}

#pragma mark - Getters
- (CAShapeLayer *)shapeLayer {
    if (_shapeLayer) return _shapeLayer;
    _shapeLayer = [CAShapeLayer layer];
    return _shapeLayer;
}

- (CAGradientLayer *)gradientLayer {
    if (_gradientLayer) return _gradientLayer;
    _gradientLayer = [CAGradientLayer layer];
    _gradientLayer.startPoint = CGPointMake(.5, .0);
    _gradientLayer.endPoint = CGPointMake(.5, 1.0);
    _gradientLayer.mask = self.shapeLayer;
    return _gradientLayer;
}

- (CGRect)drawingBox {
    if (_style == AXBarChartCellStyleCornerRadius) {
        if (_direction == AXBarChartCellHorizontal) {
            return CGRectMake(CGRectGetHeight(self.frame)*.5, 0, MAX(0, CGRectGetWidth(self.frame)-CGRectGetHeight(self.frame)), CGRectGetHeight(self.frame));
        } else {
            return CGRectMake(0, CGRectGetWidth(self.frame)*.5, CGRectGetWidth(self.frame), MAX(0, CGRectGetHeight(self.frame)-CGRectGetWidth(self.frame)));
        }
    } else {
        return self.bounds;
    }
}

#pragma mark - Setters
- (void)setStyle:(AXBarChartCellStyle)style {
    _style = style;
    [self setNeedsDisplay];
}

- (void)setValue:(CGFloat)value {
    _value = value;
    [self setNeedsDisplay];
}

- (void)setDirection:(AXBarChartCellDirection)direction {
    _direction = direction;
    [self setNeedsDisplay];
}

- (void)setStrokeColor:(UIColor *)strokeColor {
    _strokeColor = strokeColor;
    [self setStrokeColors];
}

- (void)setStrokeEndColor:(UIColor *)strokeEndColor {
    _strokeEndColor = strokeEndColor;
    [self setStrokeColors];
}

#pragma mark - Public
- (void)redrawAnimated:(BOOL)animated completion:(dispatch_block_t)completion {
    [self updateToValue:_value animated:animated completion:completion];
}

- (void)updateToValue:(CGFloat)value animated:(BOOL)animated completion:(dispatch_block_t)completion {
    if (_redrawing) return;
    _visible = YES;
    _redrawing = YES;
    if (!animated) {
        [self setNeedsDisplay];
        if (completion) {
            completion();
        }
        return;
    }
    POPBasicAnimation *anim = [self pop_animationForKey:kPOPViewAXCBarValues];
    if(anim == nil)
    {
        anim = [POPBasicAnimation animation];
        anim.property = [AXChartBase AXCPropertyWithName:kPOPViewAXCBarValues];
        [self pop_addAnimation:anim forKey:kPOPViewAXCBarValues];
        anim.completionBlock=^(POPAnimation *ani, BOOL finished){
            if (finished) {
                _redrawing = NO;
                [self setNeedsDisplay];
                if (completion) {
                    completion();
                }
            }
        };
    }
    anim.duration = _duration;
    anim.timingFunction = kAXDefaultMediaTimingFunction;
    anim.fromValue = [NSNumber numberWithFloat:.0];
    anim.toValue = [NSNumber numberWithFloat:value];
}

#pragma mark - Private
- (void)setStrokeColors {
    NSMutableArray *colors = [NSMutableArray array];
    if (_strokeColor != nil) {
        [colors addObject:(id)_strokeColor.CGColor];
    }
    if (_strokeEndColor != nil) {
        [colors addObject:(id)_strokeEndColor.CGColor];
    }
    _gradientLayer.colors = colors;
}
@end