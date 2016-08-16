//
//  AXPieChart.m
//  AXChartKits
//
//  Created by ai on 15/12/30.
//  Copyright © 2015年 AiXing. All rights reserved.
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

#import "AXPieChartView.h"
#import <objc/runtime.h>

#ifndef kAXPieChartSize
#define kAXPieChartSize (MIN(CGRectGetHeight(self.frame), CGRectGetWidth(self.frame))-_maxAllowedOffsets*2)
#endif

@interface AXPieChartView ()
{
    @private
    /// Parts.
    NSMutableArray *_parts;
    /// Animated label.
    BOOL _animateLabel;
    /// Needs update labels.
    BOOL _needsUpdateLabel;
}
/// Title label.
@property(strong, nonatomic) UILabel *titleLabel;
/// Valid count of parts.
@property(readonly, nonatomic) NSInteger validCount;
@end

@interface _AXPieShapeLayer : CAShapeLayer
/// Start line layer.
@property(readonly, strong, nonatomic) CAShapeLayer *maskLayer;
/// Offsets.
@property(assign, nonatomic) CGFloat offsets;
/// Angle offsets.
@property(assign, nonatomic) CGFloat angleOffsets;
/// Seperator offsets.
@property(assign, nonatomic) CGFloat seperatorOffsets;
/// Drawing size.
@property(assign, nonatomic) CGFloat drawingSize;
/// Start angle.
@property(assign, nonatomic) CGFloat startAngle;
/// End angle.
@property(assign, nonatomic) CGFloat endAngle;
/// Inner circle radius.
@property(assign, nonatomic) CGFloat innerRadius;
@end

@interface _AXPieGradientLayer : CAGradientLayer
/// Shape layer.
@property(readonly, strong, nonatomic) _AXPieShapeLayer *shapeLayer;
@end

static char *const kAXPieChartHighLightedLayerKey = "selectionlayer";
static char *const kAXPieChartSelectionKey = "selection";
static char *const kAXPieChartTextLabelKey = "label";
static char *const kAXPieChartPartPercentKey = "percent";
static char *const kAXPieChartPartAnimationKey = "animation";

static NSString *const kAXPercentStarting = @"starting";
static NSString *const kAXPercentEnding = @"ending";

inline static CGFloat percentsOfAngle(CGPoint center, CGPoint point, CGFloat angleOffsets, NSString *flag) {
    //Calculate angle of line Passing In Reference And Center
    if ((int)point.x == (int)center.x) {
        if (center.y > point.y) {
            if ([flag isEqualToString:kAXPercentEnding]) {
                return 1.0;
            } else if ([flag isEqualToString:kAXPercentStarting]) {
                return .0;
            } else {
                return .0;
            }
        } else {
            return .5;
        }
    }
    CGFloat angleOfLine = atanf((point.y - center.y) / (point.x - center.x));
    CGFloat percentage = (angleOfLine - angleOffsets)/(2 * M_PI);
    return (point.x - center.x) > 0 ? percentage : percentage + .5;
}

@implementation AXPieChartView
#pragma mark - Initialzier
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
    _parts = [NSMutableArray array];
    _hollowRadius = 20;
    _maxAllowedOffsets = 10;
    _angle = M_PI*2;
    _angleOffsets = -M_PI_2;
    _shouldSelection = YES;
    _allowsMultipleSelection = NO;
    _showsAbsoluteValues = NO;
    _hidesValues = NO;
    _showsOnlyValues = NO;
    _percentsLimitsOfLabel = 0.05;
    _textFont = [UIFont systemFontOfSize:12];
    _textColor = [UIColor whiteColor];
    _maxAllowedLabelWidth = 100;
    _seperatorOffsets = 6;
    _needsUpdateLabel = YES;
    
    _titleFont = [UIFont boldSystemFontOfSize:15];
    _titleColor = [UIColor colorWithWhite:0 alpha:0.8];
    _titleUsingSelectionColor = YES;
    _showsTitle = YES;
    _titleFollowingSelectionPart = YES;
    [self addSubview:self.titleLabel];
}

- (void)dealloc {
}

#pragma mark - Override
- (void)awakeFromNib {
    [super awakeFromNib];
    [self initializer];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    if (!_visible) return;
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(context);
    CGFloat size = kAXPieChartSize;
    CGContextSetLineWidth(context, size/2-_hollowRadius);
    CGFloat startAngle = 0;
    CGFloat endAngle = 0;
    for (NSUInteger i = 0; i < _parts.count; i++) {
        AXPieChartPart *part = _parts[i];
        CGContextSetStrokeColorWithColor(context, ([objc_getAssociatedObject(part, kAXPieChartSelectionKey) boolValue] || [objc_getAssociatedObject(part, kAXPieChartPartAnimationKey) boolValue]) ? [UIColor clearColor].CGColor : part.color.CGColor);
        endAngle += M_PI*2*part.percent;
        endAngle = MIN(_angle, endAngle);
        CGContextAddArc(context, CGRectGetWidth(self.frame)/2, CGRectGetHeight(self.frame)/2, size/4+_hollowRadius/2, startAngle+_angleOffsets, endAngle+_angleOffsets, 0);
        startAngle = endAngle;
        CGContextStrokePath(context);
        UILabel *label = objc_getAssociatedObject(part, kAXPieChartTextLabelKey);
        if (!label) {
            label = [self descriptionLabelForPartAtIndex:i];
            objc_setAssociatedObject(part, kAXPieChartTextLabelKey, label, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        } else if (_needsUpdateLabel) {
            [self updateDescriptionLabel:label atIndex:i animated:NO];
        }
        if (i == _parts.count - 1 && _needsUpdateLabel) {// Set needs update labels to NO if needed.
            _needsUpdateLabel = NO;
        }
        [self addSubview:label];
    }
    UIGraphicsPopContext();
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = sqrt(pow(_hollowRadius, 2)*2);
    CGSize size = CGSizeMake(width, width);
    
    _titleLabel.frame = CGRectMake(CGRectGetWidth(self.frame)*.5-size.width*.5, CGRectGetHeight(self.frame)*.5-size.height*.5, size.width, size.height);
}

- (void)didTouch:(CGPoint)location {
    [super didTouch:location];
    
    CGPoint center = CGPointMake(CGRectGetWidth(self.frame)/2, CGRectGetHeight(self.frame)/2);
    CGFloat distance = sqrt(pow((location.y - center.y),2) + pow((location.x - center.x),2));
    
    CGFloat size = kAXPieChartSize;
    
    if (distance <= size/2) {
        if (distance < _hollowRadius) {
            [self handleInnerCircle];
            return;
        }
        
        if (_parts.count == 0) {
            return;
        }
        
        CGFloat percent = percentsOfAngle(center, location, _angleOffsets, nil);
        int index = 0;
        while (percent > [self endPercentsForItemAtIndex:index]) {
            if (index >= _parts.count - 1) {
                break;
            }
            index ++;
        }
        
        if (percent <= [self endPercentsForItemAtIndex:index]) {
            [self handleTouchOnPartAtIndex:index];
        } else {
            [self handleOutsideCircle];
        }
    } else {
        [self handleOutsideCircle];
    }
}
#pragma mark - Getters
- (NSArray *)parts {
    return [_parts copy];
}

- (NSNumber *)totalValue {
    double value = .0;
    for (AXPieChartPart *part in _parts) {
        value += [part.value doubleValue];
    }
    return @(value);
}

- (UILabel *)titleLabel {
    if (_titleLabel) return _titleLabel;
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _titleLabel.font = _titleFont;
    _titleLabel.adjustsFontSizeToFitWidth = YES;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.numberOfLines = 0;
    _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    return _titleLabel;
}

- (NSInteger)validCount {
    NSInteger __block count = 0;
    [_parts enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        AXPieChartPart *part = (AXPieChartPart *)obj;
        if ([part.value doubleValue] > 0.0) {
            count++;
        }
    }];
    return count;
}

