//
//  TimeDiscDisplay.m
//  TimeDisc
//
//  Created by Andreas on Fri Nov 08 2002.
//  Copyright (c) 2002 Andreas Mayer. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TimeDiscDisplay.h"

#undef	MIN
#undef	MAX
#define MIN(a,b)        (((a)<(b)) ? (a) : (b))
#define MAX(a,b)        (((a)>(b)) ? (a) : (b))

#define ConvertAngle(a) (fmod((90.0-(a)), 360.0))

#define DEG2RAD  0.017453292519943295


@interface TimeDiscDisplay (Private)
- (void)initColors;
@end


@implementation TimeDiscDisplay

- (id)init
{
	[self setOffsetAbsolute:NSMakeSize(0, 0)];
	[self initColors];
	innerDiscSize = 0.8;
	middleDiscSize = 0.85;
	secondsDotSize = 0.5;
	displaySeconds = TimeDiscSecondsRing;
	displayTickMarks = TimeDiscTickMarksMinutes;
	tickMarksHourLength = 12;
	tickMarksMinuteLength = 5;
	tickMarksHourWidth = 1.0;
	tickMarksMinuteWidth = 1.0;
	return self;
}

- (void)initColors
{
	[self setHoursAMColor:[NSColor redColor]];
	[self setHoursPMColor:[NSColor blueColor]];
	[self setMinutesOddColor:[NSColor yellowColor]];
	[self setMinutesEvenColor:[NSColor greenColor]];
	[self setSecondsOddColor:[NSColor whiteColor]];
	[self setSecondsEvenColor:[NSColor blackColor]];
	[self setSecondsDotColor:[NSColor orangeColor]];
	[self setTickMarksHourColor:[NSColor blackColor]];
	[self setTickMarksMinuteColor:[NSColor blackColor]];
}


- (float)clockSize
{
    return clockSize;
}

- (void)setClockSize:(float)newClockSize
{
    clockSize = newClockSize;
}

- (NSSize)absoluteOffsetWithRect:(NSRect)bounds
{
	NSSize result;
	if (offsetIsRelative) {
		result = NSMakeSize(offsetRelative.width*bounds.size.width, offsetRelative.height*bounds.size.height);
	} else {
		result = offsetAbsolute;
	}
    return result;
}

- (NSSize)offsetAbsolute
{
    return offsetAbsolute;
}

- (void)setOffsetAbsolute:(NSSize)newOffsetAbsolute
{
    offsetAbsolute = newOffsetAbsolute;
	offsetIsRelative = NO;
}

- (NSSize)offsetRelative
{
    return offsetRelative;
}

- (void)setOffsetRelative:(NSSize)newOffsetRelative
{
    offsetRelative = newOffsetRelative;
	offsetIsRelative = YES;
}

- (void)setOffsetRelative:(NSSize)newOffset constrainToRect:(NSRect)bounds
{
	float r0;
	r0 = clockSize*MIN(bounds.size.width/2, bounds.size.height/2);
    offsetRelative = NSMakeSize(MAX(-(bounds.size.width/2)+r0, MIN((bounds.size.width/2)-r0, newOffset.width*bounds.size.width))/bounds.size.width, MAX(-(bounds.size.height/2)+r0, MIN((bounds.size.height/2)-r0, newOffset.height*bounds.size.height))/bounds.size.height);
	offsetIsRelative = YES;
}


- (NSColor *)hoursAMColor
{
    return hoursAMColor;
}

- (void)setHoursAMColor:(NSColor *)newHoursAMColor
{
    id old = nil;

    if (newHoursAMColor != hoursAMColor) {
        old = hoursAMColor;
        hoursAMColor = [newHoursAMColor retain];
        [old release];
    }
}

- (NSColor *)hoursPMColor
{
    return hoursPMColor;
}

- (void)setHoursPMColor:(NSColor *)newHoursPMColor
{
    id old = nil;

    if (newHoursPMColor != hoursPMColor) {
        old = hoursPMColor;
        hoursPMColor = [newHoursPMColor retain];
        [old release];
    }
}

- (NSColor *)minutesEvenColor
{
    return minutesEvenColor;
}

- (void)setMinutesEvenColor:(NSColor *)newMinutesEvenColor
{
    id old = nil;

    if (newMinutesEvenColor != minutesEvenColor) {
        old = minutesEvenColor;
        minutesEvenColor = [newMinutesEvenColor retain];
        [old release];
    }
}

- (NSColor *)minutesOddColor
{
    return minutesOddColor;
}

