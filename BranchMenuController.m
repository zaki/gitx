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
	
	NSMutableDictionary *remotes=[NSMutableDictionary dictionary];
	
    NSLog(@"[%@ %s] repository=%@", [self class], _cmd,repository);
	for (PBGitRevSpecifier *rev in [repository branches]) {
		if ([rev isLocalBranch]) {
			item=[menu addItemWithTitle:[rev description] action:nil keyEquivalent:@""];
			[item setRepresentedObject:rev];
			if([rev isEqual:[repository headRef]]){
				[item setImage:[PBSourceViewBadge checkedOutBadge]];
			}
		}else if ([rev isRemoteBranch]) {
			NSString *remoteName=[rev remoteName];
			NSMenu *remoteSubMenu=[remotes objectForKey:remoteName];
			if(remoteSubMenu==nil){
				remoteSubMenu=[NSMenu alloc];
				[remotes setObject:remoteSubMenu forKey:remoteName];
			}
			item=[remoteSubMenu addItemWithTitle:[rev remoteBranchName] action:nil keyEquivalent:@""];
			[item setRepresentedObject:rev];
			[item setTarget:self];
			[item setAction:@selector(change:)];
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
	item=[menu addItemWithTitle:@"Remotes" action:nil keyEquivalent:@""];

	for (NSString *subMenuName in [remotes allKeys]) {
		NSMenu *subMenu=[remotes objectForKey:subMenuName];
		item=[menu addItemWithTitle:subMenuName action:nil keyEquivalent:@""];
		[menu setSubmenu:subMenu forItem:item];
	}

	[menu addItem:[NSMenuItem separatorItem]];
	item=[menu addItemWithTitle:@"Tags" action:nil keyEquivalent:@""];
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

-(void)setCommit:(PBGitCommit *)commit
{	
	NSString *title=[NSString stringWithFormat:@"SHA: %@",[commit realSha]];

	NSMutableArray *refs=[commit refs];
	if(refs!=nil){
		PBGitRef *ref=[refs objectAtIndex:0];
		if([ref isTag])
			title=[NSString stringWithFormat:@"SHA: %@",[ref tagName]];
		else if([ref isRemote])
			title=[NSString stringWithFormat:@"Remote: %@",[ref remoteBranchName]];
		else if([ref isBranch])
			title=[NSString stringWithFormat:@"Branch: %@",[ref branchName]];
	}
	
	[button setTitle:title];
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
}

@end
