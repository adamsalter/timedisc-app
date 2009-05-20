//
//  TimeDiscThemePanelController.m
//  TimeDisc
//
//  Created by Andreas on Wed Jan 22 2003.
//  Copyright (c) 2003 Andreas Mayer. All rights reserved.
//

#import "TimeDiscThemePanelController.h"
#import "AMFileNameFormatter.h"

#define ThemeExtension @"tdt"

@interface TimeDiscThemePanelController (Private)
- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void  *)contextInfo;
@end


@implementation TimeDiscThemePanelController

- (id)initWithApplicationName:(NSString *)appName delegate:(id)theDelegate
{
	if ([self initWithWindowNibName:@"ThemePanel"]) {
		themeManager = [[TimeDiscThemeManager alloc] initWithApplicationName:appName];
		[themeManager setDelegate:theDelegate];
		[self setStringToAppendToCopy:@"Copy"];
		[self setUntitledString:@"Untitled"];
	}
	return self;
}

- (void)awakeFromNib
{
	[themeNamesTableView setDataSource:self];
	[themeNamesTableView setDelegate:self];
	[[[[themeNamesTableView tableColumns] objectAtIndex:0] dataCell] setFormatter:[[[AMFileNameFormatter alloc] init] autorelease]];
	[themeNamesTableView selectRow:0 byExtendingSelection:NO];
	[themeNamesScrollView setDelegate:self];
	[themeNamesScrollView registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, NSStringPboardType, nil]];
	[themeNamesScrollView setHighlightingView:themeNamesTableView];
}

- (void)dealloc
{
	[theme release];
	[themeManager release];
	[stringToAppendToCopy release];
	[exportPanelTitle release];
	[importPanelTitle release];
	[exportPanelPrompt release];
	[importPanelPrompt release];
	[draggedThemeName release];
	[untitledString release];
	[super dealloc];
}

- (void)showPanelForWindow:(NSWindow *)docWindow
{
	[NSApp beginSheet:[self window] modalForWindow:docWindow modalDelegate:self didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) contextInfo:nil];
}

- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void  *)contextInfo
{
	[sheet orderOut:self];
}


// ============================================================
#pragma mark -
#pragma mark ━ setter/getters ━
// ============================================================
- (NSString *)stringToAppendToCopy
{
    return stringToAppendToCopy;
}

- (void)setStringToAppendToCopy:(NSString *)newStringToAppendToCopy
{
    id old = nil;

    if (newStringToAppendToCopy != stringToAppendToCopy) {
        old = stringToAppendToCopy;
        stringToAppendToCopy = [newStringToAppendToCopy retain];
        [old release];
    }
}

- (NSString *)exportPanelTitle
{
    return exportPanelTitle;
}

- (void)setExportPanelTitle:(NSString *)newExportPanelTitle
{
    id old = nil;

    if (newExportPanelTitle != exportPanelTitle) {
        old = exportPanelTitle;
        exportPanelTitle = [newExportPanelTitle retain];
        [old release];
    }
}

- (NSString *)importPanelTitle
{
    return importPanelTitle;
}

- (void)setImportPanelTitle:(NSString *)newImportPanelTitle
{
    id old = nil;

    if (newImportPanelTitle != importPanelTitle) {
        old = importPanelTitle;
        importPanelTitle = [newImportPanelTitle retain];
        [old release];
    }
}

- (NSString *)exportPanelPrompt
{
    return exportPanelPrompt;
}

- (void)setExportPanelPrompt:(NSString *)newExportPanelPrompt
{
    id old = nil;

    if (newExportPanelPrompt != exportPanelPrompt) {
        old = exportPanelPrompt;
        exportPanelPrompt = [newExportPanelPrompt retain];
        [old release];
    }
}

- (NSString *)importPanelPrompt
{
    return importPanelPrompt;
}

- (void)setImportPanelPrompt:(NSString *)newImportPanelPrompt
{
    id old = nil;

    if (newImportPanelPrompt != importPanelPrompt) {
        old = importPanelPrompt;
        importPanelPrompt = [newImportPanelPrompt retain];
        [old release];
    }
}

- (NSString *)draggedThemeName
{
    return draggedThemeName;
}

