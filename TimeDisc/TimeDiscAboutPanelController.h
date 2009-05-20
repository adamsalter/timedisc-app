//
//  TimeDiscAboutPanelController.h
//  TimeDisc
//
//  Created by Andreas on Sat Feb 15 2003.
//  Copyright (c) 2003 Andreas Mayer. All rights reserved.
//

#import <AppKit/AppKit.h>


@interface TimeDiscAboutPanelController : NSWindowController {
	IBOutlet NSButton *homeURLButton;
	IBOutlet NSButton *applicationIcon;
}

- (IBAction)openHomeURL:(id)sender;


@end
