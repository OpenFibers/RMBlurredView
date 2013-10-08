//
//  NSBlurredView.m
//
//  Created by Raffael Hannemann on 08.10.13.
//  Copyright (c) 2013 Raffael Hannemann. All rights reserved.
//

#import "NSBlurredView.h"

#define kNSBlurredViewDefaultTintColor [NSColor colorWithCalibratedWhite:1.0 alpha:0.7]
#define kNSBlurredViewDefaultSaturationFactor 2.0
#define kNSBlurredViewDefaultBlurRadius 20.0

@implementation NSBlurredView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		[self setUp];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setUp];
    }
    return self;
}

- (void) setTintColor:(NSColor *)tintColor {
	_tintColor = tintColor;
	
	// Since we need a CGColor reference, store it for the drawing of the layer.
	if (_tintColor) {
		[self.layer setBackgroundColor:_tintColor.CGColor];
	}
	
	// Trigger a re-drawing of the layer
	[self.layer setNeedsDisplay];
}

- (void) setBlurRadius:(float)blurRadius {
	// Setting the blur radius requires a resetting of the filters
	_blurRadius = blurRadius;
	[self resetFilters];
}

- (void) setSaturationFactor:(float)saturationFactor {
	// Setting the saturation factor also requires a resetting of the filters
	_saturationFactor = saturationFactor;
	[self resetFilters];
}

- (void) setUp {
	// Instantiate a new CALayer and set it as the NSView's layer
	CALayer *blurLayer = [CALayer layer];
	[self setWantsLayer:YES];
	[self setLayer:blurLayer];
	
	// Set up the default parameters
	_blurRadius = kNSBlurredViewDefaultBlurRadius;
	_saturationFactor = kNSBlurredViewDefaultSaturationFactor;
	[self setTintColor:kNSBlurredViewDefaultTintColor];
	
	// It's important to set the layer to mask to its bounds, otherwise the whole parent view might get blurred
	[self.layer setMasksToBounds:YES];
	
	// Set the layer to redraw itself once it's size is changed
	[self.layer setNeedsDisplayOnBoundsChange:YES];
	
	// Initially create the filter instances
	[self resetFilters];
}

- (void) resetFilters {
	
	// To get a higher color saturation, we create a ColorControls filter
	_saturationFilter = [CIFilter filterWithName:@"CIColorControls"];
	[_saturationFilter setDefaults];
	[_saturationFilter setValue:[NSNumber numberWithFloat:_saturationFactor] forKey:@"inputSaturation"];
	
	// Next, we create the blur filter
	_blurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
	[_blurFilter setDefaults];
	[_blurFilter setValue:[NSNumber numberWithFloat:_blurRadius] forKey:@"inputRadius"];
	
	// Now we apply the two filters as the layer's background filters
	[self.layer setBackgroundFilters:@[_saturationFilter,_blurFilter]];
	
	// ... and trigger a refresh
	[self.layer setNeedsDisplay];
}

@end