/*
File:		CustomWindow.m

Description: 	This is the implementation file for the CustomWindow class, which is our subclass of NSWindow.  We need to subclass
		NSWindow in order to configure the window properly in -initWithContentRect:styleMask:backing:defer:
		to have a custom shape and be transparent.  We also override the -mouseDown: and -mouseDragged: routines,
		to allow for dragging the window by clicking on its content area (since it doesn't have a title bar to drag).

Author:		MCF

Copyright: 	© Copyright 2001 Apple Computer, Inc. All rights reserved.

Disclaimer:	IMPORTANT:  This Apple software is supplied to you by Apple Computer, Inc.
                ("Apple") in consideration of your agreement to the following terms, and your
                use, installation, modification or redistribution of this Apple software
                constitutes acceptance of these terms.  If you do not agree with these terms,
                please do not use, install, modify or redistribute this Apple software.

                In consideration of your agreement to abide by the following terms, and subject
                to these terms, Apple grants you a personal, non-exclusive license, under Apple’s
                copyrights in this original Apple software (the "Apple Software"), to use,
                reproduce, modify and redistribute the Apple Software, with or without
                modifications, in source and/or binary forms; provided that if you redistribute
                the Apple Software in its entirety and without modifications, you must retain
                this notice and the following text and disclaimers in all such redistributions of
                the Apple Software.  Neither the name, trademarks, service marks or logos of
                Apple Computer, Inc. may be used to endorse or promote products derived from the
                Apple Software without specific prior written permission from Apple.  Except as
                expressly stated in this notice, no other rights or licenses, express or implied,
                are granted by Apple herein, including but not limited to any patent rights that
                may be infringed by your derivative works or by other works in which the Apple
                Software may be incorporated.

                The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO
                WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED
                WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR
                PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN
                COMBINATION WITH YOUR PRODUCTS.

                IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR
                CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
                GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
                ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION
                OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF CONTRACT, TORT
                (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN
                ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
                
Change History (most recent first):

03/2001 - MCF - initial version
01/2002 - MCF - updated code to add -canBecomeKeyWindow override to allow controls to be enabled

*/


#import "CustomWindow.h"
#import <AppKit/AppKit.h>
#import <ApplicationServices/ApplicationServices.h>

@implementation CustomWindow

//In Interface Builder we set CustomWindow to be the class for our window, so our own initializer is called here.
- (id)initWithContentRect:(NSRect)contentRect styleMask:(unsigned int)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag {

    //Call NSWindow's version of this function, but pass in the all-important value of NSBorderlessWindowMask
    //for the styleMask so that the window doesn't have a title bar
    NSWindow* result = [super initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
    //Set the background color to clear so that (along with the setOpaque call below) we can see through the parts
    //of the window that we're not drawing into
    [result setBackgroundColor: [NSColor clearColor]];
    //This next line pulls the window up to the front on top of other system windows.  This is how the Clock app behaves;
    //generally you wouldn't do this for windows unless you really wanted them to float above everything.
    //[result setLevel: NSStatusWindowLevel];
	//[result setLevel:kCGDesktopWindowLevel];
    //Let's start with no transparency for all drawing into the window
    [result setAlphaValue:1.0];
    //but let's turn off opaqueness so that we can see through the parts of the window that we're not drawing into
    [result setOpaque:NO];
    //and while we're at it, make sure the window has a shadow, which will automatically be the shape of our custom content.
    //[result setHasShadow: YES];
	//[result makeKeyAndOrderFront:self];
    return result;
}

// Custom windows that use the NSBorderlessWindowMask can't become key by default.  Therefore, controls in such windows
// won't ever be enabled by default.  Thus, we override this method to change that.
/*
- (BOOL) canBecomeKeyWindow
{
    return YES;
}
*/

//Once the user starts dragging the mouse, we move the window with it. We do this because the window has no title
//bar for the user to drag (so we have to implement dragging ourselves)
- (void)mouseDragged:(NSEvent *)theEvent
{
   NSPoint currentLocation;
   NSRect newFrame;
   NSRect windowFrame = [self frame];

   //grab the current global mouse location; we could just as easily get the mouse location 
   //in the same way as we do in -mouseDown:
   newFrame = windowFrame;
   currentLocation = [self convertBaseToScreen:[self mouseLocationOutsideOfEventStream]];
   newFrame.origin.x = currentLocation.x - initialLocation.x;
   newFrame.origin.y = currentLocation.y - initialLocation.y;

   //go ahead and move the window to the new location
   [self setFrameOrigin:[self constrainFrameRect:newFrame toScreen:[self screen]].origin];
}

//We start tracking the a drag operation here when the user first clicks the mouse,
//to establish the initial location.
- (void)mouseDown:(NSEvent *)theEvent
{    
    NSRect  windowFrame = [self frame];

    //grab the mouse location in global coordinates
   initialLocation = [self convertBaseToScreen:[theEvent locationInWindow]];
   initialLocation.x -= windowFrame.origin.x;
   initialLocation.y -= windowFrame.origin.y;
}

- (NSRect)constrainFrameRect:(NSRect)frame toScreen:(NSScreen *)screen
{
	// make sure that frame is not completely outside the desktop frame
	NSRect result;
	NSRect screenFrame = [[self screen] frame];

	//NSLog(@"CustomWindow contrainFrameRect:(x:%f, y:%f, w:%f, h:%f) toScreen:", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
	result = frame;
    if (frame.origin.y+(0.2*frame.size.height) > (screenFrame.origin.y+screenFrame.size.height))
		result.origin.y = screenFrame.origin.y+(screenFrame.size.height-frame.size.height);
	if ((frame.origin.y+(0.8*frame.size.height)) < screenFrame.origin.y)
		result.origin.y = screenFrame.origin.y;
    if (frame.origin.x+(0.2*frame.size.width) > (screenFrame.origin.x+screenFrame.size.width))
		result.origin.x = screenFrame.origin.x+(screenFrame.size.width-frame.size.width);
	if ((frame.origin.x+(0.8*frame.size.width)) < screenFrame.origin.x)
		result.origin.x = screenFrame.origin.x;
	//NSLog(@"resulting rect:(x:%f, y:%f, w:%f, h:%f)", result.origin.x, result.origin.y, result.size.width, result.size.height);
	return result;
}


@end
