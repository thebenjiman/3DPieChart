//
//  TBMChartViewTests.m
//  PieChart
//
//  Created by Benjamin DOMERGUE on 19/11/12.
//  Copyright (c) 2012 Benjamin DOMERGUE. All rights reserved.
//

#import "TBMChartViewTests.h"
#import "TBMChartView.h"

#import "TBMSlice.h" // For mocking purpose

#import <QuartzCore/QuartzCore.h>
#import <OCMock/OCMock.h>

@interface TBMChartView (TestFacilities)

- (void)setCenter:(CGPoint)center;
- (void)setRadius:(CGFloat)radius;

@end

@implementation TBMChartView (TestFacilities)

- (void)setCenter:(CGPoint)center
{
	_center = center;
}

- (void)setRadius:(CGFloat)radius
{
	_radius = radius;
}

@end

@interface TBMChartView (StubbedMethods)

- (CAGradientLayer *)_cleanGradientLayer;
- (CAShapeLayer *)_cleanShapeLayer;
- (UIBezierPath *)_cleanBezierPath;

- (CGPoint)_sliceStartWithAngle:(CGFloat)angle;

@end

@interface TBMChartView (TestedMethods)

- (void)_addSlicesLayers;
- (void)_styliseLayer;

-(CGPathRef)_slicePathWithStartAngle:(CGFloat)degStartAngle endAngle:(CGFloat)degEndAngle;
-(CALayer *)_sliceLayerWithStartAngle:(CGFloat)start endAngle:(CGFloat)end color:(UIColor *)color;

-(CGPathRef)_shadowPathWithStartAngle:(CGFloat)degStartAngle endAngle:(CGFloat)degEndAngle;
-(CALayer *)_shadowLayerWithStartAngle:(CGFloat)start endAngle:(CGFloat)end color:(UIColor *)color;

@end

@implementation TBMChartViewTests

- (void)setUp
{
	_chartView = [[TBMChartView alloc] initWithFrame:CGRectNull];
	_chartViewMock = [OCMockObject partialMockForObject:_chartView];
}

- (void)tearDown
{
	[_chartView release];
}

- (void)testDrawRect
{
	[[_chartViewMock expect] _addSlicesLayers];
	[[_chartViewMock expect] _styliseLayer];
	
	[_chartView drawRect:CGRectNull];
	
	[_chartViewMock verify];
}

- (void)testAddSlicesLayers
{
	TBMSlice *fakeSlice = [TBMSlice sliceWithColor:[UIColor blackColor] percentage:50 name:@"FakeName"];
	TBMSlice *fakeSliceWithoutShadow = [TBMSlice sliceWithColor:[UIColor whiteColor] percentage:15 name:@"FakeName"];
	
	id chartViewLayerMock = [OCMockObject niceMockForClass:[CALayer class]];
	[[[_chartViewMock stub] andReturn:chartViewLayerMock] layer];
	
	[[[_chartViewMock stub] andReturn:[NSArray arrayWithObjects:fakeSlice, fakeSliceWithoutShadow, nil]] slices];
	
	// First slice
	id fakeSliceLayer = [OCMockObject niceMockForClass:[CALayer class]];
	[[[_chartViewMock expect] andReturn:fakeSliceLayer] _sliceLayerWithStartAngle:0. endAngle:180. color:[UIColor blackColor]];
	
	// First slice's shadow
	id fakeSliceLayerShadow = [OCMockObject niceMockForClass:[CALayer class]];
	[[[_chartViewMock expect] andReturn:fakeSliceLayerShadow] _shadowLayerWithStartAngle:.0 endAngle:180. color:[UIColor blackColor]];
	[[chartViewLayerMock expect] addSublayer:fakeSliceLayer];
	[[chartViewLayerMock expect] addSublayer:fakeSliceLayerShadow];
	
	// Seconde slice
	id fakeSliceWithoutShadowLayer = [OCMockObject niceMockForClass:[CALayer class]];
	[[[_chartViewMock expect] andReturn:fakeSliceWithoutShadowLayer] _sliceLayerWithStartAngle:180. endAngle:234. color:[UIColor whiteColor]];
	[[_chartViewMock reject] _shadowLayerWithStartAngle:180. endAngle:234. color:[UIColor whiteColor]];
	[[chartViewLayerMock expect] addSublayer:fakeSliceWithoutShadowLayer];
	
	// Trigger
	[_chartView _addSlicesLayers];
	
	// Verify
	[chartViewLayerMock verify];
	[_chartViewMock verify];
}

#define FAKE_CENTER CGPointMake(1., 1.)
#define FAKE_START CGPointMake(2., 2.)
#define FAKE_RADIUS 2.

