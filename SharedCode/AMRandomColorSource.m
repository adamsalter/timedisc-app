//
//  AMRandomColorSource.m
//  TimeDisc
//
//  Created by Andreas on Wed Nov 13 2002.
//  Copyright (c) 2002 Andreas Mayer. All rights reserved.
//

#import "AMRandomColorSource.h"

#define BitmapWidth 100
#define BitmapHeight 100

#define DEG2RAD  0.017453292519943295


int randomInt(u)
{
	int r = rand();
	return (r<0) ? -r%u : r%u;
}

@interface AMRandomColorSource (Private)
- (void)_setBitmapRep:(NSBitmapImageRep *)newBitmapRep;
@end

@implementation AMRandomColorSource

- (void)initialize
{
	srand(time(0));
}

- (id)init
{
	_bitmapRep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:nil pixelsWide:BitmapWidth pixelsHigh:BitmapHeight bitsPerSample:8 samplesPerPixel:3 hasAlpha:NO isPlanar:NO colorSpaceName:NSCalibratedRGBColorSpace bytesPerRow:0 bitsPerPixel:24];
	_bitmapImage = [[NSImage alloc] init];
	[_bitmapImage setSize:NSMakeSize(BitmapWidth, BitmapHeight)];
	[_bitmapImage addRepresentation:_bitmapRep];
    _bitmapPtr = [_bitmapRep bitmapData];
	return self;
}

- (id)initWithColorMap
{
	int x, y, offset;
	float r, g, b;
	NSColor *color;
	
	[self init];
    //_bitmapPtr = [_bitmapRep bitmapData];
	for(y=0; y<BitmapHeight; y++) {
		for(x=0; x<BitmapWidth; x++) {
			if (x<BitmapWidth/2) { // brightness
				color = [NSColor colorWithCalibratedHue:((float)y/BitmapHeight) saturation:0.999 brightness:(2.0*x/BitmapWidth) alpha:nil];
			} else { // saturation
				color = [NSColor colorWithCalibratedHue:((float)y/BitmapHeight) saturation:((BitmapWidth-2.0*(x-BitmapWidth/2.0))/BitmapWidth) brightness:0.999 alpha:nil];
			}
			[color getRed:&r green:&g blue:&b alpha:nil];
			offset = 3*(y*(int)BitmapWidth+x);
			_bitmapPtr[offset++]=256*r;
			_bitmapPtr[offset++]=256*g;
			_bitmapPtr[offset]=256*b;
		}
	}
	return self;
}

- (id)initWithImage:(NSImage *)image
{
	[self init];
	if ([image isValid]) {
		[self setImage:image];
	} else {
		NSLog(@"Invalid Image.");
		[self release];
		return nil;
	}
	return self;
}

- (id)initWithImageFromPath:(NSString *)imagePath
{
	return [self initWithImage:[[[NSImage alloc] initWithContentsOfFile:imagePath] autorelease]];
}


- (void)_setBitmapRep:(NSBitmapImageRep *)newBitmapRep
{
    id old = nil;

    if (newBitmapRep != _bitmapRep) {
        old = _bitmapRep;
        _bitmapRep = [newBitmapRep retain];
        [old release];
    }
}


- (void)dealloc
{
	[_bitmapRep release];
	[_bitmapImage release];
	//[_bitmapView release];
}

- (NSImage *)image
{
	return _bitmapImage;
}

- (void)setImage:(NSImage *)newImage
{
	if ([newImage isValid]) {
		[_bitmapImage lockFocus]; // OnRepresentation:_bitmapRep];
		[newImage drawInRect:NSMakeRect(0, 0, BitmapWidth, BitmapHeight) fromRect:NSMakeRect(0, 0, [newImage size].width, [newImage size].height) operation:NSCompositeCopy fraction:1.0];
		[self _setBitmapRep:[[[NSBitmapImageRep alloc] initWithFocusedViewRect:NSMakeRect(0, 0, BitmapWidth, BitmapHeight)] autorelease]];
		[_bitmapImage unlockFocus];
		_bitmapPtr = [_bitmapRep bitmapData];
	}
}


