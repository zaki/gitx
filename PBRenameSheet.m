//
//  PBRenameSheet.m
//  GitX
//
//  Created by Robert Kyriakis on 18.12.2011.
//  Copyright 2011 Robert Kyriakis. All rights reserved.
//

#import "PBRenameSheet.h"
#import "PBGitRepository.h"
//#import "PBGitDefaults.h"
//#import "PBGitCommit.h"
//#import "PBGitRef.h"
#import "PBGitWindowController.h"

@interface PBRenameSheet ()
- (void) showRenameSheetAtRefish:(id <PBGitRefish>)ref inRepository:(PBGitRepository *)repo;
@property (strong) PBGitRepository *repository;
@property (strong) id <PBGitRefish> startRefish;
@end


@implementation PBRenameSheet

#pragma mark - Private Properties
@synthesize repository;
@synthesize startRefish;

static PBRenameSheet *sheet;

+ (void) showRenameSheetAtRefish:(id <PBGitRefish>)ref inRepository:(PBGitRepository *)repo
{
    if(!sheet){
        sheet = [[self alloc] initWithWindowNibName:@"PBRenameSheet"];
    }
	[sheet showRenameSheetAtRefish:ref inRepository:repo];
}

- (void) showRenameSheetAtRefish:(id <PBGitRefish>)ref inRepository:(PBGitRepository *)repo
{
	self.repository = repo;
	self.startRefish = ref;

	[self window];
    
    [newRefNameTextField setStringValue:@""];
    [[newRefNameTextField window] makeFirstResponder:newRefNameTextField];
     
	[errorMessageTextField setStringValue:@""];
    [oldRefNameTextField setStringValue:[NSString stringWithFormat:@"Rename %@ %@",[ref refishType],[ref shortName]]];
    
	[NSApp beginSheet:[self window] 
       modalForWindow:[self.repository.windowController window] 
        modalDelegate:self 
       didEndSelector:nil contextInfo:NULL];
}

#pragma mark IBActions

- (IBAction)renameRef:(id)sender
{
	PBGitRef *ref = [PBGitRef refFromString:[kGitXBranchRefPrefix stringByAppendingString:[newRefNameTextField stringValue]]];
    
    if (![self.repository checkRefFormat:[ref ref]]) {
		[errorMessageTextField setStringValue:@"Invalid name"];
		[errorMessageTextField setHidden:NO];
		return;
	}
    
	if ([self.repository refExists:ref]) {
		[errorMessageTextField setStringValue:[NSString stringWithFormat:@"%@ already exists",[newRefNameTextField stringValue]]];
		[errorMessageTextField setHidden:NO];
		return;
	}
	[self cancelRenameSheet:self];
	[self.repository renameRefAtRefish:self.startRefish withNewName:[newRefNameTextField stringValue]];
}


- (IBAction)cancelRenameSheet:(id)sender
{
	[NSApp endSheet:[self window]];
	[[self window] orderOut:self];
}



@end
