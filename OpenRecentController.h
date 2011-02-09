//
//  OpenRecentController.h
//  GitX
//
//  Created by Hajo Nils Krabbenhöft on 07.10.10.
//  Copyright 2010 spratpix GmbH & Co. KG. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface OpenRecentController :NSObject {
	NSSearchField* searchField;
	NSWindow* searchWindow;
	NSMutableArray* currentResults;
	NSMutableArray* possibleResults;
	NSURL* selectedResult;
	NSTableView* resultViewer;
}

+ (void)openUrl:(NSURL*)url;
+ (OpenRecentController*)sharedOpenRecentController;
-(BOOL)showWindow;
- (IBAction)doSearch: sender;
- (IBAction)changeSelection: sender;
- (void) tableDoubleClick:(id)sender;

@property (retain, nonatomic) IBOutlet NSSearchField* searchField;
@property (retain, nonatomic) IBOutlet NSWindow* searchWindow;
@property (retain, nonatomic) IBOutlet NSTableView* resultViewer;
@end
