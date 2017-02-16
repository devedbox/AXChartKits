//
//  AXChart.m
//  AXChartKits
//
//  Created by ai on 15/12/28.
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

#import "AXChartBase.h"
#import "AXPieChartView.h"
#import "AXLineChartCell.h"
#import "AXCircleChartView.h"
#import "AXBarChartView/AXBarChartCell.h"

static CGFloat const kPOPLayerAXCQuadThreshold = 1.0;

NSString *const kPOPViewAXCStartOffsets = @"startOffsets";
NSString *const kPOPViewAXCEndOffsets = @"endOffsets";
NSString *const kPOPViewAXCStartDashDrawingProgress = @"startDashDrawingProgress";
NSString *const kPOPViewAXCEndDashDrawingProgress = @"endDashDrawingProgress";
NSString *const kPOPViewAXCPieAngle = @"angle";
NSString *const kPOPViewAXCCirclePercents = @"percents";
NSString *const kPOPViewAXCBarValues = @"value";

@implementation AXChartBase
+ (NSArray *)AXCAnimatableProperties {
    static NSArray *props;
    if (props == nil) {
        props =
        @[
          [POPAnimatableProperty propertyWithName:kPOPViewAXCEndOffsets initializer:^(POPMutableAnimatableProperty *prop) {
              prop.readBlock = ^(AXLineChartCell *lineChart, CGFloat values[]) {
                  values[0] = lineChart.endOffsets;
              };
              prop.writeBlock = ^(AXLineChartCell *lineChart, const CGFloat values[]) {
                  lineChart.endOffsets = values[0];
                  
              };
              prop.threshold = kPOPLayerAXCQuadThreshold;
          }],
          [POPAnimatableProperty propertyWithName:kPOPViewAXCStartOffsets initializer:^(POPMutableAnimatableProperty *prop) {
              prop.readBlock = ^(AXLineChartCell *lineChart, CGFloat values[]) {
                  values[0] = lineChart.startOffsets;
              };
              prop.writeBlock = ^(AXLineChartCell *lineChart, const CGFloat values[]) {
                  lineChart.startOffsets = values[0];
                  
              };
              prop.threshold = kPOPLayerAXCQuadThreshold;
          }],
          [POPAnimatableProperty propertyWithName:kPOPViewAXCPieAngle initializer:^(POPMutableAnimatableProperty *prop) {
              prop.readBlock = ^(AXPieChartView *pieChart, CGFloat values[]) {
                  values[0] = pieChart.angle;
              };
              prop.writeBlock = ^(AXPieChartView *pieChart, const CGFloat values[]) {
                  pieChart.angle = values[0];
              };
              prop.threshold = kPOPLayerAXCQuadThreshold;
          }],
          [POPAnimatableProperty propertyWithName:kPOPViewAXCCirclePercents initializer:^(POPMutableAnimatableProperty *prop) {
              prop.readBlock = ^(AXCircleChartView *pieChart, CGFloat values[]) {
                  values[0] = pieChart.percents;
              };
              prop.writeBlock = ^(AXCircleChartView *pieChart, const CGFloat values[]) {
                  pieChart.percents = values[0];
              };
              prop.threshold = kPOPLayerAXCQuadThreshold;
          }],
          [POPAnimatableProperty propertyWithName:kPOPViewAXCBarValues initializer:^(POPMutableAnimatableProperty *prop) {
              prop.readBlock = ^(AXBarChartCell *barChart, CGFloat values[]) {
                  values[0] = barChart.value;
              };
              prop.writeBlock = ^(AXBarChartCell *barChart, const CGFloat values[]) {
                  barChart.value = values[0];
              };
              prop.threshold = kPOPLayerAXCQuadThreshold;
          }],
          [POPAnimatableProperty propertyWithName:kPOPViewAXCStartDashDrawingProgress initializer:^(POPMutableAnimatableProperty *prop) {
              prop.readBlock = ^(AXLineChartCell *lineChart, CGFloat values[]) {
                  values[0] = lineChart.startDashDrawingProgress;
              };
              prop.writeBlock = ^(AXLineChartCell *lineChart, const CGFloat values[]) {
                  lineChart.startDashDrawingProgress = values[0];
                  
              };
              prop.threshold = kPOPLayerAXCQuadThreshold;
          }],
          [POPAnimatableProperty propertyWithName:kPOPViewAXCEndDashDrawingProgress initializer:^(POPMutableAnimatableProperty *prop) {
              prop.readBlock = ^(AXLineChartCell *lineChart, CGFloat values[]) {
                  values[0] = lineChart.endDashDrawingProgress;
              };
              prop.writeBlock = ^(AXLineChartCell *lineChart, const CGFloat values[]) {
                  lineChart.endDashDrawingProgress = values[0];
                  
              };
              prop.threshold = kPOPLayerAXCQuadThreshold;
          }]
          ];
    }
    return props;
}

+ (POPAnimatableProperty *)AXCPropertyWithName:(NSString *)name {
    NSArray *props = [self AXCAnimatableProperties];
    
    for(POPAnimatableProperty *prop in props)
    {
        if([prop.name isEqualToString:name])
        {
            return prop;
        }
    }
    
    return nil;
}
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
