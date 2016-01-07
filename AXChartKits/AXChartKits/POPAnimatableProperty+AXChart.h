//
//  POPAnimatableProperty+AXChart.h
//  AXChartKits
//
//  Created by ai on 15/12/28.
//  Copyright © 2015年 AiXing. All rights reserved.
//

#import <pop/pop.h>

extern NSString *const kPOPViewAXCEndOffsets;
extern NSString *const kPOPViewAXCStartOffsets;
extern NSString *const kPOPViewAXCPieAngle;
extern NSString *const kPOPViewAXCCirclePercents;

@interface POPAnimatableProperty (AXChart)
+ (instancetype)AXCPropertyWithName:(NSString *)name;
@end