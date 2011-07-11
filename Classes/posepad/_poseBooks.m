// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to poseBooks.m instead.

#import "_poseBooks.h"

@implementation poseBooksID
@end

@implementation _poseBooks

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"poseBooks" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"poseBooks";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"poseBooks" inManagedObjectContext:moc_];
}

- (poseBooksID*)objectID {
	return (poseBooksID*)[super objectID];
}




@dynamic notes;






@dynamic name;






@dynamic pose;

	
- (NSMutableSet*)poseSet {
	[self willAccessValueForKey:@"pose"];
	NSMutableSet *result = [self mutableSetValueForKey:@"pose"];
	[self didAccessValueForKey:@"pose"];
	return result;
}
	

@dynamic equipment;

	
- (NSMutableSet*)equipmentSet {
	[self willAccessValueForKey:@"equipment"];
	NSMutableSet *result = [self mutableSetValueForKey:@"equipment"];
	[self didAccessValueForKey:@"equipment"];
	return result;
}
	



@end
