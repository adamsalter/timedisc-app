//
//  TimeDiscImage.h
//  TimeDisc
//
//  Created by Andreas on Fri Nov 08 2002.
//  Copyright (c) 2002 Andreas Mayer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TimeDiscDisplay.h"


@interface TimeDiscImage : NSImage {
	TimeDiscDisplay *display;
}

- (TimeDiscDisplay *)display;
- (void)setDisplay:(TimeDiscDisplay *)newDisplay;

- (void)draw;


@end
