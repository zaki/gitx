//
//  PBChangeRemoteUrlSheet.h
//  GitX
//
//  Created by Robert Kyriakis on 27.12.2011.
//  Copyright 2011 Robert Kyriakis. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PBChangeRemoteUrlSheet : NSWindowController 
{
	IBOutlet NSTextField *RemoteNameTextField;
	IBOutlet NSTextField *RemoteUrlTextField;
	IBOutlet NSTextField *errorMessageTextField;
	NSOpenPanel *browseRemoteUrlPanel;
	NSString    *remoteUrl;
}

+ (id) panel;
+ (void)showChangeRemoteUrlSheet:(NSString *)repository toURL:(NSURL *)targetURL isBare:(BOOL)bare;

- (void)showMessageSheet:(NSString *)messageText infoText:(NSString *)infoText;
- (void)showErrorSheet:(NSError *)error;

- (IBAction) closeCloneRepositoryPanel:(id)sender;
- (IBAction) clone:(id)sender;
- (IBAction) browseRepository:(id)sender;
- (IBAction) showHideHiddenFiles:(id)sender;
- (IBAction) browseDestination:(id)sender;

@end
