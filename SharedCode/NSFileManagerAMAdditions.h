//
//  NSFileManagerAMAdditions.h
//  CommX
//
//  Created by Andreas on Thu Jul 04 2002.
//  Copyright (c) 2002 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSFileManager (AMAdditions)

- (NSString *)findSystemFolderType:(int)folderType forDomain:(int)domain;

@end
