//
//  AXLineChart.m
//  AXChartKits
//
//  Created by ai on 15/12/28.
//  Copyright © 2015年 AiXing. All rights reserved.
//

#import "AXLineChart.h"

@interface AXLineChart ()
@end

@implementation AXLineChart
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
    _drawingDirection = AXLineChartDrawingHorizontal;
    _endLocation = .0;
    _startLocation = .0;
    _lineWidth = 1.0;
    _lineCap = AXLineCapRound;
    _startOffsets = 0.0;
    _endOffsets = 0.0;
    _visible = NO;
    _isBeginning = NO;
    _isEnding = NO;
    _shouldShowDashAtStart = NO;
    _shouldShowDashAtEnd = NO;
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
    
    CGContextSetStrokeColorWithColor(context, self.tintColor.CGColor);
    CGContextSetFillColorWithColor(context, self.tintColor.CGColor);
    CGContextSetLineWidth(context, _lineWidth);
    CGContextSetLineCap(context, (CGLineCap)_lineCap);
    
    CGPoint startPoint = CGPointZero;
    CGPoint endPoint = CGPointZero;
    
    CGRect drawbox = self.bounds;
    
    CGFloat startLocation = _startLocation;
    CGFloat endLocation = _endLocation;
    
    switch (_drawingDirection) {
        case AXLineChartDrawingHorizontal:
            startPoint = CGPointMake(drawbox.origin.x, CGRectGetHeight(drawbox) * startLocation);
            endPoint = CGPointMake(CGRectGetWidth(drawbox), CGRectGetHeight(drawbox) * endLocation);
            startPoint.x += _startOffsets;
            endPoint.x -= _endOffsets;
            CGFloat startOffsets = 0.0;
            CGFloat endOffsets = 0.0;
            if (startPoint.y > endPoint.y) {
                startOffsets = _startOffsets * (CGRectGetHeight(drawbox)*(startLocation-endLocation)/CGRectGetWidth(drawbox));
                startPoint.y -= startOffsets;
                endOffsets = _endOffsets * (CGRectGetHeight(drawbox)*(startLocation-endLocation)/CGRectGetWidth(drawbox));
                endPoint.y += endOffsets;
            } else if (startPoint.y < endPoint.y) {
                startOffsets = _startOffsets * (CGRectGetHeight(drawbox)*(endLocation-startLocation)/CGRectGetWidth(drawbox));
                startPoint.y += startOffsets;
                endOffsets = _endOffsets * (CGRectGetHeight(drawbox)*(endLocation-startLocation)/CGRectGetWidth(drawbox));
                endPoint.y -= endOffsets;
            }
            CGContextMoveToPoint(context, startPoint.x, startPoint.y);
            CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
            CGContextStrokePath(context);
            
            CGContextSetLineWidth(context, 2.0);
            if (_shouldShowDashAtStart && !_redrawing) {
                CGContextMoveToPoint(context, startPoint.x, startPoint.y);
                CGFloat length[] = {_lineWidth/2, _lineWidth*2};
                CGContextSetLineDash(context, _lineWidth/2, length, 2);
                CGContextAddLineToPoint(context, startPoint.x, CGRectGetHeight(drawbox));
                CGContextStrokePath(context);
            }
            
            if (_shouldShowDashAtEnd && !_redrawing) {
                CGContextMoveToPoint(context, CGRectGetWidth(drawbox), endPoint.y+_endOffsets * (CGRectGetHeight(drawbox)*(endLocation-startLocation)/CGRectGetWidth(drawbox)));
                CGFloat length[] = {_lineWidth/2, _lineWidth*2};
                CGContextSetLineDash(context, _lineWidth/2, length, 2);
                CGContextAddLineToPoint(context, CGRectGetWidth(drawbox), CGRectGetHeight(drawbox));
                CGContextStrokePath(context);
            }
            break;
        default:
            startPoint = CGPointMake(CGRectGetWidth(drawbox) * startLocation, 0.0);
            endPoint = CGPointMake(CGRectGetWidth(drawbox) * endLocation, CGRectGetHeight(drawbox));
            startPoint.y += _startOffsets;
            endPoint.y -= _endOffsets;
            if (startPoint.x > endPoint.x) {
                startPoint.x -= _startOffsets * (CGRectGetWidth(drawbox)*(startLocation-endLocation)/CGRectGetHeight(drawbox));
                endPoint.x += _endOffsets * (CGRectGetWidth(drawbox)*(startLocation-endLocation)/CGRectGetHeight(drawbox));
            } else if (startPoint.x < endPoint.x) {
                startPoint.x += _startOffsets * (CGRectGetWidth(drawbox)*(endLocation-startLocation)/CGRectGetHeight(drawbox));
                endPoint.x -= _endOffsets * (CGRectGetWidth(drawbox)*(endLocation-startLocation)/CGRectGetHeight(drawbox));
            }
            CGContextMoveToPoint(context, startPoint.x, startPoint.y);
            CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
            CGContextStrokePath(context);
            break;
    }
    
    UIGraphicsPopContext();
}

