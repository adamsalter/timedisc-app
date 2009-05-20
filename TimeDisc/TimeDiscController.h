//
//  TimeDiscController.h
//  TimeDisc
//
//  Created by Andreas on Wed Nov 06 2002.
//  Copyright (c) 2002 Andreas Mayer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TimeDiscView.h"
#import "AMDefaultsDictionary.h"
#import "TimeDiscImage.h"
#import "AMRandomColorSource.h"
#import "TimeDiscThemeNamePanelController.h"
#import "TimeDiscThemePanelController.h"
#import "TimeDiscAboutPanelController.h"

@interface TimeDiscController : NSObject {
	NSTimer *timer;
	IBOutlet NSWindow *mainWindow;
	IBOutlet NSWindow *prefsWindow;
	IBOutlet TimeDiscView *timeDiscView;
	TimeDiscDisplay *mainDisplay;
	TimeDiscImage *dockImage;
	TimeDiscImage *statusItemImage;
	TimeDiscDisplay *iconDisplay;
	TimeDiscImage *iconImage;
	
	IBOutlet NSButton *showInWindowCheckBox;
	IBOutlet NSButton *showInDockCheckBox;
	IBOutlet NSButton *showInMenuBarCheckBox;
	IBOutlet NSButton *display24HoursCheckBox;
	IBOutlet NSImageView *showInDockCautionImage;
	IBOutlet NSTextField *showInDockCautionTextField;
	IBOutlet NSButton *menuShowClockCheckBox;
	IBOutlet NSButton *menuShowIconCheckBox;
	IBOutlet NSButton *menuShowTimeCheckBox;
	IBOutlet NSButton *menuShow24hCheckBox;
	IBOutlet NSButton *menuShowWeekdayCheckBox;
	IBOutlet NSButton *menuShowDateCheckBox;
	IBOutlet NSTextField *clockPulseTextField;
	IBOutlet NSSlider *clockPulseSlider;
	IBOutlet NSButton *reniceCheckBox;

	IBOutlet NSTextField *windowSizeTextField;
	IBOutlet NSSlider *windowSizeSlider;
	IBOutlet NSTextField *windowTransparencyTextField;
	IBOutlet NSSlider *windowTransparencySlider;
	IBOutlet NSButton *windowLevelNormalRadioButton;
	IBOutlet NSButton *windowLevelFloatRadioButton;
	IBOutlet NSButton *windowLevelFloatAboveMenuBarCheckBox;
	IBOutlet NSButton *windowLevelDesktopRadioButton;
	IBOutlet NSButton *windowShadowCheckBox;
	IBOutlet NSButton *noClickThroughCheckBox;

	IBOutlet NSPopUpButton *unitRankingPopUpButton;
	IBOutlet NSButton *displaySecondsRingRadioButton;
	IBOutlet NSButton *displaySecondsDotRadioButton;
	IBOutlet NSButton *displaySecondsNoneRadioButton;
	IBOutlet NSImageView *middleRingCautionImage;
	IBOutlet NSTextField *middleRingCautionText;
	IBOutlet NSTextField *innerDiscSizeTextField;
	IBOutlet NSSlider *innerDiscSizeSlider;
	IBOutlet NSTextField *middleDiscSizeTextField;
	IBOutlet NSSlider *middleDiscSizeSlider;

	IBOutlet NSPopUpButton *themePopUpButton;
	IBOutlet NSTextField *hoursAMLabelTextField;
	IBOutlet NSTextField *hoursPMLabelTextField;
	IBOutlet NSColorWell *hoursAMColorWell;
	IBOutlet NSColorWell *hoursPMColorWell;
	IBOutlet NSColorWell *minutesOddColorWell;
	IBOutlet NSColorWell *minutesEvenColorWell;
	IBOutlet NSColorWell *secondsOddColorWell;
	IBOutlet NSColorWell *secondsEvenColorWell;	
	IBOutlet NSColorWell *secondsDotColorWell;
	IBOutlet NSColorWell *tickMarksColorWell;
	IBOutlet NSTextField *sourcePictureTextField;
	IBOutlet NSButton *chooseSourcePictureButton;
	IBOutlet NSButton *chooseRandomColorsButton;

