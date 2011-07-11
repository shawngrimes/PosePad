// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to EquipmentClass.h instead.

#import <CoreData/CoreData.h>


@class poseBooks;



@interface EquipmentClassID : NSManagedObjectID {}
@end

@interface _EquipmentClass : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (EquipmentClassID*)objectID;



@property (nonatomic, retain) NSString *name;

//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSSet* book;
- (NSMutableSet*)bookSet;



@end

@interface _EquipmentClass (CoreDataGeneratedAccessors)

- (void)addBook:(NSSet*)value_;
- (void)removeBook:(NSSet*)value_;
- (void)addBookObject:(poseBooks*)value_;
- (void)removeBookObject:(poseBooks*)value_;

@end

@interface _EquipmentClass (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSMutableSet*)primitiveBook;
- (void)setPrimitiveBook:(NSMutableSet*)value;


@end
