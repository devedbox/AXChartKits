//
//  AXCircleChart.m
//  AXChartKits
//
//  Created by ai on 16/1/5.
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

#import "AXCircleChartView.h"

@interface AXCircleChartView ()
{
    UILabel *_textLabel;
    CGSize _maxLabelSize;
}
/// Shape layer.
@property(strong, nonatomic) CAShapeLayer *shapeLayer;
/// Fill layer.
@property(strong, nonatomic) CAShapeLayer *fillLayer;
/// Gradient layer.
@property(strong, nonatomic) CAGradientLayer *gradientLayer;
/// MAX size of text label.
@property(readonly, nonatomic) CGSize maxLabelSize;
/// Text label.
@property(readonly, strong, nonatomic) UILabel *textLabel;
@end

static NSString *FormtterStringWithFormat(AXCircleChartFormat format) {
    NSString *formatstr;
    switch (format) {
        case AXCircleChartFormatPercent:
            formatstr = @"%.0f %%";
            break;
        case AXCircleChartFormatRMB:
            formatstr = @"%.0f ¥";
            break;
        case AXCircleChartFormatDollar:
            formatstr = @"%.0f $";
            break;
        case AXCircleChartFormatDecimal:
            formatstr = @"%.1f";
            break;
        case AXCircleChartFormatDecimalTwoPlaces:
            formatstr = @"%.2f";
            break;
        case AXCircleChartFormatNone:
        default:
            formatstr = @"%.0f";
            break;
    }
    return formatstr;
}

@implementation AXCircleChartView
#pragma mark - Life cycle
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

- (void)initializer {
    _percents = .0;
    _lineWidth = 12.0;
    _lineCap = AXLineCapRound;
    _angleOffsets = -M_PI_2;
    _duration = 1.2;
    _fillsPath = YES;
    _strokeColor = [UIColor orangeColor];
    _strokeEndColor = [UIColor redColor];
    _formatter = AXCircleChartFormatPercent;
    _showsLabel = YES;
    _switchsFillingOnTouch = YES;
    _fillColor = [UIColor orangeColor];
    _touchAction = AXCircleChartTouchActionSwitchFilling;
    [self.layer addSublayer:self.gradientLayer];
    [self.layer addSublayer:self.fillLayer];
    [self addSubview:self.textLabel];
}
#pragma mark - Override
- (void)layoutSublayersOfLayer:(CALayer *)layer {
    [super layoutSublayersOfLayer:layer];
    _gradientLayer.frame = self.layer.bounds;
    _shapeLayer.frame = CGRectMake(0, 0, 2*self.bounds.size.width, 2*self.bounds.size.height);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [_textLabel sizeToFit];
    CGRect rect = _textLabel.frame;
    rect.size = self.maxLabelSize;
    rect.origin.x = (CGRectGetWidth(self.frame) - CGRectGetWidth(rect))/2;
    rect.origin.y = (CGRectGetHeight(self.frame) - CGRectGetHeight(rect))/2;
    _textLabel.frame = rect;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initializer];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    if (!_visible) return;
    CGFloat size = MIN(CGRectGetHeight(self.frame), CGRectGetWidth(self.frame));
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(CGRectGetWidth(self.frame)/2, CGRectGetHeight(self.frame)/2) radius:size/2 - _lineWidth/2 startAngle:0+_angleOffsets endAngle:M_PI*2*_percents+_angleOffsets clockwise:YES];
    _shapeLayer.path = circlePath.CGPath;
    _fillLayer.lineWidth = (size-_lineWidth*2)/2;
    _fillLayer.path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(CGRectGetWidth(self.frame)/2, CGRectGetHeight(self.frame)/2) radius:(size-_lineWidth*2)/4 startAngle:0+_angleOffsets endAngle:M_PI*2*_percents+_angleOffsets clockwise:YES].CGPath;
    if (_fillsPath) {
        _fillLayer.strokeColor = [_fillColor colorWithAlphaComponent:0.3].CGColor;
    } else {
        _fillLayer.strokeColor = [UIColor clearColor].CGColor;
    }
    [self layoutSubviews];
}

