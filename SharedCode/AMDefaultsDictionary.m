//
//  AMDefaultsDictionary.m
//  CommX
//
//  Created by Andreas on Mon Aug 19 2002.
//  Copyright (c) 2002 Andreas Mayer. All rights reserved.
//

#import "AMDefaultsDictionary.h"


@implementation AMDefaultsDictionary

// ============================================================
#pragma mark -
#pragma mark ━ initializers/dealloc ━
// ============================================================

// init as proxy for userDefaults
- (id)initWithUserDefaults:(NSUserDefaults *)theUserDefaults
{
    [super init];
	userDefaultsProxy = YES;
	[self setUserDefaults:theUserDefaults];
	return self;
}

// init as root
- (id)initAsRoot
{
	NSDictionary *value;

    [super init];
	userDefaultsProxy = NO;
	[self setName:nil];
	[self setParent:nil];
	value = [NSMutableDictionary dictionaryWithCapacity:1];
	[self setDictionary:value];
	return self;
}

// init as child
- (id)initWithName:(NSString *)theName parent:(AMDefaultsDictionary *)parentDictionary
{
	NSDictionary *value;

    if (self = [super init]) {
		userDefaultsProxy = NO;
		[self setName:theName];
		if (!(value = [parent objectForKey:name])) {
			value = [NSMutableDictionary dictionaryWithCapacity:1];
			//[parent setObject:value forKey:name];
		}
		[self setDictionary:value];
		[self setParent:parentDictionary];
	}
	return self;
}

- (id)initWithName:(NSString *)theName
{
    if (self = [super init]) {
		userDefaultsProxy = NO;
		[self setName:theName];
		[self setDictionary:[NSMutableDictionary dictionaryWithCapacity:1]];
	}
	return self;
}

- (void)dealloc
{
	[name release];
	[parent release];
	[dictionary release];
	[super dealloc];
}

// remove dictionary from parent
- (void)remove
{
	if (!userDefaultsProxy)
		if (parent)
			[parent removeObjectForKey:name];
	dirty = NO;
}


// ============================================================
#pragma mark -
#pragma mark ━ setters/accessors ━
// ============================================================

- (NSUserDefaults *)userDefaults
{
    return userDefaults;
}

- (void)setUserDefaults:(NSUserDefaults *)newUserDefaults
{
    id old = nil;

    if (newUserDefaults != userDefaults) {
        old = userDefaults;
        userDefaults = [newUserDefaults retain];
        [old release];
    }
}

- (void)setDictionary:(NSDictionary *)newDictionary
{
	NSMutableDictionary *oldValue;

	if (userDefaultsProxy) {
		[userDefaults registerDefaults:newDictionary];
	} else {
		oldValue = dictionary;
		dictionary = [[NSMutableDictionary dictionaryWithCapacity:1] retain];
		[dictionary setDictionary:newDictionary];
		[oldValue release];
		[parent setObject:dictionary forKey:name];
	}
}

- (NSDictionary *)dictionary
{
	if (userDefaultsProxy)
		return [userDefaults dictionaryRepresentation];
	else
		return dictionary;
}

- (void)setName:(NSString *)newName
{
	NSString *oldValue;

	if (!userDefaultsProxy) {
		oldValue = name;
		name = [newName retain];
		[oldValue release];
	}
}

- (NSString *)name
{
	return name;
}

- (void)setParent:(AMDefaultsDictionary *)newParent
{
	AMDefaultsDictionary *oldValue;
	NSDictionary *dict;

	if (!userDefaultsProxy) {
		[self remove]; // remove from old parent
		oldValue = parent;
		parent = [newParent retain];
		[oldValue release];
		if (dict = [parent objectForKey:name]) {
			[self setDictionary:dict];
		} else {
			[parent setObject:dictionary forKey:name];
		}
	}
}

- (AMDefaultsDictionary *)parent
{
	return parent;
}

// ============================================================
#pragma mark -
#pragma mark ━ remove all ━
// ============================================================

- (void)removeAllObjects
{
	if (!userDefaultsProxy)
		[dictionary removeAllObjects];
}

// ============================================================
#pragma mark -
#pragma mark ━ Getting a default ━
// ============================================================

- (NSArray *)arrayForKey:(NSString *)defaultName
{
	id object;
	object = [[self dictionary] objectForKey:defaultName];
	if ([object isKindOfClass:[NSArray class]])
		return (NSArray *)object;
	else
		return nil;
}

- (BOOL)boolForKey:(NSString *)defaultName
{
	id object;
	if (userDefaultsProxy)
		return [userDefaults boolForKey:defaultName];
	else {
		object = [self stringForKey:defaultName];
		if ([object isKindOfClass:[NSString class]])
			return ([[(NSString *)object uppercaseString] isEqualToString:@"YES"] | [(NSString *)object intValue]);
		else
			return NO;
	}
}

- (NSData *)dataForKey:(NSString *)defaultName
{
	id object;
	if (userDefaultsProxy)
		return [userDefaults dataForKey:defaultName];
	else {
		object = [dictionary objectForKey:defaultName];
		if ([object isKindOfClass:[NSData class]])
			return (NSData *)object;
		else
			return nil;
	}
}