- (void)setMinutesOddColor:(NSColor *)newMinutesOddColor
{
    id old = nil;

    if (newMinutesOddColor != minutesOddColor) {
        old = minutesOddColor;
        minutesOddColor = [newMinutesOddColor retain];
        [old release];
    }
}

- (NSColor *)secondsEvenColor
{
    return secondsEvenColor;
}

- (void)setSecondsEvenColor:(NSColor *)newSecondsEvenColor
{
    id old = nil;

    if (newSecondsEvenColor != secondsEvenColor) {
        old = secondsEvenColor;
        secondsEvenColor = [newSecondsEvenColor retain];
        [old release];
    }
}

- (NSColor *)secondsOddColor
{
    return secondsOddColor;
}

- (void)setSecondsOddColor:(NSColor *)newSecondsOddColor
{
    id old = nil;

    if (newSecondsOddColor != secondsOddColor) {
        old = secondsOddColor;
        secondsOddColor = [newSecondsOddColor retain];
        [old release];
    }
}

- (NSColor *)secondsDotColor
{
    return secondsDotColor;
}

- (void)setSecondsDotColor:(NSColor *)newSecondsDotColor
{
    id old = nil;

    if (newSecondsDotColor != secondsDotColor) {
        old = secondsDotColor;
        secondsDotColor = [newSecondsDotColor retain];
        [old release];
    }
}

- (NSColor *)tickMarksHourColor
{
    return tickMarksHourColor;
}

- (void)setTickMarksHourColor:(NSColor *)newTickMarksHourColor
{
    id old = nil;

    if (newTickMarksHourColor != tickMarksHourColor) {
        old = tickMarksHourColor;
        tickMarksHourColor = [newTickMarksHourColor retain];
        [old release];
    }
}

- (NSColor *)tickMarksMinuteColor
{
    return tickMarksMinuteColor;
}

- (void)setTickMarksMinuteColor:(NSColor *)newTickMarksMinuteColor
{
    id old = nil;

    if (newTickMarksMinuteColor != tickMarksMinuteColor) {
        old = tickMarksMinuteColor;
        tickMarksMinuteColor = [newTickMarksMinuteColor retain];
        [old release];
    }
}

- (float)innerDiscSize
{
    return innerDiscSize;
}

- (void)setInnerDiscSize:(float)newInnerDiscSize
{
    innerDiscSize = newInnerDiscSize;
}

- (float)middleDiscSize
{
    return middleDiscSize;
}

- (void)setMiddleDiscSize:(float)newMiddleDiscSize
{
    middleDiscSize = newMiddleDiscSize;
}

- (float)secondsDotSize
{
    return secondsDotSize;
}

- (void)setSecondsDotSize:(float)newSecondsDotSize
{
    secondsDotSize = newSecondsDotSize;
}

- (int)unitRanking
{
    return unitRanking;
}

- (void)setUnitRanking:(int)newUnitRanking
{
    unitRanking = newUnitRanking;
}

- (int)displaySeconds
{
    return displaySeconds;
}

- (void)setDisplaySeconds:(int)newDisplaySeconds
{
    displaySeconds = newDisplaySeconds;
}

- (int)displayTickMarks
{
    return displayTickMarks;
}

- (void)setDisplayTickMarks:(int)newDisplayTickMarks
{
    displayTickMarks = newDisplayTickMarks;
}

- (BOOL)display24Hours
{
    return display24Hours;
}

- (void)setDisplay24Hours:(BOOL)newDisplay24Hours
{
    display24Hours = newDisplay24Hours;
}


// ---------------------------------------------------------
// - tickMarksHourLength:
// ---------------------------------------------------------
- (int)tickMarksHourLength
{
    return tickMarksHourLength;
}

// ---------------------------------------------------------
// - setTickMarksHourLength:
// ---------------------------------------------------------
- (void)setTickMarksHourLength:(int)newTickMarksHourLength
{
    tickMarksHourLength = newTickMarksHourLength;
}

// ---------------------------------------------------------
// - tickMarksMinuteLength:
// ---------------------------------------------------------
- (int)tickMarksMinuteLength
{
    return tickMarksMinuteLength;
}

// ---------------------------------------------------------
// - setTickMarksMinuteLength:
// ---------------------------------------------------------
- (void)setTickMarksMinuteLength:(int)newTickMarksMinuteLength
{
    tickMarksMinuteLength = newTickMarksMinuteLength;
}

// ---------------------------------------------------------
// - tickMarksHourWidth:
// ---------------------------------------------------------
- (float)tickMarksHourWidth
{
    return tickMarksHourWidth;
}

