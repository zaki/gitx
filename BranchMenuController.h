//
//  BranchMenuController.h
//  GitX
//
//  Created by glaullon on 6/17/10.
//  Copyright 2010 VMware, Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PBGitRepository.h"


@interface BranchMenuController : NSObject {
	IBOutlet NSPopUpButton *button;
	PBGitRepository *repository;
	id controller;
}

@property(readwrite) PBGitRepository *repository;
@property(readwrite) id controller;

-(void)reloadBranchs;
-(IBAction)change:(id)sender;

@end
