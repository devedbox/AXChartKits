//
//  CircleChartViewController.m
//  AXChartKits
//
//  Created by ai on 16/1/5.
//  Copyright © 2016年 AiXing. All rights reserved.
//

#import "CircleChartViewController.h"
#import "AXCircleChart.h"

@interface CircleChartViewController ()
/// Circle chart.
@property(weak, nonatomic) IBOutlet AXCircleChart *circleChart;
/// Circle chart small.
@property(strong, nonatomic) AXCircleChart *smallCircleChart;
@end

@implementation CircleChartViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    _smallCircleChart = [[AXCircleChart alloc] initWithFrame:CGRectMake(self.view.frame.size.width*.5 - 50, 64, 100, 120)];
    _smallCircleChart.percents = 0.8;
    _smallCircleChart.formatter = AXCircleChartFormatDollar;
    [self.view addSubview:_smallCircleChart];
    _smallCircleChart.touchAction = AXCircleChartTouchActionRedraw;
}

#pragma mark - Actions
- (IBAction)redraw:(id)sender {
    [_smallCircleChart redrawAnimated:YES completion:NULL];
    if (_circleChart.percents >= .8) {
        [_circleChart redrawAnimated:YES completion:NULL];
    } else {
        [_circleChart updateFromCurrentToPercents:_circleChart.percents+0.1 animated:YES completion:NULL];
    }
}
@end