- (void)setDraggedThemeName:(NSString *)newDraggedThemeName
{
    id old = nil;

    if (newDraggedThemeName != draggedThemeName) {
        old = draggedThemeName;
        draggedThemeName = [newDraggedThemeName retain];
        [old release];
    }
}

- (NSString *)untitledString
{
    return untitledString;
}

- (void)setUntitledString:(NSString *)newUntitledString
{
    id old = nil;

    if (newUntitledString != untitledString) {
        old = untitledString;
        untitledString = [newUntitledString retain];
        [old release];
    }
}

// ============================================================
#pragma mark -
#pragma mark ━ action methods ━
// ============================================================

- (IBAction)copyTheme:(id)sender
{
	TimeDiscTheme *newTheme = [[[themeManager themeWithName:[[themeManager themeNameList] objectAtIndex:[themeNamesTableView selectedRow]]] copy] autorelease];
	if (newTheme) {
		NSString *baseName = [[newTheme name] stringByAppendingString:stringToAppendToCopy];
		NSString *newName = baseName;
		int i = 1;
		while ([themeManager themeExistsWithName:newName])
			newName = [baseName stringByAppendingFormat:@" %i", ++i];
		[newTheme setName:newName];
		if (![themeManager addTheme:newTheme]) {
			// error creating copy
			NSLog(@"TimeDiscThemePanelController - error creating theme file named: %@", [theme name]);
			if ([[themeManager delegate] respondsToSelector:@selector(themeCreationFailed:sender:)])
				[[themeManager delegate] performSelector:@selector(themeCreationFailed:sender:) withObject:[theme name] withObject:self];
		} else {
			[themeNamesTableView reloadData];
			[themeNamesTableView editColumn:0 row:[[themeManager themeNameList] indexOfObject:[newTheme name]] withEvent:nil select:YES];
		}
	}
}

- (IBAction)renameTheme:(id)sender
{
	[themeNamesTableView editColumn:0 row:[themeNamesTableView selectedRow] withEvent:nil select:YES];
}

- (IBAction)deleteTheme:(id)sender
{
	[themeManager removeThemeWithName:[[themeManager themeNameList] objectAtIndex:[themeNamesTableView selectedRow]]];
	[themeNamesTableView reloadData];
}

- (IBAction)importTheme:(id)sender
{
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	[openPanel setTitle:importPanelTitle];
	[openPanel setPrompt:importPanelPrompt];
	[openPanel setCanChooseFiles:YES];
	[openPanel setCanChooseDirectories:NO];
	[openPanel setAllowsMultipleSelection:YES];
	if ([openPanel runModalForDirectory:nil file:nil types:[NSArray arrayWithObject:ThemeExtension]] == NSFileHandlingPanelOKButton) {
		NSEnumerator *enumerator = [[openPanel filenames] objectEnumerator];
		NSString *filename;
		TimeDiscTheme *newTheme;
		while (filename = [enumerator nextObject]) {
			newTheme = [[TimeDiscTheme alloc] initWithPath:filename];
			if ((newTheme == nil) ) {
				// error reading theme
				NSLog(@"error importing theme from %@", filename);
				if ([[themeManager delegate] respondsToSelector:@selector(themeImportFailed:sender:)])
					[[themeManager delegate] performSelector:@selector(themeImportFailed:sender:) withObject:filename withObject:self];
			} else {
				if ([themeManager themeExistsWithName:[newTheme name]]) {
					// theme already exists - rename
					NSString *baseName = [[newTheme name] stringByAppendingString:stringToAppendToCopy];
					NSString *newName = baseName;
					int i = 1;
					while ([themeManager themeExistsWithName:newName])
						newName = [baseName stringByAppendingFormat:@" %i", ++i];
					[newTheme setName:newName];
				}
				if (![themeManager addTheme:newTheme]) {
					// error adding theme
					NSLog(@"error adding theme %@", [newTheme name]);
					if ([[themeManager delegate] respondsToSelector:@selector(themeCreationFailed:sender:)])
						[[themeManager delegate] performSelector:@selector(themeCreationFailed:sender:) withObject:[theme name] withObject:self];
				}
			}
		}
		[themeNamesTableView reloadData];
		if ([[themeManager delegate] respondsToSelector:@selector(themeListChanged:)])
			[[themeManager delegate] performSelector:@selector(themeListChanged:) withObject:self];
	}
}

