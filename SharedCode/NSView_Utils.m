// FROM: Andy Lee
// DATE: 2002-06-16 18:30

#import "NSView_Utils.h"

@implementation NSView (Utils)

- (id)viewOfClass:(Class)aClass withTag:(int)tag
{
	NSEnumerator* e;
	NSView* aSubview;
	NSView* result;
	if (([self tag] == tag) && [self isKindOfClass:aClass])
		return self;
	e = [[self subviews] objectEnumerator];
	while ((aSubview = [e nextObject]))
		if ((result = [aSubview viewOfClass:aClass withTag:tag]))
			return result;
	return nil;
}

- (id)buttonWithTag:(int)tag
{
	return [self viewOfClass:[NSButton class] withTag:tag];
}

@end