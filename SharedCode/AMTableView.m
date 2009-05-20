//
//  AMTableView.m
//  TimeDisc
//
//  Created by Andreas on Fri Feb 07 2003.
//  Copyright (c) 2003 Andreas Mayer. All rights reserved.
//

#import "AMTableView.h"


@implementation AMTableView

- (void)textDidEndEditing:(NSNotification *)aNotification
{
	int column;
	int row;
	BOOL doEdit = YES;

	column = [self editedColumn];
	row = [self editedRow];
	[super textDidEndEditing:aNotification];

	//if (column == [self columnWithIdentifier:@"VarName"]) {
	switch ([[[aNotification userInfo] objectForKey:@"NSTextMovement"] intValue]) {
		case NSReturnTextMovement:	// return
		{
			/*
			 row++;
			 if (row >= [self numberOfRows])
			 row = 0;
			 */
			doEdit = NO;
			break;
		}
		case NSBacktabTextMovement:	// shift tab
		{
			if (column == 0) {
				row--;
				if (row < 0)
					row = [self numberOfRows]-1;
				column = [self numberOfColumns]-1;
			} else {
				column--;
			}
			doEdit = YES;
			break;
		}
			//case NSTabTextMovement:		// tab
		default:
		{
			if (column == [self numberOfColumns]-1) {
				row++;
				if (row >= [self numberOfRows])
					row = 0;
				column = 0;
			} else {
				column++;
			}
			doEdit = YES;
		}
	} // switch
	[self selectRow:row byExtendingSelection:NO];
	if (doEdit) {
		[self editColumn:column row:row withEvent:nil select:YES];
	} else {
		[self validateEditing];
		[self abortEditing];
		if ([_delegate respondsToSelector:@selector(tableViewDidEndEditing:)])
			[_delegate performSelector:@selector(tableViewDidEndEditing:) withObject:self];
	}
	//}
}

- (void)doCommandBySelector:(SEL)aSelector
{
	//NSLog(@"doCommandBySelector:%@\n", NSStringFromSelector(aSelector));
	if ([self currentEditor] && (aSelector = @selector(_cancelKey:))) {
		[self abortEditing];
	} else {
		[super doCommandBySelector:aSelector];
	}
}

@end
