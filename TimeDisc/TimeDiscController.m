//
//  TimeDiscController.m
//  TimeDisc
//
//  Created by Andreas on Wed Nov 06 2002.
//  Copyright (c) 2002 Andreas Mayer. All rights reserved.
//

#import <Carbon/Carbon.h>
#import "TimeDiscController.h"

#import "AMDefaultsDictionary-Color.h"
#import "AMDefaultsDictionary-Rect.h"
#import "NSView_Utils.h"
#import "NSFileManagerAMAdditions.h"
#import "TimeDiscThemeManager.h"
#import "TimeDiscTheme.h"
#import "AMDisplayPathFormatter.h"


// ============================================================
#pragma mark -
#pragma mark ━ constants ━
// ============================================================

#define ApplicationName @"TimeDisc"
#define NSUIElementKey @"NSUIElement"
#define NSUIElementOff @"0"
#define NSUIElementOn @"1"
#define RenicePath @"/usr/bin/renice"
#define RenicePriorityMax 20
#define DateAndTimePrefPanePath @"/System/Library/PreferencePanes/DateAndTime.prefPane"

#define HoursAMColor_OldKey @"HourAM"
#define HoursPMColor_OldKey @"HourPM"
#define MinutesOddColor_OldKey @"MinuteOdd"
#define MinutesEvenColor_OldKey @"MinuteEven"
#define TickMarksHourColor_OldKey @"updateMarkHour"
#define TickMarksMinuteColor_OldKey @"updateMarkMinute"
#define HoursDiscSize_OldKey @"HoursDiscSize"

#define SubsectionColorsKey @"Colors"
#define SubsectionMenuBarClockKey @"MenuBar"
#define SubsectionLayoutKey @"Layout"

// global
#define ActiveThemeNameKey @"ActiveThemeName"
#define ShowClockInWindowKey @"ShowClockInWindow"
#define ShowClockInDockKey @"ShowClockInDock"
#define ShowClockInMenuBarKey @"ShowClockInMenuBar"
#define ForceShowDockIconKey @"ForceShowDockIcon"
// subsection MenuBar
#define MenuBarShowClockKey @"ShowClock"
#define MenuBarUseIconKey @"ShowIcon"
#define MenuBarUseInanimatedIconKey @"ShowInanimatedIcon"
#define MenuBarShowTimeKey @"ShowTime"
#define MenuBarUse24hKey @"Show24h"
#define MenuBarShowWeekdayKey @"ShowWeekday"
#define MenuBarShowDateKey @"ShowDate"
// global
#define ClockPulseKey @"ClockPulse"
#define ForceAllowChangingClockPulseKey @"ForceAllowChangingClockPulse"
#define ReniceKey @"Renice"
#define RenicePriorityKey @"RenicePriority"

#define WindowSizeMaxKey @"ClockWindowMaxSize"
#define WindowFrameKey @"ClockWindowFrame"
#define WindowLevelKey @"WindowLevel"
#define WindowAlphaValueKey @"WindowAlphaValue"
#define WindowShowShadowKey @"WindowShowShadow"
#define EnableClickThroughKey @"EnableClickThrough"

// subsection Layout
#define UnitRankingKey @"UnitRanking"
#define DisplaySecondsKey @"DisplaySeconds"
#define InnerDiscSizeKey @"InnerDiscSize"
#define MiddleDiscSizeKey @"MiddleDiscSize"
#define Display24HoursKey @"Display24Hours"
#define TickMarksMinuteLengthKey @"TickMarksMinuteLength"
#define TickMarksHourLengthKey @"TickMarksHourLength"
#define TickMarksMinuteWidthKey @"TickMarksMinuteWidth"
#define TickMarksHourWidthKey @"TickMarksHourWidth"

// subsection Colors
#define HoursAMColorKey @"HoursAM"
#define HoursPMColorKey @"HoursPM"
#define MinutesOddColorKey @"MinutesOdd"
#define MinutesEvenColorKey @"MinutesEven"
#define SecondsOddColorKey @"SecondsOdd"
#define SecondsEvenColorKey @"SecondsEven"
#define SecondsDotColorKey @"SecondsDot"
#define TickMarksHourColorKey @"TickMarksHour"
#define TickMarksMinuteColorKey @"TickMarksMinute"
#define ColorSourcePathKey @"ColorSourcePath"

// test
#define ShowImagePreviewKey @"ShowImagePreview"

#define AMScreenSaverActivatedNotification @"de.furrysoft.timediscsaver.screenSaverActivatedNotification"


// redefine some constants for 10.1.x compatibility
UInt32 AM_kWindowIgnoreClicksAttribute  = (1L << 29);


// ============================================================
#pragma mark -
#pragma mark ━ private interface ━
// ============================================================
@interface TimeDiscController (Private)
- (NSCalendarDate *)lastMenuBarUpdate;
- (void)setLastMenuBarUpdate:(NSCalendarDate *)newLastMenuBarUpdate;
- (void)readPreferences;
- (void)readThemePrefs;
- (void)updatePrefsWindow;
- (void)setClickThrough:(BOOL)clickThrough;
- (BOOL)canRenice;
- (BOOL)localeUsesAMPM;
- (void)update:(NSTimer *)timer;
- (BOOL)secondsDotOverlaps;
- (void)updateShadow;
- (void)reenableShadow;
- (void)setNoClickThroughCheckBoxState:(BOOL)onState;
- (void)setNoClickThroughCheckBoxEnabled:(BOOL)enabled;
- (void)createStatusItem;
- (void)removeStatusItem;
- (void)updateStatusItem;
- (NSString *)NSUIElement;
- (BOOL)setNSUIElement:(NSString *)value;
- (void)doRenice:(int)niceValue;
- (void)restartTimer:(float)interval;
- (AMRandomColorSource *)randomColorSource;
- (void)setRandomColorSource:(AMRandomColorSource *)newRandomColorSource;
- (NSString *)randomColorSourcePath;
- (void)setRandomColorSourcePath:(NSString *)newRandomColorSourcePath;
- (NSStatusItem *)statusItem;
- (void)setStatusItem:(NSStatusItem *)newStatusItem;
- (NSCalendarDate *)lastTick;
- (void)setLastTick:(NSCalendarDate *)newLastTick;
- (TimeDiscThemeNamePanelController *)themeNamePanelController;
- (void)setThemeNamePanelController:(TimeDiscThemeNamePanelController *)newThemeNamePanelController;
- (TimeDiscThemePanelController *)themePanelController;
- (void)setThemePanelController:(TimeDiscThemePanelController *)newThemePanelController;
- (NSString *)activeThemeName;
- (void)setActiveThemeName:(NSString *)newActiveThemeName;
- (void)themeListChanged:(id)sender;
- (void)themeNameChanged:(NSString *)newThemeName sender:(id)sender;
@end


@implementation TimeDiscController

// ============================================================
#pragma mark -
#pragma mark ━ initialization ━
// ============================================================
- (void)initialize
{
	srand(time(0));
}

- (void)awakeFromNib
{
	srand(time(0));

	// register for desktop changed notifications
	[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(desktopPictureChanged:) name:@"com.apple.desktop" object:nil];

	// register for TimeDiscSaver activated notifications
	[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(screenSaverActivated:) name:AMScreenSaverActivatedNotification object:nil];

	systemKnowsSetIgnoresMouseEvents = [mainWindow respondsToSelector:@selector(setIgnoresMouseEvents:)];

	dockIconAndMenuHidden = [[self NSUIElement] isEqualToString:NSUIElementOn];

	[themePopUpButton setAutoenablesItems:NO];
	[[themePopUpButton itemAtIndex:[themePopUpButton indexOfItemWithTag:0]] setEnabled:NO];

	// create display
	mainDisplay = [[TimeDiscDisplay alloc] init];
	[timeDiscView setDisplay:mainDisplay];
	[mainDisplay setClockSize:1.0];

	// create icon display
	statusItemSize = [[NSStatusBar systemStatusBar] thickness];
	if (menuBarUseInanimatedIcon) {
		iconImage = [TimeDiscImage imageNamed:@"TimeDiscMenuIcon"];
	} else {
		iconDisplay = [[TimeDiscDisplay alloc] init];
		[iconDisplay setHoursAMColor:[NSColor whiteColor]];
		[iconDisplay setHoursPMColor:[NSColor colorWithCalibratedHue:0.0 saturation:0.0 brightness:0.19 alpha:1.0]];
		[iconDisplay setMinutesEvenColor:[NSColor colorWithCalibratedHue:0.0 saturation:0.0 brightness:0.08 alpha:1.0]];
		[iconDisplay setMinutesOddColor:[NSColor colorWithCalibratedHue:0.0 saturation:0.0 brightness:0.08 alpha:1.0]];
		[iconDisplay setInnerDiscSize:0.62];
		[iconDisplay setMiddleDiscSize:0.72];
		[iconDisplay setUnitRanking:TimeDiscUnitRankingHMS];
		[iconDisplay setDisplaySeconds:TimeDiscSecondsNone];
		[iconDisplay setDisplayTickMarks:TimeDiscTickMarksNone];
		[iconDisplay setClockSize:1.0];
		[iconDisplay setOffsetAbsolute:NSMakeSize(0, -1)];
		iconImage = [[TimeDiscImage alloc] initWithSize:NSMakeSize(statusItemSize, statusItemSize)];
		iconImageRep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL pixelsWide:(int)statusItemSize pixelsHigh:(int)statusItemSize bitsPerSample:8 samplesPerPixel:4 hasAlpha:YES isPlanar:YES colorSpaceName:NSCalibratedRGBColorSpace bytesPerRow:0 bitsPerPixel:0];
		[iconImage setDataRetained:YES];
		[iconImage addRepresentation:iconImageRep];
		[iconImage setDisplay:iconDisplay];
	}

	// read prefs
	[self readPreferences];

}

- (void)dealloc
{
	[aboutPanelController release];
	[themeNamePanelController release];
	[themePanelController release];
	[iconDisplay release];
	[iconImageRep release];
	[iconImage release];
	[randomColorSourcePath release];
	[randomColorSource release];
	[lastMenuBarUpdate release];
	[statusItem release];
	[statusItemImage release];
	[tickSoundPath release];
	[tickSound release];
	[dockImage release];
	[mainDisplay release];
	[timer invalidate];
	[timer release];
	[colorDefaults release];
	[globalDefaults release];
}


// ============================================================
#pragma mark -
#pragma mark ━ setter/getters ━
// ============================================================
- (NSCalendarDate *)lastMenuBarUpdate
{
    return lastMenuBarUpdate;
}

- (void)setLastMenuBarUpdate:(NSCalendarDate *)newLastMenuBarUpdate
{
    id old = nil;

    if (newLastMenuBarUpdate != lastMenuBarUpdate) {
        old = lastMenuBarUpdate;
        lastMenuBarUpdate = [newLastMenuBarUpdate retain];
        [old release];
    }
}

- (AMRandomColorSource *)randomColorSource
{
    return randomColorSource;
}

- (void)setRandomColorSource:(AMRandomColorSource *)newRandomColorSource
{
    id old = nil;

    if (newRandomColorSource != randomColorSource) {
        old = randomColorSource;
        randomColorSource = [newRandomColorSource retain];
        [old release];
    }
}

- (NSString *)randomColorSourcePath
{
    return randomColorSourcePath;
}

