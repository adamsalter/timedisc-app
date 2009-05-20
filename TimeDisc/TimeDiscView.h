//
//  TimeDiscView.h
//  TimeDisc
//
//  Created by Andreas on Wed Nov 06 2002.
//  Copyright (c) 2002 Andreas Mayer. All rights reserved.
//

#import <AppKit/AppKit.h>
#import "TimeDiscDisplay.h"


@interface TimeDiscView : NSView {
	TimeDiscDisplay *display;
}

- (TimeDiscDisplay *)display;
- (void)setDisplay:(TimeDiscDisplay *)newDisplay;


@end
