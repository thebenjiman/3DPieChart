//
//  TBMSlice.h
//  PieChart
//
//  Created by Benjamin DOMERGUE on 17/11/12.
//  Copyright (c) 2012 Benjamin DOMERGUE. All rights reserved.
//

@interface TBMSlice : NSObject
{
	UIColor *_color;
	CGFloat _percentage;
	NSString *_name;
}
+ (TBMSlice *)sliceWithColor:(UIColor *)color percentage:(CGFloat)percentage name:(NSString *)name;

@property (nonatomic, readonly) UIColor *color;
@property (nonatomic, readonly) CGFloat percentage;
@property (nonatomic, readonly) NSString *name;

@end
