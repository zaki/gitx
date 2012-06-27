//
//  PBGitRepository.h
//  GitTest
//
//  Created by Pieter de Bie on 13-06-08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PBGitHistoryList.h"
#import "PBGitRevSpecifier.h"
#import "PBGitConfig.h"
#import "PBGitRefish.h"

extern NSString* PBGitRepositoryErrorDomain;
typedef enum branchFilterTypes {
	kGitXAllBranchesFilter = 0,
	kGitXLocalRemoteBranchesFilter,
	kGitXSelectedBranchFilter
} PBGitXBranchFilterType;

static NSString * PBStringFromBranchFilterType(PBGitXBranchFilterType type) {
    switch (type) {
        case kGitXAllBranchesFilter:
            return @"All";
            break;
        case kGitXLocalRemoteBranchesFilter:
            return @"Local";
            break;
        case kGitXSelectedBranchFilter:
            return @"Selected";
            break;
        default:
            break;
    }
    return @"Not a branch filter type";
}

@class PBGitWindowController;
@class PBGitCommit;
@class PBGitResetController;
@class PBStashController;
@class PBSubmoduleController;

dispatch_queue_t PBGetWorkQueue();

@interface PBGitRepository : NSDocument {
	PBGitHistoryList* revisionList;
	PBGitConfig *config;

	BOOL hasChanged;
	NSInteger currentBranchFilter;
	NSMutableDictionary *refs;

	PBGitRevSpecifier *_headRef; // Caching
	NSString* _headSha;
	
	PBStashController *stashController;
	PBSubmoduleController *submoduleController;
	PBGitResetController *resetController;

	BOOL didCheckBareRepository;
	BOOL bareRepository;
	NSString* workingDirectory;
}

@property (nonatomic, strong, readonly) PBStashController *stashController;
@property (nonatomic, strong, readonly) PBSubmoduleController *submoduleController;
@property (nonatomic, strong, readonly) PBGitResetController *resetController;

- (void) cloneRepositoryToPath:(NSString *)path bare:(BOOL)isBare;
- (void) beginAddRemote:(NSString *)remoteName forURL:(NSString *)remoteURL;
- (void) beginFetchFromRemoteForRef:(PBGitRef *)ref;
- (void) beginPullFromRemote:(PBGitRef *)remoteRef forRef:(PBGitRef *)ref;
- (void) beginPushRef:(PBGitRef *)ref toRemote:(PBGitRef *)remoteRef;
- (BOOL) checkoutRefish:(id <PBGitRefish>)ref;
- (BOOL) checkoutFiles:(NSArray *)files fromRefish:(id <PBGitRefish>)ref;
- (BOOL) mergeWithRefish:(id <PBGitRefish>)ref;
- (BOOL) cherryPickRefish:(id <PBGitRefish>)ref;
- (BOOL) rebaseBranch:(id <PBGitRefish>)branch onRefish:(id <PBGitRefish>)upstream;
- (BOOL) renameRef:(PBGitRef*)ref withNewName:(NSString *)newName;
- (BOOL) createBranch:(NSString *)branchName atRefish:(id <PBGitRefish>)ref;
- (BOOL) createTag:(NSString *)tagName message:(NSString *)message atRefish:(id <PBGitRefish>)commitSHA force:(BOOL)force;
- (BOOL) deleteRemote:(PBGitRef *)ref;
- (BOOL) isRemoteConnected:(NSString*)remoteName;
- (BOOL) deleteRemoteBranch:(PBGitRef *)ref;
- (BOOL) deleteRemoteTag:(PBGitRef *)ref;
- (BOOL) deleteRef:(PBGitRef *)ref;
- (NSString*) containingBranchesOnRefish:(id <PBGitRefish>)ref;

- (BOOL) hasSvnRemote;
- (NSArray*) svnRemotes;
- (BOOL) svnFetch:(NSString*)remoteName;
- (BOOL) svnRebase:(NSString*)remoteName;
- (BOOL) svnDcommit:(NSString*)commitURL;