- (float)colorDeltaMax
{
	return colorDeltaMax;
}

- (void)setColorDeltaMax:(float)newColorDeltaMax
{
	colorDeltaMax = newColorDeltaMax;
}

- (float)colorDeltaMin
{
	return colorDeltaMin;
}

- (void)setColorDeltaMin:(float)newColorDeltaMin
{
	colorDeltaMin = newColorDeltaMin;
}

- (float)maxNeighbourDistance
{
    return maxNeighbourDistance;
}

- (void)setMaxNeighbourDistance:(float)newMaxNeighbourDistance
{
    maxNeighbourDistance = newMaxNeighbourDistance;
}


- (AMPoint3D)positionInColorspaceForColor:(NSColor *)color
{
	AMPoint3D result;
	float h, s, b;
	
	[color getHue:&h saturation:&s brightness:&b alpha:nil];
	result.x = cos(h*360*DEG2RAD)*s*b;
	result.y = b;
	result.z = sin(h*360*DEG2RAD)*s*b;
	return result;
}

- (NSColor *)colorAtPoint:(NSPoint)point
{
	int offset = 3*(point.y*(int)BitmapWidth+point.x);
	return [NSColor colorWithCalibratedRed:_bitmapPtr[offset++]/256.0 green:_bitmapPtr[offset++]/256.0 blue:_bitmapPtr[offset]/256.0 alpha:1.0];
}

- (BOOL)color:(NSColor *)firstColor isSimilarToColor:(NSColor *)secondColor
{
	AMPoint3D p1;
	AMPoint3D p2;
	float d;
	p1 = [self positionInColorspaceForColor:firstColor];
	p2 = [self positionInColorspaceForColor:secondColor];

	d = AMDistance3D(p1, p2);
	return d<colorDeltaMax;
}

- (BOOL)color:(NSColor *)firstColor isDifferentFromColor:(NSColor *)secondColor
{
	AMPoint3D p1;
	AMPoint3D p2;
	float d;
	p1 = [self positionInColorspaceForColor:firstColor];
	p2 = [self positionInColorspaceForColor:secondColor];

	d = AMDistance3D(p1, p2);
	/*
	float h1, s1, b1;
	float h2, s2, b2;
	[firstColor getHue:&h1 saturation:&s1 brightness:&b1 alpha:nil];
	[secondColor getHue:&h2 saturation:&s2 brightness:&b2 alpha:nil];
	NSLog(@"h1:%f h2:%f - s1:%f s2:%f - b1:%f b2:%f -> d:%f (min:%f)", h1, h2, s1, s2, b1, b2, d, colorDeltaMin);
	 */
	return d>colorDeltaMin;
}

- (NSColor *)randomColor
{
	_lastPos = NSMakePoint(randomInt(100), randomInt(100));
	return [self colorAtPoint:_lastPos];
}

- (NSColor *)neighbourColor
{
	return nil;
}

- (NSColor *)randomColorSimilarTo:(NSColor *)aColor
{
	NSColor *result;
	int i = 0;
	do {
		result = [self randomColor];
		i++;
	} while ((![self color:result isSimilarToColor:aColor]) && (i<100));
	return result;
}

- (NSColor *)randomColorDifferentFrom:(NSColor *)aColor
{
	NSColor *result;
	int i = 0;
	do {
		result = [self randomColor];
		i++;
	} while (([self color:result isDifferentFromColor:aColor] == NO) && (i<100));
	/*
	float h1, s1, b1;
	float h2, s2, b2;
	[aColor getHue:&h1 saturation:&s1 brightness:&b1 alpha:nil];
	[result getHue:&h2 saturation:&s2 brightness:&b2 alpha:nil];
	 NSLog(@"h1:%f h2:%f - s1:%f s2:%f - b:1%f b:2%f", h1, h2, s1, s2, b1, b2);
	 */
	if (i==100)
		NSLog(@"no different color found ...");
	return result;
}


@end
