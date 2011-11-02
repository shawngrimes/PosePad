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
#import "tableDisplayController.h"
#import "settingsViewController.h"
#import "infoViewController.h"
#import "poseBooks.h"
//#import "JSON.h"
#import "SBJson.h"
//#import "getSamplesViewController.h"
#import "posestoreMainViewController.h"
#import <SystemConfiguration/SCNetworkReachability.h>
#include <netinet/in.h>
#import <QuartzCore/QuartzCore.h>
#import "poseEditViewController.h"

@implementation poseThumbnailViewController

@synthesize managedObjectContext;
@synthesize fetchedResultsController;
@synthesize editBookButton;
@synthesize getSamplePosesButton;
@synthesize navBar;
@synthesize popoverController, menu;
@synthesize checkButtons;

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
@synthesize invisibleButtons;

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
	/*self.navigationItem.rightBarButtonItem = self.editButtonItem;
	UIBarButtonItem *booksButton = [[UIBarButtonItem alloc] 
    							  initWithTitle:@"Pose Books" style:UIBarButtonItemStyleBordered 
								  target:self 
									action:@selector(showBooks:)];
	self.navigationItem.leftBarButtonItem=booksButton;*/
	self.bookNotesTextView.hidden=YES;
	self.bookNotesLabel.hidden=YES;
	//[booksButton release];
	
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController{
	[self.popoverController dismissPopoverAnimated:YES];
	[self fetchResults];
	[self generateThumbnails];
	
}
-(IBAction) displaySettings:(id) sender{
	if(self.popoverController.popoverVisible){
		[self.popoverController dismissPopoverAnimated:YES];
	}else{
		settingsViewController *settingsVC = [[settingsViewController alloc] initWithPosebook:self.selectedBook];
		settingsVC.contentSizeForViewInPopover=CGSizeMake(412.0, 200.0);
		//settingsVC.extWindow=self.extWindow;
		settingsVC.delegate=self;
		UINavigationController *popoverNavCon = [[UINavigationController alloc] initWithRootViewController:settingsVC];
		UIPopoverController *aPopover = [[UIPopoverController alloc] initWithContentViewController:popoverNavCon];
		aPopover.delegate = self;
		[aPopover setPopoverContentSize:CGSizeMake(412.0, 200.0)];
		
		self.popoverController = aPopover;
		[self.popoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	}
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

/*-(void) showBooks:(id) sender{
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
}*/

-(IBAction)getFreeSamples:(id) sender{
	getSamplesViewController *getSamplesVC = [[getSamplesViewController alloc] initWithNibName:@"getSamplesViewController" bundle:nil];
	getSamplesVC.managedObjectContext = managedObjectContext;
	
	[self presentModalViewController:getSamplesVC animated:YES];
	
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
			
			self.popoverController = aPopover;
		
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
		//self.editBookNotesButton.title=@"Thumbnails";
		self.equipmentListUIView.hidden=NO;
		[self fetchTotalEquipment];
		[self fetchBookEquipment];
		[self.sessionEquipmentTableView reloadData];
		
	}else{
		self.bookNotesLabel.hidden=YES;
		self.bookNotesTextView.hidden=YES;
		self.thumbnailScrollView.hidden=NO;
		//self.editBookNotesButton.title=@"Notes";
        self.equipmentListUIView.hidden=YES;
		totalEquipmentArray=nil;
	}
	
		[UIView commitAnimations];
    
    if (self.bookNotesTextView.hidden)
        self.editBookNotesButton.title = @"Notes";
    else
        self.editBookNotesButton.title = @"Thumbnails";
	
}

-(void) bookWasSelected:(poseBooks *) chosenBook{
	//[self showBooks:self];
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
-(void)darkenButton:(id)sender
{
    UIButton *button = sender;
    button.backgroundColor = [UIColor colorWithRed:.3 green:.3 blue:.3 alpha:.6];
}
-(void)unDarkenButton:(id)sender
{
    UIButton *button = sender;
    button.backgroundColor = [UIColor clearColor];
}
-(void)checkButtonPressed:(id)sender
{
    UIImageView *checkImage = (UIImageView *)[[sender subviews] lastObject];
    poseSummary *pose = [poses objectAtIndex:checkImage.tag];
    if (pose.checked)
    {
        pose.checked = 0;
        checkImage.image = [UIImage imageNamed:@"Gray-Check.png"];
    }
    else
    {
        pose.checked = [NSNumber numberWithBool:YES];
        checkImage.image = [UIImage imageNamed:@"Green-Check.png"];
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
		height = (([[self.fetchedResultsController fetchedObjects] count] / 2) * (200 + VERTICAL_SPACE)) + (200+(VERTICAL_SPACE*2));

		[thumbnailScrollView setContentSize:CGSizeMake(self.view.bounds.size.width, height)];
	}else if((self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) || (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft)){
		horizontalSpace = (975 -(200*4))/4;
		height=(([[self.fetchedResultsController fetchedObjects] count] / 3) * (200 + VERTICAL_SPACE)) + (200+(VERTICAL_SPACE*2));
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
    UIImageView *checkView;
    UIButton *checkButton;
	poses = [[fetchedResultsController fetchedObjects] mutableCopy];
    NSLog(@"%i", [poses count]);
    if ([poses count] == 0)
    {
        suggestionLabel.hidden = NO;   
        suggestionLabel.frame = CGRectMake(10, 20, self.view.frame.size.width-20, 40);

    }
    else
    {
        suggestionLabel.hidden = YES;
    }
    self.checkButtons = [[NSMutableArray alloc] initWithCapacity:[poses count]];
    self.invisibleButtons = [[NSMutableArray alloc] initWithCapacity:[poses count]];
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
            //iconImg = [[UIImage alloc] initWithContentsOfFile:pose.imagePath];
		}
		
		
		//create a buttons
		button = [UIButton buttonWithType: UIButtonTypeCustom];
		//and add it as a sub view of the scorller
		//[self.view addSubview: button];
		//set the button's frame
		CGRect frame;
        UIView *poseView;
        UIView *poseSubView;
        UIImageView *poseThumb;
		int rowHeight;
		int i= [poses indexOfObject:pose];
		if((self.interfaceOrientation == UIInterfaceOrientationPortrait) || (self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)){
			rowHeight=(i / 2 * (iconImg.size.height)) + VERTICAL_SPACE;
			frame = CGRectMake (horizontalSpace + i % 2 * (iconImg.size.width + horizontalSpace+125)+10, 
								rowHeight+30, 
								iconImg.size.width + 100, 
								150);
		}else if((self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) || (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft)){
			rowHeight=(i / 3 * (iconImg.size.height-10)) + VERTICAL_SPACE;
			frame = CGRectMake (horizontalSpace + i % 3 * (iconImg.size.width + horizontalSpace+85)-10, 
								rowHeight+20, 
								iconImg.size.width + 100, 
								150);
		}
		//NSLog(@"RowHeight: %i", rowHeight);
		//i / 3 * (iconImg.size.height + VERTICAL_SPACE), 
		
		
		[button setFrame: CGRectMake(0, 0, frame.size.width, frame.size.height)];
		[button setBackgroundColor:[UIColor clearColor]];
		//do setBackgroundImage and setImage:forState: here.
		button.tag=[pose.sortIndex intValue];
		//[button setImage:iconImg forState:UIControlStateNormal]; 
		button.layer.cornerRadius = 15.0;
		[button addTarget: self action:@selector(thumbnailTouch:) forControlEvents:UIControlEventTouchUpInside];
        [button addTarget:self action:@selector(darkenButton:) forControlEvents:UIControlEventTouchDown];
        [button addTarget:self action:@selector(unDarkenButton:) forControlEvents:UIControlEventTouchDragOutside];
		[button setTag:i];
		
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(poseMenu:)];
        longPress.allowableMovement = 25.0;
        [button addGestureRecognizer:longPress];
        [[longPress view] setTag:i];
        
        [self.invisibleButtons addObject:button];
        
        poseThumb = [[UIImageView alloc] initWithImage:iconImg];
        //poseThumb.frame = CGRectMake(0, 0, iconImg.size.width, iconImg.size.height);
        poseThumb.frame = CGRectMake(0, 0, 150, 150);
        poseThumb.layer.cornerRadius = 15.0;
        poseThumb.clipsToBounds = YES;
        //poseThumb.contentMode = UIViewContentModeScaleAspectFit;
        
        poseView = [[UIView alloc] initWithFrame:frame];
        poseView.layer.cornerRadius = 15.0;
        poseView.clipsToBounds = YES;
        poseView.backgroundColor = [UIColor colorWithRed:.9 green:.9 blue:.9 alpha:0.6];
        [poseView addSubview:poseThumb];
        
        poseSubView = [[UIView alloc] initWithFrame:CGRectMake(140, -5, frame.size.width-140, frame.size.height+10)];
        poseSubView.backgroundColor = [UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1.0];
        poseSubView.layer.borderColor = [[UIColor blackColor] CGColor];
        poseSubView.layer.borderWidth = 1.0;
        //alloc the label and init it frame
		label = [[UILabel alloc] initWithFrame:CGRectMake(10 , 10, frame.size.width-150, 60)];
		//set parameters
		label.textAlignment = UITextAlignmentCenter;
		label.font = [UIFont fontWithName:@"Arial" size:19.0 ];
		label.backgroundColor = [UIColor clearColor];
		label.textColor= [UIColor colorWithRed:.1 green:.1 blue:.1 alpha:1];
        label.shadowColor = [UIColor colorWithRed:.4 green:.4 blue:.4 alpha:.6];
        label.shadowOffset = CGSizeMake(-1.0, -1.0);
		label.numberOfLines = 1;
		label.minimumFontSize = 12;
		//set its text
		label.text = pose.title;
		//add the label to the scroller view
		[poseSubView addSubview:label];
        
        if (pose.checked)
        {
            checkView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Green-Check.png"]];
        }
        else
        {
            checkView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Gray-Check.png"]];
        }
        [self.checkButtons addObject:checkView];
        checkView.frame = CGRectMake(0, 0, 50, 50);
        checkView.tag = i;
        checkButton = [[UIButton alloc] initWithFrame:CGRectMake(250, 100, 50, 50)];
        [checkButton addTarget:self action:@selector(checkButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        [poseView addSubview:poseSubView];
        [checkButton addSubview:checkView];
		[poseView addSubview:button];
        [poseView addSubview:checkButton];
        
        [thumbnailScrollView addSubview:poseView];
		//[pose release];
	}
    
	//[posesArray release];
    self.view.backgroundColor = [UIColor clearColor];
    thumbnailScrollView.backgroundColor = [UIColor clearColor];
	[self.view addSubview:thumbnailScrollView];
	//[poses release];
	[super viewDidLoad];
}
-(void)viewDidDisappear:(BOOL)animated
{
    self.title=@"Back";
}
-(IBAction) editBook:(id) sender{

	tableDisplayController *mainTVC = [[tableDisplayController alloc] init];
	mainTVC.managedObjectContext=managedObjectContext;
	mainTVC.fetchedResultsController=fetchedResultsController;
	mainTVC.selectedBook=self.selectedBook;
	[self.navigationController setToolbarHidden:NO];
	[self.navigationController pushViewController:mainTVC animated:YES];
	
}

-(void) thumbnailTouch:(id) sender{
    
	detailViewController * dvc = [[detailViewController alloc] initWithNibName:nil bundle:nil managedObjectContest:managedObjectContext fetchedResultsController:self.fetchedResultsController];
	//dvc.managedObjectContext = managedObjectContext;
	//dvc.fetchedResultsController= self.fetchedResultsController;
		
	UIButton *btn = (UIButton *) sender;
    btn.backgroundColor = [UIColor clearColor];
	//NSLog(@"poseThumbVC:(thumbnailTouch)Sender: %i", btn.tag);
	//NSLog(@"poseThumbVC:(thumbnailTouch)Poses Count: %i", [poses count]);
	poseSummary *selectedPose=[poses objectAtIndex:btn.tag];
	//NSIndexPath *currentIndexPath = [self.fetchedResultsController indexPathForObject:selectedPose];

	/*NSLog(@"poseThumbVC:(thumbnailTouch)Selected Pose: %@", selectedPose.title);
	NSLog(@"poseThumbVC:(thumbnailTouch)Poses Count in FRC: %i", [[self.fetchedResultsController fetchedObjects] count]);
	NSLog(@"poseThumbVC:(thumbnailTouch)selected Pose: %@", selectedPose);
	NSLog(@"poseThumbVC:(thumbnailTouch)poses: %@", [self.fetchedResultsController fetchedObjects]);
	NSLog(@"poseThumbVC:(thumbnailTouch)Cache Name: %@", self.fetchedResultsController.cacheName);
	NSLog(@"poseThumbVC:(thumbnailTouch)Index Path for chosen pose: %@", currentIndexPath);*/
	
	[dvc populateViewWithPoseFromObject:selectedPose];

	[self.navigationController pushViewController:dvc animated:YES];
	
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
		}
		
	//}

	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"poseSummary" inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];
	

	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF IN %@", selectedBook.pose];
	[request setPredicate:predicate];
	
	NSLog(@"poseThumbVC:(fetchResults) Predicate: SELF IN %@", self.selectedBook.name );
	
	self.title = [NSString stringWithFormat:@"%@",selectedBook.name];
	
	//NSUserDefaults *prefs= [NSUserDefaults standardUserDefaults];
	NSSortDescriptor *sortDescriptor;
	NSInteger sortSetting=[self.selectedBook.alphaSorted intValue];
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
	
	
	
}