// ---------------------------------------------------------
// - setTickMarksHourWidth:
// ---------------------------------------------------------
- (void)setTickMarksHourWidth:(float)newTickMarksHourWidth
{
    tickMarksHourWidth = newTickMarksHourWidth;
}

// ---------------------------------------------------------
// - tickMarksMinuteWidth:
// ---------------------------------------------------------
- (float)tickMarksMinuteWidth
{
    return tickMarksMinuteWidth;
}

// ---------------------------------------------------------
// - setTickMarksMinuteWidth:
// ---------------------------------------------------------
- (void)setTickMarksMinuteWidth:(float)newTickMarksMinuteWidth
{
    tickMarksMinuteWidth = newTickMarksMinuteWidth;
}


- (void)drawSplitDiscAt:(NSPoint)center withRadius:(float)r splitAngle:(float)splitAngle firstColor:(NSColor *)firstColor secondColor:(NSColor *)secondColor
{
	NSBezierPath *bPath;

	bPath = [[[NSBezierPath alloc] init] autorelease];
	[firstColor set];
	[bPath moveToPoint:center];
	[bPath appendBezierPathWithArcWithCenter:center radius:r startAngle:splitAngle endAngle:90 clockwise:YES];
	[bPath lineToPoint:center];
	[bPath fill];
	
	bPath = [[[NSBezierPath alloc] init] autorelease];
	[secondColor set];
	[bPath moveToPoint:center];
	[bPath appendBezierPathWithArcWithCenter:center radius:r startAngle:90 endAngle:splitAngle clockwise:YES];
	[bPath lineToPoint:center];
	[bPath fill];
}

- (void)drawFullDiscAt:(NSPoint)center withRadius:(float)r color:(NSColor *)color
{
	NSBezierPath *bPath;
	
	bPath = [[[NSBezierPath alloc] init] autorelease];
	[color set];
	[bPath appendBezierPathWithArcWithCenter:center radius:r startAngle:0 endAngle:180 clockwise:YES];
	[bPath appendBezierPathWithArcWithCenter:center radius:r startAngle:180 endAngle:360 clockwise:YES];
	[bPath fill];
}

- (void)drawHours:(NSCalendarDate *)time atCenter:(NSPoint)center withRadius:(float)r
{
	NSColor *backColor, *foreColor;
	int h, m, s;

	h = [time hourOfDay];
	m = [time minuteOfHour];
	s = [time secondOfMinute];

	if (!display24Hours) {
		// hour background
		if (h >= 12) { // PM
			backColor = hoursAMColor;
			foreColor = hoursPMColor;
			h = h-12.0;
		} else {
			backColor = hoursPMColor;
			foreColor = hoursAMColor;
		}

		if (h+m+s > 0) {
			[self drawSplitDiscAt:center withRadius:r splitAngle:ConvertAngle((h*60.0+m+s/60.0)/2) firstColor:backColor secondColor:foreColor];
		} else {
			// draw background only
			[self drawFullDiscAt:center withRadius:r color:backColor];
		}
	} else { // 24 hours
		int d = [time dayOfCommonEra];
		// hour background
		if (d%2) {
			backColor = hoursAMColor;
			foreColor = hoursPMColor;
		} else {
			backColor = hoursPMColor;
			foreColor = hoursAMColor;
		}

		if (h+m+s > 0) {
			[self drawSplitDiscAt:center withRadius:r splitAngle:ConvertAngle((h*30.0+m/2+s/120.0)/2) firstColor:backColor secondColor:foreColor];
		} else {
			// draw background only
			[self drawFullDiscAt:center withRadius:r color:backColor];
		}
	}
}

- (void)drawMinutes:(NSCalendarDate *)time atCenter:(NSPoint)center withRadius:(float)r
{
	NSColor *backColor, *foreColor;
	int h, m, s;

	h = [time hourOfDay];
	m = [time minuteOfHour];
	s = [time secondOfMinute];

	// minute background
	if (h%2) {
		backColor = minutesOddColor;
		foreColor = minutesEvenColor;
	} else {
		backColor = minutesEvenColor;
		foreColor = minutesOddColor;
	}

	if (m+s > 0) {
		[self drawSplitDiscAt:center withRadius:r splitAngle:ConvertAngle(m*6.0+s/10.0) firstColor:backColor secondColor:foreColor];
	} else {
		// draw background only
		[self drawFullDiscAt:center withRadius:r color:backColor];
	}
}

