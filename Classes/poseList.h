//
//  poseList.h
//  PoseBook
//
//  Created by shawn on 3/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface poseList : NSObject {
	NSMutableArray *poses;

}

@property (nonatomic, retain) NSMutableArray *poses;

-(id) initWithSaveFile;

-(void) saveToFileSystem;

@end
