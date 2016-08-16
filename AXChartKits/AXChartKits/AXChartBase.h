//
//  AXChart.h
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

#import <UIKit/UIKit.h>
#import <pop/pop.h>

#ifndef kAXDefaultMediaTimingFunction
#define kAXDefaultMediaTimingFunction [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]
#endif

/// Pop animatalbe property key for start offsets of `AXLineChartCell`.
extern NSString *const kPOPViewAXCEndOffsets;
/// Pop animatable property key for end offsets of `AXLineChartCell`.
extern NSString *const kPOPViewAXCStartOffsets;
/// Pop animatable property key for angle of `AXPieChartView`.
extern NSString *const kPOPViewAXCPieAngle;
/// Pop animatable property key for percents of `AXCircleChartView`.
extern NSString *const kPOPViewAXCCirclePercents;
/// Pop animatable property key for value of `AXBarChartCell`.
extern NSString *const kPOPViewAXCBarValues;
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