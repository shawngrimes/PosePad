//
//  bookPickerViewController.h
//  PosePad
//
//  Created by shawn on 4/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>
#import "poseSummary.h"

@protocol bookPickerViewControllerDelegate <NSObject>
-(void)bookWasChosen:(poseBooks *) selectedBook;
@end



@interface bookPickerViewController : UIViewController <NSFetchedResultsControllerDelegate,UIPickerViewDelegate> {
	id<bookPickerViewControllerDelegate> delegate;
	
	UILabel *selectBookLabel;
	UIButton *savePoseButton;
	UIPickerView *pickerView;
	
	NSManagedObjectContext *managedObjectContext;
	NSFetchedResultsController *fetchedResultsController;

	poseSummary *selectedPose;
	NSMutableArray *books;

}
@property (assign) id<bookPickerViewControllerDelegate> delegate;

@property (nonatomic, retain) poseSummary *selectedPose;
@property(nonatomic, retain) NSMutableArray *books;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic,retain) IBOutlet UIButton *savePoseButton;
@property (nonatomic, retain) IBOutlet UILabel *selectBookLabel;
@property (nonatomic,retain) IBOutlet 	UIPickerView *pickerView;

-(void) createView;
-(IBAction) savePose:(id) sender;
-(void) fetchBooks;
-(void) populatePicker;

@end
