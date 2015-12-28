//
//  AXLineChart.h
//  AXChartKits
//
//  Created by ai on 15/12/28.
//  Copyright © 2015年 AiXing. All rights reserved.
//

#import "AXChart.h"
/// Drawing direction of line chart.
typedef NS_ENUM(NSInteger, AXLineChartDrawingDirection) {
    /// From left to right.
    AXLineChartDrawingHorizontal,
    /// From right to left.
    AXLineChartDrawingVertical
};
typedef NS_ENUM(NSInteger, AXLineCap) {
    AXLineCapButt = kCGLineCapButt,
    AXLineCapRound = kCGLineCapRound,
    AXLineCapSquare = kCGLineCapSquare
};
///
/// Line chart.
///
@interface AXLineChart : AXChart
/// Drawing direction.
@property(assign, nonatomic) AXLineChartDrawingDirection drawingDirection;
/// Start location percents. Value is between [0, 1].
@property(assign, nonatomic) CGFloat startLocation;
/// End location percents. Value is between [0, 1].
@property(assign, nonatomic) CGFloat endLocation;
/// Line width.
@property(assign, nonatomic) CGFloat lineWidth;
/// Line cap.
@property(assign, nonatomic) AXLineCap lineCap;
@end