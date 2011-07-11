//
//  detailViewController.h
//  PoseBook
//
//  Created by shawn on 3/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "poseList.h"
//#import "pose.h"
#import "poseSummary.h"
#import "bookPickerViewController.h"

@interface detailViewController : UIViewController <bookPickerViewControllerDelegate,UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverControllerDelegate, UITextViewDelegate > {
	UILabel *titleLabel;
	UILabel *notesLabel;
	UITextField *titleTextField;
	UITextField *imageNameTextField;
	UITextView *notesTextView;
	UIImageView *poseImageView;
	UIImageView *polaroidImageView;
	UIBarButtonItem *choosePhotoBtn;
	UIBarButtonItem *nextPoseBtn;
	UIBarButtonItem *prevPoseBtn;
	UIPopoverController *popOverController;
	IBOutlet UIToolbar *toolbar;
	UIPageControl *pageChanger;

	NSIndexPath *currentIndexPath;
	
	UIGestureRecognizer *rightSwipeRecognizer;
	UISwipeGestureRecognizer *swipeLeftRecognizer;
	UIPinchGestureRecognizer *pinchRecognizer;
	
	NSManagedObjectContext *managedObjectContext;
	NSFetchedResultsController *fetchedResultsController;
	
	UIActivityIndicatorView *activityIndicator;
	
	UIBarButtonItem *changeBookButton;
	
	
	
	IBOutlet UILabel *pinchMessageLabel;
	
	IBOutlet UIImageView *graphPaperImage;
	IBOutlet UIImageView *paperBackgroundImage;
	IBOutlet UIImageView *drawImage;
	IBOutlet UISegmentedControl *drawEraseSegmentControl;
	IBOutlet UILabel *drawSizeLabel;
	IBOutlet UILabel *eraseSizeLabel;
	IBOutlet UISlider *drawSizeSlider;
	IBOutlet UISlider *eraseSizeSlider;
	
	BOOL eraseMode;
	CGPoint lastPoint;
	
	BOOL imageChanged;
	
	NSTimer *myTimer;
	
	
	poseSummary *selectedPose;
	

	
	IBOutlet UIButton *testButton;

	UIWindow *extWindow;
	UIImageView *extImageView;
	IBOutlet UITextView *diagnosticLabel;
	
	

	
//	poseList *totalPoseList;
	
	
}

@property(nonatomic,retain) IBOutlet UITextView *diagnosticLabel;

@property(nonatomic,assign) BOOL imageChanged;

@property(nonatomic, retain) poseSummary *selectedPose;

@property (nonatomic, retain) NSIndexPath * currentIndexPath;

@property (nonatomic,retain) 	NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) 	NSManagedObjectContext *managedObjectContext;


@property (nonatomic, retain) UISwipeGestureRecognizer *swipeLeftRecognizer;
@property (nonatomic,retain) UIPinchGestureRecognizer *pinchRecognizer;


@property (nonatomic,retain) IBOutlet 	UIBarButtonItem *changeBookButton;
@property (nonatomic, retain) IBOutlet UIPageControl *pageChanger;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel *notesLabel;
@property (nonatomic, retain) IBOutlet UITextField *titleTextField;
@property (nonatomic,retain) IBOutlet UITextView *notesTextView;
@property (nonatomic,retain) IBOutlet UIImageView *poseImageView;
@property (nonatomic,retain) IBOutlet 	UIImageView *polaroidImageView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *choosePhotoBtn;
@property (nonatomic,retain) IBOutlet UIBarButtonItem *nextPoseBtn;
@property (nonatomic,retain) IBOutlet UIBarButtonItem *prevPoseBtn;
@property (nonatomic,retain) IBOutlet 	UIActivityIndicatorView *activityIndicator;


@property (nonatomic,retain) UIPopoverController *popOverController;
@property (nonatomic, retain) UIToolbar *toolbar;

@property(nonatomic,retain)	UIWindow *extWindow;
@property(nonatomic,retain) 	UIImageView *extImageView;

-(void) createVertView;
-(void) createHorizView;

-(void) populateViewWithPoseItem:(NSIndexPath *) indexPath;

-(void) populateViewWithPoseFromObject:(poseSummary *) buttonPose;

-(void) saveCurrentPose;

-(IBAction) getPhoto:(id) sender;

-(IBAction) nextPose:(id) sender;

-(IBAction) prevPose:(id) sender;

-(IBAction) clearDefaults:(UITextField *) sender;
-(IBAction)switchEraseMode:(id)sender;

-(IBAction) bookPickerShow:(id) sender;

-(IBAction)sliderChange:(id)sender;
	
-(void)sendTextViewToBack;
-(void) hidePinchMessage;
-(void) populateExternalView;
-(void) showDiagnostics;
-(NSString *) documentsDirectory;
//-(IBAction) spin:(id) sender;

//-(void) spinAndSave;

//-(IBAction)transitionFlip:(id)sender;

@end
