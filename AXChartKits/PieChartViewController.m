//
//  PieChartViewController.m
//  AXChartKits
//
//  Created by ai on 15/12/30.
//  Copyright © 2015年 AiXing. All rights reserved.
//

#import "PieChartViewController.h"
#import "AXPieChartView.h"

@interface PieChartViewController ()
@property(weak, nonatomic) IBOutlet AXPieChartView *pieChart;
@end

@implementation PieChartViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_pieChart addParts:AXPCPCreate(@"Android", [UIColor colorWithRed:77.0 / 255.0 green:216.0 / 255.0 blue:122.0 / 255.0 alpha:1.0f], @0.14),
                        AXPCPCreate(@"WWDC", [UIColor colorWithRed:77.0 / 255.0 green:196.0 / 255.0 blue:122.0 / 255.0 alpha:1.0f], @0.29),
                        AXPCPCreate(@"GOOG I/O", [UIColor colorWithRed:77.0 / 255.0 green:176.0 / 255.0 blue:122.0 / 255.0 alpha:1.0f], @0.47),
                        nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_pieChart redrawAnimated:YES completion:^{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [_pieChart appendPart:AXPCPCreate(@"APPLE", [UIColor colorWithRed:97.0 / 255.0 green:196.0 / 255.0 blue:142.0 / 255.0 alpha:1.0f], @.1) animated:YES];
            });
        }];
    });
    _pieChart.maxAllowedOffsets = 20;
    _pieChart.hollowRadius = 80;
}

#pragma mark - Actions
- (IBAction)redraw:(id)sender {
    [_pieChart redrawAnimated:YES completion:NULL];
}
@end