- (void)didTouch:(CGPoint)location {
    [super didTouch:location];
    
    CGPoint center = CGPointMake(CGRectGetWidth(self.frame)/2, CGRectGetHeight(self.frame)/2);
    CGFloat distance = sqrtf(powf(center.x - location.x, 2)+powf(center.y - location.y, 2));
    
    CGFloat size = MIN(CGRectGetHeight(self.frame), CGRectGetWidth(self.frame));
    
    if (distance <= size/2) {
        switch (_touchAction) {
            case AXCircleChartTouchActionRedraw:
                [self redrawAnimated:YES completion:NULL];
                break;
            case AXCircleChartTouchActionSwitchFilling:
                [self handleSwitchFilling];
                break;
            default:
                if (_switchsFillingOnTouch) {
                    [self handleSwitchFilling];
                }
                break;
        }
        if (_delegate && [_delegate respondsToSelector:@selector(circleChartDidTouch:)]) {
            [_delegate circleChartDidTouch:self];
        }
        if (_touchCall != NULL) {
            _touchCall (self);
        }
    }
}

#pragma mark - Getters
- (CAShapeLayer *)shapeLayer {
    if (_shapeLayer) return _shapeLayer;
    _shapeLayer = [CAShapeLayer layer];
    _shapeLayer.lineCap = kCALineCapRound;
    _shapeLayer.lineWidth = _lineWidth;
    _shapeLayer.strokeColor = [UIColor blackColor].CGColor;
    _shapeLayer.fillColor = [UIColor clearColor].CGColor;
    return _shapeLayer;
}

- (CAShapeLayer *)fillLayer {
    if (_fillLayer) return _fillLayer;
    _fillLayer = [CAShapeLayer layer];
    _fillLayer.lineCap = kCALineCapButt;
    _fillLayer.strokeColor = [_fillColor colorWithAlphaComponent:0.3].CGColor;
    _fillLayer.fillColor = [UIColor clearColor].CGColor;
    return _fillLayer;
}

- (CAGradientLayer *)gradientLayer {
    if (_gradientLayer) return _gradientLayer;
    _gradientLayer = [CAGradientLayer layer];
    _gradientLayer.startPoint = CGPointMake(.5, .0);
    _gradientLayer.endPoint = CGPointMake(.5, 1.0);
    _gradientLayer.colors = @[(id)_strokeColor.CGColor, (id)_strokeEndColor.CGColor];
    _gradientLayer.mask = self.shapeLayer;
    return _gradientLayer;
}

- (CGSize)maxLabelSize {
    CGFloat size = MIN(CGRectGetHeight(self.frame), CGRectGetWidth(self.frame));
    CGFloat radius = size/2 - _lineWidth;
    CGFloat x = radius * cosf(M_PI_4);
    if (x<=0) {
        _maxLabelSize = CGSizeZero;
    } else {
        _maxLabelSize = CGSizeMake(x*2, x*2);
    }
    return _maxLabelSize;
}

- (UILabel *)textLabel {
    if (_textLabel) return _textLabel;
    _textLabel = [[UILabel alloc] initWithFrame:self.bounds];
    _textLabel.backgroundColor = [UIColor clearColor];
    _textLabel.textColor = [UIColor orangeColor];
    _textLabel.font = [UIFont boldSystemFontOfSize:16];
    _textLabel.textAlignment = NSTextAlignmentCenter;
    _textLabel.numberOfLines = 0;
    _textLabel.adjustsFontSizeToFitWidth = YES;
    _textLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    return _textLabel;
}

- (UIColor *)textColor {
    return _textLabel.textColor;
}

- (UIFont *)textFont {
    return _textLabel.font;
}

