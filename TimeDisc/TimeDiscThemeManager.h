//
//  TimeDiscThemeManager.h
//  TimeDisc
//
//  Created by Andreas on Wed Jan 22 2003.
//  Copyright (c) 2003 Andreas Mayer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TimeDiscTheme.h"

#define ThemeFolderName @"Themes"
#define ThemeExtension @"tdt"


@interface TimeDiscThemeManager : NSObject {
	NSString *themeFolderName;
	NSArray *themes;
	id delegate;
	BOOL didCreateThemeFolder;
}

- (id)initWithApplicationName:(NSString *)appName;

- (id)initWithApplicationName:(NSString *)appName cloneFolder:(NSString *)folderPath;

- (id)delegate;
- (void)setDelegate:(id)newDelegate;

- (NSArray *)themeNameList;

- (TimeDiscTheme *)themeWithName:(NSString *)themeName;

- (BOOL)addTheme:(TimeDiscTheme *)theme;

- (BOOL)removeTheme:(TimeDiscTheme *)theme;

- (BOOL)removeThemeWithName:(NSString *)themeName;

- (BOOL)renameThemeNamed:(NSString *)oldName to:(NSString *)newName;

- (BOOL)themeExistsWithName:(NSString *)themeName;


- (NSString *)pathForThemeNamed:(NSString *)themeName;


@end
