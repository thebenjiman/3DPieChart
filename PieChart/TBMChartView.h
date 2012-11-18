//
//  TBMChartView.h
//  PieChart
//
//  Created by Benjamin DOMERGUE on 17/11/12.
//  Copyright (c) 2012 Benjamin DOMERGUE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TBMChartView : UIView
{
	CGPoint _center;
	CGFloat _radius;
	
	NSArray *_slices;
}
@property (nonatomic, retain) NSArray *slices;

@end