-(void) fetchTotalEquipment{
	NSFetchRequest *equipmentRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *equipmentEntity = [NSEntityDescription entityForName:@"Equipment" inManagedObjectContext:self.managedObjectContext];
	[equipmentRequest setEntity:equipmentEntity];
	
	NSSortDescriptor *equipmentsortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
	NSArray *equipmentsortDescriptors = [[NSArray alloc] initWithObjects:equipmentsortDescriptor, nil];
	[equipmentRequest setSortDescriptors:equipmentsortDescriptors];
	
	NSError *error;
	NSArray *fetchedObjects=[[NSArray alloc] init];
	fetchedObjects=[self.managedObjectContext executeFetchRequest:equipmentRequest error:&error];
	if(fetchedObjects!=nil){
		NSLog(@"FetchedObjects= %i", [fetchedObjects count]);
		if(totalEquipmentArray==nil){
			totalEquipmentArray = [[NSMutableArray alloc] initWithCapacity:[fetchedObjects count]];
			[totalEquipmentArray setArray:fetchedObjects];
			
		}else{
			[totalEquipmentArray setArray:fetchedObjects];
		}
		NSLog(@"Added %i equipment to equipmentList", [totalEquipmentArray count]);
	}

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
	NSArray *fetchedObjects=[[NSArray alloc] init];
	fetchedObjects=[self.managedObjectContext executeFetchRequest:equipmentRequest error:&error];
	if(fetchedObjects!=nil){
		NSLog(@"FetchedObjects= %i", [fetchedObjects count]);
		if(bookEquipmentArray==nil){
			bookEquipmentArray = [[NSMutableArray alloc] initWithCapacity:[fetchedObjects count]];
			[bookEquipmentArray setArray:fetchedObjects];
			
		}else{
			[bookEquipmentArray setArray:fetchedObjects];
		}
		NSLog(@"Added %i equipment to equipmentList", [bookEquipmentArray count]);
	}
	
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    poseSummary *pose = [poses objectAtIndex:selectedPoseIndex];
    if (buttonIndex == actionSheet.destructiveButtonIndex)
    {
        //NSLog(@"Delete");
        
        NSManagedObject *goneObject = pose;      
        [self.managedObjectContext deleteObject:goneObject];
        NSError *error;
        if ([managedObjectContext save:&error])
        {
            [actionSheet dismissWithClickedButtonIndex:[actionSheet cancelButtonIndex] animated:YES];
            [self fetchResults];
            [self generateThumbnails];
        }
        else
        {
            NSLog(@"Error saving Delete"); 
        }
    }
    else if (buttonIndex == actionSheet.firstOtherButtonIndex)
    {    
        poseEditViewController *editVC = [[poseEditViewController alloc] initWithPose:pose];
        editVC.delegate = self;
        editVC.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentModalViewController:editVC animated:YES];
    }
    menuIsVisible = NO;
}
//-(void)
-(void)poseMenu:(id)sender
{
    UILongPressGestureRecognizer *longPress = sender;
    if (longPress.state == UIGestureRecognizerStateBegan)
    {
        int index = [[longPress view] tag];
        selectedPoseIndex = index;
        UIButton *button = [self.invisibleButtons objectAtIndex:selectedPoseIndex];
        if (!menuIsVisible)
        {
            [self unDarkenButton:button];
            self.menu = [[UIActionSheet alloc] initWithTitle:@"Pose Menu" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"Delete Pose" otherButtonTitles:@"Edit Pose Name", nil];
            self.menu.actionSheetStyle = UIActionSheetStyleBlackOpaque;
            [self.menu showFromRect:[button.superview frame] inView:self.view animated:YES];
            self.menu;
            menuIsVisible = YES;
        }
        else
        {
            NSLog(@"dismiss");
            [self.menu  dismissWithClickedButtonIndex:menu.cancelButtonIndex animated:YES];
            menuIsVisible = NO;
        }
    }
}
-(void)clearChecks
{
    //NSLog(@"%i", [self.checkButtons count]);
    for (poseSummary *pose in poses)
    {
        pose.checked = 0;
    }
    for (UIImageView *checkView in self.checkButtons)
    {
        if ([checkView.image isEqual:[UIImage imageNamed:@"Green-Check.png"]])
        {
            checkView.image = [UIImage imageNamed:@"Gray-Check.png"];
        }
    }
}

