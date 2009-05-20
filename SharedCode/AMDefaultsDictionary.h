//
//  AMDefaultsDictionary.h
//  CommX
//
//  Created by Andreas on Mon Aug 19 2002.
//  Copyright (c) 2002 Andreas Mayer. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AMDefaultsDictionary : NSObject {
	NSMutableDictionary *dictionary;
	NSString *name;
	AMDefaultsDictionary *parent;
	NSUserDefaults *userDefaults;
	BOOL userDefaultsProxy;
	BOOL dirty;
}

// init as proxy for [NSUserDefaults standardUserDefaults] - has no name
- (id)initWithUserDefaults:(NSUserDefaults *)userDefaults;

// init as root
- (id)initAsRoot;

// init as child
- (id)initWithName:(NSString *)name parent:(AMDefaultsDictionary *)parentDictionary;

- (id)initWithName:(NSString *)theName;


// remove dictionary from parent
- (void)remove;


// setters / accessors
- (void)setDictionary:(NSDictionary *)newDictionary;

- (NSMutableDictionary *)dictionary;

- (NSString *)name;


// remove all

- (void)removeAllObjects;

// Getting a default

- (NSArray *)arrayForKey:(NSString *)defaultName;

- (BOOL)boolForKey:(NSString *)defaultName;

- (NSData *)dataForKey:(NSString *)defaultName;

- (NSDictionary *)dictionaryForKey:(NSString *)defaultName;

- (float)floatForKey:(NSString *)defaultName;

- (int)integerForKey:(NSString *)defaultName;

- (id)objectForKey:(NSString *)defaultName;

- (NSArray *)stringArrayForKey:(NSString *)defaultName;

- (NSString *)stringForKey:(NSString *)defaultName;


// Setting and removing defaults

- (void)removeObjectForKey:(NSString *)defaultName;

- (void)setBool:(BOOL)value forKey:(NSString *)defaultName;

- (void)setFloat:(float)value forKey:(NSString *)defaultName;

- (void)setInteger:(int)value forKey:(NSString *)defaultName;

- (void)setObject:(id)value forKey:(NSString *)defaultName;


// Save modifications

- (BOOL)synchronize;

- (BOOL)writeToFile:(NSString *)path atomically:(BOOL)flag;

- (BOOL)readFromFile:(NSString *)path;


@end


// ============================================================
// private interface
// ============================================================

@interface AMDefaultsDictionary (Private)
- (NSUserDefaults *)userDefaults;
- (void)setUserDefaults:(NSUserDefaults *)newUserDefaults;
- (void)setName:(NSString *)newName;
- (void)setParent:(AMDefaultsDictionary *)newParent;
- (AMDefaultsDictionary *)parent;
- (void)setRoot:(NSMutableDictionary *)newRoot;
- (NSMutableDictionary *)root;
- (void)read;
- (void)write;
- (void)update;
@end
