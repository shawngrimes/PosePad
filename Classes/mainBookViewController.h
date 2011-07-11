//
//  mainBookViewController.h
//  PosePad
//
//  Created by shawn on 4/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>
#import "bookAddViewController.h"
#import "poseBooks.h"

@protocol mainBookViewControllerDelegate <NSObject>

-(void) bookWasSelected:(poseBooks *) selectedBook;


@end




@interface mainBookViewController : UITableViewController <NSFetchedResultsControllerDelegate,bookAddViewControllerDelegate> {
	id<mainBookViewControllerDelegate> delegate;
	NSManagedObjectContext *managedObjectContext;
	NSFetchedResultsController *fetchedResultsController;

	UINavigationBar *navBar;
}

@property (assign) 	id<mainBookViewControllerDelegate> delegate;

@property (nonatomic, retain) UINavigationBar *navBar;
@property (nonatomic,retain) 	NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) 	NSManagedObjectContext *managedObjectContext;

-(void) createView;
-(void) fetchResults;

@end
