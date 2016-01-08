//
//  AXPieChart.m
//  AXChartKits
//
//  Created by ai on 15/12/30.
//  Copyright © 2015年 AiXing. All rights reserved.
//

#import "AXPieChart.h"
#import <objc/runtime.h>

#ifndef kAXPieChartSize
#define kAXPieChartSize (MIN(CGRectGetHeight(self.frame), CGRectGetWidth(self.frame))-_maxAllowedOffsets*2)
#endif

@interface AXPieChart ()
{
    @private
    /// Parts.
    NSMutableArray *_parts;
}
@end

@interface _AXPieShapeLayer : CAShapeLayer
/// Start line layer.
@property(strong, nonatomic) CAShapeLayer *startLineLayer;
/// End line layer.
@property(strong, nonatomic) CAShapeLayer *endLineLayer;
/// Offsets.
@property(assign, nonatomic) CGFloat offsets;
/// Drawing size.
@property(assign, nonatomic) CGFloat drawingSize;
/// Start angle.
@property(assign, nonatomic) CGFloat startAngle;
/// End angle.
@property(assign, nonatomic) CGFloat endAngle;
/// Inner circle radius.
@property(assign, nonatomic) CGFloat innerRadius;
@end

static char *const kAXPieChartHighLightedLayerKey = "selectionlayer";
static char *const kAXPieChartSelectionKey = "selection";
static char *const kAXPieChartTextLabelKey = "label";

@implementation AXPieChart
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
        CGContextSetStrokeColorWithColor(context, [objc_getAssociatedObject(part, kAXPieChartSelectionKey) boolValue] ? [UIColor clearColor].CGColor : part.color.CGColor);
        endAngle += M_PI*2*part.percent;
        endAngle = MIN(_angle, endAngle);
        CGContextAddArc(context, CGRectGetWidth(self.frame)/2, CGRectGetHeight(self.frame)/2, size/4+_hollowRadius/2, startAngle+_angleOffsets, endAngle+_angleOffsets, 0);
        startAngle = endAngle;
        CGContextStrokePath(context);
        UILabel *label = objc_getAssociatedObject(part, kAXPieChartTextLabelKey);
        if (!label) {
            label = [self descriptionLabelForPartAtIndex:i];
            objc_setAssociatedObject(part, kAXPieChartTextLabelKey, label, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
        [self updateDescriptionLabel:label atIndex:i animated:YES];
        [self addSubview:label];
    }
    UIGraphicsPopContext();
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *suview = [super hitTest:point withEvent:event];
    return suview;
}

- (void)didTouch:(CGPoint)location {
    [super didTouch:location];
    
    CGPoint center = CGPointMake(CGRectGetWidth(self.frame)/2, CGRectGetHeight(self.frame)/2);
    CGFloat distance = sqrtf(powf((location.y - center.y),2) + powf((location.x - center.x),2));
    
    CGFloat size = MIN(CGRectGetHeight(self.frame), CGRectGetWidth(self.frame))-_maxAllowedOffsets;
    
    if (distance <= size/2) {
        if (distance < _hollowRadius) {
            [self handleInnerCircle];
            return;
        }
        
        CGFloat percent = [self percentsOfAngleInCenter:center point:location];
        int index = 0;
        while (percent > [self endPercentsForItemAtIndex:index]) {
            index ++;
        }
        
        [self handleTouchOnPartAtIndex:index];
    } else {
        [self handleOutsideCircle];
    }
}
#pragma mark - Getters
- (NSArray *)parts {
    return [_parts copy];
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

#pragma mark - Public
- (void)addParts:(AXPieChartPart *)part, ... {
    va_list args;
    va_start(args, part);
    AXPieChartPart *piePart;
    [_parts addObject:part];
    double percent = part.percent;
    while ((piePart = va_arg(args, AXPieChartPart*))) {
        [_parts addObject:piePart];
        percent += piePart.percent;
        if (percent >= 1.0) break;
    }
    va_end(args);
    NSAssert(percent <= 1.0, @"Percents of total parts should less then 1.0");
    [self setNeedsDisplay];
}

- (void)redrawAnimated:(BOOL)animated completion:(dispatch_block_t)completion {
    if (_redrawing) return;
    for (NSUInteger i = 0; i < _parts.count; i++) {
        AXPieChartPart *part = _parts[i];
        BOOL selection = [objc_getAssociatedObject(part, kAXPieChartSelectionKey) boolValue];
        if (selection) {
            [self selectIndex:i animated:YES opacity:YES];
        }
    }
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
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    anim.fromValue = [NSNumber numberWithFloat:.0];
    anim.toValue = [NSNumber numberWithFloat:M_PI*2];
}

#pragma mark - Private
- (void)handleOutsideCircle {
    if (_shouldSelection && _visible) {
        for (NSUInteger i = 0; i < _parts.count; i++) {
            AXPieChartPart *part = _parts[i];
            BOOL selection = [objc_getAssociatedObject(part, kAXPieChartSelectionKey) boolValue];
            if (selection) {
                [self selectIndex:i animated:YES opacity:NO];
            }
        }
        [self setNeedsDisplay];
    }
    if (_delegate && [_delegate respondsToSelector:@selector(pieChartDidTouchOutsideParts:)]) {
        [_delegate pieChartDidTouchOutsideParts:self];
    }
    if (_touchCall) {
        _touchCall(AXPieChartTouchOutside, nil);
    }
}

- (void)handleInnerCircle {
    if (_shouldSelection && _visible) {
        for (NSUInteger i = 0; i < _parts.count; i++) {
            [self selectIndex:i animated:YES opacity:NO];
        }
        [self setNeedsDisplay];
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
                        [self selectIndex:i animated:YES opacity:NO];
                    }
                }
            }
            [self setNeedsDisplay];
        }
        [self selectIndex:index animated:YES opacity:NO];
    }
    if (_delegate && [_delegate respondsToSelector:@selector(pieChart:didTouchPart:)]) {
        [_delegate pieChart:self didTouchPart:_parts[index]];
    }
    if (_touchCall) {
        _touchCall(AXPieChartTouchPart, _parts[index]);
    }
}

