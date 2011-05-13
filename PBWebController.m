//
//  PBWebController.m
//  GitX
//
//  Created by Pieter de Bie on 08-10-08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "PBWebController.h"
#import "PBGitRepository.h"
#import "PBGitXProtocol.h"
#import "PBGitDefaults.h"

#include <SystemConfiguration/SCNetworkReachability.h>

@interface PBWebController()
- (void)preferencesChangedWithNotification:(NSNotification *)theNotification;
@end

@implementation PBWebController

@synthesize startFile, repository;

- (void) awakeFromNib
{
	NSString *path = [NSString stringWithFormat:@"html/views/%@", startFile];
	NSString* file = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html" inDirectory:path];
	NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:file]];
	callbacks = [NSMapTable mapTableWithKeyOptions:(NSPointerFunctionsObjectPointerPersonality|NSPointerFunctionsStrongMemory) valueOptions:(NSPointerFunctionsObjectPointerPersonality|NSPointerFunctionsStrongMemory)];

	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self
	       selector:@selector(preferencesChangedWithNotification:)
		   name:NSUserDefaultsDidChangeNotification
		 object:nil];

	finishedLoading = NO;
	[view setUIDelegate:self];
	[view setFrameLoadDelegate:self];
	[view setResourceLoadDelegate:self];
	[[view mainFrame] loadRequest:request];
}

- (WebScriptObject *) script
{
	return [view windowScriptObject];
}

- (void)closeView
{
	if (view) {
		[[self script] setValue:nil forKey:@"Controller"];
		[view close];
	}

	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

# pragma mark Delegate methods

- (void)webView:(WebView *)sender didClearWindowObject:(WebScriptObject *)windowObject forFrame:(WebFrame *)frame
{
	id script = [view windowScriptObject];
	[script setValue: self forKey:@"Controller"];
}

- (void) webView:(id) v didFinishLoadForFrame:(id) frame
{
	finishedLoading = YES;
	if ([self respondsToSelector:@selector(didLoad)])
		[self performSelector:@selector(didLoad)];
}

- (void)webView:(WebView *)webView addMessageToConsole:(NSDictionary *)dictionary
{
	DLog(@"Error from webkit: %@", dictionary);
}

- (void)webView:(WebView *)sender runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WebFrame *)frame
{
	DLog(@"Message from webkit: %@", message);
}

- (NSURLRequest *)webView:(WebView *)sender
                 resource:(id)identifier
          willSendRequest:(NSURLRequest *)request
         redirectResponse:(NSURLResponse *)redirectResponse
           fromDataSource:(WebDataSource *)dataSource
{
	if (!self.repository)
		return request;

	// TODO: Change this to canInitWithRequest
	if ([[[request URL] scheme] isEqualToString:@"GitX"]) {
		NSMutableURLRequest *newRequest = [request mutableCopy];
		[newRequest setRepository:self.repository];
		return newRequest;
	}

	return request;
}


+ (BOOL)isSelectorExcludedFromWebScript:(SEL)aSelector
{
	return NO;
}

+ (BOOL)isKeyExcludedFromWebScript:(const char *)name {
	return NO;
}

#pragma mark Functions to be used from JavaScript

- (void) log: (NSString*) logMessage
{
	DLog(@"%@", logMessage);
}

- (BOOL) isReachable:(NSString *)hostname
{
    SCNetworkReachabilityRef target;
    SCNetworkConnectionFlags flags = 0;
    Boolean reachable;
    target = SCNetworkReachabilityCreateWithName(NULL, [hostname cStringUsingEncoding:NSASCIIStringEncoding]);
    reachable = SCNetworkReachabilityGetFlags(target, &flags);
	CFRelease(target);

	if (!reachable)
		return FALSE;

	// If a connection is required, then it's not reachable
	if (flags & (kSCNetworkFlagsConnectionRequired | kSCNetworkFlagsConnectionAutomatic | kSCNetworkFlagsInterventionRequired))
		return FALSE;

	return flags > 0;
}

- (BOOL) isFeatureEnabled:(NSString *)feature
{
	if([feature isEqualToString:@"gravatar"])
		return [PBGitDefaults isGravatarEnabled];
	else if([feature isEqualToString:@"gist"])
		return [PBGitDefaults isGistEnabled];
	else if([feature isEqualToString:@"confirmGist"])
		return [PBGitDefaults confirmPublicGists];
	else if([feature isEqualToString:@"publicGist"])
		return [PBGitDefaults isGistPublic];
	else
		return YES;
}

- (void) preferencesChanged
{
}

- (void)preferencesChangedWithNotification:(NSNotification *)theNotification
{
	[self preferencesChanged];
}

@end
