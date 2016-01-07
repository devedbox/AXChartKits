//
//  AXChart.m
//  AXChartKits
//
//  Created by ai on 15/12/28.
//  Copyright © 2015年 AiXing. All rights reserved.
//

#import "AXChartBase.h"

@implementation AXChartBase
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    for (UITouch *touch in touches) {
        CGPoint point = [touch locationInView:self];
        [self didTouch:point];
    }
}

- (void)didTouch:(CGPoint)location {
}
@end