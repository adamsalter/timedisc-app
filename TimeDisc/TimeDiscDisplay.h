//
//  TimeDiscDisplay.h
//  TimeDisc
//
//  Created by Andreas on Fri Nov 08 2002.
//  Copyright (c) 2002 Andreas Mayer. All rights reserved.
//

#import <Cocoa/Cocoa.h>

enum {
    TimeDiscUnitRankingHMS = 0,
    TimeDiscUnitRankingHSM,
    TimeDiscUnitRankingMHS,
    TimeDiscUnitRankingMSH,
    TimeDiscUnitRankingSHM,
    TimeDiscUnitRankingSMH
};

enum {
	TimeDiscSecondsNone = 0,
	TimeDiscSecondsDot = 1,
	TimeDiscSecondsRing = 2
};

enum {
	TimeDiscTickMarksNone = 0,
	TimeDiscTickMarksMinutes = 1,
	TimeDiscTickMarksHours = 2,
	TimeDiscTickMarksQuarters = 3
};



@interface TimeDiscDisplay : NSObject {
	NSColor *hoursAMColor;
	NSColor *hoursPMColor;
	NSColor *minutesEvenColor;
	NSColor *minutesOddColor;
	NSColor *secondsEvenColor;
	NSColor *secondsOddColor;
	NSColor *secondsDotColor;
	NSColor *tickMarksHourColor;
	NSColor *tickMarksMinuteColor;
	NSSize offsetAbsolute;
	NSSize offsetRelative;
	BOOL offsetIsRelative;
	float clockSize;
	float innerDiscSize;
	float middleDiscSize;
	float secondsDotSize;
	int unitRanking;
	int displaySeconds;
	int displayTickMarks;
	BOOL display24Hours;
	int tickMarksHourLength;	// 0 - 100 % of radius
	int tickMarksMinuteLength;	// 0 - 100 % of radius
	float tickMarksHourWidth;	// 1 = standard
	float tickMarksMinuteWidth;	// 1 = standard
}


- (float)clockSize;
- (void)setClockSize:(float)newClockSize;

- (NSSize)offsetAbsolute;
- (void)setOffsetAbsolute:(NSSize)newOffsetAbsolute;

- (NSSize)offsetRelative;
- (void)setOffsetRelative:(NSSize)newOffsetRelative;

- (NSSize)absoluteOffsetWithRect:(NSRect)bounds;
- (void)setOffsetRelative:(NSSize)newOffset constrainToRect:(NSRect)rect;

- (NSColor *)hoursAMColor;
- (void)setHoursAMColor:(NSColor *)newHourAMColor;

- (NSColor *)hoursPMColor;
- (void)setHoursPMColor:(NSColor *)newHourPMColor;

- (NSColor *)minutesEvenColor;
- (void)setMinutesEvenColor:(NSColor *)newMinuteEvenColor;

- (NSColor *)minutesOddColor;
- (void)setMinutesOddColor:(NSColor *)newMinuteOddColor;

- (NSColor *)secondsEvenColor;
- (void)setSecondsEvenColor:(NSColor *)newSecondsEvenColor;

- (NSColor *)secondsOddColor;
- (void)setSecondsOddColor:(NSColor *)newSecondsOddColor;

- (NSColor *)secondsDotColor;
- (void)setSecondsDotColor:(NSColor *)newSecondColor;

- (NSColor *)tickMarksHourColor;
- (void)setTickMarksHourColor:(NSColor *)newTickMarkHourColor;

- (NSColor *)tickMarksMinuteColor;
- (void)setTickMarksMinuteColor:(NSColor *)newTickMarkMinuteColor;

- (float)innerDiscSize;
- (void)setInnerDiscSize:(float)newInnerDiscSize;

- (float)middleDiscSize;
- (void)setMiddleDiscSize:(float)newMiddleDiscSize;

- (float)secondsDotSize;
- (void)setSecondsDotSize:(float)newSecondsDotSize;

- (int)unitRanking;
- (void)setUnitRanking:(int)newUnitRanking;

- (int)displaySeconds;
- (void)setDisplaySeconds:(int)newDisplaySeconds;

- (int)displayTickMarks;
- (void)setDisplayTickMarks:(int)newDisplayTickMarks;

- (BOOL)display24Hours;
- (void)setDisplay24Hours:(BOOL)newDisplay24hours;

- (int)tickMarksHourLength;
- (void)setTickMarksHourLength:(int)newTickMarksHourLength;

- (int)tickMarksMinuteLength;
- (void)setTickMarksMinuteLength:(int)newTickMarksMinuteLength;

- (float)tickMarksHourWidth;
- (void)setTickMarksHourWidth:(float)newTickMarksHourWidth;

- (float)tickMarksMinuteWidth;
- (void)setTickMarksMinuteWidth:(float)newTickMarksMinuteWidth;


- (void)drawWithFrame:(NSRect)frame;

- (BOOL)hitTest:(NSPoint)aPoint withRect:(NSRect)bounds;


@end