- (void)drawSeconds:(NSCalendarDate *)time atCenter:(NSPoint)center withRadius:(float)r
{
	NSColor *backColor, *foreColor;
	int m, s;

	m = [time minuteOfHour];
	s = [time secondOfMinute];
	
	// second background
	if (m%2) {
		backColor = secondsOddColor;
		foreColor = secondsEvenColor;
	} else {
		backColor = secondsEvenColor;
		foreColor = secondsOddColor;
	}

	if (s > 0) {
		[self drawSplitDiscAt:center withRadius:r splitAngle:ConvertAngle(s*6.0) firstColor:backColor secondColor:foreColor];
	} else {
		// draw background only
		[self drawFullDiscAt:center withRadius:r color:backColor];
	}
}

- (void)drawTickMarks:(NSCalendarDate *)time atCenter:(NSPoint)center withMinuteRadius:(float)rm hourRadius:(float)rh
{
	NSBezierPath *bPath, *bPath2;
	NSPoint outer, inner;
	int h, m, s;
	int i;
	float a, rm1, rm2, rh1;
	
	h = [time hourOfDay];
	m = [time minuteOfHour];
	s = [time secondOfMinute];

	// draw tick marks
	bPath = [[[NSBezierPath alloc] init] autorelease];
	bPath2 = [[[NSBezierPath alloc] init] autorelease];
	if (!display24Hours) {
		rm1 = rm*(100-tickMarksMinuteLength)/100;
		rm2 = rm*(100-tickMarksHourLength)/100;
		for (i=0; i<60; i++) {
			a = i*6*DEG2RAD;
			if (i%5) {
				if (displayTickMarks == TimeDiscTickMarksMinutes) {
				// minute tick
					outer = NSMakePoint(center.x+cos(a)*rm, center.y+sin(a)*rm);
					inner = NSMakePoint(center.x+cos(a)*rm1, center.y+sin(a)*rm1);
					[bPath moveToPoint:outer];
					[bPath lineToPoint:inner];
				}
			} else {
				if ((displayTickMarks == TimeDiscTickMarksHours) || (displayTickMarks == TimeDiscTickMarksMinutes)) {
				// hour tick
					outer = NSMakePoint(center.x+cos(a)*rm, center.y+sin(a)*rm);
					inner = NSMakePoint(center.x+cos(a)*rm2, center.y+sin(a)*rm2);
					[bPath2 moveToPoint:outer];
					[bPath2 lineToPoint:inner];
				}
			}
		}
	} else { // 24 hours
		if (displayTickMarks == TimeDiscTickMarksMinutes) {
			rm1 = rm*(100-tickMarksMinuteLength)/100;
			for (i=0; i<60; i++) {
				a = i*6*DEG2RAD;
				if (i%5) {
					// minute tick
					outer = NSMakePoint(center.x+cos(a)*rm, center.y+sin(a)*rm);
					inner = NSMakePoint(center.x+cos(a)*rm1, center.y+sin(a)*rm1);
					[bPath moveToPoint:outer];
					[bPath lineToPoint:inner];
				} else {
					// 5-minute tick
					outer = NSMakePoint(center.x+cos(a)*rm, center.y+sin(a)*rm);
					inner = NSMakePoint(center.x+cos(a)*rm1, center.y+sin(a)*rm1);
					[bPath2 moveToPoint:outer];
					[bPath2 lineToPoint:inner];
				}
			}
		}
		if ((displayTickMarks == TimeDiscTickMarksHours) || (displayTickMarks == TimeDiscTickMarksMinutes)) {
			rh1 = rh*(100-tickMarksHourLength)/100;
			for (i=0; i<24; i++) {
				a = i*15*DEG2RAD;
				// hour tick
				outer = NSMakePoint(center.x+cos(a)*rh, center.y+sin(a)*rh);
				inner = NSMakePoint(center.x+cos(a)*rh1, center.y+sin(a)*rh1);
				[bPath2 moveToPoint:outer];
				[bPath2 lineToPoint:inner];
			}
		}
	}
	[tickMarksMinuteColor set];
	[bPath setLineWidth:MAX(0.3, 0.3*tickMarksMinuteWidth*(rm/200))];
	[bPath stroke];
	[tickMarksHourColor set];
	[bPath2 setLineWidth:MAX(0.5, 0.5*tickMarksHourWidth*(rh/200))];
	[bPath2 stroke];
}