- (void)setRandomColorSourcePath:(NSString *)newRandomColorSourcePath
{
    id old = nil;

    if (newRandomColorSourcePath != randomColorSourcePath) {
        old = randomColorSourcePath;
        randomColorSourcePath = [newRandomColorSourcePath retain];
        [old release];
    }
}

- (NSStatusItem *)statusItem
{
    return statusItem;
}

- (void)setStatusItem:(NSStatusItem *)newStatusItem
{
    id old = nil;

    if (newStatusItem != statusItem) {
        old = statusItem;
        statusItem = [newStatusItem retain];
        [old release];
    }
}

- (NSCalendarDate *)lastTick
{
    return lastTick;
}

- (void)setLastTick:(NSCalendarDate *)newLastTick
{
    id old = nil;

    if (newLastTick != lastTick) {
        old = lastTick;
        lastTick = [newLastTick retain];
        [old release];
    }
}

- (TimeDiscThemeNamePanelController *)themeNamePanelController
{
    return themeNamePanelController;
}

- (void)setThemeNamePanelController:(TimeDiscThemeNamePanelController *)newThemeNamePanelController
{
    id old = nil;

    if (newThemeNamePanelController != themeNamePanelController) {
        old = themeNamePanelController;
        themeNamePanelController = [newThemeNamePanelController retain];
        [old release];
    }
}

- (TimeDiscThemePanelController *)themePanelController
{
    return themePanelController;
}

- (void)setThemePanelController:(TimeDiscThemePanelController *)newThemePanelController
{
    id old = nil;

    if (newThemePanelController != themePanelController) {
        old = themePanelController;
        themePanelController = [newThemePanelController retain];
        [old release];
    }
}

- (NSString *)activeThemeName
{
    return activeThemeName;
}

- (void)setActiveThemeName:(NSString *)newActiveThemeName
{
    id old = nil;

    if (newActiveThemeName != activeThemeName) {
        old = activeThemeName;
        activeThemeName = [newActiveThemeName retain];
        [old release];
    }
}

// ============================================================
#pragma mark -
#pragma mark ━ user defaults / preferences ━
// ============================================================
- (AMDefaultsDictionary *)globalDefaults
{
	return globalDefaults;
}

- (AMDefaultsDictionary *)colorDefaults
{
	return colorDefaults;
}

- (void)readPreferences
{
	// register some default values
	// these dictionary objects are only temporary; variables will be reused
	globalDefaults = [[[AMDefaultsDictionary alloc] initAsRoot] autorelease];
	layoutDefaults = [[[AMDefaultsDictionary alloc] initWithName:SubsectionLayoutKey parent:globalDefaults] autorelease];
	menuBarDefaults = [[[AMDefaultsDictionary alloc] initWithName:SubsectionMenuBarClockKey parent:globalDefaults] autorelease];
	
	[globalDefaults setBool:YES forKey:ShowClockInWindowKey];
	[globalDefaults setBool:YES forKey:ShowClockInDockKey];
	[globalDefaults setBool:NO forKey:ForceShowDockIconKey];

	[menuBarDefaults setBool:YES forKey:MenuBarShowClockKey];
	[menuBarDefaults setBool:YES forKey:MenuBarShowTimeKey];

	[globalDefaults setInteger:1 forKey:ClockPulseKey];
	[globalDefaults setBool:NO forKey:ForceAllowChangingClockPulseKey];
	[globalDefaults setInteger:RenicePriorityMax forKey:RenicePriorityKey];

	[globalDefaults setInteger:1024 forKey:WindowSizeMaxKey];

	[globalDefaults setBool:YES forKey:WindowShowShadowKey];

	[layoutDefaults setInteger:1 forKey:UnitRankingKey];

	[layoutDefaults setInteger:1 forKey:DisplaySecondsKey];

	[layoutDefaults setFloat:0.8 forKey:InnerDiscSizeKey];

	[layoutDefaults setFloat:0.82 forKey:MiddleDiscSizeKey];

	[layoutDefaults setInteger:5 forKey:TickMarksMinuteLengthKey];
	[layoutDefaults setInteger:12 forKey:TickMarksHourLengthKey];

	[layoutDefaults setFloat:1.0 forKey:TickMarksMinuteWidthKey];
	[layoutDefaults setFloat:1.0 forKey:TickMarksHourWidthKey];

	[[NSUserDefaults standardUserDefaults] registerDefaults:[globalDefaults dictionary]];

	// set up default dictionaries
	globalDefaults = [[AMDefaultsDictionary alloc] initWithUserDefaults:[NSUserDefaults standardUserDefaults]];
	colorDefaults = [[AMDefaultsDictionary alloc] initWithName:SubsectionColorsKey];
	[colorDefaults setParent:globalDefaults];
	layoutDefaults = [[AMDefaultsDictionary alloc] initWithName:SubsectionLayoutKey];
	[layoutDefaults setParent:globalDefaults];
	menuBarDefaults = [[AMDefaultsDictionary alloc] initWithName:SubsectionMenuBarClockKey];
	[menuBarDefaults setParent:globalDefaults];

	
	// update old keys
	NSColor *defaultColor;
	if (defaultColor = [colorDefaults colorForKey:HoursAMColor_OldKey]) {
		[colorDefaults removeObjectForKey:HoursAMColor_OldKey];
		[colorDefaults setColor:defaultColor forKey:HoursAMColorKey];
	}
	if (defaultColor = [colorDefaults colorForKey:HoursPMColor_OldKey]) {
		[colorDefaults removeObjectForKey:HoursPMColor_OldKey];
		[colorDefaults setColor:defaultColor forKey:HoursPMColorKey];
	}
	if (defaultColor = [colorDefaults colorForKey:MinutesOddColor_OldKey]) {
		[colorDefaults removeObjectForKey:MinutesOddColor_OldKey];
		[colorDefaults setColor:defaultColor forKey:MinutesOddColorKey];
	}
	if (defaultColor = [colorDefaults colorForKey:MinutesEvenColor_OldKey]) {
		[colorDefaults removeObjectForKey:MinutesEvenColor_OldKey];
		[colorDefaults setColor:defaultColor forKey:MinutesEvenColorKey];
	}
	if (defaultColor = [colorDefaults colorForKey:TickMarksHourColor_OldKey]) {
		[colorDefaults removeObjectForKey:TickMarksHourColor_OldKey];
		[colorDefaults setColor:defaultColor forKey:TickMarksHourColorKey];
	}
	if (defaultColor = [colorDefaults colorForKey:TickMarksMinuteColor_OldKey]) {
		[colorDefaults removeObjectForKey:TickMarksMinuteColor_OldKey];
		[colorDefaults setColor:defaultColor forKey:TickMarksMinuteColorKey];
	}
	float defaultInnerDiscSize;
	if (defaultInnerDiscSize = [globalDefaults floatForKey:HoursDiscSize_OldKey]) {
		[globalDefaults removeObjectForKey:HoursDiscSize_OldKey];
		[layoutDefaults setFloat:defaultInnerDiscSize forKey:InnerDiscSizeKey];
	}

	// test keys
	showImagePreview = [globalDefaults boolForKey:ShowImagePreviewKey];
	if (showImagePreview)
		[testWindow orderFront:self];
	
	// read user defaults
	[self setActiveThemeName:[globalDefaults objectForKey:ActiveThemeNameKey]];
	showClockInMenuBar = [globalDefaults boolForKey:ShowClockInMenuBarKey];
	showClockInDock = [globalDefaults boolForKey:ShowClockInDockKey];
	showClockInWindow = [globalDefaults boolForKey:ShowClockInWindowKey] || !(showClockInDock || showClockInMenuBar);
	forceShowDockIcon = [globalDefaults boolForKey:ForceShowDockIconKey];
	
	if (!forceShowDockIcon && ([[self NSUIElement] isEqualToString:NSUIElementOff] != showClockInDock)) {
		if (showClockInDock) {
			[self setNSUIElement:NSUIElementOff];
		} else {
			if (!forceShowDockIcon)
				[self setNSUIElement:NSUIElementOn];
		}
	}

	if (dockIconAndMenuHidden)
		showClockInMenuBar = YES;

	menuBarShowClock = [menuBarDefaults boolForKey:MenuBarShowClockKey];
	menuBarUseIcon = [menuBarDefaults boolForKey:MenuBarUseIconKey];
	menuBarUseInanimatedIcon = [menuBarDefaults boolForKey:MenuBarUseInanimatedIconKey];
	menuBarShowTime = [menuBarDefaults boolForKey:MenuBarShowTimeKey];
	menuBarUse24h = [menuBarDefaults boolForKey:MenuBarUse24hKey];
	menuBarShowWeekday = [menuBarDefaults boolForKey:MenuBarShowWeekdayKey];
	menuBarShowDate = [menuBarDefaults boolForKey:MenuBarShowDateKey];
	// at least one menuBarShow item must be activated
	int menuBarShowItemsCount = 0;
	menuBarShowClock ? menuBarShowItemsCount++ : 0;
	menuBarShowTime ? menuBarShowItemsCount++ : 0;
	menuBarShowWeekday ? menuBarShowItemsCount++ : 0;
	menuBarShowDate ? menuBarShowItemsCount++ : 0;
	menuBarShowTime = (menuBarShowTime || (menuBarShowItemsCount == 0));

	clockPulse = [globalDefaults floatForKey:ClockPulseKey];
	forceAllowChangingClockPulse = [globalDefaults boolForKey:ForceAllowChangingClockPulseKey];

	useRenice = [globalDefaults boolForKey:ReniceKey];
	renicePriority = [globalDefaults integerForKey:RenicePriorityKey];

	windowSizeMax = [globalDefaults integerForKey:WindowSizeMaxKey];
	if (windowSizeMax < 64)
		windowSizeMax = 1024;
	NSRect defaultWindowFrame;
	defaultWindowFrame = [globalDefaults rectForKey:WindowFrameKey];

	float defaultAlphaValue;
	if ((defaultAlphaValue = [globalDefaults floatForKey:WindowAlphaValueKey]) <= 0) {
		defaultAlphaValue = 1.0;
		[globalDefaults setFloat:defaultAlphaValue forKey:WindowAlphaValueKey];
	}

	int defaultWindowLevel = [globalDefaults integerForKey:WindowLevelKey];
	showShadow = [globalDefaults boolForKey:WindowShowShadowKey];
	enableClickThrough = [globalDefaults boolForKey:EnableClickThroughKey];

	int defaultDisplaySeconds = [layoutDefaults integerForKey:DisplaySecondsKey];

	[self readThemePrefs];
	
	[self setRandomColorSourcePath:[globalDefaults stringForKey:ColorSourcePathKey]];
	BOOL isFolder;
	if ([[NSFileManager defaultManager] fileExistsAtPath:randomColorSourcePath isDirectory:&isFolder]) {
		if (isFolder)
			[self newRandomSourceImage:self];
		else
			[self setRandomColorSource:[[AMRandomColorSource alloc] initWithImageFromPath:randomColorSourcePath]];
	} else {
		[self setRandomColorSourcePath:nil];
		[self setRandomColorSource:[[AMRandomColorSource alloc] initWithColorMap]];
	}

	if (!dockIconAndMenuHidden) {
		// create dock image
		dockImage = [[TimeDiscImage alloc] initWithSize:NSMakeSize(128, 128)];
		[dockImage setDisplay:mainDisplay];
	}
	
	// create status item image
	int thickness = [[NSStatusBar systemStatusBar] thickness]-2;
	statusItemImage = [[TimeDiscImage alloc] initWithSize:NSMakeSize(thickness, thickness)];
	[statusItemImage setDisplay:mainDisplay];
	
	showClockInMenuBar = (showClockInMenuBar || dockIconAndMenuHidden);
	if (showClockInMenuBar)
		[self createStatusItem];

	
	if (clockPulse < 1.0)
		if (defaultDisplaySeconds != 0)
			clockPulse = 1.0;
		else
			clockPulse = 5.0;

	if (useRenice)
		[self doRenice:renicePriority];

	// set window defaults
	[mainWindow setAlphaValue:defaultAlphaValue];
	[self setClickThrough:enableClickThrough];
	[mainWindow setHasShadow:showShadow];
	if (defaultWindowFrame.size.width > 0)
		[mainWindow setFrame:defaultWindowFrame display:showClockInWindow animate:NO];
	if (showClockInWindow) {
		[mainWindow setFrameOrigin:[mainWindow constrainFrameRect:[mainWindow frame] toScreen:[mainWindow screen]].origin];
		[mainWindow orderFront:self];
	}
	[mainWindow setLevel:defaultWindowLevel];
	if ([mainWindow level] == kCGDesktopWindowLevel)
		[self setClickThrough:YES];

	
	// sound
	playTickSound = NO;
	//tickSoundPath = [[NSBundle mainBundle] pathForResource:@"TickSound" ofType:@"snd"];
	//tickSound = [[NSSound alloc] initWithContentsOfFile:tickSoundPath byReference:NO];
	//tickSound = [[NSSound soundNamed:@"Bottle"] retain];
}

