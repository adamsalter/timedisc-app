//
//  TimeDiscTheme.m
//  TimeDisc
//
//  Created by Andreas on Wed Jan 22 2003.
//  Copyright (c) 2003 Andreas Mayer. All rights reserved.
//

#import "TimeDiscTheme.h"

#define ThemeSubsectionColorsKey @"Colors"
#define ThemeSubsectionLayoutKey @"Layout"


@implementation TimeDiscTheme

- (id)copyWithZone:(NSZone *)zone
{
	return [[TimeDiscTheme allocWithZone:zone] initWithName:[self name] andProperties:[self properties]];
}

- (id)initWithName:(NSString *)theName andProperties:(NSDictionary *)theProperties
{
	id result = self;
	if (theName) {
		name = [theName retain];
		properties = [theProperties retain];
	} else {
		[self dealloc];
		result = nil;
	}
	return result;
}

- (id)initWithName:(NSString *)theName andDefaults:(NSUserDefaults *)defaults
{
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[defaults objectForKey:ThemeSubsectionLayoutKey], ThemeSubsectionLayoutKey, [defaults objectForKey:ThemeSubsectionColorsKey], ThemeSubsectionColorsKey, nil];
	TimeDiscTheme *newTheme = [self initWithName:theName andProperties:dict];
	return newTheme;
	//return [self initWithName:theName andProperties:[NSDictionary dictionaryWithObjectsAndKeys:[defaults objectForKey:ThemeSubsectionLayoutKey], ThemeSubsectionLayoutKey, [defaults objectForKey:ThemeSubsectionColorsKey], ThemeSubsectionColorsKey, nil]];
}

- (id)initWithName:(NSString *)theName
{
	return [self initWithName:theName andProperties:nil];
}

- (id)initWithPath:(NSString *)path
{
	id result = nil;
	NSString *theName = [[path lastPathComponent] stringByDeletingPathExtension];
	NSDictionary *prop = [[[NSDictionary alloc] initWithContentsOfFile:path] autorelease];
	if (prop)
		result = [self initWithName:theName andProperties:prop];
	else {
		[self dealloc];
	}
	return result;
}

- (BOOL)writeToFile:(NSString *)path atomically:(BOOL)atomicFlag
{
	return [properties writeToFile:path atomically:atomicFlag];
}

- (void)writeLayoutDefaults:(AMDefaultsDictionary *)layoutDefaults colorDefaults:(AMDefaultsDictionary *)colorDefaults
{
	[layoutDefaults setDictionary:[properties objectForKey:ThemeSubsectionLayoutKey]];
	[colorDefaults setDictionary:[properties objectForKey:ThemeSubsectionColorsKey]];
}

- (void)dealloc
{
	[properties release];
	[name release];
	[super dealloc];
}


- (NSDictionary *)properties
{
    return properties;
}

- (void)setProperties:(NSDictionary *)newProperties
{
    id old = nil;

    if (newProperties != properties) {
        old = properties;
        properties = [newProperties retain];
        [old release];
    }
}

- (NSString *)name
{
    return name;
}

- (void)setName:(NSString *)newName
{
    id old = nil;

    if (newName != name) {
        old = name;
        name = [newName retain];
        [old release];
    }
}



@end