- (void)drawWithFrame:(NSRect)bounds
{
	NSCalendarDate *time;
	NSGraphicsContext *gContext;
	NSBezierPath *bPath;
	NSPoint center;
	NSSize offset;
	int s;
	float r0, r, r2, r3, rmtick = 0.0, rhtick = 0.0, a;

	time = [[NSCalendarDate alloc] init];
	s = [time secondOfMinute];


	gContext = [NSGraphicsContext currentContext];
	[gContext setShouldAntialias:YES];

	offset = [self absoluteOffsetWithRect:bounds];
	center = NSMakePoint(bounds.size.width/2+0.5+offset.width, bounds.size.height/2+0.5+offset.height);
//	r0 = clockSize*MIN((bounds.size.width-fabs(offset.width))/2, ((bounds.size.height-fabs(offset.height))/2));
	r0 = MIN(clockSize*MIN(bounds.size.width, bounds.size.height)/2, MIN((bounds.size.width/2)-fabs(offset.width), (bounds.size.height/2)-fabs(offset.height)));
	r = r0-0.5;
	r2 = r0*middleDiscSize-0.5;
	r3 = r0*innerDiscSize-0.5;

	//NSLog(@"clockSize: %f width: %f height: %f", clockSize, bounds.size.width, bounds.size.height);
	//NSLog(@"r0: %f", r0);
	
	switch (unitRanking) {
		case TimeDiscUnitRankingHMS: {
			if (displaySeconds == TimeDiscSecondsRing) {
				[self drawSeconds:time atCenter:center withRadius:r];
			}
			[self drawMinutes:time atCenter:center withRadius:r2];
			[self drawHours:time atCenter:center withRadius:r3];
			rmtick = r2;
			rhtick = r3;
			break;
		}
		case TimeDiscUnitRankingHSM: {
			[self drawMinutes:time atCenter:center withRadius:r];
			if (displaySeconds == TimeDiscSecondsRing) {
				[self drawSeconds:time atCenter:center withRadius:r2];
			}
			[self drawHours:time atCenter:center withRadius:r3];
			rmtick = r;
			rhtick = r3;
			break;
		}
		case TimeDiscUnitRankingMHS: {
			if (displaySeconds == TimeDiscSecondsRing) {
				[self drawSeconds:time atCenter:center withRadius:r];
			}
			[self drawHours:time atCenter:center withRadius:r2];
			[self drawMinutes:time atCenter:center withRadius:r3];
			rmtick = r3;
			rhtick = r2;
			break;
		}
		case TimeDiscUnitRankingMSH: {
			[self drawHours:time atCenter:center withRadius:r];
			if (displaySeconds == TimeDiscSecondsRing) {
				[self drawSeconds:time atCenter:center withRadius:r2];
			}
			[self drawMinutes:time atCenter:center withRadius:r3];
			rmtick = r3;
			rhtick = r;
			break;
		}
		case TimeDiscUnitRankingSHM: {
			[self drawMinutes:time atCenter:center withRadius:r];
			[self drawHours:time atCenter:center withRadius:r2];
			if (displaySeconds == TimeDiscSecondsRing) {
				[self drawSeconds:time atCenter:center withRadius:r3];
			}
			rmtick = r;
			rhtick = r2;
			break;
		}
		case TimeDiscUnitRankingSMH: {
			[self drawHours:time atCenter:center withRadius:r];
			[self drawMinutes:time atCenter:center withRadius:r2];
			if (displaySeconds == TimeDiscSecondsRing) {
				[self drawSeconds:time atCenter:center withRadius:r3];
			}
			rmtick = r2;
			rhtick = r;
		}
	}
	
	// draw tick marks
	if (displayTickMarks != TimeDiscTickMarksNone)
		[self drawTickMarks:time atCenter:center withMinuteRadius:rmtick hourRadius:rhtick];

	// draw seconds dot
	if (displaySeconds == TimeDiscSecondsDot) {
		float rDot;
		NSRect secondsDot;
		rDot = r*MIN(middleDiscSize, 1.0-middleDiscSize)*secondsDotSize;
		a = ConvertAngle(s*6);
		a = a *DEG2RAD;
		secondsDot = NSMakeRect(center.x+cos(a)*r2-rDot, center.y+sin(a)*r2-rDot, 2*rDot, 2*rDot);
		[secondsDotColor set];
		bPath = [NSBezierPath bezierPathWithOvalInRect:secondsDot];
		[bPath fill];
	}

	[time release];
}

- (BOOL)hitTest:(NSPoint)aPoint withRect:(NSRect)bounds
{
	float r0, dx, dy;
	NSPoint center;
	NSSize offset;

	offset = [self absoluteOffsetWithRect:bounds];
	center = NSMakePoint(bounds.size.width/2+0.5+offset.width, bounds.size.height/2+0.5+offset.height);
	r0 = clockSize*MIN(bounds.size.width/2, bounds.size.height/2);
	dx = fabsf(aPoint.x-center.x);
	dy = fabsf(aPoint.y-center.y);
	return (sqrt(dx*dx+dy*dy) <= r0);
}


@end
