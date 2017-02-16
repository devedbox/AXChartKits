//
//  AXLineChart.h
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
/// Drawing direction of line chart.
typedef NS_ENUM(NSInteger, AXLineChartDrawingDirection) {
    /// From left to right.
    AXLineChartDrawingHorizontal,
    /// From right to left.
    AXLineChartDrawingVertical
};
///
/// Line chart.
///
@interface AXLineChartCell : AXChartBase
/// Drawing direction.
@property(assign, nonatomic) AXLineChartDrawingDirection drawingDirection;
/// Start location percents. Value is between [0, 1].
@property(assign, nonatomic) CGFloat startLocation;
/// Start location offsets. Value is [0, max width of chart view].
@property(assign, nonatomic) CGFloat startOffsets;
/// End location percents. Value is between [0, 1].
@property(assign, nonatomic) CGFloat endLocation;
/// End location offsets. Value is [0, max width of chart view].
@property(assign, nonatomic) CGFloat endOffsets;
/// Line width.
@property(assign, nonatomic) CGFloat lineWidth;
/// Line cap.
@property(assign, nonatomic) AXLineCap lineCap;
/// Is beginning. Default is NO.
@property(assign, nonatomic) BOOL isBeginning;
/// Is ending. Default is NO.
@property(assign, nonatomic) BOOL isEnding;
/// Should show dash at start point.
@property(assign, nonatomic) BOOL shouldShowDashAtStart;
/// Should show dash at end point.
@property(assign, nonatomic) BOOL shouldShowDashAtEnd;
/// Start dash drawing progress. Animatable for <pop>. Defaults to 1.0.
@property(assign, nonatomic) NSUInteger startDashDrawingProgress;
/// End dash drawing progress. Animatable for <pop>. Defaults to 1.0.
@property(assign, nonatomic) NSUInteger endDashDrawingProgress;
///
- (void)redrawAnimated:(BOOL)animated reverse:(BOOL)reverse duration:(NSTimeInterval)duration curve:(UIViewAnimationCurve)curve completion:(dispatch_block_t)completion;
@end
