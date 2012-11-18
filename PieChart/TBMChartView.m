//
//  TBMChartView.m
//  PieChart
//
//  Created by Benjamin DOMERGUE on 17/11/12.
//  Copyright (c) 2012 Benjamin DOMERGUE. All rights reserved.
//

#import "TBMChartView.h"
#import "TBMSlice.h"

#import <QuartzCore/QuartzCore.h>

#define MARGIN 30.
#define GRADIENT_ALPHA .3
#define SHADOW_OFFSET 40.

#define LAYER_FLAT_TRANSFORM .6
#define LAYER_REPLACE_TRANSFORM -50.

#define DEGREES_TO_RADIANS(angle) angle * M_PI/180.0

@interface TBMChartView (Private)

- (void)_addSlicesLayers;

@end

@interface TBMChartView (Drawing)

-(CGPathRef)_slicePathWithStartAngle:(CGFloat)degStartAngle endAngle:(CGFloat)degEndAngle;
-(CALayer *)_sliceLayerWithStartAngle:(CGFloat)start endAngle:(CGFloat)end color:(UIColor *)color;

-(CGPathRef)_shadowPathWithStartAngle:(CGFloat)degStartAngle endAngle:(CGFloat)degEndAngle;
-(CALayer *)_shadowLayerWithStartAngle:(CGFloat)start endAngle:(CGFloat)end color:(UIColor *)color;

- (void)_styliseLayer;

@end

@implementation TBMChartView
@synthesize slices = _slices;

- (id)initWithFrame:(CGRect)frame
{
    if((self = [super initWithFrame:frame]))
	{
		CGSize drawingSize = CGSizeMake(frame.size.width - MARGIN * 2, frame.size.width - MARGIN * 2);
		_center = CGPointMake(drawingSize.width / 2 + MARGIN, drawingSize.height / 2 + MARGIN);
		_radius = drawingSize.width / 2;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
	[self _addSlicesLayers];
	[self _styliseLayer];
}

@end

@implementation TBMChartView (Private)

- (void)_addSlicesLayers
{
	CGFloat lastSliceAngle = .0;
	for(TBMSlice *slice in self.slices)
	{
		CGFloat sliceAngle = 360 * slice.percentage / 100;
		CGFloat sliceAngleEnd = (lastSliceAngle + sliceAngle);
		
		CALayer *sliceLayer = [self _sliceLayerWithStartAngle:lastSliceAngle endAngle:sliceAngleEnd color:slice.color];
		if((lastSliceAngle >= 0 && lastSliceAngle <= 180) || (sliceAngleEnd > 0 && sliceAngleEnd < 180))
		{
			CALayer *shadowLayer = [self _shadowLayerWithStartAngle:lastSliceAngle endAngle:sliceAngleEnd color:slice.color];
			[self.layer addSublayer:shadowLayer];
		}
		
		[self.layer addSublayer:sliceLayer];
		lastSliceAngle += sliceAngle;
	}
}

@end

@implementation TBMChartView (Drawing)

-(CGPathRef)_slicePathWithStartAngle:(CGFloat)degStartAngle endAngle:(CGFloat)degEndAngle
{
	UIBezierPath *piePath = [UIBezierPath bezierPath];
	[piePath moveToPoint:_center];
	
	CGPoint sliceStart = CGPointMake(_center.x + _radius * cosf(DEGREES_TO_RADIANS(degStartAngle)), _center.y + _radius * sinf(DEGREES_TO_RADIANS(degStartAngle)));
	[piePath addLineToPoint:sliceStart];
	
	[piePath addArcWithCenter:_center radius:_radius startAngle:DEGREES_TO_RADIANS(degStartAngle) endAngle:DEGREES_TO_RADIANS(degEndAngle) clockwise:YES];
	
	[piePath closePath];
	
	return piePath.CGPath;
}

-(CALayer *)_sliceLayerWithStartAngle:(CGFloat)start endAngle:(CGFloat)end color:(UIColor *)color
{
	CGPathRef slicePath = [self _slicePathWithStartAngle:start endAngle:end];
	
	CAShapeLayer *slice = [CAShapeLayer layer];
	slice.path = slicePath;
	
	CAGradientLayer *gradientLayer = [CAGradientLayer layer];
	gradientLayer.startPoint = CGPointMake(.0, .0);
	gradientLayer.endPoint = CGPointMake(1., 1.);
	gradientLayer.frame = CGRectMake(.0, .0, self.frame.size.width, self.frame.size.height);
	
	CGColorRef startColor = [color CGColor];
	CGColorRef endColor = CGColorCreateCopyWithAlpha(startColor, GRADIENT_ALPHA);
	gradientLayer.colors = [NSArray arrayWithObjects:(id)startColor, endColor, nil];
	[gradientLayer setMask:slice];
	CFRelease(endColor);
	
	return gradientLayer;
}

-(CGPathRef)_shadowPathWithStartAngle:(CGFloat)degStartAngle endAngle:(CGFloat)degEndAngle
{
	if(degEndAngle > 180.)
	{
		degEndAngle = 180.;
	}
		
	CGPoint shadowCenter = CGPointMake(_center.x, _center.y + SHADOW_OFFSET);
	
	UIBezierPath *shadowPath = [UIBezierPath bezierPath];
	
	CGPoint sliceStart = CGPointMake(_center.x + _radius * cosf(DEGREES_TO_RADIANS(degStartAngle)), _center.y + _radius * sinf(DEGREES_TO_RADIANS(degStartAngle)));
	[shadowPath moveToPoint:sliceStart];
	
	CGPoint shadowStart = CGPointMake(sliceStart.x, sliceStart.y + SHADOW_OFFSET);
	[shadowPath addLineToPoint:shadowStart];
	
	[shadowPath addArcWithCenter:shadowCenter radius:_radius startAngle:DEGREES_TO_RADIANS(degStartAngle) endAngle:DEGREES_TO_RADIANS(degEndAngle) clockwise:YES];
	
	CGPoint sliceEnd = CGPointMake(shadowPath.currentPoint.x, shadowPath.currentPoint.y - SHADOW_OFFSET);
	[shadowPath addLineToPoint:sliceEnd];
	
	[shadowPath addArcWithCenter:_center radius:_radius startAngle:DEGREES_TO_RADIANS(degEndAngle) endAngle:DEGREES_TO_RADIANS(degStartAngle) clockwise:NO];
	
	[shadowPath closePath];
	
	return shadowPath.CGPath;
}

-(CALayer *)_shadowLayerWithStartAngle:(CGFloat)start endAngle:(CGFloat)end color:(UIColor *)color
{
	CGPathRef shadowPath = [self _shadowPathWithStartAngle:start endAngle:end];
	
	CAShapeLayer *shadow = [CAShapeLayer layer];
	shadow.path = shadowPath;
	shadow.fillColor = color.CGColor;
	shadow.opacity = .7;
	
	return shadow;
}

- (void)_styliseLayer
{
	CATransform3D scale = CATransform3DMakeScale(1., LAYER_FLAT_TRANSFORM, 1.);
	CATransform3D replace = CATransform3DMakeTranslation(.0, LAYER_REPLACE_TRANSFORM, 0.);
	self.layer.transform = CATransform3DConcat(scale, replace);
}

@end
