//
//  poseBookThumbnailViewController.m
//  PosePad
//
//  Created by Colin Francis on 7/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "poseBookThumbnailViewController.h"
#import "poseBooks.h"
#import "poseSummary.h"
#import "poseThumbnailViewController.h"
#import "infoViewController.h"
#import "tableDisplayController.h"
#import <QuartzCore/QuartzCore.h>

@implementation poseBookThumbnailViewController

@synthesize managedObjectContext, thumbnailScrollView, frc;
@synthesize popoverController, extWindow;
@synthesize toolbar;
@synthesize invisibleButtons;

-(IBAction)getFreeSamples:(id)sender{
	getSamplesViewController *getSamplesVC = [[getSamplesViewController alloc] initWithNibName:@"getSamplesViewController" bundle:nil];
	getSamplesVC.managedObjectContext = managedObjectContext;
	
	[self presentModalViewController:getSamplesVC animated:YES];
}
-(void)externalDisplayEnabled:(UIWindow *) extWindowSetting{
	self.extWindow=extWindowSetting;
}
#define VERTICAL_SPACE 30
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
-(void) thumbnailTouch:(id) sender{
    UIButton *button = sender;
    poseThumbnailViewController *thumbnailVC = [[poseThumbnailViewController alloc] initWithNibName:nil bundle:nil];
	thumbnailVC.managedObjectContext = self.managedObjectContext;
    
	//NSUserDefaults *prefs= [NSUserDefaults standardUserDefaults];
	thumbnailVC.lastBookName = [[[self.frc fetchedObjects] objectAtIndex:button.tag] name];
    [self unDarkenButton:button];
    [self.navigationController pushViewController:thumbnailVC animated:YES];
	
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (id)initWithManagedObjectContext:(NSManagedObjectContext *)moc
{
    self = [super init];
    if (self)
    {
        self.title = @"Pose Books";
        self.managedObjectContext = moc;
    }
     return self;
}
-(void)fetchResults
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *bookEntity = [NSEntityDescription entityForName:@"poseBooks" inManagedObjectContext:self.managedObjectContext];
    NSSortDescriptor *booksortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *booksortDescriptors = [[NSArray alloc] initWithObjects:booksortDescriptor, nil];
    //NSPredicate *bookPredicate = [NSPredicate predicateWithFormat:@"name contains %@", @"DEFAULT"];
    [fetchRequest setEntity:bookEntity];
    [fetchRequest setSortDescriptors:booksortDescriptors];
    self.frc = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    NSError *error;
    if (![self.frc performFetch:&error]) NSLog(@"Error Fetching: %@", [error localizedDescription]);
    
    

}
-(void) clearThumbnails{
	for (UIView *thumbnailItem in thumbnailScrollView.subviews) {
		[thumbnailItem removeFromSuperview];
		//[thumbnailItem release];
	}
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
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.destructiveButtonIndex)
    {
        //NSLog(@"Delete");
        
        NSManagedObject *goneObject = [[self.frc fetchedObjects] objectAtIndex:selectedBookIndex];      
        [self.managedObjectContext deleteObject:goneObject];
        NSError *error;
        if ([managedObjectContext save:&error])
        {
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
        bookAddViewController *editVC = [[bookAddViewController alloc] initWithPosebook:[[self.frc fetchedObjects] objectAtIndex:selectedBookIndex]];
        editVC.delegate = self;
        editVC.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentModalViewController:editVC animated:YES];
    }
    else if (buttonIndex == actionSheet.firstOtherButtonIndex+1)
    {
        tableDisplayController *tdc = [[tableDisplayController alloc] init];
        tdc.managedObjectContext = self.managedObjectContext;
        poseBooks *selectedBookHere = [[self.frc fetchedObjects] objectAtIndex:selectedBookIndex];
        
        //poseThumbnailViewController *ptvc = [[poseThumbnailViewController alloc] init];
        //tdc.fetchedResultsController = ptvc.fetchedResultsController;
        tdc.fetchedResultsController = nil;
        tdc.selectedBook = selectedBookHere;
        
        NSLog(@"Selected Book Here: %@", [selectedBookHere name]);
        
        [self.navigationController pushViewController:tdc animated:YES];
    
        //[ptvc release];
        
    }
    else if (buttonIndex == actionSheet.cancelButtonIndex)
    {
        //Cancel
        NSLog(@"Cancel");
    }
    //[self generateThumbnails];
    //[actionSheet dismissWithClickedButtonIndex:buttonIndex animated:YES];
    //[actionSheet removeFromSuperview];
}
-(void)bookMenu:(id)sender
{
    UILongPressGestureRecognizer *longPress = sender;
    if (longPress.state == UIGestureRecognizerStateBegan)
    {
        int tag = [[longPress view] tag];
        selectedBookIndex = tag;
        [self unDarkenButton:[invisibleButtons objectAtIndex:tag]];
        UIActionSheet *menu = [[UIActionSheet alloc] initWithTitle:@"Book Menu" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"Delete Book" otherButtonTitles:@"Edit Book Name", @"View Book", nil];
        menu.actionSheetStyle = UIActionSheetStyleBlackOpaque;
        UIButton *button = [invisibleButtons objectAtIndex:tag];
        [menu showFromRect:[button frame] inView:self.view animated:YES];
    }
}
-(void)generateThumbnails
{
    [self clearThumbnails];
    thumbnailScrollView.contentMode = (UIViewContentModeScaleAspectFit);
    
	int horizontalSpace;
    
	int height;
	
	
	if((self.interfaceOrientation == UIInterfaceOrientationPortrait) || (self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)){
        
		horizontalSpace = (768 - (200 * 3)) / 4;
        
		//set the size og the ***content*** inside the scroller
		height = ((([[self.frc fetchedObjects] count]) / 3) * (200 + VERTICAL_SPACE)) + (400+(VERTICAL_SPACE*2));
        
		[thumbnailScrollView setContentSize:CGSizeMake(708, height)];
        
        
	}else if((self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) || (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft)){
		horizontalSpace = (975 -(200*4))/4;
		height=((([[self.frc fetchedObjects] count]) / 4) * (200 + VERTICAL_SPACE)) + (400+(VERTICAL_SPACE*2));
		[thumbnailScrollView setContentSize:CGSizeMake(thumbnailScrollView.superview.frame.size.width-40 , height)];
	}
	
	thumbnailScrollView.autoresizingMask = ( UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	thumbnailScrollView.clipsToBounds = YES;
	thumbnailScrollView.delegate = self;
	thumbnailScrollView.scrollEnabled = TRUE;
	//thumbnailScrollView.showsHorizontalScrollIndicator = YES;
	thumbnailScrollView.userInteractionEnabled = TRUE;
	
	UIButton *button;
	UILabel *label;
	NSMutableArray *posebooksArray = [[self.frc fetchedObjects] mutableCopy];
    self.invisibleButtons = [[NSMutableArray alloc] initWithCapacity:[[self.frc fetchedObjects] count]];
	for (poseBooks *book in posebooksArray) 
	{
		UIImage *iconImg;
		//alloc the image
        NSSortDescriptor *posesortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sortIndex" ascending:YES];
        NSArray *posesortDescriptors = [[NSArray alloc] initWithObjects:posesortDescriptor, nil];
        NSArray *allPoses = [book.pose sortedArrayUsingDescriptors:posesortDescriptors];
        poseSummary *poseSummary;
        if ([allPoses count])
            poseSummary = [allPoses objectAtIndex:0];
        else
            poseSummary = [allPoses lastObject];
		NSData *thumbnailData = poseSummary.thumbnail;
		if (thumbnailData == nil){
			NSString * defaultFileName=[[NSBundle mainBundle] pathForResource: @"NewPoseThumb"  ofType: @"png"];
			iconImg = [[UIImage alloc] initWithContentsOfFile:defaultFileName];
			//[defaultFileName release];
		}else{
			iconImg= [[UIImage alloc] initWithData:thumbnailData];
		}
		
		//create a button
		button = [UIButton buttonWithType:UIButtonTypeCustom];
		//set the button's frame
		CGRect frame;
        UIView *poseView;
        UIImageView *poseSurroundImage;
        UIImageView *poseThumb;
		int rowHeight;
		int i= [posebooksArray indexOfObject:book];
		if((self.interfaceOrientation == UIInterfaceOrientationPortrait) || (self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)){
			rowHeight=(i / 3 * (260)) + VERTICAL_SPACE-20;
			frame = CGRectMake (horizontalSpace + i % 3 * (100 + horizontalSpace+105)-30, 
								rowHeight, 
								216, 
								216);
		}else if((self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) || (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft)){
			rowHeight=(i / 4 * (260)) + VERTICAL_SPACE-20;
			frame = CGRectMake (horizontalSpace + i % 4 * (100 + horizontalSpace+105)-30, 
								rowHeight, 
								216, 
								216);
		}
		//NSLog(@"RowHeight: %i", rowHeight);
		//i / 3 * (iconImg.size.height + VERTICAL_SPACE), 
        [poseSurroundImage = [UIImageView alloc] initWithImage:[UIImage imageNamed:@"PoseBook Surround.png"]];
		//[poseSurroundImage setFrame:frame];
		[button setFrame: frame];
		[button setBackgroundColor:[UIColor clearColor]];
		//do setBackgroundImage and setImage:forState: here.
		//button.tag=[book.sortIndex intValue];
		//[button setImage:iconImg forState:UIControlStateNormal]; 
		button.layer.cornerRadius = 15.0;
		[button addTarget: self action:@selector(thumbnailTouch:) forControlEvents:UIControlEventTouchUpInside];
        [button addTarget:self action:@selector(darkenButton:) forControlEvents:UIControlEventTouchDown];
        [button addTarget:self action:@selector(unDarkenButton:) forControlEvents:UIControlEventTouchDragOutside];
        //[button addTarget:self action:@selector(bookMenu:) forControlEvents:UIControlEventTouchDragInside];
        
		[button setTag:i];
		
		//[button setTitle:pose.title forState:UIControlStateNormal];
		
        
        poseThumb = [[UIImageView alloc] initWithImage:iconImg];
        poseThumb.frame = CGRectMake(20, 20, 176, 135);
        //poseThumb.frame = CGRectMake(20, 20, iconImg.size.width, iconImg.size.height);
        poseThumb.layer.cornerRadius = 0;
        poseThumb.clipsToBounds = YES;
        poseThumb.contentMode = UIViewContentModeScaleAspectFill;
        poseThumb.backgroundColor = [UIColor blackColor];
        
        poseView = [[UIView alloc] initWithFrame:frame];
        [poseView addSubview:poseSurroundImage];
        poseView.layer.cornerRadius = 15.0;
        poseView.clipsToBounds = YES;
        poseView.tag = i;
        poseView.backgroundColor = [UIColor colorWithRed:.8 green:.8 blue:.8 alpha:0.6];
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(bookMenu:)];
        longPress.allowableMovement = 25;
        [button addGestureRecognizer:longPress];
        [poseView addSubview:poseThumb];
        //[self.view addSubview:poseThumb];
        //alloc the label and init it frame
		label = [[UILabel alloc] initWithFrame:CGRectMake(10 , 177, frame.size.width-20, 25)];
		//set parameters
		label.textAlignment = UITextAlignmentCenter;
		label.font = [UIFont fontWithName:@"Arial" size:19.0 ];
		label.backgroundColor = [UIColor clearColor];
        label.shadowColor = [UIColor colorWithRed:.4 green:.4 blue:.4 alpha:.6];
        label.shadowOffset = CGSizeMake(-1.0, -1.0);
		label.textColor= [UIColor colorWithRed:.10 green:.10 blue:.1 alpha:1];
		label.numberOfLines = 1;
		label.minimumFontSize = 12;
		//set its text
		label.text = book.name;
		//add the label to the scroller view
		[poseView addSubview:label];
        
        //poseView addSubview:poseSubView];
        
        [thumbnailScrollView addSubview:poseView];
		[thumbnailScrollView addSubview:button];
        [self.invisibleButtons addObject:button];
        //[button release];
        //break;
		//[pose release];
	}
    
	//[posesArray release];
    self.view.backgroundColor = [UIColor clearColor];
    thumbnailScrollView.backgroundColor = [UIColor clearColor];
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
		settingsViewController *settingsVC = [[settingsViewController alloc] init];
		settingsVC.contentSizeForViewInPopover=CGSizeMake(412.0, 520.0);
		//settingsVC.extWindow=self.extWindow;
		settingsVC.delegate=self;
		UINavigationController *popoverNavCon = [[UINavigationController alloc] initWithRootViewController:settingsVC];
		UIPopoverController *aPopover = [[UIPopoverController alloc] initWithContentViewController:popoverNavCon];
		aPopover.delegate = self;
		[aPopover setPopoverContentSize:CGSizeMake(412.0, 520.0)];
		
		self.popoverController = aPopover;
		[self.popoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	}
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle
-(void)willAnimateSecondHalfOfRotationFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self generateThumbnails];
}
-(void)bookWasCanceled
{
    [self dismissModalViewControllerAnimated:YES];
}
-(void)bookWasAdded{
	[self fetchResults];
	[self generateThumbnails];
}
-(void) add{
	bookAddViewController *bookAddVC = [[bookAddViewController alloc] initWithNibName:@"bookAddViewController" bundle:nil];
	bookAddVC.delegate = self;
	bookAddVC.managedObjectContext = managedObjectContext;
	//bookAddVC.fetchedResultsController = self.fetchedResultsController;
 	
	[self presentModalViewController:bookAddVC animated:YES];
    
	
    //	[self.navigationController pushViewController:bookAddVC animated:YES];
	//[self.view addSubview:bookAddVC.view];
    
}
-(IBAction) displayInfo:(id) sender{
	if(popoverController.popoverVisible){
		[self.popoverController dismissPopoverAnimated:YES];
	}else{
        
        infoViewController *infoVC = [[infoViewController alloc] init];
        infoVC.contentSizeForViewInPopover=CGSizeMake(245.0, 642.0);
        UINavigationController *popoverNavCon = [[UINavigationController alloc] initWithRootViewController:infoVC];
        UIPopoverController *aPopover = [[UIPopoverController alloc] initWithContentViewController:popoverNavCon];
        aPopover.delegate = self;
        [aPopover setPopoverContentSize:CGSizeMake(245.0, 642.0)];
        
        self.popoverController = aPopover;
		
		[self.popoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	}
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self fetchResults];
    [self generateThumbnails];
    
    
    UIBarButtonItem *samplesButton = [[UIBarButtonItem alloc] initWithTitle:@"Samples" style:UIBarButtonItemStylePlain target:self action:@selector(getFreeSamples:)];
    self.navigationItem.leftBarButtonItem = samplesButton;
    
    /*if (self.toolbar == nil)
        self.toolbar = [[UIToolbar alloc] init];
    NSMutableArray *buttonarray = [[NSMutableArray alloc] initWithCapacity:3];
    
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
    [buttonarray addObject:button];
    [button release];
    
    button = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"info-icon.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(displayInfo:)];
    [buttonarray addObject:button];
    [button release];
    
    button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
    [buttonarray addObject:button];
    [button release];
    
    [self.toolbar setItems:buttonarray animated:NO];
    
    [buttonarray release];*/
    // Do any additional setup after loading the view from its nib.
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
   
        [self fetchResults];
        [self generateThumbnails];
    
    UIToolbar* tools = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 105, 44.01)];
    
    // create the array to hold the buttons, which then gets added to the toolbar
    buttons = [[NSMutableArray alloc] initWithCapacity:3];
    
    UIBarButtonItem *bi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(add)];
    
    [buttons addObject:bi];
    
    bi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:NULL];
    bi.width=15;
    [buttons addObject:bi];
    
    
    bi = [[UIBarButtonItem alloc] 
          initWithImage:[UIImage imageNamed:@"info-icon.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(displayInfo:)];
    [buttons addObject:bi];
    
    // stick the buttons in the toolbar
    [tools setItems:buttons animated:NO];
    tools.barStyle = UIBarStyleBlackOpaque;
    //[buttons release];
    
    // and put the toolbar in the nav bar
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:tools];
    
}
- (void)viewDidUnload
{
    self.popoverController = nil;
    self.thumbnailScrollView = nil;
    self.managedObjectContext = nil;
    self.frc = nil;
    self.extWindow = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

@end