#pragma mark - Setters
- (void)setHollowRadius:(CGFloat)hollowRadius {
    _hollowRadius = hollowRadius;
    [self setNeedsDisplay];
}

- (void)setVisible:(BOOL)visible {
    [super setVisible:visible];
    if (!visible) {
        [self hideLabelAnimated:NO];
    }
    [self setNeedsDisplay];
}

- (void)setAngle:(CGFloat)angle {
    _angle = angle;
    [self setNeedsDisplay];
}

- (void)setAngleOffsets:(CGFloat)angleOffsets {
    _angleOffsets = angleOffsets;
    [self setNeedsDisplay];
}

- (void)setTextFont:(UIFont *)textFont {
    _textFont = textFont;
    [_parts enumerateObjectsUsingBlock:^(AXPieChartPart*  _Nonnull part, NSUInteger idx, BOOL * _Nonnull stop) {
        UILabel *label = objc_getAssociatedObject(part, kAXPieChartTextLabelKey);
        if (label != nil) {
            [self updateDescriptionLabel:label atIndex:idx animated:NO];
        }
    }];
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    [_parts enumerateObjectsUsingBlock:^(AXPieChartPart*  _Nonnull part, NSUInteger idx, BOOL * _Nonnull stop) {
        UILabel *label = objc_getAssociatedObject(part, kAXPieChartTextLabelKey);
        if (label != nil) {
            [self updateDescriptionLabel:label atIndex:idx animated:NO];
        }
    }];
}

- (void)setMaxAllowedLabelWidth:(CGFloat)maxAllowedLabelWidth {
    _maxAllowedLabelWidth = maxAllowedLabelWidth;
    [_parts enumerateObjectsUsingBlock:^(AXPieChartPart*  _Nonnull part, NSUInteger idx, BOOL * _Nonnull stop) {
        UILabel *label = objc_getAssociatedObject(part, kAXPieChartTextLabelKey);
        if (label != nil) {
            [self updateDescriptionLabel:label atIndex:idx animated:NO];
        }
    }];
}

- (void)setShowsOnlyValues:(BOOL)showsOnlyValues {
    _showsOnlyValues = showsOnlyValues;
    _needsUpdateLabel = YES;
    [self setNeedsDisplay];
}

- (void)setShowsAbsoluteValues:(BOOL)showsAbsoluteValues {
    _showsAbsoluteValues = showsAbsoluteValues;
    _needsUpdateLabel = YES;
    [self setNeedsDisplay];
}

- (void)setHidesValues:(BOOL)hidesValues {
    _hidesValues = hidesValues;
    _needsUpdateLabel = YES;
    [self setNeedsDisplay];
}


- (void)setTitle:(NSString *)title {
    _title = title;
    if (_showsTitle) {
        _titleLabel.text = _title;
    }
}

- (void)setTitleFont:(UIFont *)titleFont {
    _titleFont = titleFont;
    _titleLabel.font = _titleFont;
}

- (void)setTitleColor:(UIColor *)titleColor {
    _titleColor = titleColor;
    _titleLabel.textColor = _titleColor;
}
#pragma mark - Public
- (void)addParts:(AXPieChartPart *)part, ... {
    va_list args;
    va_start(args, part);
    AXPieChartPart *piePart;
    [_parts addObject:part];
    while ((piePart = va_arg(args, AXPieChartPart*))) {
        [_parts addObject:piePart];
    }
    va_end(args);
    [self setPercent];
    [self setNeedsDisplay];
}

- (void)appendPart:(AXPieChartPart *)part animated:(BOOL)animated {
    [self unselectPartIfNeeded];
    [self removeAllTextLabelFromSuperView];
    [self removeAllHightLayerFromSuperLayer];
    [_parts addObject:part];
    [self setPercent];
    [self redrawAnimated:animated completion:NULL];
}

- (AXPieChartPart *)removePartAtIndex:(NSInteger)index animated:(BOOL)animated {
    AXPieChartPart * __block part = nil;
    if (_parts.count == 0) return part;
    [self unselectPartIfNeeded];
    [self removeAllTextLabelFromSuperView];
    [self removeAllHightLayerFromSuperLayer];
    NSUInteger inx;
    if (index == AXPieChartPartFirstIndex) {
        inx = 0;
    } else if (index == AXPieChartPartLastIndex) {
        inx = _parts.count - 1;
    } else if (index <= _parts.count - 1) {
        inx = index;
    } else {
        return part;
    }
    [_parts removeObjectAtIndex:inx];
    [self setPercent];
    [self redrawAnimated:animated completion:NULL];
    return part;
}

- (void)replacePartAtIndex:(NSInteger)index withPart:(AXPieChartPart *)part animated:(BOOL)animated {
    if (_parts.count == 0) return;
    [self unselectPartIfNeeded];
    [self removeAllTextLabelFromSuperView];
    [self removeAllHightLayerFromSuperLayer];
    NSUInteger inx;
    if (index == AXPieChartPartFirstIndex) {
        inx = 0;
    } else if (index == AXPieChartPartLastIndex) {
        inx = _parts.count - 1;
    } else if (index <= _parts.count - 1) {
        inx = index;
    } else {
        return;
    }
    [_parts replaceObjectAtIndex:inx withObject:part];
    [self setPercent];
    [self redrawAnimated:animated completion:NULL];
}

