//
//  AXChartView.h
//  AXChartKits
//
//  Created by devedbox on 16/8/18.
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

#import "AXChartBase.h"

@interface AXChartView : AXChartBase
/// Background end color.
///
/// @discusstion Background color begin with `backgroundColor` and end with `backgroundEndColor`. Background will be gradiented if `backgroundColor` and `backgroundEndColor` are both coloured, and will be single color if any one of `backgroundColor` and `backgroundEndColor` is coloured.
/// Default is begin with orange and end with red.
@property(strong, nonatomic) UIColor *backgroundEndColor;
/// Content insets.
@property(assign, nonatomic) UIEdgeInsets contentInsets;
@end