#pragma mark - Setters
- (void)setLineWidth:(CGFloat)lineWidth {
    _lineWidth = lineWidth;
    if (_isEnding) {
        _endOffsets = lineWidth/2;
    }
    if (_isBeginning) {
        _startOffsets = lineWidth/2;
    }
    [self setNeedsDisplay];
}

- (void)setIsBeginning:(BOOL)isBeginning {
    _isBeginning = isBeginning;
    if (_isBeginning) {
        _startOffsets = _lineWidth/2;
    }
    [self setNeedsDisplay];
}

- (void)setIsEnding:(BOOL)isEnding {
    _isEnding = isEnding;
    if (_isEnding) {
        _endOffsets = _lineWidth/2;
    }
    [self setNeedsDisplay];
}

- (void)setDrawingDirection:(AXLineChartDrawingDirection)drawingDirection {
    _drawingDirection = drawingDirection;
    [self setNeedsDisplay];
}

- (void)setStartLocation:(CGFloat)startLocation {
    _startLocation = startLocation;
    [self setNeedsDisplay];
}

- (void)setEndLocation:(CGFloat)endLocation {
    _endLocation = endLocation;
    [self setNeedsDisplay];
}

- (void)setTintColor:(UIColor *)tintColor {
    [super setTintColor:tintColor];
    [self setNeedsDisplay];
}

- (void)setLineCap:(AXLineCap)lineCap {
    _lineCap = lineCap;
    [self setNeedsDisplay];
}

- (void)setStartOffsets:(CGFloat)startOffsets {
    _startOffsets = startOffsets;
    [self setNeedsDisplay];
}

- (void)setEndOffsets:(CGFloat)endOffsets {
    _endOffsets = endOffsets;
    [self setNeedsDisplay];
}

- (void)setVisible:(BOOL)visible {
    [super setVisible:visible];
    [self setNeedsDisplay];
}

- (void)setShouldShowDashAtStart:(BOOL)shouldShowDashAtStart {
    _shouldShowDashAtStart = shouldShowDashAtStart;
    [self setNeedsDisplay];
}

- (void)setShouldShowDashAtEnd:(BOOL)shouldShowDashAtEnd {
    _shouldShowDashAtEnd = shouldShowDashAtEnd;
    [self setNeedsDisplay];
}

#pragma mark - Public
- (void)redrawAnimated:(BOOL)animated reverse:(BOOL)reverse duration:(NSTimeInterval)duration curve:(UIViewAnimationCurve)curve completion:(dispatch_block_t)completion
{
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
    POPBasicAnimation *anim = [self pop_animationForKey:kPOPViewAXCEndOffsets];
    if(anim == nil)
    {
        anim = [POPBasicAnimation animation];
        [self pop_addAnimation:anim forKey:kPOPViewAXCEndOffsets];
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
    anim.duration = duration;
    CAMediaTimingFunction *timingFunc;
    switch (curve) {
        case UIViewAnimationCurveEaseIn:
            timingFunc = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
            break;
        case UIViewAnimationCurveEaseInOut:
            timingFunc = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            break;
        case UIViewAnimationCurveEaseOut:
            timingFunc = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
            break;
        default:
            timingFunc = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
            break;
    }
    anim.timingFunction = timingFunc;
    if (reverse) {
        anim.property = [AXChartBase AXCPropertyWithName:kPOPViewAXCStartOffsets];
        anim.fromValue = [NSNumber numberWithFloat:CGRectGetWidth(self.frame)-_endOffsets];
        anim.toValue = [NSNumber numberWithFloat:_startOffsets];
    } else {
        anim.property = [AXChartBase AXCPropertyWithName:kPOPViewAXCEndOffsets];
        anim.fromValue = [NSNumber numberWithFloat:CGRectGetWidth(self.frame)-_startOffsets];
        anim.toValue = [NSNumber numberWithFloat:_endOffsets];
    }
}
@end