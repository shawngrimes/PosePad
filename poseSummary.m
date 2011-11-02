//
//  poseSummary.m
//  PosePad
//
//  Created by Colin Francis on 8/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "poseSummary.h"
#import "poseBooks.h"


@implementation poseSummary
@dynamic checked;
@dynamic lightingDiagram;
@dynamic thumbnail;
@dynamic notes;
@dynamic sortIndex;
@dynamic title;
@dynamic imagePath;
@dynamic books;

-(void) prepareForDeletion{
	NSLog(@"Preparing to delete: %@", self.imagePath);
	NSError *error;
	//NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	//NSString *documentsDirectory = [paths objectAtIndex:0];
	
	//NSString *imgPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.jpg", self.title]];
	if([[NSFileManager defaultManager] fileExistsAtPath:self.imagePath]){
		if(![[NSFileManager defaultManager] removeItemAtPath:self.imagePath error:&error]) NSLog(@"Error deleting old file: %@ (%@)",self.imagePath,[error localizedDescription]);
	}
	
	
}
- (void)addBooksObject:(poseBooks *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"books" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"books"] addObject:value];
    [self didChangeValueForKey:@"books" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
}

- (void)removeBooksObject:(poseBooks *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"books" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"books"] removeObject:value];
    [self didChangeValueForKey:@"books" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
}

- (void)addBooks:(NSSet *)value {    
    [self willChangeValueForKey:@"books" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"books"] unionSet:value];
    [self didChangeValueForKey:@"books" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeBooks:(NSSet *)value {
    [self willChangeValueForKey:@"books" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"books"] minusSet:value];
    [self didChangeValueForKey:@"books" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}


@end
