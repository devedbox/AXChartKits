//
//  AXPieChart.m
//  AXChartKits
//
//  Created by ai on 15/12/30.
//  Copyright © 2015年 AiXing. All rights reserved.
//

#import "AXPieChart.h"
#import <objc/runtime.h>

@interface AXPieChart ()
{
    @private
    /// Parts
    NSMutableArray *_parts;
}
@end

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
    self.userInteractionEnabled = YES;
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
    CGFloat size = MIN(CGRectGetHeight(self.frame), CGRectGetWidth(self.frame))-_maxAllowedOffsets;
    CGContextSetLineWidth(context, size/2-_hollowRadius);
    CGFloat startAngle = 0;
    CGFloat endAngle = 0;
    for (NSUInteger i = 0; i < _parts.count; i++) {
        AXPieChartPart *part = _parts[i];
        CGContextSetStrokeColorWithColor(context, part.color.CGColor);
        endAngle += M_PI*2*part.percent;
        endAngle = MIN(_angle, endAngle);
        CGContextAddArc(context, CGRectGetWidth(self.frame)/2, CGRectGetHeight(self.frame)/2, size/4+_hollowRadius/2, startAngle+_angleOffsets, endAngle+_angleOffsets, 0);
        startAngle = endAngle;
        CGContextStrokePath(context);
    }
    UIGraphicsPopContext();
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *suview = [super hitTest:point withEvent:event];
    return suview;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
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
    }
    va_end(args);
    NSAssert(percent <= 1.0, @"Percents of total parts should less then 1.0");
    [self setNeedsDisplay];
}

- (void)redrawAnimated:(BOOL)animated completion:(dispatch_block_t)completion {
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
    POPBasicAnimation *anim = [self pop_animationForKey:kPOPViewAXCPieAngle];
    if(anim == nil)
    {
        anim = [POPBasicAnimation animation];
        anim.property = [POPAnimatableProperty AXCPropertyWithName:kPOPViewAXCPieAngle];
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
    anim.duration = 1.2;
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    anim.fromValue = [NSNumber numberWithFloat:.0];
    anim.toValue = [NSNumber numberWithFloat:M_PI*2];
}
@end

AXPieChartPart *AXPCPCreate(NSString *content, UIColor *color, CGFloat percent) {
    return [AXPieChartPart partWithContent:content color:color percent:percent];
}

@implementation AXPieChartPart
+ (instancetype)partWithContent:(NSString *)content color:(UIColor *)color percent:(CGFloat)percent
{
    AXPieChartPart *part = [[self alloc] init];
    part.content = content;
    part.color = color;
    part.percent = percent;
    return part;
}
@end