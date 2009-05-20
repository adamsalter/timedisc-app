//
//  TimeDiscImage.m
//  TimeDisc
//
//  Created by Andreas on Fri Nov 08 2002.
//  Copyright (c) 2002 Andreas Mayer. All rights reserved.
//

#import "TimeDiscImage.h"


@implementation TimeDiscImage

- (void)dealloc
{
	[display release];
}


- (TimeDiscDisplay *)display
{
    return display;
}

- (void)setDisplay:(TimeDiscDisplay *)newDisplay
{
    id old = nil;

    if (newDisplay != display) {
        old = display;
        display = [newDisplay retain];
        [old release];
    }
}

- (void)draw {
    // Drawing code here.
	[self lockFocus];
	[display drawWithFrame:NSMakeRect(0,0,_size.width,_size.height)];
	[self unlockFocus];
}

@end