- (void)insertPart:(AXPieChartPart *)part atIndex:(NSInteger)index animated:(BOOL)animated {
    if (_parts.count == 0) return;
    [self unselectPartIfNeeded];
    [self removeAllTextLabelFromSuperView];
    [self removeAllHightLayerFromSuperLayer];
    NSUInteger inx;
    if (index == AXPieChartPartFirstIndex) {
        inx = 0;
    } else if (index == AXPieChartPartLastIndex) {
        inx = _parts.count - 1;
    } else if (index <= _parts.count - 1) {
        inx = index;
    } else {
        return;
    }
    [_parts insertObject:part atIndex:inx];
    [self setPercent];
    [self redrawAnimated:animated completion:NULL];
}

- (void)redrawAnimated:(BOOL)animated completion:(dispatch_block_t)completion {
    if (_redrawing) return;
    for (NSUInteger i = 0; i < _parts.count; i++) {
        AXPieChartPart *part = _parts[i];
        BOOL selection = [objc_getAssociatedObject(part, kAXPieChartSelectionKey) boolValue];
        if (selection) {
            [self selectIndex:i animated:YES opacity:YES shouldSelectTitle:NO];
        }
    }
    [self removeAllHightLayerFromSuperLayer];
    [self hideLabelAnimated:animated];
    _visible = YES;
    _redrawing = YES;
    if (!animated) {
        [self setNeedsDisplay];
        [self showLabelAnimated:NO];
        if (completion) {
            completion();
        }
        return;
    }
    POPBasicAnimation *anim = [self pop_animationForKey:kPOPViewAXCPieAngle];
    if(anim == nil)
    {
        anim = [POPBasicAnimation animation];
        anim.property = [AXChartBase AXCPropertyWithName:kPOPViewAXCPieAngle];
        [self pop_addAnimation:anim forKey:kPOPViewAXCPieAngle];
        anim.completionBlock=^(POPAnimation *ani, BOOL finished){
            if (finished) {
                _redrawing = NO;
                [self setNeedsDisplay];
                [self showLabelAnimated:YES];
                if (completion) {
                    completion();
                }
            }
        };
    }
    anim.duration = 1.2;
    anim.timingFunction = kAXDefaultMediaTimingFunction;
    anim.fromValue = [NSNumber numberWithFloat:.0];
    anim.toValue = [NSNumber numberWithFloat:M_PI*2];
}

