//
//  ViewController.m
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

#import "LineChartViewController.h"
#import "AXLineChartCell.h"

@interface LineChartViewController ()
@property(weak, nonatomic) IBOutlet AXLineChartCell *lineChart;
@property(weak, nonatomic) IBOutlet AXLineChartCell *lineChart2;
@property(weak, nonatomic) IBOutlet AXLineChartCell *lineChart1;
@end

@implementation LineChartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _lineChart1.startLocation = 0.8;
    _lineChart1.endLocation = 0.2;
    _lineChart1.lineWidth = 2.0;
    _lineChart1.isBeginning = YES;
    _lineChart1.shouldShowDashAtStart = YES;
    _lineChart1.shouldShowDashAtEnd = YES;
    _lineChart1.tintColor = [UIColor colorWithRed:0.0 / 255.0 green:171.0 / 255.0 blue:243.0 / 255.0 alpha:1.0];
    _lineChart.startLocation = 0.2;
    _lineChart.endLocation = 0.8;
    _lineChart.lineWidth = 2.0;
    _lineChart.tintColor = [UIColor colorWithRed:0.0 / 255.0 green:171.0 / 255.0 blue:243.0 / 255.0 alpha:1.0];
    _lineChart.shouldShowDashAtEnd = YES;
//    _lineChart.shouldShowDashAtStart = YES;
//    _lineChart.startOffsets = 20;
//    _lineChart.endOffsets = 20;
//    _lineChart.drawingDirection = AXLineChartDrawingVertical;
    _lineChart2.startLocation = 0.8;
    _lineChart2.endLocation = 0.3;
    _lineChart2.lineWidth = 2.0;
    _lineChart2.isEnding = YES;
    _lineChart2.tintColor = [UIColor colorWithRed:0.0 / 255.0 green:171.0 / 255.0 blue:243.0 / 255.0 alpha:1.0];
    _lineChart2.shouldShowDashAtEnd = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_lineChart1 redrawAnimated:YES reverse:NO duration:0.5 curve:UIViewAnimationCurveLinear completion:^{
            [_lineChart redrawAnimated:YES reverse:NO duration:0.5 curve:UIViewAnimationCurveLinear completion:^{
                [_lineChart2 redrawAnimated:YES reverse:NO duration:0.5 curve:UIViewAnimationCurveLinear completion:NULL];
            }];
        }];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions
- (IBAction)redraw:(id)sender {
    _lineChart.visible = NO;
    _lineChart1.visible = NO;
    _lineChart2.visible = NO;
    [_lineChart1 redrawAnimated:YES reverse:NO duration:0.5 curve:UIViewAnimationCurveLinear completion:^{
        [_lineChart redrawAnimated:YES reverse:NO duration:0.5 curve:UIViewAnimationCurveLinear completion:^{
            [_lineChart2 redrawAnimated:YES reverse:NO duration:0.5 curve:UIViewAnimationCurveLinear completion:NULL];
        }];
    }];
}

- (IBAction)reverse:(id)sender {
    _lineChart.visible = NO;
    _lineChart1.visible = NO;
    _lineChart2.visible = NO;
    [_lineChart2 redrawAnimated:YES reverse:YES duration:0.5 curve:UIViewAnimationCurveLinear completion:^{
        [_lineChart redrawAnimated:YES reverse:YES duration:0.5 curve:UIViewAnimationCurveLinear completion:^{
            [_lineChart1 redrawAnimated:YES reverse:YES duration:0.5 curve:UIViewAnimationCurveLinear completion:NULL];
        }];
    }];
}

- (IBAction)concurrent:(id)sender {
    _lineChart.visible = NO;
    _lineChart1.visible = NO;
    _lineChart2.visible = NO;
    [_lineChart redrawAnimated:YES reverse:NO duration:0.5 curve:UIViewAnimationCurveLinear completion:NULL];
    [_lineChart1 redrawAnimated:YES reverse:NO duration:0.5 curve:UIViewAnimationCurveLinear completion:NULL];
    [_lineChart2 redrawAnimated:YES reverse:NO duration:0.5 curve:UIViewAnimationCurveLinear completion:NULL];
}
@end