#pragma mark - Setters
- (void)setPercents:(CGFloat)percents {
    if (percents > 1) return;
    _percents = percents;
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

- (void)setTextColor:(UIColor *)textColor {
    _textLabel.textColor = textColor;
}

- (void)setTextFont:(UIFont *)textFont {
    _textLabel.font = textFont;
}

- (void)setFillColor:(UIColor *)fillColor {
    _fillColor = fillColor;
    _fillLayer.strokeColor = [_fillColor colorWithAlphaComponent:0.3].CGColor;
}

- (void)setShowsLabel:(BOOL)showsLabel {
    _showsLabel = showsLabel;
    _textLabel.hidden = !_showsLabel;
}

- (void)setAngleOffsets:(CGFloat)angleOffsets {
    _angleOffsets = angleOffsets;
    [self setNeedsDisplay];
}

- (void)setLineWidth:(CGFloat)lineWidth {
    _lineWidth = lineWidth;
    _shapeLayer.lineWidth = _lineWidth;
    [self setNeedsDisplay];
}

- (void)setLineCap:(AXLineCap)lineCap {
    _lineCap = lineCap;
    switch (_lineCap) {
        case AXLineCapButt:
            _shapeLayer.lineCap = kCALineCapButt;
            break;
        case AXLineCapRound:
            _shapeLayer.lineCap = kCALineCapRound;
            break;
        default:
            _shapeLayer.lineCap = kCALineCapSquare;
            break;
    }
    [self setNeedsDisplay];
}

- (void)setFillsPath:(BOOL)fillsPath {
    _fillsPath = fillsPath;
    [self setNeedsDisplay];
}

#pragma mark - Public
- (void)redrawAnimated:(BOOL)animated completion:(dispatch_block_t)completion {
    [self updateFromPercents:.0 toPercents:_percents animated:animated completion:completion];
}

- (void)updateFromCurrentToPercents:(CGFloat)toPercents animated:(BOOL)animated completion:(dispatch_block_t)completion {
    [self updateFromPercents:_percents toPercents:toPercents animated:animated completion:completion];
}

- (void)updateFromPercents:(CGFloat)fromPercents toPercents:(CGFloat)toPercents animated:(BOOL)animated completion:(dispatch_block_t)completion {
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
    POPBasicAnimation *anim = [self pop_animationForKey:kPOPViewAXCCirclePercents];
    if(anim == nil)
    {
        anim = [POPBasicAnimation animation];
        anim.property = [AXChartBase AXCPropertyWithName:kPOPViewAXCCirclePercents];
        [self pop_addAnimation:anim forKey:kPOPViewAXCPieAngle];
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
    anim.fromValue = [NSNumber numberWithFloat:fromPercents];
    anim.toValue = [NSNumber numberWithFloat:toPercents];
    [self updateTextFromPercents:fromPercents toPercents:toPercents animated:animated completion:NULL];
}

- (void)updateTextFromPercents:(CGFloat)fromPercents toPercents:(CGFloat)toPercents animated:(BOOL)animated completion:(dispatch_block_t)completion
{
    POPBasicAnimation *textAnim = [POPBasicAnimation animation];
    textAnim.duration = _duration;
    textAnim.timingFunction = kAXDefaultMediaTimingFunction;
    
    POPAnimatableProperty * prop = [POPAnimatableProperty propertyWithName:@"count" initializer:^(POPMutableAnimatableProperty *prop) {
        // read value
        prop.readBlock = ^(id obj, CGFloat values[]) {
            values[0] = [[[[obj description] componentsSeparatedByString:@" "] firstObject] floatValue];
        };
        // write value
        prop.writeBlock = ^(id obj, const CGFloat values[]) {
            [obj setText:[NSString stringWithFormat:FormtterStringWithFormat(_formatter) , MIN(values[0], 100)]];
        };
        // dynamics threshold
        prop.threshold = 0.01;
    }];
    
    textAnim.property = prop;
    
    textAnim.fromValue = @(fromPercents*100.0);
    textAnim.toValue = @(toPercents*100.0);
    
    [_textLabel pop_removeAllAnimations];
    [_textLabel pop_addAnimation:textAnim forKey:@"counting"];
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

- (void)handleSwitchFilling {
    self.fillsPath = !_fillsPath;
}
@end