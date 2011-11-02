//
//  PoseBookAppDelegate.m
//  PoseBook
//
//  Created by shawn on 3/25/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "PoseBookAppDelegate.h"
//#import "mainTableViewController.h"
#import "poseThumbnailViewController.h"
#import "poseBookThumbnailViewController.h"
#import "PoseBookDownloadProgressView.h"
#import "poseList.h"
#import "pose.h"
#import "poseSummary.h"
#import "poseBooks.h"
#import "InAppPurchaseManager.h"
#import "UIImage+Resize.h"
//#import "JSON.h"
#import "SBJson.h"
#import <SystemConfiguration/SCNetworkReachability.h>
#include <netinet/in.h>



@implementation PoseBookAppDelegate

@synthesize window, totalPoseList;
@synthesize managedObjectContext;


InAppPurchaseManager *observer;

UINavigationController *navigationController;

NSArray *storeTransactions;


- (void) applicationDidFinishLaunching:(UIApplication *)application{
	
	self.totalPoseList = [[poseList alloc] initWithSaveFile];
    [self.window setBackgroundColor:[UIColor blackColor]];
	NSManagedObjectContext *context = [self managedObjectContext];
	if (!context) {
		NSLog(@"No managed object context in appdidfinishlaunching");
		// Handle the error.
	}

	/*
	if([totalPoseList.poses count] > 0){
		NSLog(@"Converting Array to Database");
		[self convertArraytoDatabase];
	}
	 */
	//		NSLog(@"Finding Orphans");
	//[self findOrphans];
			NSLog(@"Renaming image files");
	[self renameOldVersions];

	/*poseThumbnailViewController *thumbnailVC = [[poseThumbnailViewController alloc] initWithNibName:nil bundle:nil];
	thumbnailVC.managedObjectContext = context;

	NSUserDefaults *prefs= [NSUserDefaults standardUserDefaults];
	thumbnailVC.lastBookName = [prefs objectForKey:@"lastBookName"];
	
    NSLog(@"poseBookAppDelegate:(applicationDidFinishLaunching) Last used book was: %@", thumbnailVC.lastBookName);*/
	
	InAppPurchaseManager *observer=[[InAppPurchaseManager alloc] init];
	observer.managedObjectContext = context;
	observer.window=window;
	[[SKPaymentQueue defaultQueue] addTransactionObserver:observer];

	
	navigationController = [[UINavigationController alloc] init];
    navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
//Uncomment this when done testing store kit	
    poseBookThumbnailViewController *pbtvc = [[poseBookThumbnailViewController alloc] initWithManagedObjectContext:self.managedObjectContext];
	[navigationController pushViewController:pbtvc animated:NO];	
	
//Comment this when done testing storekit
//	posestoreMainTableViewController *posestoreVC = [[posestoreMainTableViewController alloc] initWithNibName:nil bundle:nil];
//	[navigationController pushViewController:posestoreVC animated:YES];	
//	[posestoreVC release];
	
	
	
	//[thumbnailVC release];
	
	
	[window addSubview:navigationController.view];
	
	[window makeKeyAndVisible];
	
	
}

