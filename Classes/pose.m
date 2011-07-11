//
//  pose.m
//  PoseBook
//
//  Created by shawn on 3/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "pose.h"


@implementation pose

@synthesize poseTitle, poseImageName, poseNotes, poseImageData, stateChanged;

-(id) initWithDictionary:(NSDictionary *) objectValues{
	if(self = [super init]){
		self.poseTitle = [objectValues objectForKey:@"poseTitle"];
		self.poseNotes = [objectValues objectForKey:@"poseNotes"];
		self.poseImageName = [objectValues objectForKey:@"poseImageName"];
		self.poseImageData = [objectValues objectForKey:@"poseImageData"];
		self.stateChanged = NO;
	}
	return self;
}

-(id) initWithDefaultValues{
	if(self=[super init]){
		self.poseTitle=@"New Pose Title";
		self.poseNotes=@"This is a pose note";
		
//		NSString  *path = [[NSBundle mainBundle] pathForResource: @"Stephanie"  ofType: @"png"];
		//UIImage *tempImage = [[UIImage alloc] initWithContentsOfFile: path];
		self.poseImageName=[[NSBundle mainBundle] pathForResource: @"NewPose"  ofType: @"png"];
		self.poseImageData= UIImagePNGRepresentation([[UIImage alloc] initWithContentsOfFile:self.poseImageName]);
		//[path release];
		self.stateChanged=YES;
	}
	return self;
	
}


-(id) initWithTitle:(NSString *)newTitle{
	if (self=[super init]){
		poseTitle=newTitle;
	}
	return self;
}

/*-(id)initWithTitle:(NSString *)newTitle andImageName:(NSString *)newImageName andPoseNotes:(NSString *)newPoseNotes{
	if (self=[super init]){
		poseTitle=newTitle;
		NSLog(@"ImageNamTeste: %@", newImageName);
		[poseImage imageWithContentsOfFile:newImageName];
		poseNotes=newPoseNotes;
	}
	return self;
}
 */

-(NSMutableDictionary *) objectValues{
	NSMutableDictionary *md = [[NSMutableDictionary alloc] init];
	[md setObject:self.poseTitle forKey:@"poseTitle"];
	[md setObject:self.poseNotes forKey:@"poseNotes"];
	[md setObject:self.poseImageName forKey:@"poseImageName"];
	[md setObject:self.poseImageData forKey:@"poseImageData"];

	[md autorelease];
	
	return md;
	
}

-(void) dealloc {
	[poseTitle release];
	[poseImageName release];
	[poseNotes release];
	[poseImageData release];
	[super dealloc];
}
@end
