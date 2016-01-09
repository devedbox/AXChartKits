//
//  AXLineChart.h
//  AXChartKits
//
//  Created by ai on 15/12/28.
//  Copyright © 2015年 AiXing. All rights reserved.
//

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
///
- (void)redrawAnimated:(BOOL)animated reverse:(BOOL)reverse duration:(NSTimeInterval)duration curve:(UIViewAnimationCurve)curve completion:(dispatch_block_t)completion;
@end