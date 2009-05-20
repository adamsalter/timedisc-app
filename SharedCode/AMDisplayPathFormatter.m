//
//  AMDisplayPathFormatter.m
//  CommX
//
//  Created by Andreas on Thu Sep 26 2002.
//  Copyright (c) 2002 Andreas Mayer. All rights reserved.
//
//	2002-10-25	Andreas Mayer
//	- changed "Folder" in test to lowercase


#import "AMDisplayPathFormatter.h"
#import "NSFileManagerAMAdditions.h"


@implementation AMDisplayPathFormatter

- (id)init
{
	self = [super init];
	[self setDisplayTemplateIsDesktop:@"the Desktop"];
	[self setDisplayTemplateIsVolume:@"the volume %@"];
	[self setDisplayTemplateIsFolderOnVolume:@"the folder %@ on the volume %@"];
	[self setDisplayTemplateIsFileInFolderOnDesktop:@"%@ in the folder %@ on the Desktop"];
	[self setDisplayTemplateIsFileOnDesktop:@"%@ on the Desktop"];
	[self setDisplayTemplateIsFolderOnDesktop:@"the folder %@ on the Desktop"];
	[self setDisplayTemplateIsFileInFolderOnVolume:@"%@ in the folder %@ on the volume %@"];
	[self setDisplayTemplateIsFileOnVolume:@"%@ on the volume %@"];
	return self;
}


- (void)dealloc
{
	[displayTemplateIsDesktop release];
	[displayTemplateIsVolume release];
	[displayTemplateIsFolderOnVolume release];
	[displayTemplateIsFileOnDesktop release];
	[displayTemplateIsFolderOnDesktop release];
	[displayTemplateIsFileInFolderOnDesktop release];
	[displayTemplateIsFileInFolderOnVolume release];
	[displayTemplateIsFileOnVolume release];
}


- (NSString *)displayTemplateIsDesktop
{
    return displayTemplateIsDesktop;
}

- (void)setDisplayTemplateIsDesktop:(NSString *)newDisplayTemplateIsDesktop
{
    id old = nil;

    if (newDisplayTemplateIsDesktop != displayTemplateIsDesktop) {
        old = displayTemplateIsDesktop;
        displayTemplateIsDesktop = [newDisplayTemplateIsDesktop retain];
        [old release];
    }
}

- (NSString *)displayTemplateIsVolume
{
    return displayTemplateIsVolume;
}

- (void)setDisplayTemplateIsVolume:(NSString *)newDisplayTemplateIsVolume
{
    id old = nil;

    if (newDisplayTemplateIsVolume != displayTemplateIsVolume) {
        old = displayTemplateIsVolume;
        displayTemplateIsVolume = [newDisplayTemplateIsVolume retain];
        [old release];
    }
}

- (NSString *)displayTemplateIsFolderOnVolume
{
    return displayTemplateIsFolderOnVolume;
}

- (void)setDisplayTemplateIsFolderOnVolume:(NSString *)newDisplayTemplateIsFolderOnVolume
{
    id old = nil;

    if (newDisplayTemplateIsFolderOnVolume != displayTemplateIsFolderOnVolume) {
        old = displayTemplateIsFolderOnVolume;
        displayTemplateIsFolderOnVolume = [newDisplayTemplateIsFolderOnVolume retain];
        [old release];
    }
}

- (NSString *)displayTemplateIsFileOnDesktop
{
    return displayTemplateIsFileOnDesktop;
}

- (void)setDisplayTemplateIsFileOnDesktop:(NSString *)newDisplayTemplateIsFileOnDesktop
{
    id old = nil;

    if (newDisplayTemplateIsFileOnDesktop != displayTemplateIsFileOnDesktop) {
        old = displayTemplateIsFileOnDesktop;
        displayTemplateIsFileOnDesktop = [newDisplayTemplateIsFileOnDesktop retain];
        [old release];
    }
}

- (NSString *)displayTemplateIsFolderOnDesktop
{
    return displayTemplateIsFolderOnDesktop;
}

- (void)setDisplayTemplateIsFolderOnDesktop:(NSString *)newDisplayTemplateIsFolderOnDesktop
{
    id old = nil;

    if (newDisplayTemplateIsFolderOnDesktop != displayTemplateIsFolderOnDesktop) {
        old = displayTemplateIsFolderOnDesktop;
        displayTemplateIsFolderOnDesktop = [newDisplayTemplateIsFolderOnDesktop retain];
        [old release];
    }
}

- (NSString *)displayTemplateIsFileInFolderOnDesktop
{
    return displayTemplateIsFileInFolderOnDesktop;
}

- (void)setDisplayTemplateIsFileInFolderOnDesktop:(NSString *)newDisplayTemplateIsFileInFolderOnDesktop
{
    id old = nil;

    if (newDisplayTemplateIsFileInFolderOnDesktop != displayTemplateIsFileInFolderOnDesktop) {
        old = displayTemplateIsFileInFolderOnDesktop;
        displayTemplateIsFileInFolderOnDesktop = [newDisplayTemplateIsFileInFolderOnDesktop retain];
        [old release];
    }
}

