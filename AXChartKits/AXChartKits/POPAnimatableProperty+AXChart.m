//
//  POPAnimatableProperty+AXChart.m
//  AXChartKits
//
//  Created by ai on 15/12/28.
//  Copyright © 2015年 AiXing. All rights reserved.
//

#import "POPAnimatableProperty+AXChart.h"
#import "AXCircleChart.h"
#import "AXLineChart.h"
#import "AXPieChart.h"

static CGFloat const kPOPLayerAXCQuadThreshold = 1.0;

NSString *const kPOPViewAXCEndOffsets = @"startOffsets";
NSString *const kPOPViewAXCStartOffsets = @"endOffsets";
NSString *const kPOPViewAXCPieAngle = @"angle";
NSString *const kPOPViewAXCCirclePercents = @"percents";

@implementation POPAnimatableProperty (AXChart)
+ (NSArray *)AXCAnimatableProperties {
    static NSArray *props;
    if (props == nil) {
        props =
        @[
          [POPAnimatableProperty propertyWithName:kPOPViewAXCEndOffsets initializer:^(POPMutableAnimatableProperty *prop) {
              prop.readBlock = ^(AXLineChart *lineChart, CGFloat values[]) {
                  values[0] = lineChart.endOffsets;
              };
              prop.writeBlock = ^(AXLineChart *lineChart, const CGFloat values[]) {
                  lineChart.endOffsets = values[0];
                  
              };
              prop.threshold = kPOPLayerAXCQuadThreshold;
          }],
          [POPAnimatableProperty propertyWithName:kPOPViewAXCStartOffsets initializer:^(POPMutableAnimatableProperty *prop) {
              prop.readBlock = ^(AXLineChart *lineChart, CGFloat values[]) {
                  values[0] = lineChart.startOffsets;
              };
              prop.writeBlock = ^(AXLineChart *lineChart, const CGFloat values[]) {
                  lineChart.startOffsets = values[0];
                  
              };
              prop.threshold = kPOPLayerAXCQuadThreshold;
          }],
          [POPAnimatableProperty propertyWithName:kPOPViewAXCPieAngle initializer:^(POPMutableAnimatableProperty *prop) {
              prop.readBlock = ^(AXPieChart *pieChart, CGFloat values[]) {
                  values[0] = pieChart.angle;
              };
              prop.writeBlock = ^(AXPieChart *pieChart, const CGFloat values[]) {
                  pieChart.angle = values[0];
              };
              prop.threshold = kPOPLayerAXCQuadThreshold;
          }],
          [POPAnimatableProperty propertyWithName:kPOPViewAXCCirclePercents initializer:^(POPMutableAnimatableProperty *prop) {
              prop.readBlock = ^(AXCircleChart *pieChart, CGFloat values[]) {
                  values[0] = pieChart.percents;
              };
              prop.writeBlock = ^(AXCircleChart *pieChart, const CGFloat values[]) {
                  pieChart.percents = values[0];
              };
              prop.threshold = kPOPLayerAXCQuadThreshold;
          }]
          ];
    }
    return props;
}

+ (instancetype)AXCPropertyWithName:(NSString *)name {
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
@end