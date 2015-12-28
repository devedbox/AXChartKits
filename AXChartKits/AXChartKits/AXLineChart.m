//
//  AXLineChart.m
//  AXChartKits
//
//  Created by ai on 15/12/28.
//  Copyright © 2015年 AiXing. All rights reserved.
//

#import "AXLineChart.h"

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
    NSArray *paths = @[@"drawingDirection",@"startLocation",@"endLocation",@"tintColor", @"lineWidth",@"lineCap"];
    for (NSString *path in paths) {
        [self addObserver:self forKeyPath:path options:NSKeyValueObservingOptionNew context:nil];
    }
}

- (void)dealloc {
    NSArray *paths = @[@"drawingDirection",@"startLocation",@"endLocation",@"tintColor",@"lineWidth",@"lineCap"];
    for (NSString *path in paths) {
        [self removeObserver:self forKeyPath:path];
    }
}
#pragma mark - Override
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"drawingDirection"] || [keyPath isEqualToString:@"startLocation"] || [keyPath isEqualToString:@"endLocation"] || [keyPath isEqualToString:@"tintColor"] || [keyPath isEqualToString:@"lineWidth"] || [keyPath isEqualToString:@"lineCap"])
    {
        [self setNeedsDisplay];
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initializer];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(context);
    
    CGContextSetStrokeColorWithColor(context, self.tintColor.CGColor);
    CGContextSetLineWidth(context, _lineWidth);
    CGContextSetLineCap(context, (CGLineCap)_lineCap);
    
    CGPoint startPoint = CGPointZero;
    CGPoint endPoint = CGPointZero;
    
    switch (_drawingDirection) {
        case AXLineChartDrawingHorizontal:
            startPoint = CGPointMake(0.0, CGRectGetHeight(self.frame) * _startLocation);
            endPoint = CGPointMake(CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) * _endLocation);
            break;
        default:
            startPoint = CGPointMake(CGRectGetWidth(self.frame) * _startLocation, 0.0);
            endPoint = CGPointMake(CGRectGetWidth(self.frame) * _endLocation, CGRectGetHeight(self.frame));
            break;
    }
    CGContextMoveToPoint(context, startPoint.x, startPoint.y);
    CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
    
    CGContextStrokePath(context);
    
    UIGraphicsPopContext();
}
@end