- (void)viewDidLoad {
	self.title =@"Thumbnails";
	menuIsVisible = NO;
   // suggestionLabel.hidden = YES;
	NSUserDefaults *prefs= [NSUserDefaults standardUserDefaults];
	if(![prefs integerForKey:@"showDeleteWarning"]){
		UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:@"Warning!" message:@"In this version, if you delete a pose book, it will delete ALL the poses in that book" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alertView show];
		[prefs setInteger:1 forKey:@"showDeleteWarning"];
		[prefs synchronize];
	}

	//[self generateThumbnails];
    
    UIBarButtonItem *clearChecks = [[UIBarButtonItem alloc] initWithTitle:@"Uncheck All" style:UIBarButtonItemStyleBordered target:self action:@selector(clearChecks)];
    
    //UIBarButtonItem 
    UIBarButtonItem *editBook = [[UIBarButtonItem alloc] initWithTitle:@"Edit Book" style:UIBarButtonItemStyleBordered target:self action:@selector(editBook:)];
    
    
    UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings-icon.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(displaySettings:)];
    
    NSArray *buttons = [[NSArray alloc] initWithObjects:clearChecks, editBook, settingsButton, nil];
    
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    [toolbar setItems:buttons];
    toolbar.barStyle = UIBarStyleBlackOpaque;
    toolbar.frame = CGRectMake(0, 0, 240, 44);
    
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:toolbar];
	
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
		
		NSFetchedResultsController *equipmentSearchResultsController=[[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
		
		equipmentSearchResultsController.delegate = self;
		
		//NSError *error;
		if (![equipmentSearchResultsController performFetch:&error]) NSLog(@"Error Fetching: %@", [error localizedDescription]);	
		NSLog(@"fetchEquipment:(fetchResults)Found %i players that matched", [[equipmentSearchResultsController fetchedObjects] count]);	
		
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
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
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
			
			NSFetchedResultsController *equipmentSearchResultsController=[[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
			
			equipmentSearchResultsController.delegate = self;
			
			//NSError *error;
			if (![equipmentSearchResultsController performFetch:&error]) NSLog(@"Error Fetching: %@", [error localizedDescription]);	
			NSLog(@"fetchEquipment:(fetchResults)Found %i equipment that matched", [[equipmentSearchResultsController fetchedObjects] count]);	
			
			//player *typedPlayer;
			EquipmentClass *equipment;
			if([[equipmentSearchResultsController fetchedObjects] count]>0){
				equipment=[[equipmentSearchResultsController fetchedObjects] objectAtIndex:0];
			
			//Remove from book
			//[currentGame addPlayersObject:typedPlayer];
				[self.selectedBook removeEquipmentObject:equipment];
			
				if (![self.managedObjectContext save:&error]) NSLog(@"Error: %@", [error localizedDescription]);
			}
			
			
			
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
    self.checkButtons = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	equipmentTextField.delegate=nil;
	sessionEquipmentTableView.delegate=nil;
	allEquipmentTableView.delegate=nil;

	
	
	
	
	
	
	
	
	
}
-(void)bookAddDidEditName
{
    NSError *error;
    if ([self.managedObjectContext save:&error])
    {
        [self fetchResults];
        [self generateThumbnails];
    }
    else
        NSLog(@"Error Saving");
    [self dismissModalViewControllerAnimated:YES];
}
-(void)bookWasCanceled
{
    [self dismissModalViewControllerAnimated:YES];
}

@end
