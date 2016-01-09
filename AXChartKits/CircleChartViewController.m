//
//  CircleChartViewController.m
//  AXChartKits
//
//  Created by ai on 16/1/5.
//  Copyright © 2016年 AiXing. All rights reserved.
//

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