- (IBAction)exportTheme:(id)sender
{
	TimeDiscTheme *selectedTheme = [themeManager themeWithName:[[themeManager themeNameList] objectAtIndex:[themeNamesTableView selectedRow]]];
	NSSavePanel *savePanel = [NSSavePanel savePanel];
	[savePanel setRequiredFileType:ThemeExtension];
	[savePanel setTitle:exportPanelTitle];
	[savePanel setPrompt:exportPanelPrompt];
	if ([savePanel runModalForDirectory:nil file:[selectedTheme name]] == NSFileHandlingPanelOKButton) {
		NSString *filename = [savePanel filename];
		if (![selectedTheme writeToFile:filename atomically:YES]) {
			// error saving theme
			NSLog(@"error exporting theme %@ to %@", [selectedTheme name], filename);
			if ([[themeManager delegate] respondsToSelector:@selector(themeExportFailed:sender:)])
				[[themeManager delegate] performSelector:@selector(themeExportFailed:sender:) withObject:[NSArray arrayWithObjects:[selectedTheme name], filename, nil] withObject:self];
		}
	}
}

- (IBAction)commit:(id)sender
{
	[NSApp endSheet:[self window] returnCode:NSOKButton];
	if ([[themeManager delegate] respondsToSelector:@selector(themeListChanged:)])
		[[themeManager delegate] performSelector:@selector(themeListChanged:) withObject:self];
}

// ============================================================
#pragma mark -
#pragma mark ━ helper methods ━
// ============================================================

- (NSString *)uniqueThemeName:(NSString *)themeName
{
	NSString *result = themeName;
	int i = 1;
	while ([themeManager themeExistsWithName:result]) {
		result = [themeName stringByAppendingString:[NSString stringWithFormat:@" %i", ++i]];
	};
	return result;
}

- (NSString *)newUntitledThemeName
{
	NSString *result = untitledString;
	int i = 1;
	do {
		result = [untitledString stringByAppendingString:[NSString stringWithFormat:@" %i", ++i]];
	} while ([themeManager themeExistsWithName:result]);
	return result;
}

- (NSString *)temporaryFilePath
{
	NSString *result;
	NSString *tempdir = NSTemporaryDirectory();
	NSString *filename;
	do {
		filename = [NSString stringWithFormat:@"temp%i", rand()];
		result = [tempdir stringByAppendingPathComponent:filename];
	} while ([[NSFileManager defaultManager] fileExistsAtPath:result]);
	return result;
}

// ============================================================
#pragma mark -
#pragma mark ━ table data source methods ━
// ============================================================

- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return [[themeManager themeNameList] count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
	return [[themeManager themeNameList] objectAtIndex:rowIndex];
}

- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{}

- (BOOL)tableView:(NSTableView *)tableView writeRows:(NSArray*)rows toPasteboard:(NSPasteboard*)pboard
{
	// find dragged theme name and path
	NSString *themeName = [[themeManager themeNameList] objectAtIndex:[[rows objectAtIndex:0] intValue]];
	NSString *path = [themeManager pathForThemeNamed:themeName];
	// prepare for dragging files and file contents as string
	[pboard declareTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, NSStringPboardType, nil] owner:self];
	[pboard setPropertyList:[NSArray arrayWithObject:path] forType:NSFilenamesPboardType];
	[pboard setString:[NSString stringWithContentsOfFile:path] forType:NSStringPboardType];
	// remember dragged theme for eventual deletion
	[self setDraggedThemeName:themeName];
	// allow drag
	return YES;
}

