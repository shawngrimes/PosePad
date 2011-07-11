//
//  poseList.m
//  PoseBook
//
//  Created by shawn on 3/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "poseList.h"
#import "pose.h"

@implementation poseList

@synthesize poses;

-(id) initWithSaveFile{
	if (self = [super init]){
		NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [paths objectAtIndex:0]; NSString *saveFileName = [NSString stringWithFormat:@"%@/poseListSaveFile", documentsDirectory];
		NSFileManager *fm = [NSFileManager defaultManager]; 
		BOOL saveFileAlreadyExists = [fm fileExistsAtPath:saveFileName];
		
		NSMutableArray *savedData; 
		if(saveFileAlreadyExists)
			savedData = [[NSMutableArray alloc] initWithContentsOfFile:saveFileName];
		else
			savedData = [[NSMutableArray alloc] init];
	
		self.poses = [[NSMutableArray alloc] init];
		for(NSDictionary *d in savedData){ 
			pose *savedPose = [[pose alloc] initWithDictionary:d]; 
			[self.poses addObject:savedPose];
			[savedPose release];
		}
		[savedData release];
		
	}
	return self;
}

-(void) dealloc {
	[poses release];
	[super dealloc];
}

-(void) saveToFileSystem{
	NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0]; 
	NSString *saveFileName =[NSString stringWithFormat:@"%@/poseListSaveFile", documentsDirectory];
	
	NSMutableArray *savedData = [[NSMutableArray alloc] init]; 
	for(pose *savedPose in self.poses)
		[savedData addObject:[savedPose objectValues]];
	
	[savedData writeToFile:saveFileName atomically:NO]; 
	[savedData release];

}



@end
