    //
//  poseThumbnailViewController.m
//  PosePad
//
//  Created by shawn on 4/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "poseThumbnailViewController.h"
#import "poseSummary.h"
#import "detailViewController.h"
#import "mainTableViewController.h"
#import "mainBookViewController.h"
#import "settingsViewController.h"
#import "infoViewController.h"
#import "poseBooks.h"
#import "JSON.h"
//#import "getSamplesViewController.h"
#import "posestoreMainViewController.h"
#import <SystemConfiguration/SCNetworkReachability.h>
#include <netinet/in.h>


@implementation poseThumbnailViewController

@synthesize managedObjectContext;
@synthesize fetchedResultsController;
@synthesize editBookButton;
@synthesize getSamplePosesButton;
@synthesize navBar;
@synthesize popoverController;

@synthesize poses;

@synthesize thumbnailScrollView;

@synthesize selectedBook;

@synthesize lastBookName;
@synthesize activityIndicator;

@synthesize editBookNotesButton, bookNotesTextView, bookNotesLabel;;

@synthesize extWindow;


@synthesize notesView;
@synthesize editEquipmentList;
@synthesize equipmentTextField;
@synthesize sessionEquipmentTableView;
@synthesize allEquipmentTableView;
@synthesize allEquipmentUIView;
@synthesize equipmentListUIView;

NSMutableArray *totalEquipmentArray;
NSMutableArray *bookEquipmentArray;

//@synthesize newBookfromJSON;

#define VERTICAL_SPACE 40


 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
		[self createView];
	}
	
    return self;
}