- (void)readThemePrefs
{
	int defaultUnitRanking = [layoutDefaults integerForKey:UnitRankingKey];
	int defaultDisplaySeconds = [layoutDefaults integerForKey:DisplaySecondsKey];

	float defaultInnerDiscSize = [layoutDefaults floatForKey:InnerDiscSizeKey];
	if (defaultInnerDiscSize <= 0) {
		defaultInnerDiscSize = 0.8;
		[layoutDefaults setFloat:defaultInnerDiscSize forKey:InnerDiscSizeKey];
	}

	float defaultMiddleDiscSize;
	defaultMiddleDiscSize = [layoutDefaults floatForKey:MiddleDiscSizeKey];

	// set according to user defaults
	NSColor *defaultColor;
	if (defaultColor = [colorDefaults colorForKey:HoursAMColorKey])
		[mainDisplay setHoursAMColor:defaultColor];
	if (defaultColor = [colorDefaults colorForKey:HoursPMColorKey])
		[mainDisplay setHoursPMColor:defaultColor];
	if (defaultColor = [colorDefaults colorForKey:MinutesOddColorKey])
		[mainDisplay setMinutesOddColor:defaultColor];
	if (defaultColor = [colorDefaults colorForKey:MinutesEvenColorKey])
		[mainDisplay setMinutesEvenColor:defaultColor];
	if (defaultColor = [colorDefaults colorForKey:SecondsOddColorKey])
		[mainDisplay setSecondsOddColor:defaultColor];
	if (defaultColor = [colorDefaults colorForKey:SecondsEvenColorKey])
		[mainDisplay setSecondsEvenColor:defaultColor];
	if (defaultColor = [colorDefaults colorForKey:SecondsDotColorKey])
		[mainDisplay setSecondsDotColor:defaultColor];
	if (defaultColor = [colorDefaults colorForKey:TickMarksHourColorKey])
		[mainDisplay setTickMarksHourColor:defaultColor];
	if (defaultColor = [colorDefaults colorForKey:TickMarksMinuteColorKey])
		[mainDisplay setTickMarksMinuteColor:defaultColor];

	[mainDisplay setUnitRanking:defaultUnitRanking];
	[mainDisplay setDisplaySeconds:defaultDisplaySeconds];
	[mainDisplay setInnerDiscSize:defaultInnerDiscSize];
	[mainDisplay setMiddleDiscSize:defaultMiddleDiscSize];

	// registering defaults does not work when nested, so fix that here
	int tickMarksMinuteLength = [layoutDefaults integerForKey:TickMarksMinuteLengthKey];
	if (tickMarksMinuteLength == 0) // fix defaults
		[layoutDefaults setInteger:(tickMarksMinuteLength = 5) forKey:TickMarksMinuteLengthKey];
	int tickMarksHourLength = [layoutDefaults integerForKey:TickMarksHourLengthKey];
	if (tickMarksHourLength == 0) // fix defaults
		[layoutDefaults setInteger:(tickMarksHourLength = 12) forKey:TickMarksHourLengthKey];
	float tickMarksMinuteWidth = [layoutDefaults floatForKey:TickMarksMinuteWidthKey];
	if (tickMarksMinuteWidth == 0) // fix defaults
		[layoutDefaults setFloat:(tickMarksMinuteWidth = 1.0) forKey:TickMarksMinuteWidthKey];
	float tickMarksHourWidth = [layoutDefaults floatForKey:TickMarksHourWidthKey];
	if (tickMarksHourWidth == 0) // fix defaults
		[layoutDefaults setFloat:(tickMarksHourWidth = 1.0) forKey:TickMarksHourWidthKey];

	[mainDisplay setTickMarksMinuteLength:tickMarksMinuteLength];
	[mainDisplay setTickMarksHourLength:tickMarksHourLength];
	[mainDisplay setTickMarksMinuteWidth:tickMarksMinuteWidth];
	[mainDisplay setTickMarksHourWidth:tickMarksHourWidth];

	[mainDisplay setDisplay24Hours:[layoutDefaults boolForKey:Display24HoursKey]];
	[iconDisplay setDisplay24Hours:[layoutDefaults boolForKey:Display24HoursKey]];

	// clone theme folder if necessary
	//NSLog(@"Theme folder in main bundle: %@", [[NSBundle mainBundle] pathForResource:ThemeFolderName ofType:@""]);
	[[TimeDiscThemeManager alloc] initWithApplicationName:ApplicationName cloneFolder:[[NSBundle mainBundle] pathForResource:ThemeFolderName ofType:@""]];
	
	if ((defaultDisplaySeconds != TimeDiscSecondsNone) && !forceAllowChangingClockPulse){
		[self restartTimer:1.0];
	} else {
		[self restartTimer:clockPulse];
	}
}

- (void)updateShowClockInPrefs
{
	// 'Show Clock:'
	[showInWindowCheckBox setState:showClockInWindow ? NSOnState : NSOffState];
	[showInDockCheckBox setState:showClockInDock ? NSOnState : NSOffState];
	[showInMenuBarCheckBox setState:showClockInMenuBar ? NSOnState : NSOffState];
	// enable xxxCheckBox if an other option are checked
	[showInWindowCheckBox setEnabled:(showClockInDock || showClockInMenuBar)];
	[showInDockCheckBox setEnabled:(showClockInWindow || showClockInMenuBar)];
	[showInMenuBarCheckBox setEnabled:(!dockIconAndMenuHidden)];
	// show caution sign if showInDockCheckBox is different from startupSetting
	if ((forceShowDockIcon && !dockIconAndMenuHidden) || (([showInDockCheckBox state] == NSOffState) == dockIconAndMenuHidden)) {
		[showInDockCautionImage setImage:nil];
		[showInDockCautionTextField setStringValue:@""];
	} else {
		[showInDockCautionImage setImage:[NSImage imageNamed:@"caution_mini"]];
		if (!infoPlistIsWritable && (showClockInDock == dockIconAndMenuHidden)) {
			// failed to change NSUIElement
			if (showClockInDock)
				[showInDockCautionTextField setStringValue:NSLocalizedString(@"CAUTION-showDockIconFailed", @"")];
			else
				[showInDockCautionTextField setStringValue:NSLocalizedString(@"CAUTION-hideDockIconFailed", @"")];
		} else { // NSUIElement has been changed
			if (showClockInDock)
				[showInDockCautionTextField setStringValue:NSLocalizedString(@"CAUTION-showDockIcon", @"")];
			else
				[showInDockCautionTextField setStringValue:NSLocalizedString(@"CAUTION-hideDockIcon", @"")];
		}
	}
}

- (void)updateDisplay24HoursPrefs
{
	// display 24 hours
	[display24HoursCheckBox setState:[mainDisplay display24Hours] ? NSOnState : NSOffState];
}

- (void)updateMenuShowPrefs
{
	// 'Menu Bar Clock:'
	[menuShowClockCheckBox setState:menuBarShowClock ? NSOnState : NSOffState];
	[menuShowIconCheckBox setState:menuBarUseIcon ? NSOnState : NSOffState];
	[menuShowTimeCheckBox setState:menuBarShowTime ? NSOnState : NSOffState];
	[menuShow24hCheckBox setState:menuBarUse24h ? NSOnState : NSOffState];
	[menuShowWeekdayCheckBox setState:menuBarShowWeekday ? NSOnState : NSOffState];
	[menuShowDateCheckBox setState:menuBarShowDate ? NSOnState : NSOffState];
	// enable menuShow24hCheckBox only if menuShowTimeCheckBox is enabled
	[menuShow24hCheckBox setEnabled:menuBarShowTime];
	// enable menuShowIconCheckBox only if menuShowClockCheckBox is enabled
	[menuShowIconCheckBox setEnabled:menuBarShowClock];
	// at least one of the main items (excl. menuShow24hCheckBox) has to be selected
	// so disable the selected item if there is only one; enable all otherwise
	int checkedItemsCount = 0;
	menuBarShowClock ? checkedItemsCount++ : 0;
	menuBarShowTime ? checkedItemsCount++ : 0;
	menuBarShowWeekday ? checkedItemsCount++ : 0;
	menuBarShowDate ? checkedItemsCount++ : 0;
	if (checkedItemsCount < 2) {
		[menuShowClockCheckBox setEnabled:!menuBarShowClock];
		[menuShowTimeCheckBox setEnabled:!menuBarShowTime];
		[menuShowWeekdayCheckBox setEnabled:!menuBarShowWeekday];
		[menuShowDateCheckBox setEnabled:!menuBarShowDate];
	} else {
		[menuShowClockCheckBox setEnabled:YES];
		[menuShowTimeCheckBox setEnabled:YES];
		[menuShowWeekdayCheckBox setEnabled:YES];
		[menuShowDateCheckBox setEnabled:YES];
	}
}

- (void)updateClockPulsePrefs
{
	// 'Update Interval:'
	float interval = clockPulse;
	BOOL displaysSeconds = ([mainDisplay displaySeconds] != TimeDiscSecondsNone);
	if (displaysSeconds && !forceAllowChangingClockPulse){
		interval = 1.0;
	}
	[clockPulseSlider setFloatValue:interval];
	[clockPulseTextField setStringValue:[NSString stringWithFormat:@"%i s", (int)interval]];
	if (!forceAllowChangingClockPulse) {
		[clockPulseSlider setEnabled:!displaysSeconds];
		if (displaysSeconds)
			[clockPulseSlider setToolTip:NSLocalizedString(@"TOOLTIP-clockPulseLocked", @"")];
		else
			[clockPulseSlider setToolTip:nil];
	}
}

- (void)updatePriorityPrefs
{
	// 'Priority:'
	[reniceCheckBox setState:useRenice ? NSOnState : NSOffState];
	// disable reniceCheckBox if renice is not found or PID is unknown
	// ...
}

