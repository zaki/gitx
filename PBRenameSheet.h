//
//  PBRenameSheet.h
//  GitX
//
//  Created by Robert Kyriakis on 18.12.2011.
//  Copyright 2011 Robert Kyriakis. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PBGitRefish.h"

@class PBGitRepository;

@interface PBRenameSheet : NSWindowController
{
    IBOutlet NSTextField *oldRefNameTextField;
    IBOutlet NSTextField *newRefNameTextField;
    IBOutlet NSTextField *errorMessageTextField;
}

+ (void) showRenameSheetAtRefish:(id <PBGitRefish>)ref inRepository:(PBGitRepository *)repo;

- (IBAction) renameRef:(id)sender;
- (IBAction) cancelRenameSheet:(id)sender;

@end
