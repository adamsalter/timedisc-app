//
//  TimeDiscThemePanelController.h
//  TimeDisc
//
//  Created by Andreas on Wed Jan 22 2003.
//  Copyright (c) 2003 Andreas Mayer. All rights reserved.
//

#import <AppKit/AppKit.h>
#import "TimeDiscThemeManager.h"
#import "TimeDiscTheme.h"
#import "AMScrollViewDraggingDestination.h"


@interface TimeDiscThemePanelController : NSWindowController {
	IBOutlet NSButton *okButton;
	IBOutlet NSButton *copyButton;
	IBOutlet NSButton *renameButton;
	IBOutlet NSButton *deleteButton;
	IBOutlet NSButton *importButton;
	IBOutlet NSButton *exportButton;
	IBOutlet NSTableView *themeNamesTableView;
	IBOutlet AMScrollViewDraggingDestination *themeNamesScrollView;

	TimeDiscThemeManager *themeManager;
	TimeDiscTheme *theme;
	NSString *stringToAppendToCopy;
	NSString *exportPanelTitle;
	NSString *importPanelTitle;
	NSString *exportPanelPrompt;
	NSString *importPanelPrompt;

	NSString *draggedThemeName;
	NSString *untitledString;
}

- (id)initWithApplicationName:(NSString *)appName delegate:(id)theDelegate;

- (void)showPanelForWindow:(NSWindow *)docWindow;

- (NSString *)stringToAppendToCopy;
- (void)setStringToAppendToCopy:(NSString *)newStringToAppendToCopy;
- (NSString *)exportPanelTitle;
- (void)setExportPanelTitle:(NSString *)newExportPanelTitle;
- (NSString *)importPanelTitle;
- (void)setImportPanelTitle:(NSString *)newImportPanelTitle;
- (NSString *)exportPanelPrompt;
- (void)setExportPanelPrompt:(NSString *)newExportPanelPrompt;
- (NSString *)importPanelPrompt;
- (void)setImportPanelPrompt:(NSString *)newImportPanelPrompt;

- (NSString *)draggedThemeName;
- (void)setDraggedThemeName:(NSString *)newDraggedThemeName;

- (NSString *)untitledString;
- (void)setUntitledString:(NSString *)newUntitledString;


- (IBAction)copyTheme:(id)sender;
- (IBAction)renameTheme:(id)sender;
- (IBAction)deleteTheme:(id)sender;
- (IBAction)importTheme:(id)sender;
- (IBAction)exportTheme:(id)sender;

- (IBAction)commit:(id)sender;

- (void)controlTextDidChange:(NSNotification *)aNotification;

- (void)deleteDraggedTheme;


@end
