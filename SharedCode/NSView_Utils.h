// FROM: Andy Lee
// DATE: 2002-06-16 18:30

#import <Cocoa/Cocoa.h>

@interface NSView (Utils)

- (id)viewOfClass:(Class)aClass withTag:(int)tag;

- (id)buttonWithTag:(int)tag;

@end