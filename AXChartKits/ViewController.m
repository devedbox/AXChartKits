//
//  ViewController.m
//  AXChartKits
//
//  Created by ai on 15/12/28.
//  Copyright © 2015年 AiXing. All rights reserved.
//

#import "ViewController.h"
#import "AXLineChart.h"

@interface ViewController ()
@property(weak, nonatomic) IBOutlet AXLineChart *lineChart;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _lineChart.startLocation = 0.4;
    _lineChart.endLocation = 0.6;
    _lineChart.tintColor = [UIColor grayColor];
    _lineChart.lineWidth = 3.0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