#pragma mark - Private
- (void)setPercent {
    double totalValue = [self.totalValue doubleValue];
    for (AXPieChartPart *part in _parts) {
        CGFloat percent = [part.value doubleValue]/totalValue;
        objc_setAssociatedObject(part, kAXPieChartPartPercentKey, @(percent), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (void)handleOutsideCircle {
    if (_shouldSelection && _visible) {
        BOOL shouldSelection = NO;
        NSUInteger selectionCount = 0;
        for (NSUInteger i = 0; i < _parts.count; i++) {
            BOOL selection = [objc_getAssociatedObject(_parts[i], kAXPieChartSelectionKey) boolValue];
            if (selection) {
                shouldSelection = YES;
                selectionCount++;
            }
        }
        if (_titleFollowingSelectionPart) {
            if (shouldSelection && selectionCount == 1) {
                [self unselectTitleAnimated:YES];
            } else {
                [self unselectTitleAnimated:NO];
            }
        }
        [self unselectPartIfNeeded];
    }
    if (_delegate && [_delegate respondsToSelector:@selector(pieChartDidTouchOutsideParts:)]) {
        [_delegate pieChartDidTouchOutsideParts:self];
    }
    if (_touchCall) {
        _touchCall(AXPieChartTouchOutside, nil);
    }
}

- (void)unselectPartIfNeeded {
    [_parts enumerateObjectsUsingBlock:^(AXPieChartPart *prt, NSUInteger idx, BOOL * stop) {
        BOOL selection = [objc_getAssociatedObject(prt, kAXPieChartSelectionKey) boolValue];
        if (selection) {
            [self selectIndex:idx animated:YES opacity:NO shouldSelectTitle:NO];
        }
    }];
}

- (void)removeAllTextLabelFromSuperView {
    [_parts enumerateObjectsUsingBlock:^(AXPieChartPart *prt, NSUInteger idx, BOOL * stop) {
        UILabel *label = objc_getAssociatedObject(prt, kAXPieChartTextLabelKey);
        [label removeFromSuperview];
    }];
}

- (void)removeAllHightLayerFromSuperLayer {
    [_parts enumerateObjectsUsingBlock:^(AXPieChartPart *prt, NSUInteger idx, BOOL * stop) {
        CALayer *layer = objc_getAssociatedObject(prt, kAXPieChartHighLightedLayerKey);
        [layer removeFromSuperlayer];
        objc_setAssociatedObject(prt, kAXPieChartHighLightedLayerKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }];
}

- (void)handleInnerCircle {
    if (_shouldSelection && _visible) {
        BOOL shouldSelection = NO;
        NSUInteger selectionCount = 0;
        for (NSUInteger i = 0; i < _parts.count; i++) {
            BOOL selection = [objc_getAssociatedObject(_parts[i], kAXPieChartSelectionKey) boolValue];
            if (selection) {
                shouldSelection = YES;
                selectionCount++;
            }
        }
        if (_titleFollowingSelectionPart) {
            if (shouldSelection && selectionCount == 1) {
                [self unselectTitleAnimated:YES];
            } else {
                [self unselectTitleAnimated:NO];
            }
        }
        [_parts enumerateObjectsUsingBlock:^(AXPieChartPart *part, NSUInteger idx, BOOL *stop) {
            if (shouldSelection && selectionCount < _parts.count) {
                BOOL selection = [objc_getAssociatedObject(part, kAXPieChartSelectionKey) boolValue];
                if (!selection) {
                    [self selectIndex:idx animated:YES opacity:NO shouldSelectTitle:NO];
                }
            } else {
                [self selectIndex:idx animated:YES opacity:NO shouldSelectTitle:NO];
            }
        }];
    }
    if (_delegate && [_delegate respondsToSelector:@selector(pieChartDidTouchInsideParts:)]) {
        [_delegate pieChartDidTouchInsideParts:self];
    }
    if (_touchCall) {
        _touchCall(AXPieChartTouchInside, nil);
    }
}

- (void)handleTouchOnPartAtIndex:(NSUInteger)index {
    if (_shouldSelection && _visible) {
        if (!_allowsMultipleSelection) {
            for (NSUInteger i = 0; i < _parts.count; i++) {
                if (i != index) {
                    AXPieChartPart *part = _parts[i];
                    BOOL selection = [objc_getAssociatedObject(part, kAXPieChartSelectionKey) boolValue];
                    if (selection) {
                        [self selectIndex:i animated:YES opacity:NO shouldSelectTitle:NO];
                    }
                }
            }
        }
        
        /*
         CGFloat centerPercent = (index == 0 ? [self endPercentsForItemAtIndex:index] : ([self endPercentsForItemAtIndex:index-1] + [self endPercentsForItemAtIndex:index]))/ 2;
         CGFloat percentOffset = fabs(.5-centerPercent);
         POPBasicAnimation *anim = [self pop_animationForKey:@"rotate"];
         if (!anim) {
         anim = [POPBasicAnimation animation];
         anim.property = [POPAnimatableProperty propertyWithName:@"rotate" initializer:^(POPMutableAnimatableProperty *prop) {
         // read value
         prop.readBlock = ^(AXPieChartView *chart, CGFloat values[]) {
         values[0] = chart.angleOffsets;
         };
         // write value
         prop.writeBlock = ^(AXPieChartView *chart, const CGFloat values[]) {
         chart.angleOffsets = values[0];
         };
         // dynamics threshold
         prop.threshold = 1.0;
         }];
         anim.completionBlock = ^(POPAnimation *ani, BOOL finished){
         if (finished) {
         [self selectIndex:index animated:YES opacity:NO];
         }
         };
         }
         anim.duration = 0.8;
         anim.toValue = @(-M_PI_2+percentOffset*2*M_PI);
         [self pop_addAnimation:anim forKey:@"rotate"];
         for (NSUInteger i = 0; i < _parts.count; i++) {
         [self updateDescriptionLabel:objc_getAssociatedObject(_parts[i], kAXPieChartTextLabelKey) atIndex:i animated:YES];
         }
         */
        BOOL shouldSelection = NO;
        NSUInteger selectionCount = 0;
        for (NSUInteger i = 0; i < _parts.count; i++) {
            BOOL selection = [objc_getAssociatedObject(_parts[i], kAXPieChartSelectionKey) boolValue];
            if (selection) {
                shouldSelection = YES;
                selectionCount++;
            }
        }
        if (!shouldSelection || selectionCount <= 0) {
            [self selectIndex:index animated:YES opacity:NO shouldSelectTitle:YES];
        } else {
            if (!_allowsMultipleSelection) {
                if (_titleFollowingSelectionPart) {
                    if (selectionCount <= 1) {
                        [self unselectTitleAnimated:YES];
                    } else {
                        [self unselectTitleAnimated:NO];
                    }
                }
            } else {
                if (selectionCount >= 1 && selectionCount <= 2) {
                    if (_titleFollowingSelectionPart) {
                        BOOL isAddSelection = YES;
                        if ([objc_getAssociatedObject(_parts[index], kAXPieChartSelectionKey) boolValue]) {
                            isAddSelection = NO;
                        }
                        if (selectionCount == 2 && !isAddSelection) {
                            NSInteger __block selectedIndex = 0;
                            [_parts enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                AXPieChartPart *part = (AXPieChartPart *)obj;
                                if ([objc_getAssociatedObject(part, kAXPieChartSelectionKey) boolValue] && index != idx) {
                                    selectedIndex = idx;
                                    *stop = YES;
                                }
                            }];
                            [self selectTitleWithIndex:selectedIndex animated:YES];
                        } else {
                            if (selectionCount == 1) {
                                [self unselectTitleAnimated:YES];
                            } else {
                                [self unselectTitleAnimated:NO];
                            }
                        }
                    }
                } else {
                    if (_titleFollowingSelectionPart) {
                        [self unselectTitleAnimated:NO];
                    }
                }
            }
            [self selectIndex:index animated:YES opacity:NO shouldSelectTitle:NO];
        }
        
    }
    if (_delegate && [_delegate respondsToSelector:@selector(pieChart:didTouchPart:)]) {
        [_delegate pieChart:self didTouchPart:_parts[index]];
    }
    if (_touchCall) {
        _touchCall(AXPieChartTouchPart, _parts[index]);
    }
}

- (void)selectIndex:(NSUInteger)index animated:(BOOL)animated opacity:(BOOL)opacity shouldSelectTitle:(BOOL)shouldSelectTitle {
    if (self.validCount <= 1) {
        return;
    }
    AXPieChartPart *part = _parts[index];
    BOOL selection = [objc_getAssociatedObject(part, kAXPieChartSelectionKey) boolValue];
    
    if (_showsTitle) {
        if (_titleFollowingSelectionPart) {
            if (shouldSelectTitle) {
                if (!selection) {
                    [self selectTitleWithIndex:index animated:animated];
                } else {
                    [self unselectTitleAnimated:animated];
                }
            }
        }
    }
    
    _AXPieShapeLayer *layer = objc_getAssociatedObject(part, kAXPieChartHighLightedLayerKey);
    if (!layer) {
        CGFloat size = kAXPieChartSize + _maxAllowedOffsets*2;
        CGFloat startPercnet = index == 0 ? 0 : [self endPercentsForItemAtIndex:index-1];
        CGFloat endPercent = [self endPercentsForItemAtIndex:index];
        CGFloat startAngle = startPercnet*M_PI*2+_angleOffsets;
        CGFloat endAngle = endPercent*M_PI*2+_angleOffsets;
        layer = [_AXPieShapeLayer layer];
        layer.startAngle = startAngle;
        layer.endAngle = endAngle;
        layer.drawingSize = size;
        layer.innerRadius = _hollowRadius;
        layer.frame = self.layer.bounds;
        layer.strokeColor = part.color.CGColor;
        layer.fillColor = [UIColor clearColor].CGColor;
        layer.offsets = _maxAllowedOffsets*2;
        layer.angleOffsets = _angleOffsets;
        objc_setAssociatedObject(part, kAXPieChartHighLightedLayerKey, layer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    objc_setAssociatedObject(part, kAXPieChartSelectionKey, @(!selection), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (!selection) {
        [self setNeedsDisplay];
    }
    dispatch_block_t opacityCall = ^() {
        POPBasicAnimation *alphaAnim = [layer pop_animationForKey:@"opacity"];
        if (!alphaAnim) {
            alphaAnim = [POPBasicAnimation animation];
            alphaAnim.property = [POPAnimatableProperty propertyWithName:kPOPLayerOpacity];
            alphaAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            alphaAnim.duration = .25;
            alphaAnim.completionBlock = ^(POPAnimation *ani, BOOL finished) {
                if (finished) {
                    [layer removeFromSuperlayer];
                    layer.opacity = 1.0;
                }
            };
        }
        alphaAnim.toValue = @(.0);
        [layer pop_addAnimation:alphaAnim forKey:@"opacity"];
    };
    if (animated) {
        objc_setAssociatedObject(_parts[index], kAXPieChartPartAnimationKey, @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        POPSpringAnimation *anim = [layer pop_animationForKey:@"resize"];
        if (!anim) {
            anim = [POPSpringAnimation animation];
            anim.property = [POPAnimatableProperty propertyWithName:@"resize" initializer:^(POPMutableAnimatableProperty *prop) {
                // read value
                prop.readBlock = ^(_AXPieShapeLayer *layer, CGFloat values[]) {
                    values[0] = layer.offsets;
                    values[1] = layer.seperatorOffsets;
                };
                // write value
                prop.writeBlock = ^(_AXPieShapeLayer *layer, const CGFloat values[]) {
                    layer.offsets = values[0];
                    layer.seperatorOffsets = values[1];
                };
                // dynamics threshold
                prop.threshold = 1.0;
            }];
        }
        anim.fromValue = [NSValue valueWithCGPoint:CGPointMake(selection?.0:_maxAllowedOffsets*2, selection?_seperatorOffsets:0)];
        anim.toValue = [NSValue valueWithCGPoint:CGPointMake(selection?_maxAllowedOffsets*2:.0, selection?0:_seperatorOffsets)];
        anim.completionBlock = ^(POPAnimation *ani, BOOL finished) {
            if (finished) {
                objc_setAssociatedObject(_parts[index], kAXPieChartPartAnimationKey, @(NO), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                if (selection) {
                    if (opacity) {
                        opacityCall();
                    } else {
                        [self setNeedsDisplay];
                        [layer removeFromSuperlayer];
                    }
                }
            }
        };
        if (!selection) {
            [self.layer addSublayer:layer];
        }
        [layer pop_addAnimation:anim forKey:@"resize"];
        
        UILabel *label = objc_getAssociatedObject(part, kAXPieChartTextLabelKey);
        if (label) {
            [self updateDescriptionLabel:label atIndex:index animated:YES];
        }
    } else {
        if (selection) {
            if (opacity) {
                opacityCall();
            } else {
                [layer removeFromSuperlayer];
            }
        } else {
            [self.layer addSublayer:layer];
            layer.offsets = .0;
        }
        UILabel *label = objc_getAssociatedObject(part, kAXPieChartTextLabelKey);
        if (label) {
            [self updateDescriptionLabel:label atIndex:index animated:NO];
        }
    }
}

- (CGFloat)endPercentsForItemAtIndex:(NSUInteger)index{
    CGFloat percents = .0;
    for (NSUInteger i = 0; i <= index; i ++) {
        percents += [[_parts[i] valueForKey:@"percent"] floatValue];
    }
    return percents;
}

- (UILabel *)descriptionLabelForPartAtIndex:(NSUInteger)index{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _maxAllowedLabelWidth, 80)];
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    label.alpha = .0;
    label.backgroundColor = [UIColor clearColor];
    [self updateDescriptionLabel:label atIndex:index animated:NO];
    return label;
}

- (void)updateDescriptionLabel:(UILabel *)label atIndex:(NSUInteger)index animated:(BOOL)animated {
    AXPieChartPart *part = _parts[index];
    BOOL selection = [objc_getAssociatedObject(part, kAXPieChartSelectionKey) boolValue];
    CGFloat outterRadius = kAXPieChartSize/2;
    if (selection) {
        outterRadius += _maxAllowedOffsets;
    }
    CGFloat innerRatius = _hollowRadius;
    CGFloat distance = innerRatius + (outterRadius - innerRatius) / 2;
    CGFloat centerPercent = (index == 0 ? [self endPercentsForItemAtIndex:index] : ([self endPercentsForItemAtIndex:index-1] + [self endPercentsForItemAtIndex:index]))/ 2;
    CGFloat rad = centerPercent * M_PI*2;
    NSString *titleText = part.content;
    NSString *titleValue;
    
    if (_showsAbsoluteValues) {
        titleValue = [NSString stringWithFormat:@"%.0f",part.percent];
    } else {
        titleValue = [NSString stringWithFormat:@"%.0f%%",part.percent * 100];
    }
    
    if (_hidesValues)
        label.text = titleText;
    else if(!titleText || _showsOnlyValues)
        label.text = titleValue;
    else {
        NSString* str = [titleValue stringByAppendingString:[NSString stringWithFormat:@"\n%@",titleText]];
        label.text = str ;
    }
    
    //If value is less than cutoff, show no label
    if (part.percent < _percentsLimitsOfLabel)
    {
        label.text = nil;
    }
    
    CGPoint center = CGPointMake(CGRectGetWidth(self.frame)/2 + distance * sin(rad), CGRectGetHeight(self.frame)/2 - distance * cos(rad));
    label.font = _textFont;
    [label sizeToFit];
    CGSize labelSize = [label.text sizeWithAttributes:@{NSFontAttributeName:label.font}];
    label.frame = CGRectMake(label.frame.origin.x, label.frame.origin.y, MIN(labelSize.width, _maxAllowedLabelWidth), labelSize.height);
    label.textColor = _textColor;
    if (animated) {
        POPSpringAnimation *anim = [label pop_animationForKey:@"center"];
        if (!anim) {
            anim = [POPSpringAnimation animation];
            anim.property = [POPAnimatableProperty propertyWithName:kPOPViewCenter];
        }
        anim.toValue = [NSValue valueWithCGPoint:center];
        [label pop_addAnimation:anim forKey:@"center"];
    } else {
        label.center = center;
    }
}

- (void)showLabelAnimated:(BOOL)animated {
    for (AXPieChartPart *part in _parts) {
        UILabel *label = objc_getAssociatedObject(part, kAXPieChartTextLabelKey);
        [self updateDescriptionLabel:label atIndex:[_parts indexOfObject:part] animated:animated];
        if (!label) continue;
        if (animated) {
            label.alpha = .0;
            [UIView animateWithDuration:0.25 animations:^{
                label.alpha = 1.0;
            }];
        } else {
            label.alpha = 1.0;
        }
    }
}

- (void)hideLabelAnimated:(BOOL)animated {
    for (AXPieChartPart *part in _parts) {
        UILabel *label = objc_getAssociatedObject(part, kAXPieChartTextLabelKey);
        if (!label) continue;
        if (animated) {
            label.alpha = 1.0;
            [UIView animateWithDuration:0.25 animations:^{
                label.alpha = .0;
            }];
        } else {
            label.alpha = .0;
        }
    }
}

- (void)selectTitleWithIndex:(NSInteger)index animated:(BOOL)animated {
    AXPieChartPart *part = _parts[index];
    _titleLabel.text = part.content;
    if (_titleUsingSelectionColor) {
        _titleLabel.textColor = part.color;
    }
    [self showTitleLabelAnimated:animated];
}

- (void)unselectTitleAnimated:(BOOL)animated {
    if (_showsTitle) {
        _titleLabel.text = _title;
    } else {
        _titleLabel.text = @"";
    }
    _titleLabel.textColor = _titleColor;
    [self showTitleLabelAnimated:animated];
}

- (void)showTitleLabelAnimated:(BOOL)animated {
    _titleLabel.alpha = .0;
    if (animated) {
        [UIView animateWithDuration:0.35 animations:^{
            _titleLabel.alpha = 1.0;
        }];
    } else {
        _titleLabel.alpha = 1.0;
    }
}
@end

AXPieChartPart *AXPCPCreate(NSString *content, UIColor *color, NSNumber *value) {
    return [AXPieChartPart partWithContent:content color:color value:value];
}

typedef struct {
    CGPoint point1;
    CGPoint point2;
    CGPoint point3;
    CGPoint point4;
} SeperatorResult;

static SeperatorResult const SeperatorResultZero = {{0.0,0.0},{0.0,0.0},{0.0,0.0},{0.0,0.0}};
static BOOL SeperatorResultEaqulToResult(SeperatorResult result, SeperatorResult resultComp) {
    return CGPointEqualToPoint(result.point1, resultComp.point1) && CGPointEqualToPoint(result.point2, resultComp.point2) && CGPointEqualToPoint(result.point3, resultComp.point3) && CGPointEqualToPoint(result.point4, resultComp.point4);
}

@interface _AXPieShapeLayer()
{
    CAShapeLayer *_layer1;
    CAShapeLayer *_layer2;
    CAShapeLayer *_layer3;
    CAShapeLayer *_layer4;
}
@end

@implementation _AXPieShapeLayer
@synthesize maskLayer = _maskLayer;
+ (instancetype)layer {
    _AXPieShapeLayer *layer = [[_AXPieShapeLayer alloc] init];
    return layer;
}

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

- (instancetype)initWithLayer:(id)layer {
    if (self = [super initWithLayer:layer]) {
        [self initializer];
    }
    return self;
}

- (void)layoutSublayers {
    [super layoutSublayers];
    _maskLayer.frame = self.bounds;
}

- (void)initializer {
    /*
    _layer1 = [CAShapeLayer layer];
    _layer1.lineCap = kCALineCapRound;
    _layer1.lineWidth = 1;
    _layer1.strokeColor = [UIColor redColor].CGColor;
    _layer1.fillColor = [UIColor clearColor].CGColor;
    _layer1.frame = self.bounds;
    _layer2 = [CAShapeLayer layer];
    _layer2.lineCap = kCALineCapRound;
    _layer2.lineWidth = 1;
    _layer2.strokeColor = [UIColor greenColor].CGColor;
    _layer2.fillColor = [UIColor clearColor].CGColor;
    _layer2.frame = self.bounds;
    _layer3 = [CAShapeLayer layer];
    _layer3.lineCap = kCALineCapRound;
    _layer3.lineWidth = 1;
    _layer3.strokeColor = [UIColor blueColor].CGColor;
    _layer3.fillColor = [UIColor clearColor].CGColor;
    _layer3.frame = self.bounds;
    _layer4 = [CAShapeLayer layer];
    _layer4.lineCap = kCALineCapRound;
    _layer4.lineWidth = 1;
    _layer4.strokeColor = [UIColor blackColor].CGColor;
    _layer4.fillColor = [UIColor clearColor].CGColor;
    _layer4.frame = self.bounds;
    [self addSublayer:_layer1];
    [self addSublayer:_layer2];
    [self addSublayer:_layer3];
    [self addSublayer:_layer4];
     */
    self.mask = self.maskLayer;
    _seperatorOffsets = .0;
    [self drawing];
}

- (void)drawing {
    CGPoint center = CGPointMake(CGRectGetWidth(self.frame)/2, CGRectGetHeight(self.frame)/2);
    CGFloat radius = (_drawingSize-_offsets)/4+_innerRadius/2;
    CGFloat lineWidth = (_drawingSize-_offsets)/2-_innerRadius;
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:_startAngle endAngle:_endAngle clockwise:YES];
    self.lineWidth = lineWidth;
    self.path = bezierPath.CGPath;
    
    SeperatorResult (^seperatorPoint)(CGPoint point1, CGPoint point2, CGPoint center, CGFloat radius, CGFloat distance) = ^(CGPoint point1, CGPoint point2, CGPoint center, CGFloat radius, CGFloat distance)
    {
        if (distance > radius || distance <= 0) {
            return SeperatorResultZero;
        } else {
            
            register CGPoint centerOffset = center;
            
            center = CGPointZero;
            
            point1.x -= centerOffset.x;
            point1.y -= centerOffset.y;
            point2.x -= centerOffset.x;
            point2.y -= centerOffset.y;
            
            point1.y = -point1.y;
            point2.y = -point2.y;
            
            if (ceil(point1.x) == ceil(point2.x)) {
                register CGFloat d = distance;
                
                register CGFloat x1 = point1.x + d;
                register CGFloat x2 = point1.x - d;
                register CGFloat y1 = center.y - sqrt(pow(radius, 2) - pow(d, 2));
                register CGFloat y2 = center.y + sqrt(pow(radius, 2) - pow(d, 2));
                
                SeperatorResult result = {{centerOffset.x+x1,centerOffset.y-y1},{centerOffset.x+x1,centerOffset.y-y2},{centerOffset.x+x2,centerOffset.y-y1},{centerOffset.x+x2,centerOffset.y-y2}};
                
                return result;
            } else if (ceil(point1.y) == ceil(point2.y)) {
                register CGFloat d = distance;
                
                register CGFloat y1 = point1.y + d;
                register CGFloat y2 = point1.y - d;
                register CGFloat x1 = center.x - sqrt(pow(radius, 2) - pow(d, 2));
                register CGFloat x2 = center.x + sqrt(pow(radius, 2) - pow(d, 2));
                
                SeperatorResult result = {{centerOffset.x+x1,centerOffset.y-y1},{centerOffset.x+x1,centerOffset.y-y2},{centerOffset.x+x2,centerOffset.y-y1},{centerOffset.x+x2,centerOffset.y-y2}};
                
                return result;
            } else {
                register CGFloat A = point1.y - point2.y;
                register CGFloat B = point2.x - point1.x;
                register CGFloat C = point2.y*(point1.x-point2.x) - point2.x*(point1.y-point2.y);
                
                register CGFloat d = distance;
                
                register CGFloat(^_b)(CGFloat d) = ^(CGFloat d) {
                    return (CGFloat)((2*B*center.x)/A + (2*B*C)/pow(A, 2) - (2*B*d*sqrt(pow(A, 2)+pow(B, 2)))/pow(A, 2) - 2*center.y);
                };
                register CGFloat(^_c)(CGFloat d) = ^(CGFloat d) {
                    return (CGFloat)(pow(center.x, 2) - (2*center.x*(d*sqrt(pow(A, 2)+pow(B, 2))-C))/A + (pow(d, 2)*(pow(A, 2)+pow(B, 2))+pow(C, 2)-2*C*d*sqrt(pow(A, 2)+pow(B, 2)))/pow(A, 2) + pow(center.y, 2) - pow(radius, 2));
                };
                
                register CGFloat a = pow(B, 2)/pow(A, 2) + 1;
                
                register CGFloat delta1 = pow(_b(d), 2) - 4*a*_c(d);
                register CGFloat delta2 = pow(_b(-d), 2) - 4*a*_c(-d);
                
                register CGFloat y1, y2, y3, y4, x1, x2, x3, x4;
                
                if (delta1 >= 0) {
                    y1 = (-_b(d) + sqrt(delta1)) / (2*a);
                    y2 = (-_b(d) - sqrt(delta1)) / (2*a);
                    x1 = (d*sqrt(pow(A, 2)+pow(B, 2)) - B*y1 - C) / A;
                    x2 = (d*sqrt(pow(A, 2)+pow(B, 2)) - B*y2 - C) / A;
                }
                
                if (delta2 >= 0) {
                    y3 = (-_b(-d) + sqrt(delta2)) / (2*a);
                    y4 = (-_b(-d) - sqrt(delta2)) / (2*a);
                    x3 = (-d*sqrt(pow(A, 2)+pow(B, 2)) - B*y3 - C) / A;
                    x4 = (-d*sqrt(pow(A, 2)+pow(B, 2)) - B*y4 - C) / A;
                }
                
                SeperatorResult result = {{centerOffset.x+x1,centerOffset.y-y1},{centerOffset.x+x2,centerOffset.y-y2},{centerOffset.x+x3,centerOffset.y-y3},{centerOffset.x+x4,centerOffset.y-y4}};
                
                return result;
            }
        }
    };
    
    _maskLayer.path = NULL;
    
    CGPoint startPoint1 = [self circleCoordinateWithCenter:center angle:_startAngle radius:_innerRadius];
    CGPoint startPoint2 = [self circleCoordinateWithCenter:center angle:_startAngle radius:_innerRadius+lineWidth];
    CGPoint endPoint1 = [self circleCoordinateWithCenter:center angle:_endAngle radius:_innerRadius];
    CGPoint endPoint2 = [self circleCoordinateWithCenter:center angle:_endAngle radius:_innerRadius+lineWidth];
    
    SeperatorResult innerStartResult = seperatorPoint(startPoint1, startPoint2, center, _innerRadius, _seperatorOffsets);
    SeperatorResult outterStartResult = seperatorPoint(startPoint2, startPoint1, center, _innerRadius+lineWidth, _seperatorOffsets);
    SeperatorResult innerEndResult = seperatorPoint(endPoint1, endPoint2, center, _innerRadius, _seperatorOffsets);
    SeperatorResult outterEndResult = seperatorPoint(endPoint2, endPoint1, center, _innerRadius+lineWidth, _seperatorOffsets);
    
    NSArray *innerStartPoints = @[
                                 [NSValue valueWithCGPoint:innerStartResult.point1],
                                 [NSValue valueWithCGPoint:innerStartResult.point2],
                                 [NSValue valueWithCGPoint:innerStartResult.point3],
                                 [NSValue valueWithCGPoint:innerStartResult.point4]
                                 ];
    NSArray *outterStartPoints = @[
                                  [NSValue valueWithCGPoint:outterStartResult.point1],
                                  [NSValue valueWithCGPoint:outterStartResult.point2],
                                  [NSValue valueWithCGPoint:outterStartResult.point3],
                                  [NSValue valueWithCGPoint:outterStartResult.point4]
                                  ];
    NSArray *innerEndPoints = @[
                               [NSValue valueWithCGPoint:innerEndResult.point1],
                               [NSValue valueWithCGPoint:innerEndResult.point2],
                               [NSValue valueWithCGPoint:innerEndResult.point3],
                               [NSValue valueWithCGPoint:innerEndResult.point4]
                               ];
    NSArray *outterEndPoints = @[
                                [NSValue valueWithCGPoint:outterEndResult.point1],
                                [NSValue valueWithCGPoint:outterEndResult.point2],
                                [NSValue valueWithCGPoint:outterEndResult.point3],
                                [NSValue valueWithCGPoint:outterEndResult.point4]
                                ];
    
    CGPoint innerStartPoint = startPoint1;
    CGPoint outterStartPoint = startPoint2;
    CGPoint innerEndPoint = endPoint1;
    CGPoint outterEndPoint = endPoint2;
    
    if (SeperatorResultEaqulToResult(innerStartResult, SeperatorResultZero) || SeperatorResultEaqulToResult(outterStartResult, SeperatorResultZero) || SeperatorResultEaqulToResult(innerEndResult, SeperatorResultZero) || SeperatorResultEaqulToResult(outterEndResult, SeperatorResultZero)){}
     else {
        CGFloat innerStartOffset = 1.0;
        CGFloat outterStartOffset = 1.0;
        CGFloat innerEndOffset = 1.0;
        CGFloat outterEndOffset = 1.0;
        
        for (NSUInteger i = 0; i < 4; i ++) {
            NSValue *value = innerStartPoints[i];
            CGFloat percent = percentsOfAngle(center, [value CGPointValue], _angleOffsets, kAXPercentStarting);
            CGFloat startAnglePercent = percentsOfAngle(center, startPoint1, _angleOffsets, kAXPercentStarting);
            CGFloat offset = percent - startAnglePercent;
            if (percent > startAnglePercent) {
                if (offset < innerStartOffset) {
                    innerStartOffset = offset;
                    innerStartPoint = [value CGPointValue];
                }
            }
            value = outterStartPoints[i];
            percent = percentsOfAngle(center, [value CGPointValue], _angleOffsets, kAXPercentStarting);
            offset = percent - startAnglePercent;
            if (percent > startAnglePercent) {
                if (offset < outterStartOffset) {
                    outterStartOffset = offset;
                    outterStartPoint = [value CGPointValue];
                }
            }
            value = innerEndPoints[i];
            percent = percentsOfAngle(center, [value CGPointValue], _angleOffsets, kAXPercentEnding);
            CGFloat endAnglePercent = percentsOfAngle(center, endPoint1, _angleOffsets, kAXPercentEnding);
            offset = endAnglePercent - percent;
            if (percent < endAnglePercent) {
                if (offset < innerEndOffset) {
                    innerEndOffset = offset;
                    innerEndPoint = [value CGPointValue];
                }
            }
            value = outterEndPoints[i];
            percent = percentsOfAngle(center, [value CGPointValue], _angleOffsets, kAXPercentEnding);
            offset = endAnglePercent - percent;
            if (percent < endAnglePercent) {
                if (offset < outterEndOffset) {
                    outterEndOffset = offset;
                    outterEndPoint= [value CGPointValue];
                }
            }
        }
    }
    
    CGFloat innerStartPercent = percentsOfAngle(center, innerStartPoint, _angleOffsets, kAXPercentStarting);
    CGFloat outterStartPercent = percentsOfAngle(center, outterStartPoint, _angleOffsets, kAXPercentStarting);
    CGFloat innerEndPerent = percentsOfAngle(center, innerEndPoint, _angleOffsets, kAXPercentEnding);
    CGFloat outterEndPercent = percentsOfAngle(center, outterEndPoint, _angleOffsets, kAXPercentEnding);
    
    UIBezierPath *maskPath = [UIBezierPath bezierPath];
    [maskPath moveToPoint:innerStartPoint];
    [maskPath addLineToPoint:outterStartPoint];
    [maskPath addArcWithCenter:center radius:_innerRadius+lineWidth startAngle:outterStartPercent*M_PI*2+_angleOffsets endAngle:outterEndPercent*M_PI*2+_angleOffsets clockwise:YES];
    [maskPath addLineToPoint:innerEndPoint];
    [maskPath moveToPoint:innerStartPoint];
    [maskPath addArcWithCenter:center radius:_innerRadius startAngle:innerStartPercent*M_PI*2+_angleOffsets endAngle:innerEndPerent*M_PI*2+_angleOffsets clockwise:YES];
    
    [maskPath moveToPoint:startPoint1];
    [maskPath addLineToPoint:startPoint2];
    [maskPath moveToPoint:endPoint1];
    [maskPath addLineToPoint:endPoint2];
    
    _maskLayer.path = maskPath.CGPath;
    /*
     UIBezierPath *path1 = [UIBezierPath bezierPath];
     [path1 moveToPoint:CGPointMake(innerStartResult.point1.x, innerStartResult.point1.y)];
     [path1 addLineToPoint:CGPointMake(innerStartResult.point3.x, innerStartResult.point3.y)];
     [path1 addLineToPoint:CGPointMake(innerStartResult.point2.x, innerStartResult.point2.y)];
     [path1 addLineToPoint:CGPointMake(innerStartResult.point4.x, innerStartResult.point4.y)];
     [path1 addLineToPoint:CGPointMake(innerStartResult.point1.x, innerStartResult.point1.y)];
     _layer1.path = path1.CGPath;
     
     UIBezierPath *path2 = [UIBezierPath bezierPath];
     [path2 moveToPoint:CGPointMake(innerEndResult.point1.x, innerEndResult.point1.y)];
     [path2 addLineToPoint:CGPointMake(innerEndResult.point3.x, innerEndResult.point3.y)];
     [path2 addLineToPoint:CGPointMake(innerEndResult.point2.x, innerEndResult.point2.y)];
     [path2 addLineToPoint:CGPointMake(innerEndResult.point4.x, innerEndResult.point4.y)];
     [path2 addLineToPoint:CGPointMake(innerEndResult.point1.x, innerEndResult.point1.y)];
     _layer2.path = path2.CGPath;
     
     UIBezierPath *path3 = [UIBezierPath bezierPath];
     [path3 moveToPoint:CGPointMake(outterStartResult.point1.x, outterStartResult.point1.y)];
     [path3 addLineToPoint:CGPointMake(outterStartResult.point3.x, outterStartResult.point3.y)];
     [path3 addLineToPoint:CGPointMake(outterStartResult.point2.x, outterStartResult.point2.y)];
     [path3 addLineToPoint:CGPointMake(outterStartResult.point4.x, outterStartResult.point4.y)];
     [path3 addLineToPoint:CGPointMake(outterStartResult.point1.x, outterStartResult.point1.y)];
     _layer3.path = path3.CGPath;
     
     UIBezierPath *path4 = [UIBezierPath bezierPath];
     [path4 moveToPoint:CGPointMake(outterEndResult.point1.x, outterEndResult.point1.y)];
     [path4 addLineToPoint:CGPointMake(outterEndResult.point3.x, outterEndResult.point3.y)];
     [path4 addLineToPoint:CGPointMake(outterEndResult.point2.x, outterEndResult.point2.y)];
     [path4 addLineToPoint:CGPointMake(outterEndResult.point4.x, outterEndResult.point4.y)];
     [path4 addLineToPoint:CGPointMake(outterEndResult.point1.x, outterEndResult.point1.y)];
     _layer4.path = path4.CGPath;
     */
}

- (CGPoint)circleCoordinateWithCenter:(CGPoint)center angle:(CGFloat)angle radius:(CGFloat)radius{
    CGFloat x2 = radius*cos(-angle);
    CGFloat y2 = radius*sin(-angle);
    return CGPointMake(center.x+x2, center.y-y2);
}

- (CAShapeLayer *)maskLayer {
    if (_maskLayer) return _maskLayer;
    _maskLayer = [CAShapeLayer layer];
    _maskLayer.backgroundColor = [UIColor clearColor].CGColor;
    _maskLayer.strokeColor = [UIColor clearColor].CGColor;
    _maskLayer.fillColor = [UIColor orangeColor].CGColor;
    _maskLayer.lineWidth = 1;
    return _maskLayer;
}

- (void)setOffsets:(CGFloat)offsets {
    _offsets = offsets;
    [self drawing];
}
@end

@implementation _AXPieGradientLayer

@end

@implementation AXPieChartPart
+ (instancetype)partWithContent:(NSString *)content color:(UIColor *)color value:(NSNumber *)value
{
    AXPieChartPart *part = [[self alloc] init];
    part.content = content;
    part.color = color;
    part.value = value;
    return part;
}

- (CGFloat)percent {
    return [objc_getAssociatedObject(self, kAXPieChartPartPercentKey) doubleValue];
}

- (CAShapeLayer *)hightlightLayer {
    return objc_getAssociatedObject(self, kAXPieChartHighLightedLayerKey);
}

- (UILabel *)textLabel {
    return objc_getAssociatedObject(self, kAXPieChartTextLabelKey);
}
@end