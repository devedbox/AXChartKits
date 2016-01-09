//
//  AXCircleChart.h
//  AXChartKits
//
//  Created by ai on 16/1/5.
//  Copyright © 2016年 AiXing. All rights reserved.
//

#import "AXChartBase.h"

@class AXCircleChartView;
///
/// AXCircleChartDelegate
///
@protocol AXCircleChartDelegate <NSObject>
@optional
/// Did touch a valid area of circle chart.
///
/// @param chart a circle chart.
- (void)circleChartDidTouch:(AXCircleChartView *)chart;
@end
/// Call back block of touching on valid area.
///
/// @param chart a circle chart.
typedef void(^AXCircleChartDidTouchCall)(AXCircleChartView *chart);
/// Circle chart text string format.
typedef NS_ENUM (NSUInteger, AXCircleChartFormat) {
    /// Normal format.
    AXCircleChartFormatNone,
    /// RMB format.
    AXCircleChartFormatRMB,
    /// Dollar format.
    AXCircleChartFormatDollar,
    /// Percent format.
    AXCircleChartFormatPercent,
    /// Decimal.
    AXCircleChartFormatDecimal,
    /// Tow places decimal.
    AXCircleChartFormatDecimalTwoPlaces,
};
/// Circle chart touch antion
typedef NS_ENUM(NSUInteger, AXCircleChartTouchAction) {
    /// None action.
    AXCircleChartTouchActionNone,
    /// Redraw action.
    AXCircleChartTouchActionRedraw,
    /// Switch filling antion.
    AXCircleChartTouchActionSwitchFilling
};
///
/// AXCircleChart
///
@interface AXCircleChartView : AXChartBase
/// Fromatter. Defaults is Percent.
@property(assign, nonatomic) AXCircleChartFormat formatter;
/// Delegate of circle chart.
@property(assign, nonatomic) id<AXCircleChartDelegate>delegate;
/// Call back block on touch.
@property(copy, nonatomic)   AXCircleChartDidTouchCall touchCall;
/// Should show text label. Defaults is YES.
@property(assign, nonatomic) BOOL      showsLabel;
/// Should fill the path. Defaults is YES.
@property(assign, nonatomic) BOOL      fillsPath;
/// Should switch filling on touch. Defaults is YES.
@property(assign, nonatomic) BOOL      switchsFillingOnTouch __deprecated_msg("using `touchAction` instead.");
/// Action value on touch. Defaults is SwitchFilling.
@property(assign, nonatomic) AXCircleChartTouchAction touchAction;
/// Angle offsets. Defaults is -M_PI_2.
@property(assign, nonatomic) CGFloat   angleOffsets;
/// Percents. Value between [0, 1].
@property(assign, nonatomic) CGFloat   percents;
/// Line width. Defaults is 12.0 pt.
@property(assign, nonatomic) CGFloat   lineWidth;
/// Line cap. Defaults is round.
@property(assign, nonatomic) AXLineCap lineCap;
/// Stroke color. Defaults is orange color.
@property(strong, nonatomic) UIColor   *strokeColor;
/// Stroke end color. Defaults is red color.
@property(strong, nonatomic) UIColor   *strokeEndColor;
/// Text color. Defaults is orange color.
@property(nonatomic) UIColor *textColor;
/// Text font. Defaults is bold 16 of system.
@property(nonatomic) UIFont  *textFont;
/// Fill color.
@property(strong, nonatomic) UIColor *fillColor;
/// Duration of shows animation.
@property(assign, nonatomic) NSTimeInterval duration;
/// Redraw chart from 0.0 to current value with animation.
///
/// @param animated   a boolean value to show animation.
/// @param completion completion call back block.
- (void)redrawAnimated:(BOOL)animated completion:(dispatch_block_t)completion;
/// Update chart from current value to a new value with animation.
///
/// @param toPercents new value of percents of chart.
/// @param animated   a boolean value to show animation.
/// @param completion completion call back block.
- (void)updateFromCurrentToPercents:(CGFloat)toPercents animated:(BOOL)animated completion:(dispatch_block_t)completion;
/// Update chart from a value to another value with animation.
///
/// @param fromPercents percents to start with.
/// @param toPercents   percents to end with.
/// @param animated     a boolean value to show animation.
/// @param completion   completion call back block.
- (void)updateFromPercents:(CGFloat)fromPercents toPercents:(CGFloat)toPercents animated:(BOOL)animated completion:(dispatch_block_t)completion;
/// Update text value from a value to another value with animation.
///
/// @param fromPercents percents to start with.
/// @param toPercents   percents to end with.
/// @param animated     a boolean value to show animation.
/// @param completion   completion call back block.
- (void)updateTextFromPercents:(CGFloat)fromPercents toPercents:(CGFloat)toPercents animated:(BOOL)animated completion:(dispatch_block_t)completion;
@end