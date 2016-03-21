//
//  CircleChartViewController.m
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

#import "CircleChartViewController.h"
#import "AXCircleChartView.h"

@interface CircleChartViewController ()
/// Circle chart.
@property(weak, nonatomic) IBOutlet AXCircleChartView *circleChart;
/// Circle chart small.
@property(strong, nonatomic) AXCircleChartView *smallCircleChart;
@end

@implementation CircleChartViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    _smallCircleChart = [[AXCircleChartView alloc] initWithFrame:CGRectMake(self.view.frame.size.width*.5 - 50, 104, 100, 100)];
    _smallCircleChart.percents = 0.8;
    _smallCircleChart.formatter = AXCircleChartFormatDollar;
    [self.view addSubview:_smallCircleChart];
    _smallCircleChart.touchAction = AXCircleChartTouchActionRedraw;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self redraw:nil];
    });
}

#pragma mark - Actions
- (IBAction)redraw:(id)sender {
    [_smallCircleChart redrawAnimated:YES completion:NULL];
    if (_circleChart.percents >= .8) {
        [_circleChart redrawAnimated:YES completion:NULL];
    } else {
        [_circleChart updateFromCurrentToPercents:_circleChart.percents+0.2 animated:YES completion:NULL];
    }
}
@end
