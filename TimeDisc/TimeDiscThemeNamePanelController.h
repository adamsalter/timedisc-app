//
//  TimeDiscThemeNamePanelController.h
//  TimeDisc
//
//  Created by Andreas on Wed Jan 22 2003.
//  Copyright (c) 2003 Andreas Mayer. All rights reserved.
//

#import <AppKit/AppKit.h>
#import "TimeDiscThemeManager.h"
#import "TimeDiscTheme.h"


@interface TimeDiscThemeNamePanelController : NSWindowController {
	IBOutlet NSTextField *themeNameTextField;
	IBOutlet NSButton *okButton;

	TimeDiscThemeManager *themeManager;
	TimeDiscTheme *theme;
}

- (id)initWithApplicationName:(NSString *)appName theme:(TimeDiscTheme *)newTheme delegate:(id)theDelegate;

- (void)showPanelForWindow:(NSWindow *)docWindow;

- (IBAction)commit:(id)sender;
- (IBAction)dismiss:(id)sender;

- (void)controlTextDidChange:(NSNotification *)aNotification;

@end
