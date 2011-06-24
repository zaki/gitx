//
//  GXRepoDocumentController.m
//  gitx
//
//  Created by German Laullon on 23/06/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GXRepoDocumentController.h"

@implementation GXRepoDocumentController

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    DLog(@"");
    return self;
}

- (NSArray *)URLsFromRunningOpenPanel
{
    NSOpenPanel *open=[NSOpenPanel openPanel];
    [open setCanChooseFiles:NO];
    [open setCanChooseDirectories:YES];
    [open setAllowsMultipleSelection:NO];
    [open runModal];
    
    NSArray *res=[open URLs];
    NSURL *url=[res objectAtIndex:0];
    
    NSURL *dotGit=[url URLByAppendingPathComponent:@".git"];
    if([[NSFileManager defaultManager] fileExistsAtPath:[dotGit path]]){
        url=[url URLByAppendingPathExtension:@"git"];
        res=[NSArray arrayWithObject:url];
    }
    DLog(@"res=%@", res);
    return res;
}

@end
