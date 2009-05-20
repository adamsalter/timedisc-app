//
//  AMScrollViewDraggingDestination.m
//  TimeDisc
//
//  Created by Andreas on Thu Feb 13 2003.
//  Copyright (c) 2003 Andreas Mayer. All rights reserved.
//

#import "AMScrollViewDraggingDestination.h"


@implementation AMScrollViewDraggingDestination

- (void)drawRect:(NSRect)rect
{
	[super drawRect:rect];
	if (_drawDraggingHighlight) {
		[[NSColor darkGrayColor] set];
		[NSBezierPath setDefaultLineWidth:2.0];
		[NSBezierPath strokeRect:NSInsetRect(rect, 1.0, 1.0)];
	}
}


- (id)delegate
{
    return delegate;
}

- (void)setDelegate:(id)newDelegate
{
	// do not retain delegate!
	delegate = newDelegate;
}

- (NSView *)highlightingView
{
    return highlightingView;
}

- (void)setHighlightingView:(NSView *)newHighlightingView
{
	// do not retain hightlighting view
	highlightingView = newHighlightingView;
}


- (void)changeDraggingHighlight:(BOOL)doHighlight
{
	if ([highlightingView respondsToSelector:_cmd])
		[highlightingView changeDraggingHighlight:doHighlight];
	else {
		if (_drawDraggingHighlight != doHighlight) {
			_drawDraggingHighlight = doHighlight;
			[self setNeedsDisplay:YES];
		}
	}
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
	if ([delegate respondsToSelector:_cmd])
		_lastDragOperation = [delegate draggingEntered:sender];
	else
		_lastDragOperation = NSDragOperationNone;
	if (_lastDragOperation != NSDragOperationNone)
		[self changeDraggingHighlight:YES];
	return _lastDragOperation;
}

- (NSDragOperation)draggingUpdated:(id <NSDraggingInfo>)sender
{
	if ([delegate respondsToSelector:_cmd])
		_lastDragOperation = [delegate draggingUpdated:sender];
	if (_lastDragOperation != NSDragOperationNone)
		[self changeDraggingHighlight:YES];
	return _lastDragOperation;
}

- (void)draggingExited:(id <NSDraggingInfo>)sender
{
	if ([delegate respondsToSelector:_cmd])
		[delegate draggingExited:sender];
	[self changeDraggingHighlight:NO];
}

- (void)draggingEnded:(id <NSDraggingInfo>)sender
{
	if ([delegate respondsToSelector:_cmd])
		return [delegate draggingEnded:sender];
	[self changeDraggingHighlight:NO];
}

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender
{
	if ([delegate respondsToSelector:_cmd])
		return [delegate prepareForDragOperation:sender];
	else
		return NO;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
	if ([delegate respondsToSelector:_cmd])
		return [delegate performDragOperation:sender];
	else
		return NO;
}

- (void)concludeDragOperation:(id <NSDraggingInfo>)sender
{
	[self changeDraggingHighlight:NO];
	if ([delegate respondsToSelector:_cmd])
		return [delegate concludeDragOperation:sender];
}


@end
