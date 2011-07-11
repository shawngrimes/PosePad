//
//  PoseBookAppDelegate.h
//  PoseBook
//
//  Created by shawn on 3/25/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <StoreKit/StoreKit.h>
#import "poseList.h"
#import "poseBooks.h"


@interface PoseBookAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	poseList *totalPoseList;
	NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectContext *managedObjectContext;
	NSManagedObjectModel *managedObjectModel;
}


@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) poseList *totalPoseList;

@property (nonatomic, readonly) NSString *applicationDocumentsDirectory;

//- (void) initCoreData;
- (void) convertArraytoDatabase;
-(void) findOrphans;
-(void) renameOldVersions;



@end