- (void)updateWindowSizePrefs
{
	// 'Window Size:'
	[windowSizeSlider setMaxValue:windowSizeMax];
	[windowSizeSlider setFloatValue:[timeDiscView frame].size.width];
	[windowSizeTextField setStringValue:[NSString stringWithFormat:@"%.0f px", [timeDiscView frame].size.width]];
}

- (void)updateTransparencyPrefs
{
	// 'Transparency:'
	[windowTransparencySlider setFloatValue:1.0-[mainWindow alphaValue]];
	[windowTransparencyTextField setStringValue:[NSString stringWithFormat:@"%.0f %%", 100-[mainWindow alphaValue]*100]];
}

- (void)updateWindowLevelPrefs
{
	// 'Window Level:'
	// for systems < 10.2 disable desktop window level setting
	if (!systemKnowsSetIgnoresMouseEvents) {
		[windowLevelDesktopRadioButton setEnabled:NO];
		[windowLevelDesktopRadioButton setToolTip:NSLocalizedString(@"TOOLTIP-MacOSX10.2only", @"")];
	}
	if ([mainWindow level] == kCGDesktopWindowLevel) {
		[windowLevelNormalRadioButton setState:NSOffState];
		[windowLevelFloatRadioButton setState:NSOffState];
		[windowLevelFloatAboveMenuBarCheckBox setEnabled:NO];
		[windowLevelDesktopRadioButton setState:NSOnState];
	} else if ([mainWindow level] == NSFloatingWindowLevel) {
		[windowLevelNormalRadioButton setState:NSOffState];
		[windowLevelDesktopRadioButton setState:NSOffState];
		[windowLevelFloatRadioButton setState:NSOnState];
		[windowLevelFloatAboveMenuBarCheckBox setEnabled:YES];
		[windowLevelFloatAboveMenuBarCheckBox setState:NSOffState];
	} else if ([mainWindow level] == NSStatusWindowLevel) {
		[windowLevelNormalRadioButton setState:NSOffState];
		[windowLevelDesktopRadioButton setState:NSOffState];
		[windowLevelFloatRadioButton setState:NSOnState];
		[windowLevelFloatAboveMenuBarCheckBox setEnabled:YES];
		[windowLevelFloatAboveMenuBarCheckBox setState:NSOnState];
	} else {
		[windowLevelNormalRadioButton setState:NSOnState];
		[windowLevelDesktopRadioButton setState:NSOffState];
		[windowLevelFloatRadioButton setState:NSOffState];
		[windowLevelFloatAboveMenuBarCheckBox setEnabled:NO];
	}
}

- (void)updateShowShadowPrefs
{
	[windowShadowCheckBox setState:showShadow ? NSOnState : NSOffState];
}

- (void)updateClickThroughPrefs
{
	// 'Clickthrough:'
	if (!systemKnowsSetIgnoresMouseEvents) {
		[self setNoClickThroughCheckBoxEnabled:NO];
		[self setNoClickThroughCheckBoxState:YES];
		[noClickThroughCheckBox setToolTip:NSLocalizedString(@"TOOLTIP-MacOSX10.2only", @"")];
	} else {
		if ([mainWindow level] == kCGDesktopWindowLevel) {
			[self setNoClickThroughCheckBoxEnabled:NO];
			[self setNoClickThroughCheckBoxState:NO];
		} else {
			[self setNoClickThroughCheckBoxEnabled:YES];
			[self setNoClickThroughCheckBoxState:enableClickThrough];
		}
	}
}

- (void)updateUnitRankingPrefs
{
	// 'Unit Ranking:'
	[unitRankingPopUpButton selectItemAtIndex:[unitRankingPopUpButton indexOfItemWithTag:[mainDisplay unitRanking]]];
}

- (void)updateDisplaySecondsPrefs
{
	// 'Show Seconds:'
	int displaySeconds = [mainDisplay displaySeconds];
	[displaySecondsRingRadioButton setState:(displaySeconds == TimeDiscSecondsRing) ? NSOnState : NSOffState];
	[displaySecondsDotRadioButton setState:(displaySeconds == TimeDiscSecondsDot) ? NSOnState : NSOffState];
	[displaySecondsNoneRadioButton setState:(displaySeconds == TimeDiscSecondsNone) ? NSOnState : NSOffState];
}

- (void)updateInnerDiscPrefs
{
	// 'Inner Disc Size:'
	[innerDiscSizeSlider setFloatValue:[mainDisplay innerDiscSize]*100];
	[innerDiscSizeTextField setStringValue:[NSString stringWithFormat:@"%.0f %%", [mainDisplay innerDiscSize]*100]];
}

- (void)updateMiddleDiscPrefs
{
	// 'Middle Disc Size:'
	[middleDiscSizeSlider setFloatValue:[mainDisplay middleDiscSize]*100];
	[middleDiscSizeTextField setStringValue:[NSString stringWithFormat:@"%.0f %%", [mainDisplay middleDiscSize]*100]];
}

- (void)updateMiddleDiscCautionPrefs
{
	// show warning if middle ring is smaller than inner disc
	BOOL middleRingInUse = (([mainDisplay displaySeconds] == TimeDiscSecondsRing) || (([mainDisplay unitRanking] != TimeDiscUnitRankingHSM) && ([mainDisplay unitRanking] != TimeDiscUnitRankingMSH)));
	if (middleRingInUse && ([mainDisplay middleDiscSize] <= [mainDisplay innerDiscSize])) {
		[middleRingCautionImage setImage:[NSImage imageNamed:@"caution_mini"]];
		[middleRingCautionText setStringValue:NSLocalizedString (@"CAUTION-middleRingToSmall", @"")];
	} else {
		[middleRingCautionImage setImage:nil];
		[middleRingCautionText setStringValue:@""];
	}
}

- (void)updateThemePrefs
{
	TimeDiscThemeManager *themeManager;
	NSArray *themeNameList;
	NSString *listEntry;
	//NSLog(@"updateThemePrefs");
	if (themeManager = [[TimeDiscThemeManager alloc] initWithApplicationName:ApplicationName]) {
		if (themeNameList = [themeManager themeNameList]) {
			// clear menu
			int index;
			int tag = 1;
			while ((index = [themePopUpButton indexOfItemWithTag:tag++]) != -1) {
				[themePopUpButton removeItemAtIndex:index];
			}
			// add themes
			index = [themePopUpButton indexOfItemWithTag:0];
			NSEnumerator *enumerator = [themeNameList objectEnumerator];
			while (listEntry = [enumerator nextObject]) {
				[themePopUpButton insertItemWithTitle:listEntry atIndex:++index];
				[[themePopUpButton itemAtIndex:index] setTag:index];
			}
		} else {
		}
	} else {
	}
	if (activeThemeName)
		[themePopUpButton selectItemWithTitle:activeThemeName];
	else
		[themePopUpButton selectItemAtIndex:[themePopUpButton indexOfItemWithTag:0]];
	if ([themePopUpButton indexOfSelectedItem] == -1)
		[themePopUpButton selectItemAtIndex:[themePopUpButton indexOfItemWithTag:0]];
	// disable "Unnamed" entry
	[themePopUpButton setNeedsDisplay:YES];
	[themeManager release];
}

- (void)updateHourColorLabelsPrefs
{
	if ([mainDisplay display24Hours]) {
		[hoursAMLabelTextField setStringValue:NSLocalizedString (@"HOURSAM-24h", @"")];
		[hoursPMLabelTextField setStringValue:NSLocalizedString (@"HOURSPM-24h", @"")];
	} else {
		[hoursAMLabelTextField setStringValue:NSLocalizedString (@"HOURSAM-12h", @"")];
		[hoursPMLabelTextField setStringValue:NSLocalizedString (@"HOURSPM-12h", @"")];
	}
}

- (void)updateColorPrefs
{
	// 'Colors:'
	[hoursAMColorWell setColor:[mainDisplay hoursAMColor]];
	[hoursPMColorWell setColor:[mainDisplay hoursPMColor]];
	[minutesOddColorWell setColor:[mainDisplay minutesOddColor]];
	[minutesEvenColorWell setColor:[mainDisplay minutesEvenColor]];
	[secondsOddColorWell setColor:[mainDisplay secondsOddColor]];
	[secondsEvenColorWell setColor:[mainDisplay secondsEvenColor]];
	[secondsDotColorWell setColor:[mainDisplay secondsDotColor]];
	[tickMarksColorWell setColor:[mainDisplay tickMarksHourColor]];
}

- (void)updateColorSourcePrefs
{
	NSString *s = nil;
	// 'Color Source:'
	if (randomColorSourcePath) {
		BOOL isFolder;
		if ([[NSFileManager defaultManager] fileExistsAtPath:randomColorSourcePath isDirectory:&isFolder]) {
			if (isFolder) {
				s = [NSString stringWithFormat:NSLocalizedString(@"IsFolderQuote", @""), [randomColorSourcePath lastPathComponent]];
			} else {
				s = [randomColorSourcePath lastPathComponent];
			}
		}
	} else { // empty color source
		s = NSLocalizedString(@"PALETTE", @"");
	}
	if (s)
		[sourcePictureTextField setStringValue:s];
}

- (void)updatePrefsWindow
{
	[self updateShowClockInPrefs];
	[self updateDisplay24HoursPrefs];
	[self updateMenuShowPrefs];
	[self updateClockPulsePrefs];
	[self updatePriorityPrefs];
	[self updateWindowSizePrefs];
	[self updateTransparencyPrefs];
	[self updateWindowLevelPrefs];
	[self updateShowShadowPrefs];
	[self updateClickThroughPrefs];
	[self updateUnitRankingPrefs];
	[self updateDisplaySecondsPrefs];
	[self updateInnerDiscPrefs];
	[self updateMiddleDiscPrefs];
	[self updateMiddleDiscCautionPrefs];
	[self updateThemePrefs];
	[self updateHourColorLabelsPrefs];
	[self updateColorPrefs];
	[self updateColorSourcePrefs];
}


// ============================================================
#pragma mark -
#pragma mark ━ action methods ━
// ============================================================
- (IBAction)showClockInWindowChanged:(id)sender
{
	showClockInWindow = ([sender state] == NSOnState);
	if (showClockInWindow) {
		[mainWindow setFrameOrigin:[mainWindow constrainFrameRect:[mainWindow frame] toScreen:[mainWindow screen]].origin];
		[mainWindow orderFront:self];
	} else {
		[mainWindow orderOut:self];
	}
	[self updateShowClockInPrefs];
	[globalDefaults setBool:showClockInWindow forKey:ShowClockInWindowKey];
}

- (IBAction)showClockInDockChanged:(id)sender
{
	showClockInDock = ([sender state] == NSOnState);
	if (showClockInDock) {
		if (!dockIconAndMenuHidden)
			[NSApp setApplicationIconImage:dockImage];
		[self setNSUIElement:NSUIElementOff];
	} else {
		if (!dockIconAndMenuHidden)
			[NSApp setApplicationIconImage:[NSImage imageNamed:@"TimeDiscIcon"]];
		if (!forceShowDockIcon)
			[self setNSUIElement:NSUIElementOn];
	}
	[self updateShowClockInPrefs];
	[globalDefaults setBool:showClockInDock forKey:ShowClockInDockKey];
}

- (IBAction)showClockInMenuBarChanged:(id)sender
{
	showClockInMenuBar = ([sender state] == NSOnState);
	if (showClockInMenuBar) {
		[self createStatusItem];
	} else {
		[self removeStatusItem];
	}
	[self updateShowClockInPrefs];
	[globalDefaults setBool:showClockInMenuBar forKey:ShowClockInMenuBarKey];
}

