//
//  UnitTests.m
//  UnitTests
//
//  Created by German Laullon on 09/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UnitTests.h"
#import "PBEasyPipe.h"
#import "PBGitBinary.h"

@implementation UnitTests

- (void)setUp
{
    [super setUp];
    
    path=[NSString stringWithFormat:@"%@testrepo",NSTemporaryDirectory()];
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    [defaultManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    
    int terminationStatus;
	NSString *result = [PBEasyPipe outputForCommand:[PBGitBinary path] 
                                           withArgs:[NSArray arrayWithObjects:@"init", @"-q", nil] 
                                              inDir:path 
                                           retValue:&terminationStatus];
    
	if (terminationStatus != 0){
        STFail([NSString stringWithFormat:@"error on repo init '%@'",result]);
    }
    
    NSLog(@"setUp ok");
}

- (void)tearDown
{
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    [defaultManager removeItemAtPath:path error:nil];
    
    [super tearDown];
}

- (void)testEntyRepo
{
}

@end
