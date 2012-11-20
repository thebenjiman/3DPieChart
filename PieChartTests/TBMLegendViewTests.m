//
//  TBMLegendViewTests.m
//  PieChart
//
//  Created by Benjamin DOMERGUE on 20/11/12.
//  Copyright (c) 2012 Benjamin DOMERGUE. All rights reserved.
//

#import "TBMLegendViewTests.h"
#import "TBMLegendView.h"

#import "TBMSlice.h" // For mocking purpose

#import <QuartzCore/QuartzCore.h>
#import <OCMock/OCMock.h>

@interface TBMLegendView (StubbedMethods)

- (CGRect)_titleRect;
- (CATextLayer *)_cleanTextLayer;
- (CAShapeLayer *)_cleanShapeLayer;

@end

@interface TBMLegendView (TestedMethods)

- (void)_addTitle;
- (void)_addLegends;
- (void)_styliseLayer;

- (CALayer *)_chipLayerWithRect:(CGRect)rect color:(UIColor *)color;
- (CATextLayer *)_textLayerWithRect:(CGRect)rect name:(NSString *)name;

@end

@implementation TBMLegendViewTests

- (void)setUp
{
	_legendView = [[TBMLegendView alloc] initWithFrame:CGRectNull];
	_legendViewMock = [OCMockObject partialMockForObject:_legendView];
}

- (void)tearDown
{
	[_legendView release];
}

- (void)testDrawRect
{
	[[_legendViewMock expect] _addTitle];
	[[_legendViewMock expect] _addLegends];
	[[_legendViewMock expect] _styliseLayer];
	
	[_legendView drawRect:CGRectNull];
	
	[_legendViewMock verify];
}

#define FAKE_NAME @"FakeName"
#define FAKE_RECT CGRectMake(5,5,-10,30)

- (void)testAddTitle
{
	CGRect fakeTitleRect = FAKE_RECT;
	// Cannot stub this, test will crash if titleRect is stubbed
	//[[[_legendViewMock stub] andReturnValue:OCMOCK_VALUE(fakeTitleRect)] _titleRect];
	
	[[[_legendViewMock expect] andReturn:FAKE_NAME] title];
	
	id titleLayerMock = [OCMockObject niceMockForClass:[CATextLayer class]];
	[[[_legendViewMock expect] andReturn:titleLayerMock] _textLayerWithRect:fakeTitleRect name:FAKE_NAME];
	[[titleLayerMock expect] setFontSize:26];
	
	
	id legendViewLayerMock = [OCMockObject niceMockForClass:[CALayer class]];
	[[[_legendViewMock expect] andReturn:legendViewLayerMock] layer];
	[[legendViewLayerMock expect] addSublayer:titleLayerMock];
	
	[_legendView _addTitle];
	
	[titleLayerMock verify];
	[_legendViewMock verify];
	[legendViewLayerMock verify];
}


- (void)testAddLegends
{
	TBMSlice *fakeSlice = [TBMSlice sliceWithColor:[UIColor blackColor] percentage:50 name:@"FakeName1"];
	TBMSlice *fakeSlice2 = [TBMSlice sliceWithColor:[UIColor whiteColor] percentage:15 name:@"FakeName2"];
	
	id legendLayerMock = [OCMockObject niceMockForClass:[CALayer class]];
	[[[_legendViewMock stub] andReturn:legendLayerMock] layer];
	
	[[[_legendViewMock stub] andReturn:[NSArray arrayWithObjects:fakeSlice, fakeSlice2, nil]] slices];
	
	[[legendLayerMock expect] addSublayer:OCMOCK_ANY]; // first chip
	[[legendLayerMock expect] addSublayer:OCMOCK_ANY]; // legend 1
	
	[[legendLayerMock expect] addSublayer:OCMOCK_ANY]; // second chip
	[[legendLayerMock expect] addSublayer:OCMOCK_ANY]; // legend 2
	
	[_legendView _addLegends];
	
	[legendLayerMock verify];
}

- (void)testStyliseLayer
{
	id legendLayerMock = [OCMockObject niceMockForClass:[CALayer class]];
	[[[_legendViewMock stub] andReturn:legendLayerMock] layer];
	
	[[legendLayerMock expect] setCornerRadius:5.];
	[[legendLayerMock expect] setBorderColor:[UIColor whiteColor].CGColor];
	[[legendLayerMock expect] setBorderWidth:2.];
	
	[_legendView _styliseLayer];
	
	[legendLayerMock verify];
}

- (void)testChipLayerWithRectColor
{
	id shapeLayerMock = [OCMockObject niceMockForClass:[CAShapeLayer class]];
	[[[_legendViewMock expect] andReturn:shapeLayerMock] _cleanShapeLayer];
	
	[[shapeLayerMock expect] setPath:[OCMArg anyPointer]];
	[[shapeLayerMock expect] setFillColor:[UIColor blackColor].CGColor];
	[[shapeLayerMock expect] setStrokeColor:[UIColor whiteColor].CGColor];
	[[shapeLayerMock expect] setLineWidth:1.];
	
	CALayer *chipLayer = [_legendView _chipLayerWithRect:FAKE_RECT color:[UIColor blackColor]];
	STAssertEqualObjects(chipLayer, shapeLayerMock, @"The shape layer should have been returned");
	
	[shapeLayerMock verify];
	[_legendViewMock verify];
}

- (void)testTextLayerWithRectName
{
	id textLayerMock = [OCMockObject niceMockForClass:[CATextLayer class]];
	[[[_legendViewMock expect] andReturn:textLayerMock] _cleanTextLayer];
	
	[[textLayerMock expect] setFrame:FAKE_RECT];
	[[textLayerMock expect] setForegroundColor:[UIColor whiteColor].CGColor];
	[[textLayerMock expect] setString:FAKE_NAME];
	[[textLayerMock expect] setFontSize:12.];
	
	CALayer *textLayer = [_legendView _textLayerWithRect:FAKE_RECT name:FAKE_NAME];
	STAssertEqualObjects(textLayer, textLayerMock, @"The text layer should have been returned");
	
	[textLayerMock verify];
	[_legendViewMock verify];
}

@end