- (void)testSlicePathWithStartAngleEndAngle
{
	[_chartView setCenter:FAKE_CENTER];
	[_chartView setRadius:FAKE_RADIUS];
	
	CGPoint fakeStart = FAKE_START;
	
	id bezierPathMock = [OCMockObject niceMockForClass:[UIBezierPath class]];
	[[[_chartViewMock expect] andReturn:bezierPathMock] _cleanBezierPath];
	[[[_chartViewMock expect] andReturnValue:OCMOCK_VALUE(fakeStart)] _sliceStartWithAngle:0];
	
	[[bezierPathMock expect] moveToPoint:FAKE_CENTER];
	[[bezierPathMock expect] addLineToPoint:fakeStart];
	[[bezierPathMock expect] addArcWithCenter:FAKE_CENTER radius:FAKE_RADIUS startAngle:DEGREES_TO_RADIANS(0) endAngle:DEGREES_TO_RADIANS(1) clockwise:YES];
	[[bezierPathMock expect] closePath];
	
	[[bezierPathMock expect] CGPath];
	
	[_chartView _slicePathWithStartAngle:0 endAngle:1];
	
	[bezierPathMock verify];
	[_chartViewMock verify];
}

- (void)testSliceLayerWithStartAngleEndAngleColor
{
	//CGPathRef fakePath = [UIBezierPath bezierPath].CGPath;
	//[[[_chartViewMock expect] andReturn:fakePath] _slicePathWithStartAngle:0. endAngle:1.];
	[[_chartViewMock expect] _slicePathWithStartAngle:0. endAngle:1.];
	
	id sliceLayerMock = [OCMockObject niceMockForClass:[CAShapeLayer class]];
	[[[_chartViewMock expect] andReturn:sliceLayerMock] _cleanShapeLayer];
	//[[sliceLayerMock expect] setPath:fakePath];
	[[sliceLayerMock expect] setPath:[OCMArg anyPointer]];
	
	id gradientLayerMock = [OCMockObject niceMockForClass:[CAGradientLayer class]];
	[[[_chartViewMock expect] andReturn:gradientLayerMock] _cleanGradientLayer];
	[[gradientLayerMock expect] setMask:sliceLayerMock];
	
	CALayer *layer = [_chartView _sliceLayerWithStartAngle:0. endAngle:1. color:[UIColor blackColor]];
	STAssertEqualObjects(layer, gradientLayerMock, @"Wrong layer returned");
	
	[_chartViewMock verify];
	[gradientLayerMock verify];
	[sliceLayerMock verify];
}

#define SHADOW_OFFSET 40.
#define FAKE_SHADOW_END CGPointMake(4., 4.)

- (void)testShadowPathWithStartAngleEndAngle
{
	CGPoint fakeCenter = FAKE_CENTER;
	[_chartView setCenter:fakeCenter];
	[_chartView setRadius:FAKE_RADIUS];
	
	CGPoint fakeStart = FAKE_START;
	CGPoint shadowStart = CGPointMake(fakeStart.x, fakeStart.y + SHADOW_OFFSET);
	CGPoint shadowCenter = CGPointMake(fakeCenter.x, fakeCenter.y + SHADOW_OFFSET);
	
	id bezierPathMock = [OCMockObject niceMockForClass:[UIBezierPath class]];
	[[[_chartViewMock expect] andReturn:bezierPathMock] _cleanBezierPath];
	[[[_chartViewMock expect] andReturnValue:OCMOCK_VALUE(fakeStart)] _sliceStartWithAngle:0];
	
	[[bezierPathMock expect] moveToPoint:fakeStart];
	
	[[bezierPathMock expect] addLineToPoint:shadowStart];
	
	[[bezierPathMock expect] addArcWithCenter:shadowCenter radius:FAKE_RADIUS startAngle:DEGREES_TO_RADIANS(0) endAngle:DEGREES_TO_RADIANS(1) clockwise:YES];
	
	CGPoint fakeEnd = FAKE_SHADOW_END;
	[[[bezierPathMock expect] andReturnValue:OCMOCK_VALUE(fakeEnd)] currentPoint];
	[[bezierPathMock expect] addLineToPoint:CGPointMake(fakeEnd.x, fakeEnd.y - SHADOW_OFFSET)];
	
	[[bezierPathMock expect] addArcWithCenter:FAKE_CENTER radius:FAKE_RADIUS startAngle:DEGREES_TO_RADIANS(1) endAngle:DEGREES_TO_RADIANS(0) clockwise:NO];
	
	[[bezierPathMock expect] closePath];
	
	[[bezierPathMock expect] CGPath];
	
	[_chartView _shadowPathWithStartAngle:0 endAngle:1];
	
	[bezierPathMock verify];
	[_chartViewMock verify];
}

- (void)testShadowLayerWithStartAngleEndAngleColor
{
	[[_chartViewMock expect] _shadowPathWithStartAngle:0. endAngle:1.];
	
	id shadowLayerMock = [OCMockObject niceMockForClass:[CAShapeLayer class]];
	[[[_chartViewMock expect] andReturn:shadowLayerMock] _cleanShapeLayer];
	[[shadowLayerMock expect] setPath:[OCMArg anyPointer]];
	[[shadowLayerMock expect] setFillColor:[UIColor blackColor].CGColor];
	[[shadowLayerMock expect] setOpacity:.7];
	
	CALayer *layer = [_chartView _shadowLayerWithStartAngle:0. endAngle:1. color:[UIColor blackColor]];
	STAssertEqualObjects(layer, shadowLayerMock, @"Wrong layer returned");
	
	[shadowLayerMock verify];
	[_chartViewMock verify];
}

@end