	AMDefaultsDictionary *globalDefaults;
	AMDefaultsDictionary *colorDefaults;
	AMDefaultsDictionary *layoutDefaults;
	AMDefaultsDictionary *menuBarDefaults;
	BOOL showClockInDock;
	BOOL showClockInWindow;
	BOOL showClockInMenuBar;
	BOOL forceShowDockIcon;
	BOOL menuBarShowClock;
	BOOL menuBarUseIcon;
	BOOL menuBarUseInanimatedIcon;
	BOOL menuBarShowTime;
	BOOL menuBarUse24h;
	BOOL menuBarShowWeekday;
	BOOL menuBarShowDate;
	float clockPulse;
	BOOL forceAllowChangingClockPulse;
	BOOL useRenice;
	int renicePriority;
	BOOL showShadow;
	BOOL enableClickThrough;
	int windowSizeMax;
	NSString *colorSourcePath;
	NSStatusItem *statusItem;
	IBOutlet NSMenu *statusItemMenu;
	IBOutlet NSMenuItem *dateDisplayMenuItem;
	float statusItemSize;
	NSBitmapImageRep *iconImageRep;
	NSString *tickSoundPath;
	NSSound *tickSound;
	BOOL infoPlistIsWritable;
	int updateShadow_displaySeconds;
 	
	BOOL playTickSound;

	// as set by NSUIElement in the info.plist
	BOOL dockIconAndMenuHidden;
	// for compatibility
	BOOL systemKnowsSetIgnoresMouseEvents;

	AMRandomColorSource *randomColorSource;
	NSString *randomColorSourcePath;
	IBOutlet NSWindow *testWindow;
	IBOutlet NSButton *chooseRandomColors;
	IBOutlet NSImageView *imageView;
	BOOL showImagePreview;
	NSCalendarDate *lastTick;
	NSCalendarDate *lastMenuBarUpdate;
	TimeDiscThemeNamePanelController *themeNamePanelController;
	TimeDiscThemePanelController *themePanelController;
	TimeDiscAboutPanelController *aboutPanelController;
	NSString *activeThemeName;
}

- (AMDefaultsDictionary *)globalDefaults;

- (AMDefaultsDictionary *)colorDefaults;


- (IBAction)showClockInWindowChanged:(id)sender;

- (IBAction)showClockInDockChanged:(id)sender;

- (IBAction)showClockInMenuBarChanged:(id)sender;

- (IBAction)display24HoursChanged:(id)sender;

- (IBAction)menuBarShowClockChanged:(id)sender;

- (IBAction)menuBarUseIconChanged:(id)sender;

- (IBAction)menuBarShowTimeChanged:(id)sender;

- (IBAction)menuBarUse24hChanged:(id)sender;

- (IBAction)menuBarShowWeekdayChanged:(id)sender;

- (IBAction)menuBarShowDateChanged:(id)sender;

- (IBAction)clockspeedChanged:(id)sender;

- (IBAction)reniceChanged:(id)sender;


- (IBAction)windowSizeChanged:(id)sender;

- (IBAction)transparencyChanged:(id)sender;

- (IBAction)windowLevelChanged:(id)sender;

- (IBAction)windowShowShadowChanged:(id)sender;

- (IBAction)clickThroughChanged:(id)sender;


- (IBAction)unitRankingChanged:(id)sender;

- (IBAction)displaySecondsChanged:(id)sender;

- (IBAction)innerDiscSizeChanged:(id)sender;

- (IBAction)middleDiscSizeChanged:(id)sender;


- (IBAction)themeChanged:(id)sender;

- (IBAction)hoursAMColorChanged:(id)sender;

- (IBAction)hoursPMColorChanged:(id)sender;

- (IBAction)minutesOddColorChanged:(id)sender;

- (IBAction)minutesEvenColorChanged:(id)sender;

- (IBAction)secondsOddColorChanged:(id)sender;

- (IBAction)secondsEvenColorChanged:(id)sender;

- (IBAction)secondsDotColorChanged:(id)sender;

- (IBAction)tickMarksColorChanged:(id)sender;

- (IBAction)chooseSourcePicture:(id)sender;

- (IBAction)chooseRandomColors:(id)sender;


- (IBAction)openPreferences:(id)sender;

- (IBAction)openReadMe:(id)sender;

- (IBAction)openDateAndTimePreferencePane:(id)sender;

- (IBAction)showAboutPanel:(id)sender;


- (IBAction)newRandomSourceImage:(id)sender;


@end
