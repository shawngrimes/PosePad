//
//  pose.h
//  PoseBook
//
//  Created by shawn on 3/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface pose : NSObject {
	NSString *poseTitle;
	NSString *poseImageName;
	NSString *poseNotes;
	NSData *poseImageData;
	BOOL stateChanged;
}



-(NSMutableDictionary *) objectValues;

-(id)initWithDefaultValues;

-(id)initWithDictionary:(NSDictionary *) objectValues;

@property (nonatomic,retain) NSString *poseTitle;
@property (nonatomic,retain) NSString *poseImageName;
@property (nonatomic,retain) NSData *poseImageData;
@property (nonatomic,retain) NSString *poseNotes;
@property (nonatomic,assign) BOOL stateChanged;



@end