- (void)deleteDraggedTheme
{
	[themeManager removeThemeWithName:draggedThemeName];
	[themeNamesTableView reloadData];
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
	NSDragOperation result = NSDragOperationNone;
	// do not accept local drags
	if (![sender draggingSource]) {
		NSPasteboard *pboard = [sender draggingPasteboard];
		if ([pboard availableTypeFromArray:[NSArray arrayWithObjects:NSFilenamesPboardType, NSStringPboardType, nil]])
			result = NSDragOperationEvery;
	}
	return result;
}

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender
{
	return YES;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
	TimeDiscTheme *newTheme = nil;
	NSPasteboard *pboard = [sender draggingPasteboard];
	if ([pboard availableTypeFromArray:[NSArray arrayWithObject:NSFilenamesPboardType]]) {
		NSArray *filenames = [pboard propertyListForType:NSFilenamesPboardType];
		NSEnumerator *enumerator = [filenames objectEnumerator];
		NSString *filename;
		while (filename = [enumerator nextObject]) {
			if (newTheme = [[TimeDiscTheme alloc] initWithPath:filename]) {
				[newTheme setName:[self uniqueThemeName:[newTheme name]]];
				if (![themeManager addTheme:newTheme]) {
					// error adding theme
					NSLog(@"error adding theme %@", [newTheme name]);
					if ([[themeManager delegate] respondsToSelector:@selector(themeCreationFailed:sender:)])
						[[themeManager delegate] performSelector:@selector(themeCreationFailed:sender:) withObject:[theme name] withObject:self];
				}
			} else {
				// not a legal theme file
				NSLog(@"error importing theme from %@", filename);
				if ([[themeManager delegate] respondsToSelector:@selector(themeImportFailed:sender:)])
					[[themeManager delegate] performSelector:@selector(themeImportFailed:sender:) withObject:filename withObject:self];
			}
		}
	} else 	if ([pboard availableTypeFromArray:[NSArray arrayWithObject:NSStringPboardType]]) {
		NSString *themeProperties = [pboard stringForType:NSStringPboardType];
		NSString *tempFilePath = [self temporaryFilePath];
		[themeProperties writeToFile:tempFilePath atomically:NO];
		NSString *newThemeName = [self newUntitledThemeName];
		if (newTheme = [[TimeDiscTheme alloc] initWithPath:tempFilePath]) {
			[newTheme setName:newThemeName];
			if (![themeManager addTheme:newTheme]) {
				// error adding theme
				NSLog(@"error adding theme %@", [newTheme name]);
				if ([[themeManager delegate] respondsToSelector:@selector(themeCreationFailed:sender:)])
					[[themeManager delegate] performSelector:@selector(themeCreationFailed:sender:) withObject:[theme name] withObject:self];
			}
		} else {
			// not a legal theme file
			NSLog(@"error importing theme: %@", themeProperties);
			if ([[themeManager delegate] respondsToSelector:@selector(themeImportFailed:sender:)])
				[[themeManager delegate] performSelector:@selector(themeImportFailed:sender:) withObject:newThemeName withObject:self];
		}
	}
	[themeNamesTableView reloadData];
	return YES;
}

- (void)concludeDragOperation:(id <NSDraggingInfo>)sender
{
}


// ============================================================
#pragma mark -
#pragma mark ━ table view delegate methods ━
// ============================================================

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	BOOL selectionValid = [themeNamesTableView selectedRow] > -1;
	[copyButton setEnabled:selectionValid];
	[renameButton setEnabled:selectionValid];
	[deleteButton setEnabled:selectionValid];
	[exportButton setEnabled:selectionValid];
}

- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor
{
	// do not allow end editing if name is not allowed (e.g. already existing)
	BOOL result = [[[themeManager themeNameList] objectAtIndex:[themeNamesTableView editedRow]] isEqualToString:[fieldEditor string]];
	if (!result) {
		result = ![themeManager themeExistsWithName:[fieldEditor string]];
	}
	return result;
}

- (void)controlTextDidEndEditing:(NSNotification *)aNotification
{
	// theme renamed: change theme file name
	NSString *oldName = [[themeManager themeNameList] objectAtIndex:[themeNamesTableView editedRow]];
	NSString *newName = [[[aNotification userInfo] objectForKey:@"NSFieldEditor"] string];
	if (![oldName isEqualToString:newName]) {
		if ([themeManager renameThemeNamed:oldName to:newName]) {
			if ([[themeManager delegate] respondsToSelector:@selector(themeListChanged:)])
				[[themeManager delegate] performSelector:@selector(themeListChanged:) withObject:self];
		} else {
			// error renaming theme
			NSBeep();
		}
	}
}

- (void)controlTextDidChange:(NSNotification *)aNotification
{
	/*
	 NSText *fieldEditor = [[aNotification userInfo] objectForKey:@"NSFieldEditor"];
	 [okButton setEnabled:![[themeManager themeNameList] containsObject:[fieldEditor string]]];
	 */
}


@end