- (IBAction)display24HoursChanged:(id)sender
{
	BOOL display24Hours = ([sender state] == NSOnState);
	[layoutDefaults setBool:display24Hours forKey:Display24HoursKey];
	[mainDisplay setDisplay24Hours:display24Hours];
	[iconDisplay setDisplay24Hours:display24Hours];
	// preliminary - until user has control over tick mark sizes:
	if (display24Hours) {
		[mainDisplay setTickMarksHourLength:[mainDisplay tickMarksMinuteLength]];
	} else {
		[mainDisplay setTickMarksHourLength:12];
	}
	// and save this ...
	[layoutDefaults setInteger:[mainDisplay tickMarksHourLength] forKey:TickMarksHourLengthKey];
		
	[self update:nil];
	[self updateStatusItem];
	[self updateHourColorLabelsPrefs];
	[self themeNameChanged:nil sender:self];
}

- (IBAction)menuBarShowClockChanged:(id)sender
{
	menuBarShowClock = ([sender state] == NSOnState);
	[self updateMenuShowPrefs];
	[self updateStatusItem];
	[menuBarDefaults setBool:menuBarShowClock forKey:MenuBarShowClockKey];
}

- (IBAction)menuBarUseIconChanged:(id)sender
{
	menuBarUseIcon = ([sender state] == NSOnState);
	[self updateMenuShowPrefs];
	[self updateStatusItem];
	[menuBarDefaults setBool:menuBarUseIcon forKey:MenuBarUseIconKey];
}

- (IBAction)menuBarShowTimeChanged:(id)sender
{
	menuBarShowTime = ([sender state] == NSOnState);
	[self updateMenuShowPrefs];
	[self updateStatusItem];
	[menuBarDefaults setBool:menuBarShowTime forKey:MenuBarShowTimeKey];
}

- (IBAction)menuBarUse24hChanged:(id)sender
{
	menuBarUse24h = ([sender state] == NSOnState);
	[self updateMenuShowPrefs];
	[self updateStatusItem];
	[menuBarDefaults setBool:menuBarUse24h forKey:MenuBarUse24hKey];
}

- (IBAction)menuBarShowWeekdayChanged:(id)sender
{
	menuBarShowWeekday = ([sender state] == NSOnState);
	[self updateMenuShowPrefs];
	[self updateStatusItem];
	[menuBarDefaults setBool:menuBarShowWeekday forKey:MenuBarShowWeekdayKey];
}

- (IBAction)menuBarShowDateChanged:(id)sender
{
	menuBarShowDate = ([sender state] == NSOnState);
	[self updateMenuShowPrefs];
	[self updateStatusItem];
	[menuBarDefaults setBool:menuBarShowDate forKey:MenuBarShowDateKey];
}

- (IBAction)clockspeedChanged:(id)sender
{
	clockPulse = [sender floatValue];
	[globalDefaults setFloat:clockPulse forKey:ClockPulseKey];
	[self restartTimer:clockPulse];
	[self updateClockPulsePrefs];
}

- (IBAction)reniceChanged:(id)sender
{
	useRenice = ([sender state] == NSOnState);
	if (useRenice) {
		//[NSThread setThreadPriority:0.0];
		[self doRenice:renicePriority];
	} else {
		//[NSThread setThreadPriority:1.0];
		[self doRenice:0];
	}
	[globalDefaults setBool:useRenice forKey:ReniceKey];
	[self updatePriorityPrefs];
}


- (IBAction)windowSizeChanged:(id)sender
{
	NSRect oldFrame = [mainWindow frame];
	float r = oldFrame.size.width/2;
	float newSize = [(NSSlider *)sender floatValue];
	float rNew = newSize/2;
	NSPoint center = NSMakePoint(oldFrame.origin.x+r, oldFrame.origin.y+r);
	NSRect newFrame = NSMakeRect(center.x-rNew, center.y-rNew, newSize, newSize);
	[globalDefaults setRect:newFrame forKey:WindowFrameKey];
	[mainWindow setFrame:newFrame display:YES animate:YES];
	[self updateWindowSizePrefs];
	if (showShadow && [self secondsDotOverlaps])
		[self updateShadow];
}

- (IBAction)transparencyChanged:(id)sender
{
	if (showClockInWindow) {
		//set the window's alpha value from 0.0-1.0
		[mainWindow setAlphaValue:1.0-[sender floatValue]];
		//go ahead and tell the window to redraw things, which has the effect of calling CustomView's -drawRect: routine
		[globalDefaults setFloat:1.0-[sender floatValue] forKey:WindowAlphaValueKey];
		[mainWindow display];
		[self updateTransparencyPrefs];
	}
}

- (IBAction)windowLevelChanged:(id)sender
{
	BOOL floatingAction = NO;
	[self setClickThrough:enableClickThrough];
	if (sender == windowLevelFloatRadioButton) {
		if ([sender state] == NSOnState)
			floatingAction = YES;
	} else if (sender == windowLevelDesktopRadioButton) {
		if ([sender state] == NSOnState) {
			[mainWindow setLevel:kCGDesktopWindowLevel];
			[self setClickThrough:YES];
		}
	} else if (sender == windowLevelNormalRadioButton) {
		if ([sender state] == NSOnState) {
			[mainWindow setLevel:NSNormalWindowLevel];
		}
	}
	if (floatingAction || (sender == windowLevelFloatAboveMenuBarCheckBox)) {
		if ([windowLevelFloatAboveMenuBarCheckBox state] == NSOnState)
			[mainWindow setLevel:NSStatusWindowLevel];
		else
			[mainWindow setLevel:NSFloatingWindowLevel];
	}
	[globalDefaults setInteger:[mainWindow level] forKey:WindowLevelKey];
	[self updateWindowLevelPrefs];
	[self updateClickThroughPrefs];
}

- (IBAction)windowShowShadowChanged:(id)sender
{
	showShadow = ([sender state] == NSOnState);
	[globalDefaults setBool:showShadow forKey:WindowShowShadowKey];
	if ((showShadow) && [self secondsDotOverlaps])
		[self updateShadow];
	else
		[mainWindow setHasShadow:showShadow];
	//[self updateShowShadowPrefs];
}

- (IBAction)clickThroughChanged:(id)sender
{
	enableClickThrough = ([noClickThroughCheckBox state] == NSOffState);
	[self setClickThrough:enableClickThrough];
	[globalDefaults setBool:enableClickThrough forKey:EnableClickThroughKey];
	[self updateClickThroughPrefs];
}


- (IBAction)unitRankingChanged:(id)sender
{
	BOOL overlapOld = [self secondsDotOverlaps];
	int newRanking = [[sender selectedItem] tag];
	[mainDisplay setUnitRanking:newRanking];
	[layoutDefaults setInteger:newRanking forKey:UnitRankingKey];
	[self updateUnitRankingPrefs];
	if ((showShadow) && (overlapOld || [self secondsDotOverlaps]))
		[self updateShadow];
	else
		[self update:nil];
	[self themeNameChanged:nil sender:self];
}

- (IBAction)displaySecondsChanged:(id)sender
{
	int newValue = 0;
	if (sender == displaySecondsNoneRadioButton) {
		newValue = TimeDiscSecondsNone;
	} else if (sender == displaySecondsDotRadioButton) {
		newValue = TimeDiscSecondsDot;
	} else if (sender == displaySecondsRingRadioButton) {
		newValue = TimeDiscSecondsRing;
	}
	if ((newValue != TimeDiscSecondsNone) && !forceAllowChangingClockPulse){
		[self restartTimer:1.0];
	} else {
		[self restartTimer:clockPulse];
	}
	[mainDisplay setDisplaySeconds:newValue];
	[layoutDefaults setInteger:newValue forKey:DisplaySecondsKey];
	[self updateDisplaySecondsPrefs];
	[self updateClockPulsePrefs];
	[self updateMiddleDiscCautionPrefs];
	if ((showShadow) && [self secondsDotOverlaps])
		[self updateShadow];
	else
		[self update:nil];
	[self themeNameChanged:nil sender:self];
}

- (IBAction)innerDiscSizeChanged:(id)sender
{
	[layoutDefaults setFloat:[(NSSlider *)sender floatValue]/100 forKey:InnerDiscSizeKey];
	[mainDisplay setInnerDiscSize:[(NSSlider *)sender floatValue]/100];
	[self update:nil];
	[self updateInnerDiscPrefs];
	[self updateMiddleDiscCautionPrefs];
	[self themeNameChanged:nil sender:self];
}

- (IBAction)middleDiscSizeChanged:(id)sender
{
	[layoutDefaults setFloat:[(NSSlider *)sender floatValue]/100 forKey:MiddleDiscSizeKey];
	[mainDisplay setMiddleDiscSize:[(NSSlider *)sender floatValue]/100];
	[self update:nil];
	[self updateMiddleDiscPrefs];
	[self updateMiddleDiscCautionPrefs];
	if ((showShadow) && [self secondsDotOverlaps])
		[self updateShadow];
	[self themeNameChanged:nil sender:self];
}


- (IBAction)themeChanged:(id)sender
{
	NSMenuItem *item;
	if (item = [sender selectedItem]) {
		switch ([item tag]) {
			case 0: { // default theme
				[self updateThemePrefs];
				break;
			}
			case -1: { // new theme
				TimeDiscTheme *newTheme = [[[TimeDiscTheme alloc] initWithName:@"new" andDefaults:[NSUserDefaults standardUserDefaults]] autorelease];
				[self setThemeNamePanelController:[[[TimeDiscThemeNamePanelController alloc] initWithApplicationName:ApplicationName theme:newTheme delegate:self] autorelease]];
				[themeNamePanelController showPanelForWindow:[sender window]];
				break;
			}
			case -2: { // manage themes
				[self setThemePanelController:[[[TimeDiscThemePanelController alloc] initWithApplicationName:ApplicationName delegate:self] autorelease]];
				[themePanelController setStringToAppendToCopy:NSLocalizedString(@"APPEND-Copy", @"")];
				[themePanelController setExportPanelTitle:NSLocalizedString(@"TITLE-ExportTheme", @"")];
				[themePanelController setExportPanelPrompt:NSLocalizedString(@"EXPORT", @"")];
				[themePanelController setImportPanelTitle:NSLocalizedString(@"TITLE-ImportTheme", @"")];
				[themePanelController setImportPanelPrompt:NSLocalizedString(@"IMPORT", @"")];
				[themePanelController setUntitledString:NSLocalizedString(@"UNTITLED", @"")];
				[themePanelController showPanelForWindow:[sender window]];
				[self updateThemePrefs];
				break;
			}
			default: { // other theme
				TimeDiscThemeManager *themeManager = [[TimeDiscThemeManager alloc] initWithApplicationName:ApplicationName];
				TimeDiscTheme *newTheme = [themeManager themeWithName:[item title]];
				if (newTheme) {
					//NSLog(@"set new theme: %@", [newTheme name]);
					BOOL overlapOld = [self secondsDotOverlaps];
					[newTheme writeLayoutDefaults:layoutDefaults colorDefaults:colorDefaults];
					[self themeNameChanged:[newTheme name] sender:self];
					[self readThemePrefs];
					[self updateDisplay24HoursPrefs];
					[self updateClockPulsePrefs];
					[self updateUnitRankingPrefs];
					[self updateDisplaySecondsPrefs];
					[self updateInnerDiscPrefs];
					[self updateMiddleDiscPrefs];
					[self updateMiddleDiscCautionPrefs];
					[self updateThemePrefs];
					[self updateHourColorLabelsPrefs];
					[self updateColorPrefs];
					if ((showShadow) && (overlapOld || [self secondsDotOverlaps]))
						[self updateShadow];
					else
						[self update:nil];
				}
				break;
			}
		} // switch ([item tag])
	}
}

