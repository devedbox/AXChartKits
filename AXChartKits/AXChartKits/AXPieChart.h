//
//  AXPieChart.h
//  AXChartKits
//
//  Created by ai on 15/12/30.
//  Copyright © 2015年 AiXing. All rights reserved.
//

#import "AXChartBase.h"
/// Class `AXPieChartPart`
@class AXPieChartPart;
/// Class `AXPieChart`
@class AXPieChart;
///
/// AXPieChartDelegate
///
@protocol AXPieChartDelegate <NSObject>
/// Called when pie chart view did touch part at index.
///
/// @param chart a pie chart view.
/// @param part  touched part.
- (void)pieChart:(AXPieChart *)chart didTouchPart:(AXPieChartPart *)part;
/// Called when pie chart view did touch inside.
///
/// @param chart a pie chart view.
- (void)pieChartDidTouchInsideParts:(AXPieChart *)chart;
/// Called when pie chart view did touch outside.
///
/// @param chart a pie chart view.
- (void)pieChartDidTouchOutsideParts:(AXPieChart *)chart;
@end
/// Touch type of pie chart.
typedef NS_ENUM(NSUInteger, AXPieChartTouchType) {
    /// Touch part.
    AXPieChartTouchPart,
    /// Touch inside.
    AXPieChartTouchInside,
    /// Touch outside.
    AXPieChartTouchOutside
};
/// Call back block when touch events occure.
///
/// @param touch a type of touch event. See `AXPieChartTouchType` for more.
/// @param part  a part of `AXPieChartTouchPart` type.
typedef void(^AXPieChartDidTouchCall)(AXPieChartTouchType touch, AXPieChartPart* part);
///
/// AXPieChart
///
@interface AXPieChart : AXChartBase
/// Delegate.
@property(assign, nonatomic) id<AXPieChartDelegate>delegate;
/// Call back block.
@property(copy, nonatomic) AXPieChartDidTouchCall touchCall;
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
/// Should selected on touch. Defaults is YES.
@property(assign, nonatomic) BOOL shouldSelection;
/// Should allow to select multiple parts. Defaults is NO.
@property(assign, nonatomic) BOOL allowsMultipleSelection;
/// Should show absolute values. Defaults is NO.
@property(assign, nonatomic) BOOL showsAbsoluteValues;
/// Should hide values. Defaults is NO.
@property(assign, nonatomic) BOOL hidesValues;
/// Should show only values. Default is NO.
@property(assign, nonatomic) BOOL showsOnlyValues;
/// Percents limits of label. Defaults is 0.05.
@property(assign, nonatomic) CGFloat percentsLimitsOfLabel;
/// Text font.
@property(strong, nonatomic) UIFont *textFont;
/// Text color.
@property(strong, nonatomic) UIColor *textColor;
/// Max text allowed width.
@property(assign, nonatomic) CGFloat maxAllowedLabelWidth;
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
/// Highlight layer.
@property(readonly, nonatomic) CAShapeLayer *hightlightLayer;
/// Text label.
@property(readonly, nonatomic) UILabel *textLabel;
/// Create a new part of pie chart with content and color and percent.
///
/// @param content content description of part.
/// @param color   color of part arc.
/// @param percent percent of part.
///
/// @return a new part.
+ (instancetype)partWithContent:(NSString *)content color:(UIColor *)color percent:(CGFloat)percent;
@end