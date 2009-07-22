//
//  PBGitRepositoryWatcher.m
//  GitX
//
//  Created by Dave Grijalva on 1/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//
#import <CoreServices/CoreServices.h>
#import "PBGitRepositoryWatcher.h"
#import "PBEasyPipe.h"

NSString *PBGitRepositoryEventNotification = @"PBGitRepositoryModifiedNotification";
NSString *kPBGitRepositoryEventTypeUserInfoKey = @"kPBGitRepositoryEventTypeUserInfoKey";
NSString *kPBGitRepositoryEventPathsUserInfoKey = @"kPBGitRepositoryEventPathsUserInfoKey";

@interface PBGitRepositoryWatcher (internal_callback)
- (void) _handleEventCallback:(NSArray *)eventPaths;
@end

@interface PBGitRepositoryWatcherEventPath : NSObject
{
	NSString *path;
	FSEventStreamEventFlags flag;
}
@property (retain) NSString *path;
@property (assign) FSEventStreamEventFlags flag;
@end

@implementation PBGitRepositoryWatcherEventPath
@synthesize path, flag;
@end


static void PBGitRepositoryWatcherCallback(ConstFSEventStreamRef streamRef, void *clientCallBackInfo, 
										size_t numEvents, void *eventPaths, 
										const FSEventStreamEventFlags eventFlags[], const FSEventStreamEventId eventIds[]){
    PBGitRepositoryWatcher *watcher = clientCallBackInfo;
	int i;
    char **paths = eventPaths;
	NSMutableArray *changePaths = [[NSMutableArray alloc] init];
	for(i = 0; i < numEvents; ++i){
//		NSLog(@"FSEvent Watcher: %@ Change %llu in %s, flags %lu", watcher, eventIds[i], paths[i], eventFlags[i]);

		PBGitRepositoryWatcherEventPath *ep = [[PBGitRepositoryWatcherEventPath alloc] init];
		ep.path = [NSString stringWithFormat:@"%s", paths[i]];
		ep.flag = eventFlags[i];
		[changePaths addObject:ep];
		[ep release];
		
	}
    [watcher _handleEventCallback:changePaths];
	[changePaths release];
}

@implementation PBGitRepositoryWatcher

@synthesize repository;

- (id) initWithRepository:(PBGitRepository *)theRepository {
    if(self = [super init]){
        repository = [theRepository retain];

        FSEventStreamContext context = {0, self, NULL, NULL, NULL};
        
		NSString *path = [repository isBareRepository] ? repository.gitDir.path : [repository workingDirectory];
		
        // Create and activate event stream
        eventStream = FSEventStreamCreate(kCFAllocatorDefault, &PBGitRepositoryWatcherCallback, &context, 
										  CFArrayCreate(NULL, (const void **)&path, 1, NULL), 
										  kFSEventStreamEventIdSinceNow, 1.0, kFSEventStreamCreateFlagNone);
        [self start];
    }
    return self;
}

- (BOOL) _indexChanged {
	NSString *newDigest = [PBEasyPipe outputForCommand:@"/sbin/md5" withArgs:[NSArray arrayWithObject:[repository.gitDir.path stringByAppendingPathComponent:@"index"]]];
	if(![newDigest isEqual:indexDigest]){
		indexDigest = newDigest;
		return YES;
	}
	else{
		return NO;
	}
}

- (BOOL) _gitDirectoryChanged {
	NSMutableArray *paths = [[NSMutableArray alloc] init];
	BOOL isDirectory;
	for(NSString *filename in [[NSFileManager defaultManager] directoryContentsAtPath:repository.gitDir.path]){
		NSString *filepath = [repository.gitDir.path stringByAppendingPathComponent:filename];
		[[NSFileManager defaultManager] fileExistsAtPath:filepath isDirectory:&isDirectory];
		if(!isDirectory){
			[paths addObject:filepath];
		}
	}
	NSString *newDigest = [PBEasyPipe outputForCommand:@"/sbin/md5" withArgs:paths];
	if(![newDigest isEqual:gitDirDigest]){
		gitDirDigest = newDigest;
		return YES;
	}
	else{
		return NO;
	}
}

- (void) _handleEventCallback:(NSArray *)eventPaths {
	PBGitRepositoryWatcherEventType event = 0x0;

	if([self _indexChanged]){
		event = event | PBGitRepositoryWatcherEventTypeIndex;
	}
	
    NSMutableArray *paths = [NSMutableArray array];
    
	for(PBGitRepositoryWatcherEventPath *eventPath in eventPaths){
		// .git dir
		if([[eventPath.path stringByStandardizingPath] isEqual:[repository.gitDir.path stringByStandardizingPath]]){
			if([self _gitDirectoryChanged] || eventPath.flag != kFSEventStreamEventFlagNone){
				event = event | PBGitRepositoryWatcherEventTypeGitDirectory;
                [paths addObject:eventPath.path];
			}
		}
		// subdirs of .git dir
		else if([eventPath.path rangeOfString:repository.gitDir.path].location != NSNotFound){
			event = event | PBGitRepositoryWatcherEventTypeGitDirectory;
            [paths addObject:eventPath.path];
		}
		// working dir
		else if([[eventPath.path stringByStandardizingPath] isEqual:[[repository workingDirectory] stringByStandardizingPath]]){
			if(eventPath.flag != kFSEventStreamEventFlagNone){
				event = event | PBGitRepositoryWatcherEventTypeGitDirectory;
			}
			event = event | PBGitRepositoryWatcherEventTypeWorkingDirectory;
            [paths addObject:eventPath.path];
		}
		// subdirs of working dir
		else {
			event = event | PBGitRepositoryWatcherEventTypeWorkingDirectory;
            [paths addObject:eventPath.path];
		}
	}
	
	if(event != 0x0){
//		NSLog(@"PBGitRepositoryWatcher firing notification for repository %@ with flag %lu", repository, event);
        NSDictionary *eventInfo = [NSDictionary dictionaryWithObjectsAndKeys: 
                                   [NSNumber numberWithUnsignedInt:event], kPBGitRepositoryEventTypeUserInfoKey,
                                   paths, kPBGitRepositoryEventPathsUserInfoKey,
                                   NULL];
        
		[[NSNotificationCenter defaultCenter] postNotificationName:PBGitRepositoryEventNotification object:self userInfo:eventInfo];
	}
}

- (void) start {
    if(!_running){
		// set initial state
		[self _gitDirectoryChanged];
		[self _indexChanged];
        FSEventStreamScheduleWithRunLoop(eventStream, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
        FSEventStreamStart(eventStream);
        _running = YES;
    }
}

- (void) stop {
    if(_running){
        FSEventStreamStop(eventStream);
		FSEventStreamUnscheduleFromRunLoop(eventStream, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
        _running = NO;
    }
}

- (void) finalize {
    // cleanup 
    [self stop];
    FSEventStreamInvalidate(eventStream);
    FSEventStreamRelease(eventStream);
	
	[super finalize];
}

- (void) dealloc {
	[self finalize];
	
    [repository release];
    [super dealloc];
}

@end
