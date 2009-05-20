//
//  TimeDiscAboutPanelController.m
//  TimeDisc
//
//  Created by Andreas on Sat Feb 15 2003.
//  Copyright (c) 2003 Andreas Mayer. All rights reserved.
//

#import "TimeDiscAboutPanelController.h"


@implementation TimeDiscAboutPanelController

- (void)awakeFromNib
{
	[homeURLButton setToolTip:NSLocalizedString(@"HOMEURL", @"")];
	NSImage *appImage = [NSApp applicationIconImage];
	NSImage *newImage = [[[NSImage alloc] init] autorelease];
	[newImage setSize:[applicationIcon frame].size];
	NSRect destRect = NSMakeRect(0,0,[newImage size].width, [newImage size].height);
	NSRect srcRect = NSMakeRect(0,0,[appImage size].width, [appImage size].height);
	[newImage lockFocus];
	[appImage drawInRect:destRect fromRect:srcRect operation:NSCompositeCopy fraction:1.0];
	[newImage unlockFocus];
	[applicationIcon setImage:newImage];
	[[self window] center];
}

- (IBAction)openHomeURL:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:NSLocalizedString(@"HOMEURL", @"")]];
}


@end
