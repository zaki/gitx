//
//  OpenRecentController.m
//  GitX
//
//  Created by Hajo Nils Krabbenhöft on 07.10.10.
//  Copyright 2010 spratpix GmbH & Co. KG. All rights reserved.
//

#import "OpenRecentController.h"
#import "PBGitDefaults.h"
#import "PBRepositoryDocumentController.h"


@implementation OpenRecentController

@synthesize searchField, searchWindow, resultViewer;

- (id) init
{
  self = [super init];
  if (self != nil) {
    [NSBundle loadNibNamed: @"OpenRecentPopup" owner:self];
    currentResults = [NSMutableArray new];
    possibleResults = [NSMutableArray new];
  }
  return self;
}

static OpenRecentController *sharedOpenRecentController = nil;

+ (OpenRecentController*)sharedOpenRecentController {
    @synchronized(self) {
        if (sharedOpenRecentController == nil) {
            [[self alloc] init]; // assignment not done here
        }
    }
    return sharedOpenRecentController;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedOpenRecentController == nil) {
            sharedOpenRecentController = [super allocWithZone:zone];
            return sharedOpenRecentController;  // assignment and return on first allocation
        }
    }
    return nil; //on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)retain {
    return self;
}

- (NSUInteger)retainCount {
    return UINT_MAX;  //denotes an object that cannot be released
}

- (void)release {
    //do nothing
}

- (id)autorelease {
    return self;
}

-(BOOL)showWindow {
  [currentResults removeAllObjects];
  [possibleResults removeAllObjects];
  for (NSURL *url in [[NSDocumentController sharedDocumentController] recentDocumentURLs]) {
		[possibleResults addObject: url];
	}
	[searchField setStringValue:@""];
	[self doSearch: nil];
	[searchWindow makeKeyAndOrderFront:nil];
	return [possibleResults count] > 0;
}

+ (void)openUrl:(NSURL*)url
{
	NSError *error = nil;
	[[PBRepositoryDocumentController sharedDocumentController] openDocumentWithContentsOfURL:url display:YES error:&error];
}


- (IBAction)doSearch: sender
{
	NSString *searchString = [searchField stringValue];
	
	while( [currentResults count] > 0 ) [currentResults removeLastObject];
	
    for(NSURL* url in possibleResults){
		NSString* label = [[url path] lastPathComponent];
		if([searchString length] > 0) {
			NSRange aRange = [label rangeOfString: searchString options: NSCaseInsensitiveSearch];
			if (aRange.location == NSNotFound) continue;
		}
		[currentResults addObject: url];
    }   
	
	if( [currentResults count] > 0 )
		selectedResult = [currentResults objectAtIndex:0];
	else
		selectedResult = nil;
	
	[resultViewer reloadData];
}

- (void)awakeFromNib
{
    [resultViewer setTarget:self];
    [resultViewer setDoubleAction:@selector(tableDoubleClick:)];
}


- (void) tableDoubleClick:(id)sender 
{
	[self changeSelection:nil];
	if(selectedResult != nil) {
		[OpenRecentController openUrl:selectedResult];
	}
	[searchWindow orderOut:nil];
}

- (BOOL)control:(NSControl*)control textView:(NSTextView*)textView doCommandBySelector:(SEL)commandSelector {
    BOOL result = NO;
    if (commandSelector == @selector(insertNewline:)) {
		if(selectedResult != nil) {
			[OpenRecentController openUrl:selectedResult];
		}
		[searchWindow orderOut:nil];
//		[searchWindow makeKeyAndOrderFront: nil];
		result = YES;
    }
	else if(commandSelector == @selector(cancelOperation:)) {
		[searchWindow orderOut:nil];
		result = YES;
	}
	else if(commandSelector == @selector(moveUp:)) {
		if(selectedResult != nil) {
			int index = [currentResults indexOfObject: selectedResult]-1;
			if(index < 0) index = 0;
			selectedResult = [currentResults objectAtIndex:index];
			[resultViewer selectRow:index byExtendingSelection:FALSE];
			[resultViewer scrollRowToVisible:index];
		}
		result = YES;
	}
	else if(commandSelector == @selector(moveDown:)) {
		if(selectedResult != nil) {
			int index = [currentResults indexOfObject: selectedResult]+1;
			if(index >= [currentResults count]) index = [currentResults count] - 1;
			selectedResult = [currentResults objectAtIndex:index];
			[resultViewer selectRow:index byExtendingSelection:FALSE];
			[resultViewer scrollRowToVisible:index];
		}
		result = YES;
	}
    return result;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{	
    id theValue;
    NSParameterAssert(rowIndex >= 0 && rowIndex < [currentResults count]);
	
    NSURL* row = [currentResults objectAtIndex:rowIndex];
	if( [[aTableColumn identifier] isEqualToString: @"icon"] ) {
		id icon = nil;
		if ([row isFileURL])
			icon = [[NSWorkspace sharedWorkspace] iconForFile:[row path]];
		return icon;
	} else if( [[aTableColumn identifier] isEqualToString: @"label"] ) {
		return [[row path] lastPathComponent];
	}
    return theValue;
	
}
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	
    return [currentResults count];
	
}

- (IBAction)changeSelection: sender {
	int i = [resultViewer selectedRow];
	if(i >= 0 && i < [currentResults count])
		selectedResult = [currentResults objectAtIndex: i];
	else 
		selectedResult = nil;
}


@end
