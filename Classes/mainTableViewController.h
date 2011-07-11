//
//  mainTableViewController.h
//  Poser
//
//  Created by shawn on 3/24/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>
#import "poseBooks.h";


//#import "poseList.h"



@interface mainTableViewController : UITableViewController <NSFetchedResultsControllerDelegate,UIImagePickerControllerDelegate,UIPopoverControllerDelegate> {

	NSManagedObjectContext *managedObjectContext;
	NSFetchedResultsController *fetchedResultsController;
	poseBooks *selectedBook;
	
	UIPopoverController *popOverController;
	
}

@property (nonatomic,retain) UIPopoverController *popOverController;

@property (nonatomic,retain) 	poseBooks *selectedBook;

@property (nonatomic,retain) 	NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) 	NSManagedObjectContext *managedObjectContext;

-(void) createView;
-(void) fetchResults;
-(void) returnThumbnailView;
- (void) openDetailsForPoseAtIndexPath:(NSIndexPath *)indexPath;


//-(poseList *) totalPoseList;

@end