- (void)selectIndex:(NSUInteger)index animated:(BOOL)animated opacity:(BOOL)opacity {
    AXPieChartPart *part = _parts[index];
    BOOL selection = [objc_getAssociatedObject(part, kAXPieChartSelectionKey) boolValue];
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
        objc_setAssociatedObject(part, kAXPieChartHighLightedLayerKey, layer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    objc_setAssociatedObject(part, kAXPieChartSelectionKey, @(!selection), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self setNeedsDisplay];
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
        POPSpringAnimation *anim = [layer pop_animationForKey:@"resize"];
        if (!anim) {
            anim = [POPSpringAnimation animation];
            anim.property = [POPAnimatableProperty propertyWithName:@"resize" initializer:^(POPMutableAnimatableProperty *prop) {
                // read value
                prop.readBlock = ^(_AXPieShapeLayer *layer, CGFloat values[]) {
                    values[0] = layer.offsets;
                };
                // write value
                prop.writeBlock = ^(_AXPieShapeLayer *layer, const CGFloat values[]) {
                    layer.offsets = values[0];
                };
                // dynamics threshold
                prop.threshold = 1.0;
            }];
        }
        anim.fromValue = @(selection?.0:_maxAllowedOffsets*2);
        anim.toValue = @(selection?_maxAllowedOffsets*2:.0);
        anim.completionBlock = ^(POPAnimation *ani, BOOL finished) {
            if (finished) {
                if (selection) {
                    if (opacity) {
                        opacityCall();
                    } else {
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

- (CGFloat)percentsOfAngleInCenter:(CGPoint)center point:(CGPoint)point{
    //Calculate angle of line Passing In Reference And Center
    CGFloat angleOfLine = atanf((point.y - center.y) / (point.x - center.x));
    CGFloat percentage = (angleOfLine - _angleOffsets)/(2 * M_PI);
    return (point.x - center.x) > 0 ? percentage : percentage + .5;
}

- (CGFloat)endPercentsForItemAtIndex:(NSUInteger)index{
    CGFloat percents = .0;
    for (NSUInteger i = 0; i <= index; i ++) {
        percents += [[_parts[i] valueForKey:@"percent"] floatValue];
    }
    return percents;
}

- (CGPoint)circleCoordinateWithCenter:(CGPoint)center angle:(CGFloat)angle radius:(CGFloat)radius{
    CGFloat x2 = radius*cosf(angle*180/M_PI);
    CGFloat y2 = radius*sinf(angle*180/M_PI);
    return CGPointMake(center.x+x2, center.y-y2);
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
@end

AXPieChartPart *AXPCPCreate(NSString *content, UIColor *color, CGFloat percent) {
    return [AXPieChartPart partWithContent:content color:color percent:percent];
}

@implementation _AXPieShapeLayer
+ (instancetype)layer {
    _AXPieShapeLayer *layer = [super layer];
    [layer addSublayer:layer.startLineLayer];
    [layer addSublayer:layer.startLineLayer];
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

- (void)initializer {
    [self addSublayer:self.startLineLayer];
    [self addSublayer:self.endLineLayer];
}

- (void)drawing {
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(CGRectGetWidth(self.frame)/2, CGRectGetHeight(self.frame)/2)
                                                              radius:(_drawingSize-_offsets)/4+_innerRadius/2
                                                          startAngle:_startAngle
                                                            endAngle:_endAngle
                                                           clockwise:YES];
    self.lineWidth = (_drawingSize-_offsets)/2-_innerRadius;
    self.path = bezierPath.CGPath;
}

- (CAShapeLayer *)startLineLayer {
    if (_startLineLayer) return _startLineLayer;
    _startLineLayer = [CAShapeLayer layer];
    _startLineLayer.backgroundColor = [UIColor clearColor].CGColor;
    return _startLineLayer;
}

- (CAShapeLayer *)endLineLayer {
    if (_endLineLayer) return _endLineLayer;
    _endLineLayer = [CAShapeLayer layer];
    _endLineLayer.backgroundColor = [UIColor clearColor].CGColor;
    return _endLineLayer;
}

- (void)setOffsets:(CGFloat)offsets {
    _offsets = offsets;
    [self drawing];
}
@end

@implementation AXPieChartPart
+ (instancetype)partWithContent:(NSString *)content color:(UIColor *)color percent:(CGFloat)percent
{
    AXPieChartPart *part = [[self alloc] init];
    part.content = content;
    part.color = color;
    part.percent = percent;
    return part;
}

- (CAShapeLayer *)hightlightLayer {
    return objc_getAssociatedObject(self, kAXPieChartHighLightedLayerKey);
}

- (UILabel *)textLabel {
    return objc_getAssociatedObject(self, kAXPieChartTextLabelKey);
}
@end