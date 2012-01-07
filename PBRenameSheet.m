//
//  PBRenameSheet.m
//  GitX
//
//  Created by Robert Kyriakis on 18.12.2011.
//  Copyright 2011 Robert Kyriakis. All rights reserved.
//

#import "PBRenameSheet.h"
#import "PBGitWindowController.h"

@interface PBRenameSheet ()
- (void) showRenameSheetAtRef:(PBGitRef*)ref inRepository:(PBGitRepository *)repo;
@property (strong) PBGitRepository *repository;
@property (strong) PBGitRef *refToRename;
@end


@implementation PBRenameSheet

#pragma mark - Private Properties
@synthesize repository;
@synthesize refToRename;

static PBRenameSheet *sheet;

+ (void) showRenameSheetAtRef:(PBGitRef*)ref inRepository:(PBGitRepository *)repo
{
    if(!sheet){
        sheet = [[self alloc] initWithWindowNibName:@"PBRenameSheet"];
    }
	[sheet showRenameSheetAtRef:ref inRepository:repo];
}

- (void) showRenameSheetAtRef:(PBGitRef*)ref inRepository:(PBGitRepository *)repo
{
	self.repository = repo;
	self.refToRename = ref;

	[self window];
    
    [newRefNameTextField setStringValue:@""];
    [[newRefNameTextField window] makeFirstResponder:newRefNameTextField];
     
	[errorMessageTextField setStringValue:@""];
    [oldRefNameTextField setStringValue:[NSString stringWithFormat:@"Rename %@ %@",[ref refishType],[ref shortName]]];
    
	[NSApp beginSheet:[self window] 
       modalForWindow:[self.repository.windowController window] 
        modalDelegate:self 
       didEndSelector:nil 
          contextInfo:nil];
}

#pragma mark IBActions

- (IBAction)renameRef:(id)sender
{
    PBGitRef *refWithNewName;
    
    [errorMessageTextField setStringValue:@""];
    [errorMessageTextField setHidden:YES];
    
    if ([refToRename refishType] == kGitXTagType)
    {
        refWithNewName = [PBGitRef refFromString:[kGitXTagRefPrefix stringByAppendingString:[newRefNameTextField stringValue]]];
    } 
    else if ([refToRename refishType] == kGitXBranchType)
    {
        refWithNewName = [PBGitRef refFromString:[kGitXBranchRefPrefix stringByAppendingString:[newRefNameTextField stringValue]]];
    }
    else if ([refToRename refishType] == kGitXRemoteBranchType)
    {
        NSMutableString *refPath = [NSMutableString new];
        [refPath appendString:kGitXRemoteRefPrefix];
        [refPath appendString:[refToRename remoteName]];
        [refPath appendString:[NSString stringWithFormat:@"/%@",[newRefNameTextField stringValue]]];
        refWithNewName = [PBGitRef refFromString:refPath];
    }
    else if ([refToRename refishType] == kGitXRemoteType)
    {
        refWithNewName = [PBGitRef refFromString:[kGitXRemoteRefPrefix stringByAppendingString:[newRefNameTextField stringValue]]];
    }
    
    if (![self.repository checkRefFormat:[refWithNewName ref]]) {
		[errorMessageTextField setStringValue:@"Invalid name!"];
		[errorMessageTextField setHidden:NO];
		return;
	}
    
	if ([self.repository refExists:refWithNewName checkOnRemotes:YES]) {
		[errorMessageTextField setStringValue:@"Refname already exists local as tag or branch or remote as tag!"];
		[errorMessageTextField setHidden:NO];
		return;
	}
	[self cancelRenameSheet:self];
    
	[self.repository renameRef:self.refToRename withNewName:[newRefNameTextField stringValue]];
}


- (IBAction)cancelRenameSheet:(id)sender
{
	[NSApp endSheet:[self window]];
	[[self window] orderOut:self];
}



@end