- (NSDictionary *)dictionaryForKey:(NSString *)defaultName
{
	id object;
	if (userDefaultsProxy)
		return [userDefaults dictionaryForKey:defaultName];
	else {
		object = [dictionary objectForKey:defaultName];
		if ([object isKindOfClass:[NSDictionary class]])
			return (NSDictionary *)object;
		else
			return nil;
	}
}

- (float)floatForKey:(NSString *)defaultName
{
	id object;
	if (userDefaultsProxy)
		return [userDefaults floatForKey:defaultName];
	else {
		object = [self stringForKey:defaultName];
		if ([object isKindOfClass:[NSString class]])
			return [(NSString *)object floatValue];
		else
			return 0;
	}
}

- (int)integerForKey:(NSString *)defaultName
{
	id object;
	if (userDefaultsProxy)
		return [userDefaults integerForKey:defaultName];
	else {
		object = [self stringForKey:defaultName];
		if ([object isKindOfClass:[NSString class]])
			return [(NSString *)object intValue];
		else
			return 0;
	}
}

- (id)objectForKey:(NSString *)defaultName
{
	if (userDefaultsProxy)
		return [userDefaults objectForKey:defaultName];
	else
		return [dictionary objectForKey:defaultName];
}

- (NSArray *)stringArrayForKey:(NSString *)defaultName
{
	id object;
	id arrayElement;
	NSEnumerator *enumerator;

	if (userDefaultsProxy)
		return [userDefaults stringArrayForKey:defaultName];
	else {
		object = [[self dictionary] objectForKey:defaultName];
		if ([object isKindOfClass:[NSArray class]]) {
			enumerator = [object objectEnumerator];
			while ((arrayElement = [enumerator nextObject])) {
				if (![object isKindOfClass:[NSString class]])
					return nil;
			}
			return (NSArray *)object;
		} else
			return nil;
	}
}

- (NSString *)stringForKey:(NSString *)defaultName
{
	id object;
	if (userDefaultsProxy)
		return [userDefaults stringForKey:defaultName];
	else {
		object = [[self dictionary] objectForKey:defaultName];
		if ([object isKindOfClass:[NSString class]])
			return (NSString *)object;
		else
			return nil;
	}
}

// ============================================================
#pragma mark -
#pragma mark ━ Setting and removing defaults ━
// ============================================================

- (void)removeObjectForKey:(NSString *)defaultName
{
	if (userDefaultsProxy)
		[userDefaults removeObjectForKey:defaultName];
	else
		[dictionary removeObjectForKey:defaultName];
	[self update];
}

- (void)setBool:(BOOL)value forKey:(NSString *)defaultName
{
	if (userDefaultsProxy)
		[userDefaults setBool:value forKey:defaultName];
	else {
		if (value)
			[self setObject:@"YES" forKey:defaultName];
		else
			[self setObject:@"NO" forKey:defaultName];
	}
	[self update];
}

- (void)setFloat:(float)value forKey:(NSString *)defaultName
{
	if (userDefaultsProxy)
		[userDefaults setFloat:value forKey:defaultName];
	else
		[self setObject:[[NSNumber numberWithFloat:value] stringValue] forKey:defaultName];
	[self update];
}

- (void)setInteger:(int)value forKey:(NSString *)defaultName
{
	if (userDefaultsProxy)
		[userDefaults setInteger:value forKey:defaultName];
	else
		[self setObject:[[NSNumber numberWithInt:value] stringValue] forKey:defaultName];
	[self update];
}

- (void)setObject:(id)value forKey:(NSString *)defaultName
{
	if (userDefaultsProxy) {
		[userDefaults setObject:value forKey:defaultName];
	} else
		[[self dictionary] setObject:value forKey:defaultName];
	[self update];
}

// ============================================================
#pragma mark -
#pragma mark ━ Save modifications ━
// ============================================================

- (BOOL)synchronize
{
	BOOL result;
	
	if (dirty)
		[self write];

	if (userDefaultsProxy)
		result = [userDefaults synchronize];
	else if (parent)
		result = [parent synchronize];
	else
		result = YES; // nothing to do here

	if (result)
		[self read];
	return result;
}


// ============================================================
#pragma mark -
#pragma mark ━ Read and write dictionary ━
// ============================================================

- (void)read
{
	if (parent)
		[self setDictionary:[parent dictionaryForKey:name]];
	
	dirty = NO;
}

- (void)write
{
	if (parent)
		[parent setObject:dictionary forKey:name];
	dirty = NO;
}

- (void)update
{
	if (!dirty) {
		[[NSRunLoop currentRunLoop] performSelector:@selector(write) target:self argument:nil order:0 modes:[NSArray arrayWithObject:NSDefaultRunLoopMode]];
		dirty = YES;
	}
}

- (BOOL)writeToFile:(NSString *)path atomically:(BOOL)flag
{
	return [dictionary writeToFile:path atomically:flag];
}

- (BOOL)readFromFile:(NSString *)path
{
	BOOL result;
	NSDictionary *newDictionary;

	newDictionary = [NSDictionary dictionaryWithContentsOfFile:path];
	result = (newDictionary != nil);
	if (result)
		[self setDictionary:newDictionary];
	return result;
}


@end