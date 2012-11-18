//
//  TBMViewController.m
//  PieChart
//
//  Created by Benjamin DOMERGUE on 17/11/12.
//  Copyright (c) 2012 Benjamin DOMERGUE. All rights reserved.
//

#import "TBMViewController.h"

#import "TBMChartView.h"
#import "TBMLegendView.h"

#import "TBMSlice.h"

@interface TBMViewController (Private)

- (NSArray *)_demoSlices;
- (TBMChartView *)_chartView;
- (TBMLegendView *)_legendView;

@end

@implementation TBMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.view.backgroundColor = [UIColor blackColor];
	
	TBMChartView *chartView = [self _chartView];
	[self.view addSubview:chartView];
	
	TBMLegendView *legendView = [self _legendView];
	[self.view addSubview:legendView];
	legendView.title = @"Dummy datas";
	
	NSArray *slices = [self _demoSlices];
	chartView.slices = slices;
	legendView.slices = slices;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

@implementation TBMViewController (Private)

- (NSArray *)_demoSlices
{
	TBMSlice *firstSlice = [TBMSlice sliceWithColor:[UIColor redColor] percentage:25. name:@"Part 1"];
	TBMSlice *secondSlice = [TBMSlice sliceWithColor:[UIColor blueColor] percentage:8. name:@"Part 2"];
	TBMSlice *thirdSlice = [TBMSlice sliceWithColor:[UIColor yellowColor] percentage:12. name:@"Part 3"];
	TBMSlice *fourthSlice = [TBMSlice sliceWithColor:[UIColor greenColor] percentage:35. name:@"Part 4"];
	TBMSlice *lastSlice = [TBMSlice sliceWithColor:[UIColor whiteColor] percentage:20. name:@"Part 5"];
	
	return [NSArray arrayWithObjects:firstSlice, secondSlice, thirdSlice, fourthSlice, lastSlice, nil];
}

- (TBMChartView *)_chartView
{
	CGRect viewFrame = CGRectMake(0., 25., self.view.frame.size.width, self.view.frame.size.width);
	TBMChartView *chart = [[TBMChartView alloc] initWithFrame:viewFrame];
	return [chart autorelease];
}

- (TBMLegendView *)_legendView
{
	CGRect legendFrame = CGRectMake(0., self.view.frame.size.width - 25., self.view.frame.size.width, self.view.frame.size.height - self.view.frame.size.width - 100);
	TBMLegendView *legend = [[TBMLegendView alloc] initWithFrame:legendFrame];
	return [legend autorelease];
}

@end