- (IBAction)hoursAMColorChanged:(id)sender
{
	NSColor *newColor;

	if (newColor = [(NSColorWell *)sender color]) {
		[colorDefaults setColor:newColor forKey:HoursAMColorKey];
		[mainDisplay setHoursAMColor:newColor];
		[self update:nil];
		[self themeNameChanged:nil sender:self];
	}
}

- (IBAction)hoursPMColorChanged:(id)sender
{
	NSColor *newColor;

	if (newColor = [(NSColorWell *)sender color]) {
		[colorDefaults setColor:newColor forKey:HoursPMColorKey];
		[mainDisplay setHoursPMColor:newColor];
		[self update:nil];
		[self themeNameChanged:nil sender:self];
	}
}

- (IBAction)minutesOddColorChanged:(id)sender
{
	NSColor *newColor;

	if (newColor = [(NSColorWell *)sender color]) {
		[colorDefaults setColor:newColor forKey:MinutesOddColorKey];
		[mainDisplay setMinutesOddColor:newColor];
		[self update:nil];
		[self themeNameChanged:nil sender:self];
	}
}

- (IBAction)minutesEvenColorChanged:(id)sender
{
	NSColor *newColor;

	if (newColor = [(NSColorWell *)sender color]) {
		[colorDefaults setColor:newColor forKey:MinutesEvenColorKey];
		[mainDisplay setMinutesEvenColor:newColor];
		[self update:nil];
		[self themeNameChanged:nil sender:self];
	}
}

- (IBAction)secondsOddColorChanged:(id)sender
{
	NSColor *newColor;

	if (newColor = [(NSColorWell *)sender color]) {
		[colorDefaults setColor:newColor forKey:SecondsOddColorKey];
		[mainDisplay setSecondsOddColor:newColor];
		[self update:nil];
		[self themeNameChanged:nil sender:self];
	}
}

- (IBAction)secondsEvenColorChanged:(id)sender
{
	NSColor *newColor;

	if (newColor = [(NSColorWell *)sender color]) {
		[colorDefaults setColor:newColor forKey:SecondsEvenColorKey];
		[mainDisplay setSecondsEvenColor:newColor];
		[self update:nil];
		[self themeNameChanged:nil sender:self];
	}
}

- (IBAction)secondsDotColorChanged:(id)sender
{
	NSColor *newColor;

	if (newColor = [(NSColorWell *)sender color]) {
		[colorDefaults setColor:newColor forKey:SecondsDotColorKey];
		[mainDisplay setSecondsDotColor:[(NSColorWell *)sender color]];
		[self update:nil];
		[self themeNameChanged:nil sender:self];
	}
}

- (IBAction)tickMarksColorChanged:(id)sender
{
	NSColor *newColor;

	if (newColor = [(NSColorWell *)sender color]) {
		[colorDefaults setColor:newColor forKey:TickMarksHourColorKey];
		[colorDefaults setColor:newColor forKey:TickMarksMinuteColorKey];
		[mainDisplay setTickMarksHourColor:[(NSColorWell *)sender color]];
		[mainDisplay setTickMarksMinuteColor:[(NSColorWell *)sender color]];
		[self update:nil];
		[self themeNameChanged:nil sender:self];
	}
}

- (IBAction)chooseSourcePicture:(id)sender
{
	NSOpenPanel *openPanel;
	NSButton *openButton;

	openPanel = [NSOpenPanel openPanel];
	[openPanel setCanChooseDirectories:YES];
	[openPanel setAllowsMultipleSelection:NO];
	[openPanel setResolvesAliases:NO];
	[openPanel setTitle:NSLocalizedString(@"CHOOSE-SourcePicture", @"")]; // localize!
	openButton = [[openPanel contentView] buttonWithTag:NSFileHandlingPanelOKButton];
	[openButton setTitle:NSLocalizedString(@"CHOOSE", @"")]; // localize!
	[openPanel beginSheetForDirectory:nil file:nil types:nil modalForWindow:[sender window] modalDelegate:self didEndSelector:@selector(chooseSourceOpenPanelDidEnd:returnCode:contextInfo:) contextInfo:nil];
}

- (void)chooseSourceOpenPanelDidEnd:(NSOpenPanel *)sheet returnCode:(int)returnCode contextInfo:(void  *)contextInfo
{
	NSString *newPath;
	BOOL isFolder;
	
	if (returnCode == NSOKButton) {
		newPath = [sheet filename];
		if ([[NSFileManager defaultManager] fileExistsAtPath:newPath isDirectory:&isFolder]) {
			[self setRandomColorSourcePath:newPath];
			[globalDefaults setObject:newPath forKey:ColorSourcePathKey];
			if (isFolder) {
				[self newRandomSourceImage:self];
			} else {
				[self setRandomColorSource:[[AMRandomColorSource alloc] initWithImageFromPath:newPath]];
			}
			[self chooseRandomColors:self];
		}
	} else {
		[self setRandomColorSourcePath:nil];
		[self setRandomColorSource:[[AMRandomColorSource alloc] initWithColorMap]];
	}
	[self updateColorSourcePrefs];
}

- (IBAction)chooseRandomColors:(id)sender
{
	NSColor *newHoursAMColor;
	NSColor *newHoursPMColor;
	NSColor *newMinutesOddColor;
	NSColor *newMinutesEvenColor;
	NSColor *newSecondsOddColor;
	NSColor *newSecondsEvenColor;
	NSColor *newSecondsDotColor;
	NSColor *newTickMarksColor;
	NSColor *newTickMarksHourColor = nil;
	BOOL cond1, cond2, cond3, cond4, cond5;
	int j;
	float deltaMin = 0.3;

	[self newRandomSourceImage:self];

	[randomColorSource setColorDeltaMax:.6];
	[randomColorSource setColorDeltaMin:deltaMin];

	j = 0;
	do {
		newHoursAMColor = [randomColorSource randomColor];
		newHoursPMColor = [randomColorSource randomColor];
		cond1 = [randomColorSource color:newHoursAMColor isDifferentFromColor:newHoursPMColor];
		if ([mainDisplay display24Hours]) { // 24 hours
			newTickMarksHourColor = [randomColorSource randomColor];
			[randomColorSource setColorDeltaMin:(2*deltaMin)];	// need greater contrast here
			cond2 = [randomColorSource color:newTickMarksHourColor isDifferentFromColor:newHoursAMColor];
			cond3 = [randomColorSource color:newTickMarksHourColor isDifferentFromColor:newHoursPMColor];
			[randomColorSource setColorDeltaMin:deltaMin];
		} else {
			cond2 = cond3 = YES;
		}
		j++;
		deltaMin -= 0.001;
	} while ((!(cond1 && cond2 && cond3)) && (j<300));
	deltaMin = 0.3;
	[colorDefaults setColor:newHoursAMColor forKey:HoursAMColorKey];
	[mainDisplay setHoursAMColor:newHoursAMColor];
	
	[colorDefaults setColor:newHoursPMColor forKey:HoursPMColorKey];
	[mainDisplay setHoursPMColor:newHoursPMColor];

	j = 0;
	do {
		newSecondsEvenColor = [randomColorSource randomColor];
		newSecondsOddColor = [randomColorSource randomColor];
		j++;
	} while ((![randomColorSource color:newSecondsEvenColor isDifferentFromColor:newSecondsOddColor]) && (j<200));
	[colorDefaults setColor:newSecondsEvenColor forKey:SecondsEvenColorKey];
	[mainDisplay setSecondsEvenColor:newSecondsEvenColor];

	[colorDefaults setColor:newSecondsOddColor forKey:SecondsOddColorKey];
	[mainDisplay setSecondsOddColor:newSecondsOddColor];
	
	j = 0;
	do {
		newMinutesOddColor = [randomColorSource randomColor];
		newMinutesEvenColor = [randomColorSource randomColor];
		newSecondsDotColor = [randomColorSource randomColor];
		newTickMarksColor = [randomColorSource randomColor];

		cond1 = [randomColorSource color:newMinutesOddColor isDifferentFromColor:newMinutesEvenColor];
		cond2 = [randomColorSource color:newSecondsDotColor isDifferentFromColor:newMinutesOddColor];
		cond3 = [randomColorSource color:newSecondsDotColor isDifferentFromColor:newMinutesEvenColor];
		[randomColorSource setColorDeltaMin:(2*deltaMin)];	// need greater contrast here
		cond4 = [randomColorSource color:newTickMarksColor isDifferentFromColor:newMinutesOddColor];
		cond5 = [randomColorSource color:newTickMarksColor isDifferentFromColor:newMinutesEvenColor];

		/*
		 if (!cond1)
		 NSLog(@"minute odd color too similar to minute even color");
		 if (!cond2)
		 NSLog(@"second color too similar to minute odd color");
		 if (!cond3)
		 NSLog(@"second color too similar to minute even color");
		 if (!cond4)
		 NSLog(@"tick color too similar to minute odd color");
		 if (!cond5)
		 NSLog(@"tick color too similar to minute even color");
		 */

		j++;
		deltaMin -= 0.001;
		//NSLog(@"%i. Versuch; setze deltaMin auf %f", j, deltaMin);
		[randomColorSource setColorDeltaMin:deltaMin];
	} while ((!(cond1 && cond2 && cond3 && cond4 && cond5)) && (j<300));
	
	[colorDefaults setColor:newMinutesOddColor forKey:MinutesOddColorKey];
	[mainDisplay setMinutesOddColor:newMinutesOddColor];
	
	[colorDefaults setColor:newMinutesEvenColor forKey:MinutesEvenColorKey];
	[mainDisplay setMinutesEvenColor:newMinutesEvenColor];
	
	[colorDefaults setColor:newSecondsDotColor forKey:SecondsDotColorKey];
	[mainDisplay setSecondsDotColor:newSecondsDotColor];
	
	[colorDefaults setColor:newTickMarksColor forKey:TickMarksHourColorKey];
	[colorDefaults setColor:newTickMarksColor forKey:TickMarksMinuteColorKey];
	if ([mainDisplay display24Hours]) { // 24 hours
		[mainDisplay setTickMarksHourColor:newTickMarksHourColor];
	} else {
		[mainDisplay setTickMarksHourColor:newTickMarksColor];
	}
	[mainDisplay setTickMarksMinuteColor:newTickMarksColor];

	[self update:nil];
	[self updateColorPrefs];
	[self themeNameChanged:nil sender:self];
}

- (IBAction)newRandomSourceImage:(id)sender
{
	BOOL isDirectory;
	NSString *picturePath;
	int randomIndex;
	NSArray *pictures = [[NSFileManager defaultManager] directoryContentsAtPath:randomColorSourcePath];
	if (pictures) {
		do {
			do {
				randomIndex = abs(rand()%[pictures count]);
			//NSLog(@"random index: %i", randomIndex);
				picturePath = [NSString pathWithComponents:[NSArray arrayWithObjects:randomColorSourcePath, [pictures objectAtIndex:randomIndex], nil]];
			} while ((![[NSFileManager defaultManager] fileExistsAtPath:picturePath isDirectory:&isDirectory]) || isDirectory);
			[self setRandomColorSource:[[AMRandomColorSource alloc] initWithImageFromPath:picturePath]];
		} while (!randomColorSource);
		[imageView setImage:[randomColorSource image]];
	}
	[self updateColorSourcePrefs];
}

