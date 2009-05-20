//
//  AMDisplayPathFormatter.h
//  CommX
//
//  Created by Andreas on Thu Sep 26 2002.
//  Copyright (c) 2002 Andreas Mayer. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AMDisplayPathFormatter : NSFormatter {
	NSString *displayTemplateIsDesktop;
	NSString *displayTemplateIsVolume;
	NSString *displayTemplateIsFolderOnVolume;
	NSString *displayTemplateIsFileOnDesktop;
	NSString *displayTemplateIsFolderOnDesktop;
	NSString *displayTemplateIsFileInFolderOnDesktop;
	NSString *displayTemplateIsFileInFolderOnVolume;
	NSString *displayTemplateIsFileOnVolume;
}

- (NSString *)displayTemplateIsDesktop;
- (void)setDisplayTemplateIsDesktop:(NSString *)newDisplayTemplateIsDesktop;

- (NSString *)displayTemplateIsVolume;
- (void)setDisplayTemplateIsVolume:(NSString *)newDisplayTemplateIsVolume;

- (NSString *)displayTemplateIsFolderOnVolume;
- (void)setDisplayTemplateIsFolderOnVolume:(NSString *)newDisplayTemplateIsFolderOnVolume;

- (NSString *)displayTemplateIsFileOnDesktop;
- (void)setDisplayTemplateIsFileOnDesktop:(NSString *)newDisplayTemplateIsFileOnDesktop;

- (NSString *)displayTemplateIsFolderOnDesktop;
- (void)setDisplayTemplateIsFolderOnDesktop:(NSString *)newDisplayTemplateIsFolderOnDesktop;

- (NSString *)displayTemplateIsFileInFolderOnDesktop;
- (void)setDisplayTemplateIsFileInFolderOnDesktop:(NSString *)newDisplayTemplateIsFileInFolderOnDesktop;

- (NSString *)displayTemplateIsFileInFolderOnVolume;
- (void)setDisplayTemplateIsFileInFolderOnVolume:(NSString *)newDisplayTemplateIsFileInFolderOnVolume;

- (NSString *)displayTemplateIsFileOnVolume;
- (void)setDisplayTemplateIsFileOnVolume:(NSString *)newDisplayTemplateIsFileOnVolume;


@end
