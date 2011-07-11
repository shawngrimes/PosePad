// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to poseBooks.h instead.

#import <CoreData/CoreData.h>


@class poseSummary;
@class EquipmentClass;




@interface poseBooksID : NSManagedObjectID {}
@end

@interface _poseBooks : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (poseBooksID*)objectID;



@property (nonatomic, retain) NSString *notes;

//- (BOOL)validateNotes:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *name;

//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSSet* pose;
- (NSMutableSet*)poseSet;



@property (nonatomic, retain) NSSet* equipment;
- (NSMutableSet*)equipmentSet;



@end

@interface _poseBooks (CoreDataGeneratedAccessors)

- (void)addPose:(NSSet*)value_;
- (void)removePose:(NSSet*)value_;
- (void)addPoseObject:(poseSummary*)value_;
- (void)removePoseObject:(poseSummary*)value_;

- (void)addEquipment:(NSSet*)value_;
- (void)removeEquipment:(NSSet*)value_;
- (void)addEquipmentObject:(EquipmentClass*)value_;
- (void)removeEquipmentObject:(EquipmentClass*)value_;

@end

@interface _poseBooks (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveNotes;
- (void)setPrimitiveNotes:(NSString*)value;


- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSMutableSet*)primitivePose;
- (void)setPrimitivePose:(NSMutableSet*)value;



- (NSMutableSet*)primitiveEquipment;
- (void)setPrimitiveEquipment:(NSMutableSet*)value;


@end