- (NSString *)displayTemplateIsFileInFolderOnVolume
{
    return displayTemplateIsFileInFolderOnVolume;
}

- (void)setDisplayTemplateIsFileInFolderOnVolume:(NSString *)newDisplayTemplateIsFileInFolderOnVolume
{
    id old = nil;

    if (newDisplayTemplateIsFileInFolderOnVolume != displayTemplateIsFileInFolderOnVolume) {
        old = displayTemplateIsFileInFolderOnVolume;
        displayTemplateIsFileInFolderOnVolume = [newDisplayTemplateIsFileInFolderOnVolume retain];
        [old release];
    }
}

- (NSString *)displayTemplateIsFileOnVolume
{
    return displayTemplateIsFileOnVolume;
}

- (void)setDisplayTemplateIsFileOnVolume:(NSString *)newDisplayTemplateIsFileOnVolume
{
    id old = nil;

    if (newDisplayTemplateIsFileOnVolume != displayTemplateIsFileOnVolume) {
        old = displayTemplateIsFileOnVolume;
        displayTemplateIsFileOnVolume = [newDisplayTemplateIsFileOnVolume retain];
        [old release];
    }
}

- (NSString *)editingStringForObjectValue:(id)anObject
{
	if ([anObject isKindOfClass:[NSString class]])
		return anObject;
	else
		return nil;
}

- (BOOL)getObjectValue:(id *)anObject forString:(NSString *)string errorDescription:(NSString **)error
{
	NSLog(@"AMDisplayPathFormatter: getObjectValue:forString:errorDescription: not available in this class\n");
	//if ([(*anObject) isKindOfClass:[NSString class]]) {
	//	(*anObject) = string;
	//	return YES;
	//}
	return NO;
}

- (NSString *)stringForObjectValue:(id)anObject
{
	NSString *result = nil;
	BOOL isDirectory;
	NSArray *pathDisplayComponents;
	NSString *desktopPath;
	NSString *objectPath;

	if ([anObject isKindOfClass:[NSString class]]) {
		desktopPath = [[[NSFileManager defaultManager] findSystemFolderType:kDesktopFolderType forDomain:kUserDomain] stringByStandardizingPath];
		objectPath = [(NSString *)anObject stringByStandardizingPath];
		pathDisplayComponents = [[NSFileManager defaultManager] componentsToDisplayForPath:objectPath];
		[[NSFileManager defaultManager] fileExistsAtPath:objectPath isDirectory:&isDirectory];
		if (isDirectory) {
			if ([objectPath isEqualToString:desktopPath]) {
			// user desktop folder
				result = displayTemplateIsDesktop;
			} else {
				if ([pathDisplayComponents count] > 1) {
					if ([[objectPath stringByDeletingLastPathComponent] isEqualToString:desktopPath]) {
						result = [NSString stringWithFormat:displayTemplateIsFolderOnDesktop, [pathDisplayComponents objectAtIndex:[pathDisplayComponents count]-1]];
					} else {
				result = [NSString stringWithFormat:displayTemplateIsFolderOnVolume, [pathDisplayComponents objectAtIndex:[pathDisplayComponents count]-1], [pathDisplayComponents objectAtIndex:0]];
					}
				} else {
					result = [NSString stringWithFormat:displayTemplateIsVolume, [pathDisplayComponents objectAtIndex:0]];
				}
			}
		} else {
			if ([[objectPath stringByDeletingLastPathComponent] isEqualToString:desktopPath]) {
			// user desktop folder
				/*
				if ([pathDisplayComponents count] > 1) {
					result = [NSString stringWithFormat:displayTemplateIsFileInFolderOnDesktop, [pathDisplayComponents objectAtIndex:[pathDisplayComponents count]-1], [pathDisplayComponents objectAtIndex:[pathDisplayComponents count]-2]];
				} else {
					*/
					result = [NSString stringWithFormat:displayTemplateIsFileOnDesktop, [pathDisplayComponents objectAtIndex:[pathDisplayComponents count]-1]];
				//}
			} else {
				if ([pathDisplayComponents count] > 2) {
					result = [NSString stringWithFormat:displayTemplateIsFileInFolderOnVolume, [pathDisplayComponents objectAtIndex:[pathDisplayComponents count]-1], [pathDisplayComponents objectAtIndex:[pathDisplayComponents count]-2], [pathDisplayComponents objectAtIndex:0]];
				} else {
					result = [NSString stringWithFormat:displayTemplateIsFileOnVolume, [pathDisplayComponents objectAtIndex:[pathDisplayComponents count]-1], [pathDisplayComponents objectAtIndex:0]];
				}
			}
		}
	}
	return result;
}


@end
