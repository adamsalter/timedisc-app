//
//  TimeDiscThemeNamePanelController.m
//  TimeDisc
//
//  Created by Andreas on Wed Jan 22 2003.
//  Copyright (c) 2003 Andreas Mayer. All rights reserved.
//

#import "TimeDiscThemeNamePanelController.h"
#import "AMFileNameFormatter.h"


@interface TimeDiscThemeNamePanelController (Private)
- (TimeDiscTheme *)theme;
- (void)setTheme:(TimeDiscTheme *)newTheme;
- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void  *)contextInfo;
@end


@implementation TimeDiscThemeNamePanelController

- (id)initWithApplicationName:(NSString *)appName theme:(TimeDiscTheme *)newTheme delegate:(id)theDelegate
{
	if ([self initWithWindowNibName:@"ThemeNamePanel"]) {
		themeManager = [[TimeDiscThemeManager alloc] initWithApplicationName:appName];
		[themeManager setDelegate:theDelegate];
		[self setTheme:newTheme];
	}
	return self;
}

- (void)awakeFromNib
{
	[themeNameTextField setDelegate:self];
	[[themeNameTextField cell] setFormatter:[[[AMFileNameFormatter alloc] init] autorelease]];
}

- (TimeDiscTheme *)theme
{
    return theme;
}

- (void)setTheme:(TimeDiscTheme *)newTheme
{
    id old = nil;

    if (newTheme != theme) {
        old = theme;
        theme = [newTheme retain];
        [old release];
    }
}

- (void)dealloc
{
	[theme release];
	[themeManager release];
	[super dealloc];
}

- (void)showPanelForWindow:(NSWindow *)docWindow
{
	[NSApp beginSheet:[self window] modalForWindow:docWindow modalDelegate:self didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) contextInfo:nil];
}

- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void  *)contextInfo
{
	if (returnCode == NSOKButton) {
		[theme setName:[themeNameTextField stringValue]];
		if (![themeManager themeExistsWithName:[theme name]]) {
			if (![themeManager addTheme:theme]) {
				// error creating theme file
				NSLog(@"TimeDiscThemeNamePanelController - error creating theme file named: %@", [theme name]);
				if ([[themeManager delegate] respondsToSelector:@selector(themeCreationFailed:sender:)])
					[[themeManager delegate] performSelector:@selector(themeCreationFailed:sender:) withObject:[theme name] withObject:self];				
			} else {
				if ([[themeManager delegate] respondsToSelector:@selector(themeNameChanged:sender:)])
					[[themeManager delegate] performSelector:@selector(themeNameChanged:sender:) withObject:[theme name] withObject:self];
			}
		} else {
			// error - theme exists
			NSLog(@"TimeDiscThemeNamePanelController - theme exists: %@", [theme name]);
			// really should not happen since we do not allow entering existing
			// theme names in the first place ...
		}
	}
	[sheet orderOut:self];
}

- (IBAction)commit:(id)sender
{
	[NSApp endSheet:[self window] returnCode:NSOKButton];
}

- (IBAction)dismiss:(id)sender
{
	[NSApp endSheet:[self window] returnCode:NSCancelButton];
}


- (void)controlTextDidChange:(NSNotification *)aNotification
{
	NSText *fieldEditor = [[aNotification userInfo] objectForKey:@"NSFieldEditor"];
	[okButton setEnabled:![[themeManager themeNameList] containsObject:[fieldEditor string]]];
}


@end