- (NSFileHandle*) handleForCommand:(NSString*) cmd;
- (NSFileHandle*) handleForArguments:(NSArray*) args;
- (NSFileHandle*) handleInWorkDirForArguments:(NSArray *)args;
- (NSFileHandle *) handleInWorkDirForArguments:(NSArray *)args;
- (NSString*) outputForCommand:(NSString*) cmd;
- (NSString *)outputForCommand:(NSString *)str retValue:(int *)ret;
- (NSString *)outputForArguments:(NSArray *)arguments inputString:(NSString *)input retValue:(int *)ret;
- (NSString *)outputForArguments:(NSArray *)arguments inputString:(NSString *)input byExtendingEnvironment:(NSDictionary *)dict retValue:(int *)ret;


- (NSString*) outputForArguments:(NSArray*) args;
- (NSString*) outputForArguments:(NSArray*) args retValue:(int *)ret;
- (NSString *)outputInWorkdirForArguments:(NSArray*) arguments;
- (NSString *)outputInWorkdirForArguments:(NSArray*) arguments retValue:(int *)ret;
- (BOOL)executeHook:(NSString *)name output:(NSString **)output;
- (BOOL)executeHook:(NSString *)name withArgs:(NSArray*) arguments output:(NSString **)output;

- (NSString *)workingDirectory;
- (NSString *) projectName;
- (NSString *)gitIgnoreFilename;
- (BOOL)isBareRepository;

- (void) reloadRefs;
- (void) addRef:(PBGitRef *)ref fromParameters:(NSArray *)params;
- (void) lazyReload;
- (PBGitRevSpecifier*)headRef;
- (NSString *)headSHA;
- (PBGitCommit *)headCommit;
- (NSString *)shaForRef:(PBGitRef *)ref;
- (PBGitCommit *)commitForRef:(PBGitRef *)ref;
- (PBGitCommit *)commitForSHA:(NSString *)sha;
- (BOOL)isOnSameBranch:(NSString *)baseSHA asSHA:(NSString *)testSHA;
- (BOOL)isSHAOnHeadBranch:(NSString *)testSHA;
- (BOOL)isRefOnHeadBranch:(PBGitRef *)testRef;
- (BOOL)checkRefFormat:(NSString *)refName;
- (BOOL)refExists:(PBGitRef *)ref checkOnRemotesWithoutBranches:(BOOL)remoteCheck resultMessage:(NSString**)result;
- (BOOL)refExistsOnRemote:(PBGitRef*)ref remoteName:(NSString*)remote resultMessage:(NSString**)result;
- (BOOL)refExistsOnAnyRemote:(PBGitRef*)ref resultMessage:(NSString**)result;
- (BOOL)tagExistsOnRemote:(PBGitRef *)ref remoteName:(NSString *)remote;
- (PBGitRef *)refForName:(NSString *)name;

- (NSArray *) remotes;
- (BOOL) hasRemotes;
- (PBGitRef *) remoteRefForBranch:(PBGitRef *)branch error:(NSError **)error;
- (NSString *) infoForRemote:(NSString *)remoteName;
- (NSArray*) URLsForRemote:(NSString*)remoteName;

- (void) readCurrentBranch;
- (PBGitRevSpecifier*) addBranch: (PBGitRevSpecifier*) rev;
- (BOOL)removeBranch:(PBGitRevSpecifier *)rev;

- (NSString*) parseSymbolicReference:(NSString*) ref;
- (NSString*) parseReference:(NSString*) ref;

+ (NSURL*)gitDirForURL:(NSURL*)repositoryURL;
+ (NSURL*)baseDirForURL:(NSURL*)repositoryURL;

- (id) initWithURL: (NSURL*) path;
- (void) setup;
- (void) forceUpdateRevisions;

// for the scripting bridge
- (void)findInModeScriptCommand:(NSScriptCommand *)command;

- (NSMenu *) menu;
+(bool)isLocalBranch:(NSString *)branch branchNameInto:(NSString **)name;

- (NSString*) remoteUrl:(NSString*)remoteName;
- (void) changeRemote:(PBGitRef *)ref toURL:(NSURL*)newUrl;


@property (assign) BOOL hasChanged;
@property (readonly) PBGitWindowController *windowController;
@property (readonly) PBGitConfig *config;
@property (strong) PBGitHistoryList *revisionList;
@property (strong) NSMutableArray* branches;
@property (strong) PBGitRevSpecifier *currentBranch;
@property (assign) NSInteger currentBranchFilter;
@property (strong) NSMutableDictionary* refs;
@end
