//
//  AXChart.h
//  AXChartKits
//
//  Created by ai on 15/12/28.
//  Copyright © 2015年 AiXing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <pop/pop.h>
/// Pop animatalbe property key for start offsets of `AXLineChartCell`.
extern NSString *const kPOPViewAXCEndOffsets;
/// Pop animatable property key for end offsets of `AXLineChartCell`.
extern NSString *const kPOPViewAXCStartOffsets;
/// Pop animatable property key for angle of `AXPieChartView`.
extern NSString *const kPOPViewAXCPieAngle;
/// Pop animatable property key for percents of `AXCircleChartView`.
extern NSString *const kPOPViewAXCCirclePercents;
/// Line cap.
typedef NS_ENUM(NSInteger, AXLineCap) {
    /// Butt.
    AXLineCapButt = kCGLineCapButt,
    /// Round.
    AXLineCapRound = kCGLineCapRound,
    /// Square.
    AXLineCapSquare = kCGLineCapSquare
};
///
/// AXChartBase
///
@interface AXChartBase : UIView
{
    @protected
    /// Is chart visible.
    BOOL _visible;
    /// Is chart in redrawing.
    BOOL _redrawing;
}
/// Visible.
@property(assign, nonatomic, getter=isVisible) BOOL visible;
/// Redrawing.
@property(readonly, nonatomic, getter=isRedrawing) BOOL redrawing;
///
/// Called when touch event occured.
///
/// @param location point of touch location.
///
- (void)didTouch:(CGPoint)location;
///
/// Get animatable property with property key.
///
/// @param name a animatable property key.
///
/// @return A animatable property.
///
+ (POPAnimatableProperty *)AXCPropertyWithName:(NSString *)name;
@end