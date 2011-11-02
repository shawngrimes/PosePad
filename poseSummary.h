//
//  poseSummary.h
//  PosePad
//
//  Created by Colin Francis on 8/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class poseBooks;

@interface poseSummary : NSManagedObject {
@private
}
@property (nonatomic, retain) NSNumber * checked;
@property (nonatomic, retain) NSData * lightingDiagram;
@property (nonatomic, retain) NSData * thumbnail;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSNumber * sortIndex;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * imagePath;
@property (nonatomic, retain) NSSet* books;
- (void)addBooks:(NSSet *)value;
@end
