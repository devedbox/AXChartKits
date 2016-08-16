//
//  BarChartViewController.m
//  AXChartKits
//
//  Created by devedbox on 16/8/15.
//  Copyright © 2016年 AiXing. All rights reserved.
//

#import "BarChartViewController.h"
#import "AXBarChartCell.h"

@interface BarChartViewController ()
/// Cell0.
@property(weak, nonatomic) IBOutlet AXBarChartCell *cell0;
/// Cell1.
@property(weak, nonatomic) IBOutlet AXBarChartCell *cell1;
/// Cell2.
@property(weak, nonatomic) IBOutlet AXBarChartCell *cell2;
@end

@implementation BarChartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _cell0.direction = AXBarChartCellVertical;
    _cell1.direction = AXBarChartCellHorizontal;
    _cell2.layer.cornerRadius = 6.0;
    _cell2.layer.masksToBounds = YES;
    
    _cell1.cornerRadius = 12;
    _cell0.cornerRadius = 12;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_cell0 updateToValue:1.0 animated:YES completion:NULL];
        [_cell1 updateToValue:0.9 animated:YES completion:NULL];
        [_cell2 updateToValue:0.8 animated:YES completion:NULL];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)draw:(id)sender {
    [self redrawing0:sender];
    [self redrawing1:sender];
    [self redrawing2:sender];
}

- (IBAction)redrawing0:(id)sender {
    [_cell0 redrawAnimated:YES completion:NULL];
}

- (IBAction)redrawing1:(id)sender {
    [_cell1 redrawAnimated:YES completion:NULL];
}

- (IBAction)redrawing2:(id)sender {
    [_cell2 redrawAnimated:YES completion:NULL];
}

- (IBAction)change:(UISegmentedControl *)sender {
    _cell0.style = sender.selectedSegmentIndex;
    _cell1.style = sender.selectedSegmentIndex;
    [self draw:nil];
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
