//
//  AXChartView.m
//  AXChartKits
//
//  Created by devedbox on 16/8/18.
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

#import "AXChartView.h"

@interface AXChartView ()
/// Gradient layer.
@property(strong, nonatomic) CAGradientLayer *gradientLayer;
@end

@implementation AXChartView
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
    self.backgroundColor = [UIColor orangeColor];
    _backgroundEndColor = [UIColor redColor];
    [self.layer addSublayer:self.gradientLayer];
}

#pragma mark - Override
- (void)layoutSublayersOfLayer:(CALayer *)layer {
    [super layoutSublayersOfLayer:layer];
    // Layout gradient layer.
    _gradientLayer.frame = self.layer.bounds;
}

#pragma mark - Getters
- (CAGradientLayer *)gradientLayer {
    if (_gradientLayer) return _gradientLayer;
    _gradientLayer = [CAGradientLayer layer];
    _gradientLayer.startPoint = CGPointMake(.5, .0);
    _gradientLayer.endPoint = CGPointMake(.5, 1.0);
    _gradientLayer.colors = @[(id)self.backgroundColor.CGColor, (id)_backgroundEndColor.CGColor];
    return _gradientLayer;
}

#pragma mark - Setters
- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];
    // Set gradient colors.
    [self setGradientColors];
}

- (void)setBackgroundEndColor:(UIColor *)backgroundEndColor {
    _backgroundEndColor = backgroundEndColor;
    // Set gradient colors.
    [self setGradientColors];
}
#pragma mark - Private
- (void)setGradientColors {
    NSMutableArray *colors = [NSMutableArray array];
    if (self.backgroundColor != nil) {
        [colors addObject:(id)self.backgroundColor.CGColor];
    }
    if (_backgroundEndColor != nil) {
        [colors addObject:(id)self.backgroundEndColor.CGColor];
    }
    _gradientLayer.colors = colors;
}

@end