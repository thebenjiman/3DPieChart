//
//  TBMChartView.h
//  PieChart
//
//  Created by Benjamin DOMERGUE on 17/11/12.
//  Copyright (c) 2012 Benjamin DOMERGUE. All rights reserved.
//

#import <UIKit/UIKit.h>

#define DEGREES_TO_RADIANS(angle) angle * M_PI/180.0

@interface TBMChartView : UIView
{
	CGPoint _center;
	CGFloat _radius;
	
	NSArray *_slices;
}
@property (nonatomic, retain) NSArray *slices;

@end
