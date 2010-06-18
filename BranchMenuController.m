//
//  BranchMenuController.m
//  GitX
//
//  Created by glaullon on 6/17/10.
//  Copyright 2010 VMware, Inc. All rights reserved.
//

#import "BranchMenuController.h"
#import "PBSourceViewBadge.h"


@implementation BranchMenuController

@synthesize repository;
@synthesize controller;

- (void)awakeFromNib
{
    NSLog(@"[%@ %s]", [self class], _cmd);
	NSMenu *menu=[[NSMenu alloc] initWithTitle:@""];
	[menu addItemWithTitle:@"" action:nil keyEquivalent:@""]; // el primero es el titulo....
	[button setMenu:menu];
}

-(void)reloadBranchs
{
	NSMenuItem *item;
	NSMenu *menu=[button menu];
	NSMenu *tags=[[NSMenu alloc] initWithTitle:@""];
	
	item=[menu addItemWithTitle:@"Local Branches" action:nil keyEquivalent:@""];
	[item setEnabled:NO];
	
    NSLog(@"[%@ %s] repository=%@", [self class], _cmd,repository);
	for (PBGitRevSpecifier *rev in [repository branches]) {
		if ([rev isLocalBranch]) {
			item=[menu addItemWithTitle:[rev description] action:nil keyEquivalent:@""];
			[item setRepresentedObject:rev];
			if([rev isEqual:[repository headRef]]){
				[item setImage:[PBSourceViewBadge checkedOutBadge]];
			}
		}else if ([rev isTag]) {
			item=[tags addItemWithTitle:[rev description] action:nil keyEquivalent:@""];
			[item setRepresentedObject:rev];
			[item setTarget:self];
			[item setAction:@selector(change:)];
		}else {
			NSLog(@"[%@ %s] rev=%@", [self class], _cmd,[rev simpleRef]);
		}
		
	}
	[menu addItem:[NSMenuItem separatorItem]];
	item=[menu addItemWithTitle:@"Tags" action:nil keyEquivalent:@""];
	[item setTarget:[button cell]];
	[menu setSubmenu:tags forItem:item];
	
	[button setTitle:[NSString stringWithFormat:@"Branch: %@",[repository headRef]]];
	[button needsDisplay];
	[repository addObserver:self forKeyPath:@"branches" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:@"branchesModified"];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSLog(@"[%@ %s]", [self class], _cmd);
	[self reloadBranchs];
}	

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
	return [menuItem representedObject]!=nil || [menuItem submenu]!=nil;
}

-(IBAction)change:(id)sender
{
	PBGitRevSpecifier *rev;
	
	if(sender==button){
		rev=[[button selectedItem] representedObject];
	}else{
		rev=[sender representedObject];
	}
	
	NSLog(@"[%@ %s] rev=%@", [self class], _cmd,rev);
	repository.currentBranch = rev;
	NSString *format=@"-%@-";
	if([rev isLocalBranch])
		format=@"Branch: %@";
	else if([rev isTag])
		format=@"Tag: %@";
	[button setTitle:[NSString stringWithFormat:format,rev]];
	
}

@end
