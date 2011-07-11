// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to poseSummary.m instead.

#import "_poseSummary.h"

@implementation poseSummaryID
@end

@implementation _poseSummary

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"poseSummary" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"poseSummary";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"poseSummary" inManagedObjectContext:moc_];
}

- (poseSummaryID*)objectID {
	return (poseSummaryID*)[super objectID];
}




@dynamic title;






@dynamic sortIndex;



- (int)sortIndexValue {
	NSNumber *result = [self sortIndex];
	return [result intValue];
}

- (void)setSortIndexValue:(int)value_ {
	[self setSortIndex:[NSNumber numberWithInt:value_]];
}

- (int)primitiveSortIndexValue {
	NSNumber *result = [self primitiveSortIndex];
	return [result intValue];
}

- (void)setPrimitiveSortIndexValue:(int)value_ {
	[self setPrimitiveSortIndex:[NSNumber numberWithInt:value_]];
}





@dynamic notes;






@dynamic imagePath;






@dynamic thumbnail;






@dynamic lightingDiagram;






@dynamic books;

	
- (NSMutableSet*)booksSet {
	[self willAccessValueForKey:@"books"];
	NSMutableSet *result = [self mutableSetValueForKey:@"books"];
	[self didAccessValueForKey:@"books"];
	return result;
}
	



@end
