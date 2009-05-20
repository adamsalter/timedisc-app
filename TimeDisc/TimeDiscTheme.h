//
//  TimeDiscTheme.h
//  TimeDisc
//
//  Created by Andreas on Wed Jan 22 2003.
//  Copyright (c) 2003 Andreas Mayer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMDefaultsDictionary.h"


@interface TimeDiscTheme : NSObject {
	NSDictionary *properties;
	NSString *name;
}

- (id)initWithName:(NSString *)name andProperties:(NSDictionary *)properties;

- (id)initWithName:(NSString *)name andDefaults:(NSUserDefaults *)defaults;

- (id)initWithName:(NSString *)name;

- (id)initWithPath:(NSString *)path;

- (BOOL)writeToFile:(NSString *)path atomically:(BOOL)atomicFlag;

- (void)writeLayoutDefaults:(AMDefaultsDictionary *)layoutDefaults colorDefaults:(AMDefaultsDictionary *)colorDefaults;

- (NSDictionary *)properties;
- (void)setProperties:(NSDictionary *)newProperties;

- (NSString *)name;
- (void)setName:(NSString *)newName;


@end
