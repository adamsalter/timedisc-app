//
//  TimeDiscThemeListTableView.m
//  TimeDisc
//
//  Created by Andreas on Fri Feb 07 2003.
//  Copyright (c) 2003 Andreas Mayer. All rights reserved.
//

#import "TimeDiscThemeListTableView.h"
#import "TimeDiscThemePanelController.h"


@implementation TimeDiscThemeListTableView

- (void)drawRect:(NSRect)rect
{
	[super drawRect:rect];
	if (_drawDraggingHighlight) {
		[[NSColor darkGrayColor] set];
		[NSBezierPath setDefaultLineWidth:2.0];
		[NSBezierPath strokeRect:NSInsetRect(rect, 1.0, 1.0)];
	}
}

- (void)changeDraggingHighlight:(BOOL)doHighlight
{
	if (_drawDraggingHighlight != doHighlight) {
		_drawDraggingHighlight = doHighlight;
		[self setNeedsDisplay:YES];
	}
}

- (NSDragOperation)draggingSourceOperationMaskForLocal:(BOOL)isLocal
{
	if (isLocal)
		return NSDragOperationNone;
	else
		return (NSDragOperationCopy || NSDragOperationDelete);
}


- (void)draggedImage:(NSImage *)anImage endedAt:(NSPoint)aPoint operation:(NSDragOperation)operation
{
	if (operation == NSDragOperationDelete) {
		[(TimeDiscThemePanelController *)[self delegate] deleteDraggedTheme];
	}
}


@end
