//
//  TBMLegendView.h
//  PieChart
//
//  Created by Benjamin DOMERGUE on 17/11/12.
//  Copyright (c) 2012 Benjamin DOMERGUE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TBMLegendView : UIView
{
	NSArray *_slices;
	NSString *_title;
}
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSArray *slices;

@end
