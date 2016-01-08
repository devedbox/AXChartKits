//
//  AXChart.h
//  AXChartKits
//
//  Created by ai on 15/12/28.
//  Copyright © 2015年 AiXing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <pop/pop.h>

@class AXPieChart;
@class AXLineChart;
@class AXCircleChart;

extern NSString *const kPOPViewAXCEndOffsets;
extern NSString *const kPOPViewAXCStartOffsets;
extern NSString *const kPOPViewAXCPieAngle;
extern NSString *const kPOPViewAXCCirclePercents;

typedef NS_ENUM(NSInteger, AXLineCap) {
    AXLineCapButt = kCGLineCapButt,
    AXLineCapRound = kCGLineCapRound,
    AXLineCapSquare = kCGLineCapSquare
};

@interface AXChartBase : UIView
{
    @protected
    BOOL _visible;
    BOOL _redrawing;
}
/// Visible.
@property(assign, nonatomic, getter=isVisible) BOOL visible;
/// Redrawing.
@property(readonly, nonatomic, getter=isRedrawing) BOOL redrawing;
///
- (void)didTouch:(CGPoint)location;
///
+ (POPAnimatableProperty *)AXCPropertyWithName:(NSString *)name;
@end