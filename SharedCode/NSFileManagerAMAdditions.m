//
//  NSFileManagerAMAdditions.m
//  CommX
//
//  Created by Andreas on Thu Jul 04 2002.
//  Copyright (c) 2002 Andreas Mayer. All rights reserved.
//

#import "NSFileManagerAMAdditions.h"
//#include <CoreFoundation/CFURL.h>

//kUserDomain
//kApplicationSupportFolderType
//kCurrentUserFolderType


@implementation NSFileManager (AMAdditions)

- (NSString *)findSystemFolderType:(int)folderType forDomain:(int)domain
{
	FSRef folder;
	OSErr err = noErr;
	CFURLRef url;
	NSString *result = nil;

	err = FSFindFolder(domain, folderType, false, &folder); 

	if (err == noErr) {
		url =  CFURLCreateFromFSRef(kCFAllocatorDefault, &folder);
		result = [(NSURL *)url path];
	}

	return result;
}


@end