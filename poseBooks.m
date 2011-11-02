//
//  poseBooks.m
//  PosePad
//
//  Created by Colin Francis on 8/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "poseBooks.h"
#import "EquipmentClass.h"
#import "poseSummary.h"


@implementation poseBooks
@dynamic notes;
@dynamic name;
@dynamic alphaSorted;
@dynamic pose;
@dynamic equipment;

- (void)addPoseObject:(poseSummary *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"pose" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"pose"] addObject:value];
    [self didChangeValueForKey:@"pose" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
}

- (void)removePoseObject:(poseSummary *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"pose" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"pose"] removeObject:value];
    [self didChangeValueForKey:@"pose" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
}

- (void)addPose:(NSSet *)value {    
    [self willChangeValueForKey:@"pose" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"pose"] unionSet:value];
    [self didChangeValueForKey:@"pose" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removePose:(NSSet *)value {
    [self willChangeValueForKey:@"pose" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"pose"] minusSet:value];
    [self didChangeValueForKey:@"pose" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}


- (void)addEquipmentObject:(EquipmentClass *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"equipment" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"equipment"] addObject:value];
    [self didChangeValueForKey:@"equipment" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
}

- (void)removeEquipmentObject:(EquipmentClass *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"equipment" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"equipment"] removeObject:value];
    [self didChangeValueForKey:@"equipment" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
}

- (void)addEquipment:(NSSet *)value {    
    [self willChangeValueForKey:@"equipment" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"equipment"] unionSet:value];
    [self didChangeValueForKey:@"equipment" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeEquipment:(NSSet *)value {
    [self willChangeValueForKey:@"equipment" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"equipment"] minusSet:value];
    [self didChangeValueForKey:@"equipment" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}


@end
