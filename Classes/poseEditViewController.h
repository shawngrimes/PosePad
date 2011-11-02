//
//  bookAddViewController.h
//  PosePad
//
//  Created by shawn on 4/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>
#import "poseBooks.h"

@protocol poseEditViewControllerDelegate <NSObject>
-(void)bookWasCanceled;
-(void)bookAddDidEditName;
@end


@interface poseEditViewController : UIViewController {
	id<poseEditViewControllerDelegate> __unsafe_unretained delegate;
	
	UIBarButtonItem *saveBookButton;
	UITextField *bookNameTextField;
	UILabel *bookNameLabel;
    
	
	NSManagedObjectContext *managedObjectContext;
	NSFetchedResultsController *fetchedResultsController;
    
}
@property (assign) id<poseEditViewControllerDelegate> delegate;

@property (nonatomic, retain) IBOutlet UIBarButtonItem *saveBookButton;
@property (nonatomic,retain) IBOutlet 	UITextField *bookNameTextField;
@property (nonatomic, retain) IBOutlet 	UILabel *bookNameLabel;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, retain) poseSummary *pose;
- (id)initWithPose:(poseSummary *)poseHere;
-(IBAction) saveBook:(id) sender;
-(IBAction) cancel:(id) sender;


@end
