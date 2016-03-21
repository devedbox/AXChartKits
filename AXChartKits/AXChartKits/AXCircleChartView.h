//
//  AXCircleChart.h
//  AXChartKits
//
//  Created by ai on 16/1/5.
//  Copyright © 2016年 AiXing. All rights reserved.
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
/// Class `AXCircleChartView`.
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
@property(assign, nonatomic) IBOutlet id<AXCircleChartDelegate>delegate;
/// Call back block on touch.
@property(copy, nonatomic)   AXCircleChartDidTouchCall touchCall;
/// Should show text label. Defaults is YES.
@property(assign, nonatomic) IBInspectable BOOL      showsLabel;
/// Should fill the path. Defaults is YES.
@property(assign, nonatomic) IBInspectable BOOL      fillsPath;
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
@property(strong, nonatomic) IBInspectable UIColor   *strokeColor;
/// Stroke end color. Defaults is red color.
@property(strong, nonatomic) IBInspectable UIColor   *strokeEndColor;
/// Text color. Defaults is orange color.
@property(nonatomic) IBInspectable UIColor *textColor;
/// Text font. Defaults is bold 16 of system.
@property(nonatomic) UIFont  *textFont;
/// Fill color.
@property(strong, nonatomic) IBInspectable UIColor *fillColor;
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