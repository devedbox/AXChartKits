//
//  PieChartViewController.m
//  AXChartKits
//
//  Created by ai on 15/12/30.
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

#import "PieChartViewController.h"
#import "AXPieChartView.h"

@interface PieChartViewController ()
@property(weak, nonatomic) IBOutlet AXPieChartView *pieChart;
@end

@implementation PieChartViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [_pieChart addParts:AXPCPCreate(@"Android", [UIColor colorWithRed:77.0 / 255.0 green:216.0 / 255.0 blue:122.0 / 255.0 alpha:1.0f], @0.14),
//                        AXPCPCreate(@"WWDC", [UIColor colorWithRed:77.0 / 255.0 green:196.0 / 255.0 blue:122.0 / 255.0 alpha:1.0f], @0.29),
//                        AXPCPCreate(@"GOOG I/O", [UIColor colorWithRed:77.0 / 255.0 green:176.0 / 255.0 blue:122.0 / 255.0 alpha:1.0f], @0.47),
//                        nil];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [_pieChart redrawAnimated:YES completion:^{
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                [_pieChart appendPart:AXPCPCreate(@"APPLE", [UIColor colorWithRed:97.0 / 255.0 green:196.0 / 255.0 blue:142.0 / 255.0 alpha:1.0f], @.1) animated:YES];
//            });
//        }];
//    });
    [_pieChart addParts:AXPCPCreate(@"水", [UIColor colorWithRed:0.259 green:0.522 blue:0.957 alpha:1.00], @(371.00)), AXPCPCreate(@"电", [UIColor colorWithRed:0.922 green:0.263 blue:0.208 alpha:1.00], @(234.00)), AXPCPCreate(@"家电", [UIColor colorWithRed:0.984 green:0.741 blue:0.016 alpha:1.00], @(158.50)), AXPCPCreate(@"锁", [UIColor colorWithRed:0.208 green:0.663 blue:0.329 alpha:1.00], @(77.50)), nil];
    _pieChart.maxAllowedOffsets = 20;
    _pieChart.hollowRadius = 80;
}

#pragma mark - Actions
- (IBAction)redraw:(id)sender {
    [_pieChart redrawAnimated:YES completion:NULL];
}
@end