-(void) createView{
	//self.navigationItem.rightBarButtonItem = self.editButtonItem;
	UIBarButtonItem *booksButton = [[UIBarButtonItem alloc] 
								  initWithTitle:@"Pose Books" style:UIBarButtonItemStyleBordered 
								  target:self 
									action:@selector(showBooks:)];
	self.navigationItem.leftBarButtonItem=booksButton;
	self.bookNotesTextView.hidden=YES;
	self.bookNotesLabel.hidden=YES;
	[booksButton release];
	
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController{
	[self.popoverController dismissPopoverAnimated:YES];
	[self fetchResults];
	[self generateThumbnails];
	
}


- (BOOL) connectedToNetwork
{
    // Create zero addy
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
	
    // Recover reachability flags
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
	
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
	
    if (!didRetrieveFlags)
    {
        printf("Error. Could not recover network reachability flags\n");
        return 0;
    }
	
    BOOL isReachable = flags & kSCNetworkFlagsReachable;
    BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
	BOOL nonWiFi = flags & kSCNetworkReachabilityFlagsTransientConnection;
	
	return ((isReachable && !needsConnection) || nonWiFi) ? YES : NO;
}

-(void) showBooks:(id) sender{
	if(popoverController.popoverVisible){
		[self.popoverController dismissPopoverAnimated:YES];
		[self fetchResults];
		[self generateThumbnails];
	}else{
		//if(!self.popoverController){
		if(![self.selectedBook isFault]){
			self.selectedBook.notes=self.bookNotesTextView.text;
			NSError *error;
			if (![self.managedObjectContext save:&error]) NSLog(@"Error: %@", [error localizedDescription]);
		}
		
			mainBookViewController *BookVC = [[mainBookViewController alloc] init];
			BookVC.managedObjectContext = managedObjectContext;
			BookVC.contentSizeForViewInPopover=CGSizeMake(300.0, 500.0);
			UINavigationController *popoverNavCon = [[UINavigationController alloc] initWithRootViewController:BookVC];
			UIPopoverController *aPopover = [[UIPopoverController alloc] initWithContentViewController:popoverNavCon];
			aPopover.delegate = self;
			BookVC.delegate = self;
			[aPopover setPopoverContentSize:CGSizeMake(300.0, 600.0)];
			[BookVC release];
			[popoverNavCon release];
		
			self.popoverController = aPopover;
			[aPopover release];
		//}
		[self.popoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	}
}

-(IBAction)getFreeSamples:(id) sender{
	getSamplesViewController *getSamplesVC = [[getSamplesViewController alloc] initWithNibName:@"getSamplesViewController" bundle:nil];
	getSamplesVC.managedObjectContext = managedObjectContext;
	
	[self presentModalViewController:getSamplesVC animated:YES];
	[getSamplesVC release]; 
	
}

-(IBAction) displaySettings:(id) sender{
	if(popoverController.popoverVisible){
		[self.popoverController dismissPopoverAnimated:YES];
	}else{
		settingsViewController *settingsVC = [[settingsViewController alloc] init];
		settingsVC.contentSizeForViewInPopover=CGSizeMake(412.0, 520.0);
		settingsVC.extWindow=self.extWindow;
		settingsVC.delegate=self;
		UINavigationController *popoverNavCon = [[UINavigationController alloc] initWithRootViewController:settingsVC];
		UIPopoverController *aPopover = [[UIPopoverController alloc] initWithContentViewController:popoverNavCon];
		aPopover.delegate = self;
		[aPopover setPopoverContentSize:CGSizeMake(412.0, 520.0)];
		[settingsVC release];
		[popoverNavCon release];
		
		self.popoverController = aPopover;
		[aPopover release];
		[self.popoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	}
}

-(IBAction) displayInfo:(id) sender{
	if(popoverController.popoverVisible){
		[self.popoverController dismissPopoverAnimated:YES];
	}else{
	
			infoViewController *infoVC = [[infoViewController alloc] init];
			infoVC.contentSizeForViewInPopover=CGSizeMake(200.0, 560.0);
			UINavigationController *popoverNavCon = [[UINavigationController alloc] initWithRootViewController:infoVC];
			UIPopoverController *aPopover = [[UIPopoverController alloc] initWithContentViewController:popoverNavCon];
			aPopover.delegate = self;
			[aPopover setPopoverContentSize:CGSizeMake(200.0, 560.0)];
			[infoVC release];
			[popoverNavCon release];
			
			self.popoverController = aPopover;
			[aPopover release];
		
		[self.popoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	}
}

-(IBAction)editBookNotes:(id) sender{

	self.selectedBook.notes=self.bookNotesTextView.text;
	NSError *error;
	if (![self.managedObjectContext save:&error]) NSLog(@"Error: %@", [error localizedDescription]);
	
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.8];	
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.view cache:YES];

	
	if(self.bookNotesTextView.hidden){
		self.bookNotesTextView.hidden=NO;
		self.thumbnailScrollView.hidden=YES;
		self.bookNotesLabel.hidden=NO;
		self.editBookNotesButton.title=@"Thumbnails";
		self.equipmentListUIView.hidden=NO;
		[self fetchTotalEquipment];
		[self fetchBookEquipment];
		[self.sessionEquipmentTableView reloadData];
		
	}else{
		self.bookNotesLabel.hidden=YES;
		self.bookNotesTextView.hidden=YES;
		self.thumbnailScrollView.hidden=NO;
		self.editBookNotesButton.title=@"Notes";
				self.equipmentListUIView.hidden=YES;
		totalEquipmentArray=nil;
	}
	
		[UIView commitAnimations];
	
}

-(void) bookWasSelected:(poseBooks *) chosenBook{
	[self showBooks:self];
	NSLog(@"(bookWasSelected)Selected %@ book", chosenBook.name);
	self.selectedBook = chosenBook;
	
	NSUserDefaults *prefs= [NSUserDefaults standardUserDefaults];
	[prefs setObject:chosenBook.name forKey:@"lastBookName"];
	[prefs synchronize];
	NSLog(@"(bookWasSelected)Selected: Set last book to %@", chosenBook.name);
	
	
	
	[self fetchResults];
	[self generateThumbnails];
	
	if(!self.equipmentListUIView.hidden){
		[self fetchTotalEquipment];
		[self fetchBookEquipment];
		[self.sessionEquipmentTableView reloadData];
	}
	
}
	

-(void) clearThumbnails{
	for (UIView *thumbnailItem in thumbnailScrollView.subviews) {
		[thumbnailItem removeFromSuperview];
		//[thumbnailItem release];
	}
}

-(void) generateThumbnails{
	thumbnailScrollView.contentMode = (UIViewContentModeScaleAspectFit);
	
	[self clearThumbnails];
	
	if(!self.fetchedResultsController){
		[self fetchResults];
	}

	int horizontalSpace;

	int height;
	
	
	if((self.interfaceOrientation == UIInterfaceOrientationPortrait) || (self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)){
	
		horizontalSpace = (768 - (200 * 3)) / 4;
	
		//set the size og the ***content*** inside the scroller
		height = (([[self.fetchedResultsController fetchedObjects] count] / 3) * (200 + VERTICAL_SPACE)) + (200+(VERTICAL_SPACE*2));

		[thumbnailScrollView setContentSize:CGSizeMake(self.view.bounds.size.width, height)];
	}else if((self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) || (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft)){
		horizontalSpace = (975 -(200*4))/4;
		height=(([[self.fetchedResultsController fetchedObjects] count] / 4) * (200 + VERTICAL_SPACE)) + (200+(VERTICAL_SPACE*2));
		[thumbnailScrollView setContentSize:CGSizeMake(self.view.bounds.size.width , height)];
	}
	
	thumbnailScrollView.autoresizingMask = ( UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	thumbnailScrollView.clipsToBounds = YES;
	thumbnailScrollView.delegate = self;
	thumbnailScrollView.scrollEnabled = TRUE;
	thumbnailScrollView.showsHorizontalScrollIndicator = YES;
	thumbnailScrollView.userInteractionEnabled = TRUE;
	
	UIButton *button;
	UILabel *label;
	poses = [[fetchedResultsController fetchedObjects] mutableCopy];
	for (poseSummary *pose in poses) 
	{
		UIImage *iconImg;
		//alloc the image
		NSData *thumbnailData = pose.thumbnail;
		if (thumbnailData == nil){
			NSString * defaultFileName=[[NSBundle mainBundle] pathForResource: @"NewPose"  ofType: @"png"];
			iconImg = [[UIImage alloc] initWithContentsOfFile:defaultFileName];
			//[defaultFileName release];
		}else{
			iconImg= [[UIImage alloc] initWithData:[pose valueForKey:@"thumbnail"]];
		}
		
		
		//create a buttons
		button = [UIButton buttonWithType: UIButtonTypeCustom];
		//and add it as a sub view of the scorller
		[self.view addSubview: button];
		//set the button's frame
		CGRect frame;
		int rowHeight;
		int i= [poses indexOfObject:pose];
		if((self.interfaceOrientation == UIInterfaceOrientationPortrait) || (self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)){
			rowHeight=(i / 3 * (iconImg.size.height+40)) + VERTICAL_SPACE;
			frame = CGRectMake (horizontalSpace + i % 3 * (iconImg.size.width + horizontalSpace), 
								rowHeight, 
								iconImg.size.width + 4, 
								iconImg.size.height + 4);
		}else if((self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) || (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft)){
			rowHeight=(i / 4 * (iconImg.size.height+40)) + VERTICAL_SPACE;
			frame = CGRectMake (horizontalSpace + i % 4 * (iconImg.size.width + horizontalSpace), 
								rowHeight, 
								iconImg.size.width + 4, 
								iconImg.size.height + 4);
		}
		//NSLog(@"RowHeight: %i", rowHeight);
		//i / 3 * (iconImg.size.height + VERTICAL_SPACE), 
		
		
		[button setFrame: frame];
		[button setBackgroundColor:[UIColor orangeColor]];
		//do setBackgroundImage and setImage:forState: here.
		button.tag=[pose.sortIndex intValue];
		[button setImage:iconImg forState:UIControlStateNormal]; 
		
		[button addTarget: self action:@selector(thumbnailTouch:) forControlEvents:UIControlEventTouchUpInside];
		[button setTag:i];
		
		[button setTitle:pose.title forState:UIControlStateNormal];
		
		[thumbnailScrollView addSubview:button];
		
		
		//alloc the label and init it frame
		label = [[UILabel alloc] initWithFrame:CGRectMake(frame.origin.x ,(frame.origin.y + frame.size.height + 10), frame.size.width, 15)];
		//set parameters
		label.textAlignment = UITextAlignmentCenter;
		label.userInteractionEnabled = NO;
		label.font = [UIFont fontWithName:@"Arial" size:14 ];
		label.backgroundColor = [UIColor blackColor];
		label.textColor= [UIColor lightGrayColor];
		label.numberOfLines = 1;
		label.minimumFontSize = 12;
		//set its text
		label.text = pose.title;
		//add the label to the scroller view
		[thumbnailScrollView addSubview:label];
		[label release];
		[iconImg release];
		//[pose release];
	}
	//[posesArray release];
	self.view.backgroundColor = [UIColor blackColor];
	[self.view addSubview:thumbnailScrollView];
	//[poses release];
	[super viewDidLoad];
}

-(IBAction) editBook:(id) sender{

	mainTableViewController *mainTVC = [[mainTableViewController alloc] initWithStyle:UITableViewStylePlain];
	mainTVC.managedObjectContext=managedObjectContext;
	mainTVC.fetchedResultsController=fetchedResultsController;
	mainTVC.selectedBook=self.selectedBook;
	[self.navigationController setToolbarHidden:NO];
	[self.navigationController pushViewController:mainTVC animated:YES];
	[mainTVC release];
	
}

-(void) thumbnailTouch:(id) sender{
	detailViewController * dvc = [[detailViewController alloc] initWithNibName:nil bundle:nil];
	dvc.managedObjectContext = managedObjectContext;
	dvc.fetchedResultsController= self.fetchedResultsController;
		
	UIButton *btn = (UIButton *) sender;
	NSLog(@"poseThumbVC:(thumbnailTouch)Sender: %i", btn.tag);
	NSLog(@"poseThumbVC:(thumbnailTouch)Poses Count: %i", [poses count]);
	poseSummary *selectedPose=[poses objectAtIndex:btn.tag];
	NSIndexPath *currentIndexPath = [self.fetchedResultsController indexPathForObject:selectedPose];

	NSLog(@"poseThumbVC:(thumbnailTouch)Selected Pose: %@", selectedPose.title);
	NSLog(@"poseThumbVC:(thumbnailTouch)Poses Count in FRC: %i", [[self.fetchedResultsController fetchedObjects] count]);
	NSLog(@"poseThumbVC:(thumbnailTouch)selected Pose: %@", selectedPose);
	NSLog(@"poseThumbVC:(thumbnailTouch)poses: %@", [self.fetchedResultsController fetchedObjects]);
	NSLog(@"poseThumbVC:(thumbnailTouch)Cache Name: %@", self.fetchedResultsController.cacheName);
	NSLog(@"poseThumbVC:(thumbnailTouch)Index Path for chosen pose: %@", currentIndexPath);
	
	[dvc populateViewWithPoseFromObject:selectedPose];

	[self.navigationController pushViewController:dvc animated:YES];
	[dvc release];
	
}
-(void)externalDisplayEnabled:(UIWindow *) extWindowSetting{
	self.extWindow=extWindowSetting;
}

#pragma mark fetches
-(void) fetchResults{

	NSLog(@"Book Deleted: %i", [self.selectedBook isDeleted]);
		NSLog(@"Book Faulted: %i", [self.selectedBook isFault]);
	
	
	
	//if(!self.selectedBook){
		NSFetchRequest *bookRequest = [[NSFetchRequest alloc] init];
		NSEntityDescription *bookEntity = [NSEntityDescription entityForName:@"poseBooks" inManagedObjectContext:self.managedObjectContext];
		NSPredicate *bookPredicate;
		if(self.selectedBook && ![self.selectedBook isFault]){
			bookPredicate = [NSPredicate predicateWithFormat:@"name == %@", self.selectedBook.name];
		}else if(self.lastBookName == NULL){
			bookPredicate = [NSPredicate predicateWithFormat:@"name == 'DEFAULT'"];
		}else{
			bookPredicate = [NSPredicate predicateWithFormat:@"name == %@", self.lastBookName];
		}
		NSLog(@"poseThumbVC:(fetchResults): Predicate: %@", bookPredicate);
		[bookRequest setPredicate:bookPredicate];
		[bookRequest setEntity:bookEntity];
		
		NSSortDescriptor *booksortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
		NSArray *booksortDescriptors = [[NSArray alloc] initWithObjects:booksortDescriptor, nil];
		[bookRequest setSortDescriptors:booksortDescriptors];

		
		
		NSFetchedResultsController *bookFRC = [[NSFetchedResultsController alloc] initWithFetchRequest:bookRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
		NSError *error;
		if (![bookFRC performFetch:&error]) NSLog(@"Error Fetching: %@", [error localizedDescription]);
		
		NSLog(@"poseThumbVC:(fetchResults)Found (%i) books when looking for last used book",[[bookFRC fetchedObjects] count]);
		if([[bookFRC fetchedObjects] count]>0){
			NSLog(@"Found last used book");
			self.selectedBook = [[bookFRC fetchedObjects] objectAtIndex:0];
			NSLog(@"poseThumbVC:(fetchResults)  self.selectedbook.Name =  %@", self.selectedBook.name );
			self.bookNotesTextView.text=self.selectedBook.notes;
		}else{
			NSLog(@"poseThumbVC:(fetchResults)Could not find last used book, searching for DEFAULT book");
			bookPredicate = [NSPredicate predicateWithFormat:@"name == 'DEFAULT'"];
			[bookRequest setPredicate:bookPredicate];
			//[bookFRC release];
			NSFetchedResultsController *newBookFRC = [[NSFetchedResultsController alloc] initWithFetchRequest:bookRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
			if (![newBookFRC performFetch:&error]) NSLog(@"Error Fetching: %@", [error localizedDescription]);
				NSLog(@"poseThumbVC:(fetchResults)Found (%i) books when looking for DEFAULT book",[[bookFRC fetchedObjects] count]);
				if([[newBookFRC fetchedObjects] count]>0){
					self.selectedBook = [[newBookFRC fetchedObjects] objectAtIndex:0];
				}else{
					NSLog(@"Did not find default book, creating one");
					self.selectedBook = (poseBooks *)[NSEntityDescription insertNewObjectForEntityForName:@"poseBooks" inManagedObjectContext:managedObjectContext];
					self.selectedBook.name = @"DEFAULT";
					if (![self.managedObjectContext save:&error]) NSLog(@"Error: %@", [error localizedDescription]);
				}
			[newBookFRC release];
		}
		
		[bookFRC release];
		[bookRequest release];
		[booksortDescriptors release];
		[booksortDescriptor release];
	//}

	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"poseSummary" inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];
	

	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF IN %@", selectedBook.pose];
	[request setPredicate:predicate];
	
	NSLog(@"poseThumbVC:(fetchResults) Predicate: SELF IN %@", self.selectedBook.name );
	
	self.title = [NSString stringWithFormat:@"Thumbnails for : %@ :",selectedBook.name];
	
	NSUserDefaults *prefs= [NSUserDefaults standardUserDefaults];
	NSSortDescriptor *sortDescriptor;
	NSInteger sortSetting=[prefs integerForKey:@"sortBy"];
	if(sortSetting==0){
		sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sortIndex" ascending:YES];
	}else if(sortSetting==1){
		sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
	}
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[request setSortDescriptors:sortDescriptors];

	if(self.fetchedResultsController == NULL){
		self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
	}else{
		[self.fetchedResultsController initWithFetchRequest:request managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
	}
    self.fetchedResultsController.delegate = self;
	
	//NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) NSLog(@"Error Fetching: %@", [error localizedDescription]);
	NSLog(@"poseThumbVC:(fetchResults) found %i results", [[self.fetchedResultsController fetchedObjects] count]);
	//for (poseSummary *tempPose in [self.fetchedResultsController fetchedObjects]){
	//	NSLog(@"poseThumbVC:(fetchResults) Found pose: %@", tempPose.title);
	//}
	[request release];
	[sortDescriptors release];
	[sortDescriptor release];
	
	
	
}

-(void) fetchTotalEquipment{
	NSFetchRequest *equipmentRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *equipmentEntity = [NSEntityDescription entityForName:@"Equipment" inManagedObjectContext:self.managedObjectContext];
	[equipmentRequest setEntity:equipmentEntity];
	
	NSSortDescriptor *equipmentsortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
	NSArray *equipmentsortDescriptors = [[NSArray alloc] initWithObjects:equipmentsortDescriptor, nil];
	[equipmentRequest setSortDescriptors:equipmentsortDescriptors];
	
	NSError *error;
	NSArray *fetchedObjects=[[[NSArray alloc] init] autorelease];
	fetchedObjects=[self.managedObjectContext executeFetchRequest:equipmentRequest error:&error];
	if(fetchedObjects!=nil){
		NSLog(@"FetchedObjects= %i", [fetchedObjects count]);
		if(totalEquipmentArray==nil){
			totalEquipmentArray = [[[NSMutableArray alloc] initWithCapacity:[fetchedObjects count]] retain];
			[totalEquipmentArray setArray:fetchedObjects];
			
		}else{
			[totalEquipmentArray setArray:fetchedObjects];
		}
		NSLog(@"Added %i equipment to equipmentList", [totalEquipmentArray count]);
	}
	[equipmentRequest release];	

}


-(void) fetchBookEquipment{
	NSFetchRequest *equipmentRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *equipmentEntity = [NSEntityDescription entityForName:@"Equipment" inManagedObjectContext:self.managedObjectContext];
	[equipmentRequest setEntity:equipmentEntity];
	
	NSSortDescriptor *equipmentsortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
	NSArray *equipmentsortDescriptors = [[NSArray alloc] initWithObjects:equipmentsortDescriptor, nil];
	[equipmentRequest setSortDescriptors:equipmentsortDescriptors];
	
	NSPredicate *bookPredicate=[NSPredicate predicateWithFormat:@"ANY book==%@",self.selectedBook];
	[equipmentRequest setPredicate:bookPredicate];
	
	NSError *error;
	NSArray *fetchedObjects=[[[NSArray alloc] init] autorelease];
	fetchedObjects=[self.managedObjectContext executeFetchRequest:equipmentRequest error:&error];
	if(fetchedObjects!=nil){
		NSLog(@"FetchedObjects= %i", [fetchedObjects count]);
		if(bookEquipmentArray==nil){
			bookEquipmentArray = [[[NSMutableArray alloc] initWithCapacity:[fetchedObjects count]] retain];
			[bookEquipmentArray setArray:fetchedObjects];
			
		}else{
			[bookEquipmentArray setArray:fetchedObjects];
		}
		NSLog(@"Added %i equipment to equipmentList", [bookEquipmentArray count]);
	}
	[equipmentRequest release];	
	
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	self.title =@"Thumbnails";
	
	NSUserDefaults *prefs= [NSUserDefaults standardUserDefaults];
	if(![prefs integerForKey:@"showDeleteWarning"]){
		UIAlertView *alertView=[[[UIAlertView alloc] initWithTitle:@"Warning!" message:@"In this version, if you delete a pose book, it will delete ALL the poses in that book" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
		[alertView show];
		[prefs setInteger:1 forKey:@"showDeleteWarning"];
		[prefs synchronize];
	}

	//[self generateThumbnails];
	
    [super viewDidLoad];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
	
}



-(void) willAnimateSecondHalfOfRotationFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation duration:(NSTimeInterval)duration{
	//[self clearThumbnails];
	[self generateThumbnails];
}


-(void) viewWillAppear:(BOOL)animated{
	[self.navigationController setToolbarHidden:YES];
	[self fetchResults];
	[self generateThumbnails];
	if([self connectedToNetwork]){
		getSamplePosesButton.enabled=YES;
	}else{
		getSamplePosesButton.enabled=NO;
	}
	NSLog(@"poseThumbVC:(viewWillAppear): Done VWA");

}

#pragma mark textField Delegate
-(IBAction) editEquipmentName{
	
	if(![self.equipmentTextField.text isEqualToString:@""]){
		self.allEquipmentUIView.hidden=NO;
		self.allEquipmentTableView.hidden=NO;
		NSPredicate *bPredicate =[NSPredicate predicateWithFormat:@"SELF.name contains[c] %@",self.equipmentTextField.text];	
	    NSLog(@"Set predicate to: %@", bPredicate);
		[self fetchTotalEquipment];
		[totalEquipmentArray filterUsingPredicate:bPredicate];
		[self.allEquipmentTableView reloadData];
	}else{
		self.allEquipmentTableView.hidden=YES;
		self.allEquipmentUIView.hidden=YES;
	}

}


-(IBAction) nextButtonOnKeyboardPressed:(id)sender{
	if(![self.equipmentTextField.text isEqualToString:@""]){
		//Look for equipment name
		//if resultCount<1
		//create new equipment
		//else
		//add existing equipment
		
		
		NSError *error;
		
		
		//Check for existing player
		NSFetchRequest *request = [[NSFetchRequest alloc] init];
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"Equipment" inManagedObjectContext:managedObjectContext];
		[request setEntity:entity];
		
		NSPredicate *predicate=[NSPredicate predicateWithFormat:@"name = %@", self.equipmentTextField.text];
		[request setPredicate:predicate];
		
		
		NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
		NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
		[request setSortDescriptors:sortDescriptors];
		[sortDescriptor release];
		[sortDescriptors release];
		
		NSFetchedResultsController *equipmentSearchResultsController=[[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
		
		equipmentSearchResultsController.delegate = self;
		
		//NSError *error;
		if (![equipmentSearchResultsController performFetch:&error]) NSLog(@"Error Fetching: %@", [error localizedDescription]);	
		NSLog(@"fetchEquipment:(fetchResults)Found %i players that matched", [[equipmentSearchResultsController fetchedObjects] count]);	
		[request release];
		
		//player *typedPlayer;
		EquipmentClass *equipment;
		if([[equipmentSearchResultsController fetchedObjects] count]>0){
			equipment=[[equipmentSearchResultsController fetchedObjects] objectAtIndex:0];
		}else{
			equipment = [NSEntityDescription insertNewObjectForEntityForName:@"Equipment" inManagedObjectContext:managedObjectContext];
			equipment.name=self.equipmentTextField.text;
		}
		if (![self.managedObjectContext save:&error]) NSLog(@"Error: %@", [error localizedDescription]);
		
		//Add them to game
		//[currentGame addPlayersObject:typedPlayer];
		[self.selectedBook addEquipmentObject:equipment];
		
		if (![self.managedObjectContext save:&error]) NSLog(@"Error: %@", [error localizedDescription]);
		
		[request release];
		
		//Refresh table view
		//[bookEquipmentArray sortUsingSelector:@selector(localizedCaseInsensitiveCompare)];
		//[self fetchPlayers];
		//[totalEquipmentArray filterUsingPredicate:nil];
		[self fetchBookEquipment];
		[self.sessionEquipmentTableView reloadData];
		self.equipmentTextField.text=@"";
		self.allEquipmentTableView.hidden=YES;
	}
}


#pragma mark tableViewDelegate
-(IBAction) editEquipmentTableView{
	
	if(self.editEquipmentList.style==UIBarButtonItemStyleDone){
		self.editEquipmentList.title=@"Edit";
		self.editEquipmentList.style=UIBarButtonItemStyleBordered;
		[self.sessionEquipmentTableView setEditing:NO animated:YES];
	}else{
		self.editEquipmentList.title=@"Done";
		self.editEquipmentList.style=UIBarButtonItemStyleDone;
		[self.sessionEquipmentTableView setEditing:YES animated:YES];
		
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	if(tableView.tag==2){
		//Add selected equipment to book
		self.equipmentTextField.text=[[totalEquipmentArray objectAtIndex:indexPath.row] name];
		[self nextButtonOnKeyboardPressed:self];
	}
}


-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger) section{
	if(tableView.tag==1){
		return [self.selectedBook.equipment count];
		NSLog(@"Number of equipment rows: %d", [self.selectedBook.equipment count]);
	}else if(tableView.tag==2){
		return [totalEquipmentArray count];
//		return 0;
	}
	return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	
	NSLog(@"Table Tag: %d", tableView.tag);
	
	static NSString *cellIdentifier=@"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if(cell==nil){
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier] autorelease];
	}
	if(tableView.tag==1){
		NSLog(@"Index Path: %d", indexPath.row);
		NSLog(@"Cell Label: %@", [bookEquipmentArray objectAtIndex:indexPath.row]);
		cell.textLabel.text=[[bookEquipmentArray objectAtIndex:indexPath.row] name];
		
	}else if(tableView.tag==2){
		
		if(![self.equipmentTextField.text isEqualToString:@""]){
			cell.textLabel.text=[[totalEquipmentArray objectAtIndex:indexPath.row] name];
		}
	}
	return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if(tableView.tag==1){
		if (editingStyle == UITableViewCellEditingStyleDelete) 
		{
			NSError *error;
			NSFetchRequest *request = [[NSFetchRequest alloc] init];
			NSEntityDescription *entity = [NSEntityDescription entityForName:@"Equipment" inManagedObjectContext:managedObjectContext];
			[request setEntity:entity];
			
			NSPredicate *predicate=[NSPredicate predicateWithFormat:@"name = %@", [[bookEquipmentArray objectAtIndex:indexPath.row] name]];
			[request setPredicate:predicate];
			
			
			NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
			NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
			[request setSortDescriptors:sortDescriptors];
			[sortDescriptor release];
			[sortDescriptors release];
			
			NSFetchedResultsController *equipmentSearchResultsController=[[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
			
			equipmentSearchResultsController.delegate = self;
			
			//NSError *error;
			if (![equipmentSearchResultsController performFetch:&error]) NSLog(@"Error Fetching: %@", [error localizedDescription]);	
			NSLog(@"fetchEquipment:(fetchResults)Found %i equipment that matched", [[equipmentSearchResultsController fetchedObjects] count]);	
			[request release];
			
			//player *typedPlayer;
			EquipmentClass *equipment;
			if([[equipmentSearchResultsController fetchedObjects] count]>0){
				equipment=[[equipmentSearchResultsController fetchedObjects] objectAtIndex:0];
			
			//Remove from book
			//[currentGame addPlayersObject:typedPlayer];
				[self.selectedBook removeEquipmentObject:equipment];
			
				if (![self.managedObjectContext save:&error]) NSLog(@"Error: %@", [error localizedDescription]);
			}
			
			[request release];
			
			
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
			//		[self.tableView reloadData];
			
		}
	}
}

#pragma mark rotate
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}


#pragma mark dealloc
- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void)viewWillDisappear:(BOOL)animated{
	self.selectedBook.notes=self.bookNotesTextView.text;
	NSError *error;
	if (![self.managedObjectContext save:&error]) NSLog(@"Error: %@", [error localizedDescription]);
	[super viewWillDisappear:animated];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[notesView release];
	[editEquipmentList release];
	equipmentTextField.delegate=nil;
	[equipmentTextField release];
	sessionEquipmentTableView.delegate=nil;
	[sessionEquipmentTableView release];
	allEquipmentTableView.delegate=nil;
	[allEquipmentTableView release];

	[allEquipmentUIView release];
	[equipmentListUIView release];
	
	
	
	[thumbnailScrollView release];
	[managedObjectContext release];
	[fetchedResultsController release];
	
	[navBar release];
	
	[toolBar release];
	[editBookButton release];
	[getSamplePosesButton release];
	[displaySettingsButton release];
	[displayInfoButton release];
	[activityIndicator release];
	[editBookNotesButton release];
	[bookNotesTextView release];
	
	[popoverController release];
	
	[lastBookName release];
	
	[poses release];
	
	[selectedBook release];
	[extWindow release];
    [super dealloc];
}


@end
