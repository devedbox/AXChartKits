//
//  AXBarChartCell.h
//  AXChartKits
//
//  Created by devedbox on 16/8/15.
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
/// Direction definition of bar drawing direction.
///
typedef NS_ENUM(NSInteger, AXBarChartCellDirection) {
    /// Draw in vertical direc.
    AXBarChartCellVertical,
    /// Draw in horizontal direc.
    AXBarChartCellHorizontal
};
/// Style of bar chart view.
typedef NS_ENUM(NSInteger, AXBarChartCellStyle) {
    /// Corner radius style.
    AXBarChartCellStyleCornerRadius,
    /// Bounds radius style.
    AXBarChartCellStyleBoundsRadius
};
///
/// Bar chart cell.
///
@interface AXBarChartCell : AXChartBase
/// Style of cell.
@property(assign, nonatomic) AXBarChartCellStyle style;
/// Direction of cell.
@property(assign, nonatomic) AXBarChartCellDirection direction;
/// Reverse the animate direction. Default is NO.
/// @discusstion The default direction is from bottom to top on vertical and from left to right on horizontal. If set to YES, then using the reverse direction.
///
@property(assign, nonatomic) BOOL reverseDrawing __deprecated_msg("Not implementated.");
/// Value. From [0, 1].
@property(assign, nonatomic) CGFloat value;
/// Duration of animation. Default is 1.2.
@property(assign, nonatomic) NSTimeInterval duration;
/// Stroke color. Defaults is orange color.
@property(strong, nonatomic) UIColor   *strokeColor;
/// Stroke end color. Defaults is red color.
@property(strong, nonatomic) UIColor   *strokeEndColor;
/// Corner radius of fill zone. Default is 3.0.
@property(assign, nonatomic) CGFloat cornerRadius;
/// Redraw chart from 0.0 to current value with animation.
///
/// @param animated   a boolean value to show animation.
/// @param completion completion call back block.
- (void)redrawAnimated:(BOOL)animated completion:(dispatch_block_t)completion;
/// Update chart from 0.0 to a new value with animation.
///
/// @param value      new value of percents of chart.
/// @param animated   a boolean value to show animation.
/// @param completion completion call back block.
- (void)updateToValue:(CGFloat)value animated:(BOOL)animated completion:(dispatch_block_t)completion;
@end