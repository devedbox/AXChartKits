//
//  ChartViewController.m
//  AXChartKits
//
//  Created by devedbox on 16/8/18.
//  Copyright © 2016年 AiXing. All rights reserved.
//

#import "ChartViewController.h"
#import "AXChartKits/AXChartView.h"

@interface ChartViewController ()
/// Chart view.
@property(weak, nonatomic) IBOutlet AXChartView *chartView;
@end

@implementation ChartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
