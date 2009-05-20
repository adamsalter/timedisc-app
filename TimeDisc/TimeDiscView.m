//
//  TimeDiscView.m
//  TimeDisc
//
//  Created by Andreas on Wed Nov 06 2002.
//  Copyright (c) 2002 Andreas Mayer. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TimeDiscView.h"
#import "TimeDiscDisplay.h"


@implementation TimeDiscView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

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

- (void)drawRect:(NSRect)rect {
    // Drawing code here.
	[display drawWithFrame:[self frame]];
}


@end
