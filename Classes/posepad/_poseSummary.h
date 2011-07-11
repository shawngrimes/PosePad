// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to poseSummary.h instead.

#import <CoreData/CoreData.h>


@class poseBooks;








@interface poseSummaryID : NSManagedObjectID {}
@end

@interface _poseSummary : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (poseSummaryID*)objectID;



@property (nonatomic, retain) NSString *title;

//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *sortIndex;

@property int sortIndexValue;
- (int)sortIndexValue;
- (void)setSortIndexValue:(int)value_;

//- (BOOL)validateSortIndex:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *notes;

//- (BOOL)validateNotes:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *imagePath;

//- (BOOL)validateImagePath:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSData *thumbnail;

//- (BOOL)validateThumbnail:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSData *lightingDiagram;

//- (BOOL)validateLightingDiagram:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSSet* books;
- (NSMutableSet*)booksSet;



@end

@interface _poseSummary (CoreDataGeneratedAccessors)

- (void)addBooks:(NSSet*)value_;
- (void)removeBooks:(NSSet*)value_;
- (void)addBooksObject:(poseBooks*)value_;
- (void)removeBooksObject:(poseBooks*)value_;

@end

@interface _poseSummary (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;


- (NSNumber*)primitiveSortIndex;
- (void)setPrimitiveSortIndex:(NSNumber*)value;

- (int)primitiveSortIndexValue;
- (void)setPrimitiveSortIndexValue:(int)value_;


- (NSString*)primitiveNotes;
- (void)setPrimitiveNotes:(NSString*)value;


- (NSString*)primitiveImagePath;
- (void)setPrimitiveImagePath:(NSString*)value;


- (NSData*)primitiveThumbnail;
- (void)setPrimitiveThumbnail:(NSData*)value;


- (NSData*)primitiveLightingDiagram;
- (void)setPrimitiveLightingDiagram:(NSData*)value;




- (NSMutableSet*)primitiveBooks;
- (void)setPrimitiveBooks:(NSMutableSet*)value;


@end
