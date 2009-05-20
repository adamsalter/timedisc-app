//
//  TimeDiscThemeManager.m
//  TimeDisc
//
//  Created by Andreas on Wed Jan 22 2003.
//  Copyright (c) 2003 Andreas Mayer. All rights reserved.
//

#import "TimeDiscThemeManager.h"
#import "NSFileManagerAMAdditions.h"

@interface TimeDiscThemeManager (Private)
- (NSString *)createSupportFolderForApplicationNamed:(NSString *)appName;
- (NSString *)createThemeFolderAtPath:(NSString *)path;
- (NSString *)themeFolderName;
- (void)setThemeFolderName:(NSString *)newThemeFolderName;
- (NSArray *)themes;
- (void)setThemes:(NSArray *)newThemes;
@end


@implementation TimeDiscThemeManager

- (id)initWithApplicationName:(NSString *)appName
{
	return [self initWithApplicationName:appName cloneFolder:nil];
}

- (id)initWithApplicationName:(NSString *)appName cloneFolder:(NSString *)folderPath
{
	NSString *themeFolderPath = [self createThemeFolderAtPath:[self createSupportFolderForApplicationNamed:appName]];
	[self setThemeFolderName:themeFolderPath];
	if (!themeFolderName)
		NSLog(@"TimeDiscThemeManager - error creating themeFolder");
	if (didCreateThemeFolder && folderPath) {
		// we need to copy the clone folder
		NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:folderPath];
		NSString *file, *source, *destination;
		while (file = [enumerator nextObject]) {
			source = [folderPath stringByAppendingPathComponent:file];
			destination = [themeFolderPath stringByAppendingPathComponent:[source lastPathComponent]];
			//NSLog(@"copy %@ to %@", source, destination);
			[[NSFileManager defaultManager] copyPath:source toPath:destination handler:nil];
		}
	}
	return self;
}

- (id)delegate
{
	return delegate;
}

- (void)setDelegate:(id)newDelegate
{
	// do not retain delegate!
	delegate = newDelegate;
}

- (NSArray *)themeNameList
{
	NSMutableArray *result = nil;
	NSString *file;
	NSDirectoryEnumerator *dir = [[NSFileManager defaultManager] enumeratorAtPath:themeFolderName];
	if (dir) {
		result = [[NSMutableArray alloc] init];
		while (file = [dir nextObject]) {
			if ([[file pathExtension] isEqualToString:ThemeExtension])
				[result addObject:[[file lastPathComponent] stringByDeletingPathExtension]];
		}
	}
	return [result autorelease];
}

- (TimeDiscTheme *)themeWithName:(NSString *)themeName
{
	return [[[TimeDiscTheme alloc] initWithPath:[self pathForThemeNamed:themeName]] autorelease];
}

- (BOOL)addTheme:(TimeDiscTheme *)theme
{
	//NSLog(@"TimeDiscThemeManager - addTheme:%@", [theme name]);
	BOOL result = [theme writeToFile:[self pathForThemeNamed:[theme name]] atomically:YES];
	if ([delegate respondsToSelector:@selector(themeListChanged:)])
		[delegate performSelector:@selector(themeListChanged:) withObject:self];
	return result;
}

- (BOOL)removeTheme:(TimeDiscTheme *)theme
{
	BOOL result = [[NSFileManager defaultManager] removeFileAtPath:[self pathForThemeNamed:[theme name]] handler:nil];
	if ([delegate respondsToSelector:@selector(themeListChanged:)])
		[delegate performSelector:@selector(themeListChanged:) withObject:self];
	return result;
}

- (BOOL)removeThemeWithName:(NSString *)themeName
{
	BOOL result = [[NSFileManager defaultManager] removeFileAtPath:[self pathForThemeNamed:themeName] handler:nil];
	if ([delegate respondsToSelector:@selector(themeListChanged:)])
		[delegate performSelector:@selector(themeListChanged:) withObject:self];
	return result;
}

- (BOOL)renameThemeNamed:(NSString *)oldName to:(NSString *)newName
{
	BOOL result = [[NSFileManager defaultManager] movePath:[self pathForThemeNamed:oldName] toPath:[self pathForThemeNamed:newName] handler:nil];
	if ([delegate respondsToSelector:@selector(themeListChanged:)])
		[delegate performSelector:@selector(themeListChanged:) withObject:self];
	return result;
}

- (BOOL)themeExistsWithName:(NSString *)themeName
{
	return [[NSFileManager defaultManager] fileExistsAtPath:[self pathForThemeNamed:themeName]];
}


- (NSString *)themeFolderName
{
    return themeFolderName;
}

- (void)setThemeFolderName:(NSString *)newThemeFolderName
{
    id old = nil;

    if (newThemeFolderName != themeFolderName) {
        old = themeFolderName;
        themeFolderName = [newThemeFolderName retain];
        [old release];
    }
}

- (NSArray *)themes
{
    return themes;
}

- (void)setThemes:(NSArray *)newThemes
{
    id old = nil;

    if (newThemes != themes) {
        old = themes;
        themes = [newThemes retain];
        [old release];
    }
}

- (NSString *)pathForThemeNamed:(NSString *)themeName
{
	return [[themeFolderName stringByAppendingPathComponent:themeName] stringByAppendingPathExtension:ThemeExtension];
}

- (NSString *)createSupportFolderForApplicationNamed:(NSString *)appName
{
	NSString *result;
	BOOL isFolder;
	// find and create an application support folder if neccessary
	if (result = [[NSFileManager defaultManager] findSystemFolderType:kApplicationSupportFolderType forDomain:kUserDomain]) {
		result = [result stringByAppendingPathComponent:appName];
		if ([[NSFileManager defaultManager] fileExistsAtPath:result isDirectory:&isFolder]) {
			if (!isFolder)
				result = nil;
		} else {
			[[NSFileManager defaultManager] createDirectoryAtPath:result attributes:nil];
		}
	}
	return result;
}

- (NSString *)createThemeFolderAtPath:(NSString *)path
{
	NSString *result;
	BOOL isFolder;
	if (result = [path stringByAppendingPathComponent:ThemeFolderName]) {
		if ([[NSFileManager defaultManager] fileExistsAtPath:result isDirectory:&isFolder]) {
			if (!isFolder)
				result = nil;
		} else {
			didCreateThemeFolder = [[NSFileManager defaultManager] createDirectoryAtPath:result attributes:nil];
		}
	}
	return result;
}


@end
