//
//  poseThumbnailViewController.h
//  PosePad
//
//  Created by shawn on 4/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "mainBookViewController.h"
#import "poseBooks.h"
#import "settingsViewController.h"
#import "getSamplesViewController.h"
#import "EquipmentClass.h"

@interface poseThumbnailViewController : UIViewController <UITableViewDelegate,UITextFieldDelegate,settingsViewControllerDelegate, NSFetchedResultsControllerDelegate, UIScrollViewDelegate, UIPopoverControllerDelegate, mainBookViewControllerDelegate,UIAlertViewDelegate>{
	
	UIScrollView *thumbnailScrollView;
	NSManagedObjectContext *managedObjectContext;
	NSFetchedResultsController *fetchedResultsController;
	
	UINavigationBar *navBar;
	
	IBOutlet UIToolbar *toolBar;
	UIBarButtonItem *editBookButton;
	UIBarButtonItem *getSamplePosesButton;
	IBOutlet UIBarButtonItem *displaySettingsButton;
	IBOutlet UIBarButtonItem *displayInfoButton;
	UIActivityIndicatorView *activityIndicator;
	
	
	
	IBOutlet UIBarButtonItem *editBookNotesButton;
	IBOutlet UITextView *bookNotesTextView;
	IBOutlet UILabel *bookNotesLabel;
	
	UIPopoverController *popoverController;
	
	NSString *lastBookName;
	
	NSMutableArray *poses;
	
	IBOutlet UIView *notesView;
	IBOutlet UIBarButtonItem *editEquipmentList;
	IBOutlet UITextField *equipmentTextField;
	IBOutlet UITableView *sessionEquipmentTableView;
	IBOutlet UITableView *allEquipmentTableView;
	
	IBOutlet UIView *allEquipmentUIView;
	IBOutlet UIView *equipmentListUIView;
	
	UIWindow *extWindow;
	
	poseBooks *selectedBook;
//	poseBooks *newBookfromJSON;
	

}
@property (nonatomic, retain) 	IBOutlet UIView *equipmentListUIView;
@property (nonatomic, retain) IBOutlet UIView *allEquipmentUIView;
@property (nonatomic, retain) IBOutlet UIView *notesView;
@property (nonatomic, retain) 	IBOutlet UIBarButtonItem *editEquipmentList;
@property (nonatomic, retain) 	IBOutlet UITextField *equipmentTextField;
@property (nonatomic, retain) 	IBOutlet UITableView *sessionEquipmentTableView;
@property (nonatomic, retain) 	IBOutlet UITableView *allEquipmentTableView;

@property (nonatomic, retain) 	IBOutlet UIBarButtonItem *editBookNotesButton;
@property (nonatomic, retain) 	IBOutlet UITextView *bookNotesTextView;
@property (nonatomic, retain) 	IBOutlet UILabel *bookNotesLabel;

@property (nonatomic,retain) UIWindow *extWindow;
@property (nonatomic, retain) poseBooks *selectedBook;
//@property (nonatomic, retain) poseBooks *newBookfromJSON;
@property (nonatomic, retain) NSMutableArray *poses;
@property (nonatomic, retain) NSString *lastBookName;

@property (nonatomic, retain) IBOutlet 	UINavigationBar *navBar;
@property (nonatomic, retain) IBOutlet 	UIBarButtonItem *editBookButton;
@property (nonatomic, retain) IBOutlet 	UIBarButtonItem *getSamplePosesButton;
@property (nonatomic, retain) IBOutlet 	UIScrollView *thumbnailScrollView;
@property (nonatomic, retain) IBOutlet 	UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) 	UIPopoverController *popoverController;

@property (nonatomic,retain) 	NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) 	NSManagedObjectContext *managedObjectContext;

-(void) fetchResults;
-(IBAction) editBook:(id) sender;
//-(IBAction) getSamplePoses:(id) sender;
-(IBAction) displaySettings:(id) sender;
-(IBAction) displayInfo:(id) sender;
-(IBAction)getFreeSamples:(id) sender;
-(IBAction)editBookNotes:(id) sender;

-(void) generateThumbnails;
-(void) clearThumbnails;
-(void) createView;
-(void) showBooks:(id) sender;
-(void)externalDisplayEnabled:(UIWindow *) extWindowSetting;
//-(BOOL) checkPoseExists:(NSString *) possiblePoseName;
//-(BOOL) checkBookName:(NSString *) possibleBookName;
//-(void) getBookObject:(NSString *) bookName;
-(void) fetchTotalEquipment;
-(void) fetchBookEquipment;
-(BOOL) connectedToNetwork;

-(IBAction) nextButtonOnKeyboardPressed:(id)sender;
-(IBAction) editEquipmentName;
-(IBAction) editEquipmentTableView;

@end