- (IBAction)openPreferences:(id)sender
{
	[self updatePrefsWindow];

	//if (dockIconAndMenuHidden)
	[NSApp activateIgnoringOtherApps:YES];
	[prefsWindow makeKeyAndOrderFront:self];
}

- (IBAction)openReadMe:(id)sender
{
	[[NSWorkspace sharedWorkspace] openFile:[[NSBundle mainBundle] pathForResource:@"timedisc" ofType:@"html"]];
	//[[NSWorkspace sharedWorkspace] openFile:[[NSBundle mainBundle] pathForResource:@"TimeDisc Read Me" ofType:@"rtfd"]];
}

- (IBAction)openDateAndTimePreferencePane:(id)sender
{
	[[NSWorkspace sharedWorkspace] openFile:DateAndTimePrefPanePath];
}

- (IBAction)showAboutPanel:(id)sender
{
	if (!aboutPanelController)
		aboutPanelController = [[TimeDiscAboutPanelController alloc] initWithWindowNibName:@"About"];
	if (aboutPanelController)
		[[aboutPanelController window] makeKeyAndOrderFront:self];
}

// ============================================================
#pragma mark -
#pragma mark ━ various private methods ━
// ============================================================
- (void)setClickThrough:(BOOL)clickThrough
{
	if (systemKnowsSetIgnoresMouseEvents) {
		/* carbon */
		void *ref = [mainWindow windowRef];
		if (clickThrough)
			ChangeWindowAttributes(ref, AM_kWindowIgnoreClicksAttribute, kWindowNoAttributes);
		else
			ChangeWindowAttributes(ref, kWindowNoAttributes, AM_kWindowIgnoreClicksAttribute);
		/* cocoa */
		if (showClockInWindow)
			[mainWindow setIgnoresMouseEvents:clickThrough];
	}
}

- (void)setNoClickThroughCheckBoxState:(BOOL)onState
{
	if (systemKnowsSetIgnoresMouseEvents) {
		[noClickThroughCheckBox setState:(enableClickThrough ? NSOffState : NSOnState)];
	} else {
		[noClickThroughCheckBox setState:NSOnState];
		[noClickThroughCheckBox setEnabled:NO];
	}
}

- (void)setNoClickThroughCheckBoxEnabled:(BOOL)enabled
{
	if (systemKnowsSetIgnoresMouseEvents) {
		[noClickThroughCheckBox setEnabled:enabled];
	} else {
		[noClickThroughCheckBox setEnabled:NO];
	}
}

- (BOOL)canRenice
{
	return [[NSFileManager defaultManager] isExecutableFileAtPath:RenicePath];
}


// ============================================================
#pragma mark -
#pragma mark ━ window delegate methods ━
// ============================================================
- (void)windowDidMove:(NSNotification *)aNotification
{
	[globalDefaults setRect:[mainWindow frame] forKey:WindowFrameKey];
}

// ============================================================
#pragma mark -
#pragma mark ━ menu validation ━
// ============================================================
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
	if (menuItem == dateDisplayMenuItem) {
		[dateDisplayMenuItem setTitle:[[NSCalendarDate calendarDate] descriptionWithCalendarFormat:[globalDefaults objectForKey:NSDateFormatString] locale:[globalDefaults dictionary]]];
		return NO;
	}
	return YES;
}

// ============================================================
#pragma mark -
#pragma mark ━ theme manager delegate methods ━
// ============================================================
- (void)themeListChanged:(id)sender
{
	[self updateThemePrefs];
}

- (void)themeNameChanged:(NSString *)newThemeName sender:(id)sender
{
	if (![activeThemeName isEqualToString:newThemeName]) {
		[self setActiveThemeName:newThemeName];
		if (newThemeName != nil) {
			[globalDefaults setObject:newThemeName forKey:ActiveThemeNameKey];
		} else {
			[globalDefaults removeObjectForKey:ActiveThemeNameKey];
		}
		[self updateThemePrefs];
	}
}

- (void)themeCreationFailed:(NSString *)newThemeName sender:(id)sender
{
	AMDisplayPathFormatter *displayPath = [[[AMDisplayPathFormatter alloc] init] autorelease];
	[displayPath setDisplayTemplateIsFolderOnVolume:NSLocalizedString(@"PATH-IsFolderOnVolume", @"")];
	NSString *applicationSupportFolderDisplayName = [displayPath stringForObjectValue:[[NSFileManager defaultManager] findSystemFolderType:kApplicationSupportFolderType forDomain:kUserDomain]];
	NSRunAlertPanel([NSString stringWithFormat:NSLocalizedString(@"ALERT-ThemeCreationFailedTitle", @""), newThemeName], [NSString stringWithFormat:NSLocalizedString(@"ALERT-ThemeCreationFailedMsg", @""), ApplicationName, applicationSupportFolderDisplayName], NSLocalizedString(@"OK", @""), nil, nil);
}

- (void)themeExportFailed:(NSArray *)nameArray sender:(id)sender
{
	AMDisplayPathFormatter *displayPath = [[[AMDisplayPathFormatter alloc] init] autorelease];

	[displayPath setDisplayTemplateIsDesktop:NSLocalizedString(@"PATH-ToDesktop", @"")];
	[displayPath setDisplayTemplateIsVolume:NSLocalizedString(@"PATH-ToVolume", @"")];
	[displayPath setDisplayTemplateIsFolderOnVolume:NSLocalizedString(@"PATH-ToFolderOnVolume", @"")];
	[displayPath setDisplayTemplateIsFolderOnDesktop:NSLocalizedString(@"PATH-ToFolderOnDesktop", @"")];
	[displayPath setDisplayTemplateIsFileOnVolume:NSLocalizedString(@"PATH-IsFileOnVolume", @"")];
	NSRunAlertPanel([NSString stringWithFormat:NSLocalizedString(@"ALERT-ThemeExportFailedTitle", @""), [nameArray objectAtIndex:0]], [NSString stringWithFormat:NSLocalizedString(@"ALERT-ThemeExportFailedMsg", @""), [nameArray objectAtIndex:0], [displayPath stringForObjectValue:[[nameArray objectAtIndex:1] stringByDeletingLastPathComponent]]], NSLocalizedString(@"OK", @""), nil, nil);
}

- (void)themeImportFailed:(NSString *)filename sender:(id)sender
{
	AMDisplayPathFormatter *displayPath = [[[AMDisplayPathFormatter alloc] init] autorelease];
	[displayPath setDisplayTemplateIsFileOnDesktop:NSLocalizedString(@"PATH-IsFileOnDesktop", @"")];
	[displayPath setDisplayTemplateIsFolderOnDesktop:NSLocalizedString(@"PATH-IsFolderOnDesktop", @"")];
	[displayPath setDisplayTemplateIsFileInFolderOnDesktop:NSLocalizedString(@"PATH-IsFileInFolderOnDesktop", @"")];
	[displayPath setDisplayTemplateIsFileInFolderOnVolume:NSLocalizedString(@"PATH-IsFileInFolderOnVolume", @"")];
	[displayPath setDisplayTemplateIsFileOnVolume:NSLocalizedString(@"PATH-IsFileOnVolume", @"")];
	[displayPath setDisplayTemplateIsFolderOnVolume:NSLocalizedString(@"PATH-IsFolderOnVolume", @"")];
	NSRunAlertPanel(NSLocalizedString(@"ALERT-ThemeImportFailedTitle", @""), [NSString stringWithFormat:NSLocalizedString(@"ALERT-ThemeImportFailedMsg", @""), [displayPath stringForObjectValue:filename]], NSLocalizedString(@"OK", @""), nil, nil);
}


// ============================================================
#pragma mark -
#pragma mark ━ external notifications ━
// ============================================================
/*
- (void)logNotification:(NSNotification *)aNotification
{
    NSLog(@"notification received: %@", aNotification);
}
 */
- (void)desktopPictureChanged:(NSNotification *)aNotification
{
	/*
	 2002-11-13 00:17:25.764 TimeDisc[715] notification received: NSConcreteNotification 174f7b0 {name = com.apple.desktop; userInfo = <CFDictionary 0x174fc60 [0xa01303fc]>{type = mutable, count = 13, capacity = 22, pairs = (
																																																							  2 : <CFString 0x1750730 [0xa01303fc]>{contents = "Placement"} = <CFString 0x1750750 [0xa01303fc]>{contents = "Crop"}
																																																							  5 : <CFString 0x169f290 [0xa01303fc]>{contents = "Change"} = <CFString 0x169f2b0 [0xa01303fc]>{contents = "Never"}
																																																							  7 : <CFString 0x17507b0 [0xa01303fc]>{contents = "Random"} = <CFBoolean 0xa0131030 [0xa01303fc]>{value = true}
																																																							  12 : <CFString 0x169efd0 [0xa01303fc]>{contents = "DisplayID"} = <CFNumber 0x169eff0 [0xa01303fc]>{value = +860241985, type = kCFNumberSInt64Type}
																																																							  13 : <CFString 0x1750770 [0xa01303fc]>{contents = "PlacementKeyTag"} = <CFNumber 0x1750790 [0xa01303fc]>{value = +1, type = kCFNumberSInt64Type}
																																																							  14 : <CFString 0x169f050 [0xa01303fc]>{contents = "LastName"} = <CFString 0x1750710 [0xa01303fc]>{contents = "picture7.jpg"}
																																																							  19 : <CFString 0x169ef90 [0xa01303fc]>{contents = "CollectionString"} = <CFString 0x169efb0 [0xa01303fc]>{contents = "Desktop Pictures"}
																																																							  24 : <CFString 0x174f730 [0xa01303fc]>{contents = "ChangePath"} = <CFString 0x174f750 [0xa01303fc]>{contents = "/Volumes/Daten HD/Grafik/Bilder/Desktop Pictures"}
																																																							  26 : <CFString 0x174f7f0 [0xa01303fc]>{contents = "ChooseFolderPath"} = <CFString 0x174f750 [0xa01303fc]>{contents = "/Volumes/Daten HD/Grafik/Bilder/Desktop Pictures"}
																																																							  27 : <CFString 0x169f010 [0xa01303fc]>{contents = "ImageFileAlias"} = <CFData 0x169f1b0 [0xa01303fc]>{length = 192, capacity = 192, bytes = 0x0000000000c0000300000000b7fdab17 ... 20484400ffff0000}
																																																							  29 : <CFString 0x169f030 [0xa01303fc]>{contents = "ImageFilePath"} = <CFString 0x17506c0 [0xa01303fc]>{contents = "/Volumes/Daten HD/Grafik/Bilder/Desktop Pictures/10110.jpg"}
																																																							  30 : <CFString 0x174fc90 [0xa01303fc]>{contents = "TimerPopUpTag"} = <CFNumber 0x174fcb0 [0xa01303fc]>{value = +7, type = kCFNumberSInt64Type}
																																																							  31 : <CFString 0x174f790 [0xa01303fc]>{contents = "ChangeTime"} = <CFNumber 0x174f7d0 [0xa01303fc]>{value = +3600.00000000000000000000, type = kCFNumberFloat64Type}
																																																							  )}}

	 */
	NSString *imagePath = [[aNotification userInfo] objectForKey:@"ImageFilePath"];
	//NSLog(@"desktop picture changed. Picture: %@", imagePath);
	// load picture and sample some colors
	NSImage *desktopImage = [[[NSImage alloc] initWithContentsOfFile:imagePath] autorelease];
	if ([desktopImage isValid]) {
		//NSImageRep = [desktopImage bestRepresentationForDevice:nil];
	}

}