/*-(void) findOrphans{
	NSFetchRequest *poserequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *poseentity = [NSEntityDescription entityForName:@"poseSummary" inManagedObjectContext:self.managedObjectContext];
	NSPredicate *posepredicate = [NSPredicate predicateWithFormat:@"ANY books == NULL"];
	[poserequest setPredicate:posepredicate];
	[poserequest setEntity:poseentity];
	
	NSSortDescriptor *posesortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sortIndex" ascending:YES];
	NSArray *posesortDescriptors = [[NSArray alloc] initWithObjects:posesortDescriptor, nil];
	[poserequest setSortDescriptors:posesortDescriptors];

	
	
	NSFetchedResultsController *poseFRC = [[NSFetchedResultsController alloc] initWithFetchRequest:poserequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
	NSError *error;
	if (![poseFRC performFetch:&error]) NSLog(@"Error Fetching: %@", [error localizedDescription]);		
	
	
	NSLog(@"Found %i poses that were not assigned to a book", [[poseFRC fetchedObjects] count]);
	
	if([[poseFRC fetchedObjects] count]>0){
		poseBooks *defaultBook;
		
		NSFetchRequest *request = [[NSFetchRequest alloc] init];
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"poseBooks" inManagedObjectContext:self.managedObjectContext];
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == 'Orphan Poses'"];
		[request setPredicate:predicate];
		[request setEntity:entity];
		
		NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
		NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
		[request setSortDescriptors:sortDescriptors];
		[sortDescriptors release];
		[sortDescriptor release];

		
		
		NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
		[request release];
		if (![fetchedResultsController performFetch:&error]) NSLog(@"Error Fetching: %@", [error localizedDescription]);
		
		//NSLog(@"Found (%i) default books",[[fetchedResultsController fetchedObjects] count]);
		if([[fetchedResultsController fetchedObjects] count]){
			NSLog(@"Found Orphan Poses book");
			defaultBook = [[fetchedResultsController fetchedObjects] objectAtIndex:0];
		}else{
			NSLog(@"Did not find Orphan Poses book, creating one");
			defaultBook = (poseBooks *)[NSEntityDescription insertNewObjectForEntityForName:@"poseBooks" inManagedObjectContext:managedObjectContext];
			defaultBook.name = @"Orphan Poses";
		}
	
		for (poseSummary *orphanPose in [poseFRC fetchedObjects]) {
			
			//Create new icon
			UIImage *tempImage = [[UIImage alloc] initWithContentsOfFile:orphanPose.imagePath];
			CGSize iconSize;
			iconSize.width=200;
			iconSize.height=200;
			UIGraphicsBeginImageContext(iconSize); 
			[tempImage drawInRect:CGRectMake(0, 0, iconSize.width, iconSize.height)]; 
			UIImage *iconImg = UIGraphicsGetImageFromCurrentImageContext (); 
			UIGraphicsEndImageContext();
			orphanPose.thumbnail=UIImageJPEGRepresentation(iconImg, .7);
			[tempImage release];
			
			//Add to default book
			[orphanPose addBooksObject:defaultBook];
			if (![self.managedObjectContext save:&error]) NSLog(@"Error: %@", [error localizedDescription]);
			NSLog(@"Pose (%@) in Book(%@)", orphanPose.title, defaultBook.name );
		}
		[fetchedResultsController release];
	}	
	[poseFRC release];
	[poserequest release];
	[posesortDescriptors release];
	[posesortDescriptor release];
}
*/
-(void) renameOldVersions{
	NSFetchRequest *poserequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *poseentity = [NSEntityDescription entityForName:@"poseSummary" inManagedObjectContext:self.managedObjectContext];
	//NSPredicate *posepredicate = [NSPredicate predicateWithFormat:@"ANY"];
	//[poserequest setPredicate:posepredicate];
	[poserequest setEntity:poseentity];
	
	NSSortDescriptor *posesortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
	NSArray *posesortDescriptors = [[NSArray alloc] initWithObjects:posesortDescriptor, nil];
	[poserequest setSortDescriptors:posesortDescriptors];
	
	
	
	NSFetchedResultsController *poseFRC = [[NSFetchedResultsController alloc] initWithFetchRequest:poserequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
	NSError *error;
	if (![poseFRC performFetch:&error]) NSLog(@"Error Fetching: %@", [error localizedDescription]);		
	
	
	NSLog(@"Found %i poses that were not assigned to a book", [[poseFRC fetchedObjects] count]);
	
	
	for(poseSummary *renamePose in [poseFRC fetchedObjects]){
		NSUInteger searchRange=[renamePose.imagePath rangeOfString:renamePose.title].location;
		if(searchRange != NSNotFound ){
			NSLog(@"Found title in imagePath: (%@) in %@", renamePose.title, renamePose.imagePath);
			NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
			NSString *documentsDirectory = [paths objectAtIndex:0];

			NSString *fileName=[[[[renamePose objectID] URIRepresentation] path] substringFromIndex:13];
			NSString *imgPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.jpg", fileName]];	
			
			NSString *oldPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.jpg", renamePose.title]];
			if([[NSFileManager defaultManager] fileExistsAtPath:oldPath]) {
				if(![[NSFileManager defaultManager] moveItemAtPath:oldPath toPath:imgPath error:&error]){
					NSLog(@"Error Renaming file: %@ (%@)", imgPath, [error localizedDescription]);
				}else{
					if([[NSFileManager defaultManager] fileExistsAtPath:imgPath]) {
						renamePose.imagePath=imgPath;
						if (![self.managedObjectContext save:&error]) NSLog(@"Error: %@", [error localizedDescription]);
					}
					
				}
			}else{
				NSLog(@"Old file does not exist");
			}
/*			
			NSLog(@"Moving file (%@) to %@", renamePose.imagePath, imgPath);
			if(![[NSFileManager defaultManager] moveItemAtPath:renamePose.imagePath toPath:imgPath error:&error]){
				NSLog(@"Error Renaming file: %@ (%@)", imgPath, [error localizedDescription]);
			}else{
				if([[NSFileManager defaultManager] fileExistsAtPath:imgPath]) {
					renamePose.imagePath=imgPath;
					if (![self.managedObjectContext save:&error]) NSLog(@"Error: %@", [error localizedDescription]);
				}
				
			}
*/			
		}

	}
	
	
}

- (void)applicationWillTerminate:(UIApplication *)application{ 
	NSError *error;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
			// Handle the error.
        } 
    }
	
}

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext {
	
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }else{
		NSLog(@"Unable to create coordinator");
	}
    return managedObjectContext;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
	
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"posepad.sqlite"]];
	
	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
	NSError *error;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: self.managedObjectModel];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error]) {
        NSLog(@"Unable to create persistent Store Coordinator: %@", [error localizedDescription]);
		// Handle the error.
    }    
	
    return persistentStoreCoordinator;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
	
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
//    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
	NSString *path = [[NSBundle mainBundle] pathForResource:@"posepad" ofType:@"momd"];
    NSURL *momURL = [NSURL fileURLWithPath:path];
    managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:momURL];
	NSLog(@"MOM: %@", [momURL absoluteString]);
    return managedObjectModel;
}


