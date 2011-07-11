//
//  bookAddViewController.h
//  PosePad
//
//  Created by shawn on 4/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>

@protocol bookAddViewControllerDelegate <NSObject>
-(void)bookWasAdded;
@end


@interface bookAddViewController : UIViewController {
	id<bookAddViewControllerDelegate> delegate;
	
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


-(IBAction) saveBook:(id) sender;

@end