- (void)screenSaverActivated:(NSNotification *)aNotification
{
	if (showClockInWindow) {
		if ([[[aNotification userInfo] objectForKey:@"active"] isEqualToString:@"YES"]) {
			// screen saver activated - hide clock window
			[mainWindow orderOut:self];
		} else {
			// screen saver deactivated - unhide clock window
			if (![NSApp isHidden])
				[mainWindow orderFront:self];
		}
	}
}

// ============================================================
#pragma mark -
#pragma mark ━ update clock face ━
// ============================================================
- (void)update:(NSTimer *)timer
{
	NSCalendarDate *time = [[NSCalendarDate alloc] init];
	BOOL resync;

	if (playTickSound)
		[tickSound play];

	if (showClockInWindow)
		[timeDiscView setNeedsDisplay:YES];

	if (showClockInDock && !dockIconAndMenuHidden) {
		[dockImage draw];
		[NSApp setApplicationIconImage:dockImage];
	}

	if (showClockInMenuBar) {
		// redraw status item if:
		// a) clock is shown in menu bar AND seconds are displayed OR
		// b) last update was last (different) minute
		if (((menuBarShowClock && !menuBarUseIcon) && ([mainDisplay displaySeconds] != TimeDiscSecondsNone)) || ([lastMenuBarUpdate minuteOfHour] != [time minuteOfHour]))
			[self updateStatusItem];
		[self setLastMenuBarUpdate:time];
	}

	// restart timer every hour for resynchronization
	resync = ((clockPulse >= 1.0) && ([time minuteOfHour] == 0) && ([time secondOfMinute] == 0));
	// restart timer if last tick was more than 2*clockPulse before
	resync = (resync || ([time timeIntervalSinceDate:lastTick] > 2*clockPulse));

	//NSLog(@"time interval since last tick: %f", [time timeIntervalSinceDate:lastTick]);
	
	if (resync)  {
		//NSLog(@"restart timer to resync");
		if (([mainDisplay displaySeconds] != TimeDiscSecondsNone) && !forceAllowChangingClockPulse)
			[self restartTimer:1.0];
		else
			[self restartTimer:clockPulse];
	}

	[self setLastTick:time];
	[time release];
}

- (BOOL)secondsDotOverlaps
{
	return (([mainDisplay unitRanking] == TimeDiscUnitRankingHMS) || ([mainDisplay unitRanking] == TimeDiscUnitRankingMHS));
}

- (void)updateShadow
{
	// redraw shadow
	if (showShadow) {
		updateShadow_displaySeconds = [mainDisplay displaySeconds];
		if (updateShadow_displaySeconds == TimeDiscSecondsDot)
			[mainDisplay setDisplaySeconds:TimeDiscSecondsNone];
		[mainWindow setHasShadow:NO];
		[timeDiscView setNeedsDisplay:YES];
		[self performSelector:@selector(reenableShadow) withObject:nil afterDelay:0];
	}
	[self updateStatusItem];
}

- (void)reenableShadow
{
	[mainWindow setHasShadow:YES];
	[mainDisplay setDisplaySeconds:updateShadow_displaySeconds];
	[timeDiscView setNeedsDisplay:YES];
}

// ============================================================
#pragma mark -
#pragma mark ━ systems user interface (Dock, Status Items, etc.) ━
// ============================================================
- (void)createStatusItem
{
	int length = NSVariableStatusItemLength;
	if (menuBarShowClock && !(menuBarShowTime || menuBarShowWeekday || menuBarShowDate))
		length = NSSquareStatusItemLength;
	[self setStatusItem:[[NSStatusBar systemStatusBar] statusItemWithLength:length]];
	if (statusItem) {
		[self updateStatusItem];
		//[statusItem setImage:statusItemImage];
		//NSLog(@"statusItemMenu: %@", statusItemMenu);
		[dateDisplayMenuItem setEnabled:NO];
		[statusItem setMenu:statusItemMenu];
		[statusItem setHighlightMode:YES];
		[statusItem setEnabled:YES];
	}
}

- (void)removeStatusItem
{
	if (statusItem) {
		[[NSStatusBar systemStatusBar] removeStatusItem:statusItem];
		[self setStatusItem:nil];
	}
}

- (BOOL)localeUsesAMPM
{
	NSArray *AMPMArray;
	AMPMArray = [globalDefaults objectForKey:NSAMPMDesignation];
	return ![[AMPMArray objectAtIndex:0] isEqualToString:[AMPMArray objectAtIndex:1]];
}

- (void)updateStatusItem
{
	NSString *formatString = nil;
	
	if (statusItem) {
		// set square if clock only
		int length = NSVariableStatusItemLength;
		if (menuBarShowClock && !(menuBarShowTime || menuBarShowWeekday || menuBarShowDate))
			length = NSSquareStatusItemLength;
		[statusItem setLength:length];

		if (menuBarShowClock) {
			if (menuBarUseIcon) {
				if (!menuBarUseInanimatedIcon) {
					// clear image
					/*
					[iconImage lockFocus];
					[[NSColor clearColor] set];
					NSSize size = [iconImage size];
					NSRectFillUsingOperation(NSMakeRect(0, 0, size.width, size.height), NSCompositeCopy);
					[iconImage unlockFocus];
					 */

					memset([iconImageRep bitmapData], 0, [iconImageRep bytesPerPlane] * [iconImageRep numberOfPlanes]);
					[iconImage recache];

					// draw clock face
					[iconImage draw];
				}
				[statusItem setImage:iconImage];
			} else {
				[statusItemImage lockFocus];
				[[NSColor clearColor] set];
				NSSize size = [statusItemImage size];
				NSRectFillUsingOperation(NSMakeRect(0, 0, size.width, size.height), NSCompositeCopy);
				[statusItemImage unlockFocus];
				[statusItemImage draw];
				[statusItem setImage:statusItemImage];
			}
		} else {
			[statusItem setImage:nil];
		}
		if (menuBarShowTime || menuBarShowWeekday || menuBarShowDate) {
			if (menuBarShowTime) {
				if (menuBarShowWeekday) {
					if (menuBarShowDate) {
						if (menuBarUse24h) {
							formatString = NSLocalizedString (@"DATEANDTIME-w-d-t24", @"");
						} else { // 12h
							formatString = NSLocalizedString (@"DATEANDTIME-w-d-t", @"");
						}
					} else { // no date
						if (menuBarUse24h) {
							formatString = NSLocalizedString (@"DATEANDTIME-w-t24", @"");
						} else { // 12h
							formatString = NSLocalizedString (@"DATEANDTIME-w-t", @"");
						}
					}
				} else { // no weekday
					if (menuBarShowDate) {
						if (menuBarUse24h) {
							formatString = NSLocalizedString (@"DATEANDTIME-d-t24", @"");
						} else { // 12h
							formatString = NSLocalizedString (@"DATEANDTIME-d-t24", @"");
						}
					} else { // no date
						if (menuBarUse24h) {
							formatString = NSLocalizedString (@"DATEANDTIME-t24", @"");
						} else { // 12h
							formatString = NSLocalizedString (@"DATEANDTIME-t", @"");
						}
					}
				}
			} else if (menuBarShowWeekday) { // no time
				if (menuBarShowDate) {
					formatString = NSLocalizedString (@"DATEANDTIME-w-d", @"");
				} else { // no date
					formatString = NSLocalizedString (@"DATEANDTIME-w", @"");
				}
			} else if (menuBarShowDate) { // no weekday
				formatString = NSLocalizedString (@"DATEANDTIME-d", @"");
			}
			[statusItem setTitle:[[NSCalendarDate calendarDate] descriptionWithCalendarFormat:formatString locale:[[NSUserDefaults standardUserDefaults]
				dictionaryRepresentation]]];
			[statusItem setLength:NSVariableStatusItemLength];
		} else { // no text items
			[statusItem setTitle:nil];
		}
	}
}

- (BOOL)setNSUIElement:(NSString *)value
{
	BOOL result = NO;
	NSString *plistPath = nil;
	NSMutableDictionary *plist;
	//if (plistPath = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist" inDirectory:nil])
	if (plistPath = [[NSBundle mainBundle] bundlePath]) {
		plistPath = [plistPath stringByAppendingPathComponent:@"Contents"];
		plistPath = [plistPath stringByAppendingPathComponent:@"Info.plist"];
		infoPlistIsWritable = [[NSFileManager defaultManager] isWritableFileAtPath:plistPath];
	}
	if (infoPlistIsWritable)
		if (plist = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath]) {
			[plist setObject:value forKey:NSUIElementKey];
			result = [plist writeToFile:plistPath atomically:YES];
		}
	return result;
}

- (NSString *)NSUIElement
{
	NSString *result;
	NSString *plistPath = nil;
	NSMutableDictionary *plist;

	if ([[NSBundle mainBundle] respondsToSelector:@selector(objectForInfoDictionaryKey:)])
		result = [[NSBundle mainBundle] objectForInfoDictionaryKey:NSUIElementKey];
	else {	// 10.1.x
		result = NSUIElementOff;
		if (plistPath = [[NSBundle mainBundle] bundlePath]) {
			plistPath = [plistPath stringByAppendingPathComponent:@"Contents"];
			plistPath = [plistPath stringByAppendingPathComponent:@"Info.plist"];
			if ([[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
				if (plist = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath]) {
					result = [plist objectForKey:NSUIElementKey];
				}
			}
		}
	}
	return result;
}

- (void)doRenice:(int)niceValue
{
	int pid;
	NSTask *reniceTask;

	pid = [[NSProcessInfo processInfo] processIdentifier];

	reniceTask = [[[NSTask alloc] init] autorelease];
	[reniceTask setLaunchPath:RenicePath];
	[reniceTask setArguments:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%i", niceValue], [NSString stringWithFormat:@"%i", pid], nil]];
	[reniceTask launch];
}

- (void)restartTimer:(float)interval
{
	// stop old timer
	[timer invalidate];
	[timer release];
	// normalize interval
	if ((int)interval > 0)
		interval = (int)interval;
	else
		interval = (int)(interval*10)/10;
	// create new timer
	NSCalendarDate *startTime = [NSCalendarDate calendarDate];
	div_t divresult = div(([startTime secondOfMinute]+(int)interval), (int)interval);
	int startSecond = divresult.quot*(int)interval;
	//NSLog(@"start second for timer with interval %f: %i", interval, startSecond);
	startTime = [NSCalendarDate dateWithYear:[startTime yearOfCommonEra] month:[startTime monthOfYear] day:[startTime dayOfMonth] hour:[startTime hourOfDay] minute:[startTime minuteOfHour] second:startSecond timeZone:[startTime timeZone]];

	if (systemKnowsSetIgnoresMouseEvents) { // this is not really the right check ...
		timer = [[NSTimer alloc] initWithFireDate:startTime interval:interval target:self selector:@selector(update:) userInfo:nil repeats:YES];
	} else { // start timer right away
		timer = [[NSTimer timerWithTimeInterval:interval target:self selector:@selector(update:) userInfo:nil repeats:YES] retain];
	}
	[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
}


@end
