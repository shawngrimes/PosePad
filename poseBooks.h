//
//  poseBooks.h
//  PosePad
//
//  Created by Colin Francis on 8/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class EquipmentClass, poseSummary;

@interface poseBooks : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * alphaSorted;
@property (nonatomic, retain) NSSet* pose;
@property (nonatomic, retain) NSSet* equipment;
- (void)addEquipmentObject:(EquipmentClass *)value;
- (void)removeEquipmentObject:(EquipmentClass *)value;
@end
