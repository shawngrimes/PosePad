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

@protocol bookAddViewControllerDelegate <NSObject>
-(void)bookWasAdded;
-(void)bookWasCanceled;
-(void)bookAddDidEditName;
@end


@interface bookAddViewController : UIViewController {
	id<bookAddViewControllerDelegate> __unsafe_unretained delegate;
	
	UIBarButtonItem *saveBookButton;
	UITextField *bookNameTextField;
	UILabel *bookNameLabel;

	
	NSManagedObjectContext *managedObjectContext;
	NSFetchedResultsController *fetchedResultsController;

}
@property (assign) id<bookAddViewControllerDelegate> delegate;

@property (nonatomic, retain) IBOutlet UIBarButtonItem *saveBookButton;
@property (nonatomic,retain) IBOutlet 	UITextField *bookNameTextField;
@property (nonatomic, retain) IBOutlet 	UILabel *bookNameLabel;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@property BOOL isAdd; //True if adding, false if editing
@property (nonatomic, retain) poseBooks *book;
- (id)initWithPosebook:(poseBooks *)bookHere;
-(IBAction) saveBook:(id) sender;
-(IBAction) cancel:(id) sender;


@end
