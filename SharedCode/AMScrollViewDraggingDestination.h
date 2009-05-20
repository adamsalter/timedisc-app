//
//  AMScrollViewDraggingDestination.h
//  TimeDisc
//
//  Created by Andreas on Thu Feb 13 2003.
//  Copyright (c) 2003 Andreas Mayer. All rights reserved.
//

#import <AppKit/AppKit.h>


@interface AMScrollViewDraggingDestination : NSScrollView {
	id delegate;
	NSView *highlightingView;
	NSDragOperation _lastDragOperation;
	BOOL _drawDraggingHighlight;
}

- (id)delegate;
- (void)setDelegate:(id)newDelegate;

- (NSView *)highlightingView;
- (void)setHighlightingView:(NSView *)newHighlightingView;


@end
