//
//  TBMLegendView.m
//  PieChart
//
//  Created by Benjamin DOMERGUE on 17/11/12.
//  Copyright (c) 2012 Benjamin DOMERGUE. All rights reserved.
//

#import "TBMLegendView.h"
#import "TBMSlice.h"

#import <QuartzCore/QuartzCore.h>

#define CHIP_SIZE 15.
#define CHIP_LINE_HEIGHT (CHIP_SIZE + 5.)

//#define DOTS

#ifdef DOTS
#define CHIP_CORNER_RADIUS CHIP_SIZE / 2
#else
#define CHIP_CORNER_RADIUS 2
#endif

#define LEGEND_SPACING 100.

#define TITLE_SIZE 30.

@interface TBMLegendView (Private)

- (void)_addTitle;
- (void)_addLegends;
- (void)_styliseLayer;

@end

@interface TBMLegendView (Drawing)

- (CALayer *)_chipLayerWithRect:(CGRect)rect color:(UIColor *)color;
- (CATextLayer *)_textLayerWithRect:(CGRect)rect name:(NSString *)name;

@end

@implementation TBMLegendView
@synthesize slices = _slices;
@synthesize title = _title;

- (void)drawRect:(CGRect)rect
{
	[self _addTitle];
	[self _addLegends];
	[self _styliseLayer];
}

@end

@implementation TBMLegendView (Private)

- (void)_addTitle
{
	CGRect textRect = CGRectMake(5., 5., self.frame.size.width - 10., TITLE_SIZE);
	CATextLayer *text = [self _textLayerWithRect:textRect name:self.title];
	text.fontSize = 26.;
	[self.layer addSublayer:text];
}

- (void)_addLegends
{
	int currentSlice = 0;
	CGFloat currentLine = 1;
	for(TBMSlice *slice in self.slices)
	{
		CGRect chipRect = CGRectMake(20., TITLE_SIZE + currentLine * CHIP_LINE_HEIGHT, CHIP_SIZE, CHIP_SIZE);
		CGRect textRect = CGRectMake(20. + CHIP_SIZE + 5., TITLE_SIZE + currentLine * CHIP_LINE_HEIGHT, LEGEND_SPACING, CHIP_SIZE);
		if(currentSlice % 2)
		{
			chipRect.origin.x += self.frame.size.width / 2 - CHIP_SIZE;
			textRect.origin.x += self.frame.size.width / 2 - CHIP_SIZE;
		}
		CALayer *chip = [self _chipLayerWithRect:chipRect color:slice.color];
		[self.layer addSublayer:chip];
		
		NSString *text = [NSString stringWithFormat:@"%@ (%.1f %%)", slice.name, slice.percentage];
		CALayer *textLayer = [self _textLayerWithRect:textRect name:text];
		[self.layer addSublayer:textLayer];
		
		if(currentSlice % 2)
		{
			currentLine++;
		}
		currentSlice++;
	}
}

- (void)_styliseLayer
{
	self.layer.cornerRadius = 5.;
	self.layer.borderColor = [UIColor whiteColor].CGColor;
	self.layer.borderWidth = 2.;
}

@end

@implementation TBMLegendView (Drawing)

- (CALayer *)_chipLayerWithRect:(CGRect)rect color:(UIColor *)color
{
	UIBezierPath *chip = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:CHIP_CORNER_RADIUS];
	CAShapeLayer *chipLayer = [CAShapeLayer layer];
	chipLayer.path = chip.CGPath;
	chipLayer.fillColor = color.CGColor;
	chipLayer.strokeColor = [UIColor whiteColor].CGColor;
	chipLayer.lineWidth = 1.;
	return  chipLayer;
}

- (CATextLayer *)_textLayerWithRect:(CGRect)rect name:(NSString *)name
{
	CATextLayer *text = [CATextLayer layer];
	text.frame = rect;
	text.foregroundColor = [UIColor whiteColor].CGColor;
	text.string = name;
	text.fontSize = 12.;
	return text;
}

@end
