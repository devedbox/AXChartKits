//
//  AXPieChart.h
//  AXChartKits
//
//  Created by ai on 15/12/30.
//  Copyright © 2015年 AiXing. All rights reserved.
//

#import "AXChartBase.h"

@class AXPieChartPart;
///
/// AXPieChart
///
@interface AXPieChart : AXChartBase
/// Parts of pie chart.
@property(copy, readonly, nonatomic) NSArray *parts;
/// Angle. Default is M_PI*2.
@property(assign, nonatomic) CGFloat angle;
/// Angle offsets. Defaults is -M_PI_2.
@property(assign, nonatomic) CGFloat angleOffsets;
/// Constant value of hollow part. Default is 20.
@property(assign, nonatomic) CGFloat hollowRadius;
/// Max allowed offsets. Default is 10.
@property(assign, nonatomic) CGFloat maxAllowedOffsets;
/// Add parts to the pie chart.
///
/// @discussion Add parts to pie chart by using va_list params.
///
/// @param part,... parts to be added.
///
- (void)addParts:(AXPieChartPart *)part,...;
/// Redraw pie chart with animation.
///
/// @discussion Redraw chart with animation. When finished, completion call
///             back block will be called if completion block is valid.
///
/// @param animated   a boolean value to show animation.
/// @param completion a completion block.
- (void)redrawAnimated:(BOOL)animated completion:(dispatch_block_t)completion;
@end
/// Create a new part of pie chart.
///
/// @param content content description of part.
/// @param color   color of part arc.
/// @param percent percent of part.
///
/// @return a new part.
extern AXPieChartPart * AXPCPCreate(NSString *content, UIColor *color, CGFloat percent);
///
/// AXPieChartPart
///
@interface AXPieChartPart : NSObject
/// String content.
@property(copy, nonatomic) NSString *content;
/// Drawing color.
@property(strong, nonatomic) UIColor *color;
/// Angle percent
@property(assign, nonatomic) CGFloat percent;
/// Create a new part of pie chart with content and color and percent.
///
/// @param content content description of part.
/// @param color   color of part arc.
/// @param percent percent of part.
///
/// @return a new part.
+ (instancetype)partWithContent:(NSString *)content color:(UIColor *)color percent:(CGFloat)percent;
@end