- (NSString *)applicationDocumentsDirectory {
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

- (void) convertArraytoDatabase{
	
	NSError *error;
	//path to sqllite file.
	//NSURL *url = [NSURL fileURLWithPath:path];
	
	int poseCount=0;
	for (pose *tempPose in self.totalPoseList.poses){
		poseCount++ ;
		UIImage *tempImage;
		poseSummary *summary = (poseSummary *)[NSEntityDescription
											   insertNewObjectForEntityForName:@"poseSummary" 
											   inManagedObjectContext:self.managedObjectContext];
		summary.title = tempPose.poseTitle;
		
		summary.notes = tempPose.poseNotes;
		
		if(tempPose.poseImageData != nil){
			tempImage=[[UIImage alloc] initWithData:tempPose.poseImageData];
		}else if(tempPose.poseImageName != nil){
			tempImage = [[UIImage alloc] initWithContentsOfFile: tempPose.poseImageName];
		}else{
			NSString  *path = [[NSBundle mainBundle] pathForResource: @"ImageNotFound"  ofType: @"png"];
			//UIImage *tempImage = [[UIImage alloc] initWithContentsOfFile: path];
			tempImage = [[UIImage alloc] initWithContentsOfFile:path];
		}
		
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [paths objectAtIndex:0];
		if (!documentsDirectory) {
			NSLog(@"Documents directory not found!");
		}
		NSString *imgPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.png", tempPose.poseTitle]];
		if(![[NSFileManager defaultManager] fileExistsAtPath:imgPath]) {
			NSData *data =  UIImagePNGRepresentation(tempImage);
			[data writeToFile:imgPath atomically:YES];
		}
		
		CGSize iconSize;
		iconSize.width=200;
		iconSize.height=200;
		
		UIGraphicsBeginImageContext(iconSize); 
		[tempImage drawInRect:CGRectMake(0, 0, iconSize.width, iconSize.height)]; 
		UIImage *iconImg = UIGraphicsGetImageFromCurrentImageContext (); 
		UIGraphicsEndImageContext();
		
		
		summary.thumbnail = UIImagePNGRepresentation(iconImg);
		summary.imagePath = imgPath;
		summary.notes = tempPose.poseNotes;
		summary.sortIndex = [NSNumber numberWithInt:poseCount];
			
		
		if(![self.managedObjectContext save:&error]){
			NSLog(@"Error saving in covert array to database %@", [error localizedDescription]);
		}else{
			//Save was succesful, move old array file
			NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
			NSString *documentsDirectory = [paths objectAtIndex:0]; 
			NSString *saveFileName =[NSString stringWithFormat:@"%@/poseListSaveFile-backup", documentsDirectory];
			
			NSMutableArray *savedData = [[NSMutableArray alloc] init]; 
			for(pose *savedPose in self.totalPoseList.poses)
				[savedData addObject:[savedPose objectValues]];
			[savedData writeToFile:saveFileName atomically:NO]; 
			
			self.totalPoseList.poses = nil;
			[self.totalPoseList saveToFileSystem];
			
		}
	}
}

							   




@end
