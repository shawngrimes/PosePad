// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to EquipmentClass.m instead.

#import "_EquipmentClass.h"

@implementation EquipmentClassID
@end

@implementation _EquipmentClass

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Equipment" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Equipment";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Equipment" inManagedObjectContext:moc_];
}

- (EquipmentClassID*)objectID {
	return (EquipmentClassID*)[super objectID];
}




@dynamic name;






@dynamic book;

	
- (NSMutableSet*)bookSet {
	[self willAccessValueForKey:@"book"];
	NSMutableSet *result = [self mutableSetValueForKey:@"book"];
	[self didAccessValueForKey:@"book"];
	return result;
}
	



@end
