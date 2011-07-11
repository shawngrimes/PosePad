//
//  poseSummary.h
//  PosePad
//
//  Created by shawn on 4/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class poseBooks;

@interface poseSummary :  NSManagedObject  
{
}

@property (nonatomic, retain) NSData * thumbnail;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSString * imagePath;
@property (nonatomic, retain) NSNumber * sortIndex;
@property (nonatomic, retain) NSSet* books;

@end


@interface poseSummary (CoreDataGeneratedAccessors)
- (void)addBooksObject:(poseBooks *)value;
- (void)removeBooksObject:(poseBooks *)value;
- (void)addBooks:(NSSet *)value;
- (void)removeBooks:(NSSet *)value;

@end

