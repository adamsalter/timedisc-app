//
//  TimeDiscThemeListTableView.h
//  TimeDisc
//
//  Created by Andreas on Fri Feb 07 2003.
//  Copyright (c) 2003 Andreas Mayer. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AMTableView.h"


@interface TimeDiscThemeListTableView : AMTableView {
	int draggedRow;
	BOOL _drawDraggingHighlight;
}

- (void)changeDraggingHighlight:(BOOL)doHighlight;


@end
