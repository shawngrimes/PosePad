    //
//  detailViewController.m
//  PoseBook
//
//  Created by shawn on 3/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "detailViewController.h"
#import "poseSummary.h"
#import "poseBooks.h"
#import "UIImage+Resize.h"
#import "poseEditViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation detailViewController

@synthesize pinchRecognizer,nextPoseBtn,prevPoseBtn,toolbar,swipeLeftRecognizer,choosePhotoBtn,notesTextView,poseImageView,popOverController;
@synthesize managedObjectContext;
@synthesize fetchedResultsController;
@synthesize currentIndexPath;
@synthesize selectedPose;
@synthesize imageChanged;
@synthesize activityIndicator;
@synthesize changeBookButton;
@synthesize polaroidImageView;
@synthesize extWindow;
@synthesize extImageView;
@synthesize diagnosticLabel;

@synthesize diagramVC;
@synthesize poseScrollView;
@synthesize buttons;
@synthesize checkButton;
@synthesize subView;
@synthesize checked, menu;


-(NSString *)getfileName
{
    NSString *fileName =[[[[selectedPose objectID] URIRepresentation] path] substringFromIndex:13];
    return fileName;
}
-(NSString *)getTitle
{
    return self.selectedPose.title;
}
-(NSString *)getBookTitle
{
    NSSortDescriptor *posesortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sortIndex" ascending:YES];
    NSArray *posesortDescriptors = [[NSArray alloc] initWithObjects:posesortDescriptor, nil];
    NSArray *allPoses = [self.selectedPose.books sortedArrayUsingDescriptors:posesortDescriptors];
    //NSLog(@"Book: %@", [[allPoses objectAtIndex:0] name]);
    return [[allPoses objectAtIndex:0] name];
}
-(IBAction)checkButtonPressed:(id)sender
{
    if (self.checked == NO)
    {
            NSLog(@"nil");
        [self.checkButton setImage:[UIImage imageNamed:@"Green-Check.png"] forState:UIControlStateNormal];
        self.checked = YES;
    }
    else
    {
        [self.checkButton setImage:[UIImage imageNamed:@"Gray-Check.png"] forState:UIControlStateNormal];
        self.checked = NO;
    }
}
-(diagramViewController *)diagramVC
{
    if (!diagramVC)
    {
        diagramVC = [[diagramViewController alloc] init];
        diagramVC.managedObjectContext = self.managedObjectContext;
        diagramVC.fetchedResultsController = self.fetchedResultsController;
        diagramVC.selectedPose = self.selectedPose;
        //custom initialization
    }
    return diagramVC;
}
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {

		
		
		UIGestureRecognizer *recognizer;
		recognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchFrom:)];
		[self.view addGestureRecognizer:recognizer];
		
		self.pinchRecognizer = ((UIPinchGestureRecognizer *)recognizer);
		
		UIImagePickerController *picker =[[UIImagePickerController alloc] init];
		picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
		picker.delegate = self;
		
		UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:picker];
		self.popOverController = popover;
		popOverController.delegate = self;
		
		
		notesTextView.delegate = self;
		self.title = @"Pose Details";
		
		NSUserDefaults *prefs= [NSUserDefaults standardUserDefaults];
		if([prefs boolForKey:@"displayPinchMessage"]==NO){
			pinchMessageLabel.hidden=YES;
		}
		
		

		
		if((self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) || (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft)){
			[self createHorizView];
		}else if((self.interfaceOrientation == UIInterfaceOrientationPortrait) || (self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)){
			[self createHorizView];
		}
		/*
		diagnosticLabel=[[UILabel alloc] initWithFrame:CGRectMake(50, 50, 500, 600)];
		diagnosticLabel.text=@"Starting diagnostic...";
		diagnosticLabel.lineBreakMode=UILineBreakModeWordWrap;
		diagnosticLabel.numberOfLines=10;
		diagnosticLabel.tag=89;
		
		[self.view addSubview:diagnosticLabel];
		[diagnosticLabel release];
		
		for (UIScreen *extScreen in UIScreen.screens) {
			if(extScreen != [UIScreen mainScreen]){
				extScreen.currentMode=[[extScreen availableModes] objectAtIndex:[[extScreen availableModes] count]-1];
				self.diagnosticLabel.text=[self.diagnosticLabel.text stringByAppendingFormat:@"\nWindow did not exist, allocing"];
				extWindow=[[UIWindow alloc] initWithFrame:[extScreen bounds]];
				
				self.diagnosticLabel.text=[self.diagnosticLabel.text stringByAppendingFormat:@"\nAlloc'd window"];
				[self.extWindow setScreen:extScreen];
				
				diagnosticLabel.text=[self.diagnosticLabel.text stringByAppendingFormat:@"\extImage did not exist, allocing"];
				extImageView=[[UIImageView alloc] initWithFrame:[extScreen bounds]];
				extImageView.contentMode=UIViewContentModeScaleAspectFit;
				diagnosticLabel.text=[self.diagnosticLabel.text stringByAppendingFormat:@"\nAlloc'd extImage"];
				[extWindow addSubview:extImageView];
				[extImageView release];
				[extWindow makeKeyAndVisible];
			}
		}
		 */
		
        // Custom initialization
		
    }  
    return self;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil managedObjectContest: (NSManagedObjectContext *)moc fetchedResultsController:(NSFetchedResultsController *)frc{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        
        self.managedObjectContext = moc;
		self.fetchedResultsController = frc;
        
		
		UIGestureRecognizer *recognizer;
		recognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchFrom:)];
		[self.view addGestureRecognizer:recognizer];
		
		self.pinchRecognizer = ((UIPinchGestureRecognizer *)recognizer);
		
		UIImagePickerController *picker =[[UIImagePickerController alloc] init];
		picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
		picker.delegate = self;
		
		UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:picker];
		self.popOverController = popover;
		popOverController.delegate = self;
		
		
		notesTextView.delegate = self;
		self.title = @"Pose Details";
		
		NSUserDefaults *prefs= [NSUserDefaults standardUserDefaults];
		if([prefs boolForKey:@"displayPinchMessage"]==NO){
			pinchMessageLabel.hidden=YES;
		}
		
		
		UIBarButtonItem *drawButton = [[UIBarButtonItem alloc] 
									   initWithImage:[UIImage imageNamed:@"draw-icon.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(drawCommand)];
		self.navigationItem.rightBarButtonItem = drawButton;
        
		
		
        
		
		if((self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) || (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft)){
			[self createHorizView];
		}else if((self.interfaceOrientation == UIInterfaceOrientationPortrait) || (self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)){
			[self createHorizView];
		}
		/*
         diagnosticLabel=[[UILabel alloc] initWithFrame:CGRectMake(50, 50, 500, 600)];
         diagnosticLabel.text=@"Starting diagnostic...";
         diagnosticLabel.lineBreakMode=UILineBreakModeWordWrap;
         diagnosticLabel.numberOfLines=10;
         diagnosticLabel.tag=89;
         
         [self.view addSubview:diagnosticLabel];
         [diagnosticLabel release];
         
         for (UIScreen *extScreen in UIScreen.screens) {
         if(extScreen != [UIScreen mainScreen]){
         extScreen.currentMode=[[extScreen availableModes] objectAtIndex:[[extScreen availableModes] count]-1];
         self.diagnosticLabel.text=[self.diagnosticLabel.text stringByAppendingFormat:@"\nWindow did not exist, allocing"];
         extWindow=[[UIWindow alloc] initWithFrame:[extScreen bounds]];
         
         self.diagnosticLabel.text=[self.diagnosticLabel.text stringByAppendingFormat:@"\nAlloc'd window"];
         [self.extWindow setScreen:extScreen];
         
         diagnosticLabel.text=[self.diagnosticLabel.text stringByAppendingFormat:@"\extImage did not exist, allocing"];
         extImageView=[[UIImageView alloc] initWithFrame:[extScreen bounds]];
         extImageView.contentMode=UIViewContentModeScaleAspectFit;
         diagnosticLabel.text=[self.diagnosticLabel.text stringByAppendingFormat:@"\nAlloc'd extImage"];
         [extWindow addSubview:extImageView];
         [extImageView release];
         [extWindow makeKeyAndVisible];
         }
         }
		 */
		
        // Custom initialization
		
    }  
    return self;
}
-(NSString *) documentsDirectory{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	return [paths objectAtIndex:0];
}

-(void)drawCommand{

    [self.navigationController pushViewController:self.diagramVC animated:YES];
    /*
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.8];	
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.view cache:YES];
	
	if(graphPaperImage.hidden){
        
		NSLog(@"Flip Page and start to draw");
		self.notesTextView.hidden= YES;
		self.poseImageView.hidden= YES;
		self.poseScrollView.hidden = YES;
        self.checkButton.hidden = YES;
		pinchMessageLabel.hidden=YES;
		NSMutableArray *toolBarItems=[[toolbar.items mutableCopy] autorelease];
		[toolBarItems removeObject: changeBookButton];
		[toolBarItems removeObject: choosePhotoBtn];
		toolbar.items=toolBarItems;
		graphPaperImage.hidden=NO;
		drawImage.hidden=NO;
		drawEraseSegmentControl.hidden=NO;
		drawSizeLabel.hidden=NO;
		eraseSizeLabel.hidden=NO;
		drawSizeSlider.hidden=NO;
		eraseSizeSlider.hidden=NO;
		paperBackgroundImage.hidden=NO;
		[self.subView removeGestureRecognizer:rightSwipeRecognizer];
		[self.subView removeGestureRecognizer:swipeLeftRecognizer];
	}else{
		self.notesTextView.hidden= NO;
		self.poseImageView.hidden= NO;
        self.checkButton.hidden = NO;
        self.poseScrollView.hidden = NO;
		graphPaperImage.hidden=YES;
		drawImage.hidden=YES;
		drawEraseSegmentControl.hidden=YES;
		drawSizeLabel.hidden=YES;
		eraseSizeLabel.hidden=YES;
		drawSizeSlider.hidden=YES;
		eraseSizeSlider.hidden=YES;
		paperBackgroundImage.hidden=YES;
		
		NSMutableArray *toolBarItems=[[toolbar.items mutableCopy] autorelease];
		[toolBarItems insertObject:choosePhotoBtn atIndex:2];
		[toolBarItems insertObject:changeBookButton atIndex:3];
		toolbar.items=toolBarItems;
		
		[self.subView addGestureRecognizer:rightSwipeRecognizer];
		[self.subView addGestureRecognizer:swipeLeftRecognizer];
		
		[self.view setNeedsDisplay];
		
	}
    
	
	[UIView commitAnimations];
     */
}

-(void) willAnimateSecondHalfOfRotationFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation duration:(NSTimeInterval)duration{
	
	if((self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) || (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft)){
		/*
		//UIView *notesLabel = [self.view viewWithTag:1];
		self.notesLabel.frame = CGRectMake(680,56,68,35);
		//UIView *notesView = [self.view viewWithTag:2];
		self.notesTextView.frame = CGRectMake(680,88,320,548);
		self.poseImageView.frame = CGRectMake(7,49,657,596);
		self.pageChanger.frame = CGRectMake(847,12,38,36);
		 */
		[self createHorizView];
		
		
	}else if((self.interfaceOrientation == UIInterfaceOrientationPortrait) || (self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)){
		/*
		self.notesLabel.frame = CGRectMake(14,598,68,35);
		//UIView *notesView = [self.view viewWithTag:2];
		self.notesTextView.frame = CGRectMake(14,628,730,264);
		self.poseImageView.frame = CGRectMake(9,56,750,517);
		self.pageChanger.frame = CGRectMake(365,888,38,36);
		 */
		[self createVertView];

	}
		
		
}

-(void) add{
	if(self.popOverController.popoverVisible){
		[self.popOverController dismissPopoverAnimated:YES];
	}else{
        UIBarButtonItem *add = [buttons objectAtIndex:2];
		[self.popOverController presentPopoverFromBarButtonItem:add 
                                       permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
		//[self.popOverController setPopoverContentSize:CGSizeMake(600, 400)];
	}
	
}

-(void) createHorizView{
	/*
	self.notesLabel.frame = CGRectMake(680,56,68,35);
	self.notesTextView.frame = CGRectMake(680,88,320,548);
	self.poseImageView.frame = CGRectMake(9,68,671,364);
	self.pageChanger.frame = CGRectMake(847,12,38,36);	
	 */
	self.notesTextView.frame = CGRectMake(685,20,330,525);
	self.poseImageView.frame = CGRectMake(10,20,660,525);
    self.checkButton.frame = CGRectMake(545, 425, 125, 125);
    self.poseScrollView.frame = CGRectMake(10, 575, self.view.frame.size.width-20, 100);
    self.poseScrollView.hidden = NO;
    //self.poseScrollView.delegate = self;

	if(graphPaperImage.hidden){
		graphPaperImage.hidden=YES;
		drawImage.hidden=YES;
		drawEraseSegmentControl.hidden=YES;
		drawSizeLabel.hidden=YES;
		eraseSizeLabel.hidden=YES;
		drawSizeSlider.hidden=YES;
		eraseSizeSlider.hidden=YES;
		paperBackgroundImage.hidden=YES;
	}else{
		NSLog(@"Flip Page and start to draw");
		self.notesTextView.hidden= YES;
		self.poseImageView.hidden= YES;
		
		pinchMessageLabel.hidden=YES;
		graphPaperImage.hidden=NO;
		drawImage.hidden=NO;
		drawEraseSegmentControl.hidden=NO;
		drawSizeLabel.hidden=NO;
		eraseSizeLabel.hidden=NO;
		drawSizeSlider.hidden=NO;
		eraseSizeSlider.hidden=NO;
		paperBackgroundImage.hidden=NO;	
	}
}

-(void) createVertView{
	/*
	self.notesLabel.frame = CGRectMake(359,598,68,35);
	self.notesTextView.frame = CGRectMake(9,638,750,256);
	self.poseImageView.frame = CGRectMake(9,68,750,500);
	self.pageChanger.frame = CGRectMake(365,888,38,36);
*/
	self.notesTextView.frame = CGRectMake(10,550,750,270);
	self.poseImageView.frame = CGRectMake(10,15,750,520);
    self.poseScrollView.frame = CGRectMake(10, 840, 750, 100);
    self.checkButton.frame = CGRectMake(640, 415, 125, 125);
	if(graphPaperImage.hidden){
		graphPaperImage.hidden=YES;
		drawImage.hidden=YES;
		drawEraseSegmentControl.hidden=YES;
		drawSizeLabel.hidden=YES;
		eraseSizeLabel.hidden=YES;
		drawSizeSlider.hidden=YES;
		eraseSizeSlider.hidden=YES;
		paperBackgroundImage.hidden=YES;
	}else{
		NSLog(@"Flip Page and start to draw");
		self.notesTextView.hidden= YES;
		self.poseImageView.hidden= YES;
		
		pinchMessageLabel.hidden=YES;
		graphPaperImage.hidden=NO;
		drawImage.hidden=NO;
		drawEraseSegmentControl.hidden=NO;
		drawSizeLabel.hidden=NO;
		eraseSizeLabel.hidden=NO;
		drawSizeSlider.hidden=NO;
		eraseSizeSlider.hidden=NO;
		paperBackgroundImage.hidden=NO;	

	}
		

}

-(void) bookPickerShow {
	bookPickerViewController *bookPickVC = [[bookPickerViewController alloc] initWithNibName:@"bookPickerViewController" bundle:nil];
	bookPickVC.delegate = self;
	bookPickVC.managedObjectContext = self.managedObjectContext;
	bookPickVC.selectedPose = self.selectedPose;
 	
	[self presentModalViewController:bookPickVC animated:YES];
	[bookPickVC populatePicker];
	
	
	//	[self.navigationController pushViewController:bookAddVC animated:YES];
	//[self.view addSubview:bookAddVC.view];
	
}

/*
-(void)transitionFlip {
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:1.5];	
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.view cache:YES];
	
	[UIView commitAnimations];
}
*/

-(void)bookWasChosen:(poseBooks *) selectedBook{
	NSLog(@"Chosen book was: %@", selectedBook.name);
	selectedPose.books=[NSSet setWithObject:selectedBook];
	NSError *error;
	if (![self.managedObjectContext save:&error]) NSLog(@"Error: %@", [error localizedDescription]);
	
}

-(void)zoomToPoseImage
{
    NSUserDefaults *prefs= [NSUserDefaults standardUserDefaults];
    NSLog(@"detailVC(handlePinchFrom): Turning off pinchMessage.");
    [prefs setBool:NO forKey:@"displayPinchMessage"];
    [prefs synchronize];
    [self.view bringSubviewToFront:poseImageView];
    [self.view bringSubviewToFront:self.checkButton];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:.8];	
    //		[UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.view cache:YES];
    
    //expand Image 
    self.poseImageView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    self.checkButton.frame = CGRectMake(self.view.frame.size.width-120, self.view.frame.size.height-120, 125, 125);
    [UIView commitAnimations];
    zoomed = YES;
    self.notesTextView.editable = NO;
}
-(void)zoomFromPoseImage
{
    self.poseImageView.layer.cornerRadius = 25.0;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:.8];	
    
    //testView.transform = CGAffineTransformMakeScale(.5, .5);
    if((self.interfaceOrientation == UIInterfaceOrientationPortrait) || (self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)){
        self.poseImageView.frame =  CGRectMake(10,15,750,520);
        self.checkButton.frame = CGRectMake(640, 415, 100, 100);
        self.polaroidImageView.alpha = 1;
    }else if((self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) || (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft)){
        self.poseImageView.frame = CGRectMake(10,20,660,525);
        self.checkButton.frame = CGRectMake(545, 425, 125, 125);
        self.polaroidImageView.alpha = 1;
    }
    [UIView commitAnimations];
    zoomed = NO;
    self.notesTextView.editable = YES;
    
}
-(void)handlePinchFrom:(UIPinchGestureRecognizer *)recognizer {		
	if(recognizer.scale > 1)
    {
		[self zoomToPoseImage];
	}
    else if(recognizer.scale<1)
    {
		[self zoomFromPoseImage];
	}
	

}
							
/*
 In response to a swipe gesture, show the image view appropriately then move the image view in the direction of the swipe as it fades out.
 */
- (void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer {
	
    //[self showImageWithText:@"swipe" atPoint:location];
    if (recognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
		
		[self nextPose:self];
    }
    else if (recognizer.direction == UISwipeGestureRecognizerDirectionRight){
        [self prevPose:self];
    }
}

-(IBAction)sliderChange:(id)sender{
	drawSizeLabel.text=[NSString stringWithFormat:@"Draw Size: %i",(int)drawSizeSlider.value];
	eraseSizeLabel.text=[NSString stringWithFormat:@"Eraser Size: %i",(int)eraseSizeSlider.value];
}

-(IBAction)switchEraseMode:(id)sender{
	if(drawEraseSegmentControl.selectedSegmentIndex==0){
		NSLog(@"detailVC(switchEraseMode): Selected draw mode");
		eraseMode=NO;
	}else if(drawEraseSegmentControl.selectedSegmentIndex==1){
		NSLog(@"detailVC(switchEraseMode): Selected erase mode");
		eraseMode=YES;
	}
	
}

-(void)moveToPoseFromButton:(UIButton *)sender
{
    UIButton *button = sender;
    button.backgroundColor = [UIColor clearColor];
    
    
    NSInteger chosenI = sender.tag;
    if (!zoomed && (self.currentIndexPath.row != chosenI))
    {
    [self saveCurrentPose];
    drawImage.image=nil;
	self.currentIndexPath = [NSIndexPath indexPathForRow:chosenI inSection:currentIndexPath.section];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.8];	
	[UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.view cache:YES];
	for (UIView *extView in extWindow.subviews) {
		[extView removeFromSuperview];
	}
	
    [self populateViewWithPoseItem:self.currentIndexPath];
    [UIView commitAnimations];
    }
}
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.

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
- (void)viewDidLoad 
{
    [super viewDidLoad];
    
    CGRect subFrame;
    if ((self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) || (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft))
    {
        subFrame = CGRectMake(0, 0, self.view.frame.size.width, 560);
    }
    else
    {
        subFrame = CGRectMake(0, 0, self.view.frame.size.width, 820);
    }
    self.subView = [[UIView alloc] initWithFrame:subFrame];
    
    rightSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [self.subView addGestureRecognizer:rightSwipeRecognizer];
    
    self.swipeLeftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    swipeLeftRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.subView addGestureRecognizer:swipeLeftRecognizer];
    
    [self.view addSubview:self.subView];
    
    [self.view bringSubviewToFront:self.checkButton];
    
    [self.navigationController setNavigationBarHidden:NO];
    self.diagramVC.delegate = self;
    self.poseImageView.layer.cornerRadius = 25.0;
    self.poseScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 560, self.view.frame.size.width, 100)];
    UIImageView *poseThumbView;
    UIButton *poseThumbButton;
    self.poseScrollView.layer.cornerRadius = 25.0;
    self.poseScrollView.clipsToBounds = YES;
    NSArray *poses = self.fetchedResultsController.fetchedObjects;
    NSLog(@"%i", poses.count);
    for (int i = 0; i < poses.count; i++) {
        CGFloat xOrigin = i * 125;
        poseThumbView = [[UIImageView alloc] initWithFrame:CGRectMake(xOrigin, 0, 100, 100)];
        poseThumbView.image = [UIImage imageWithData:[[poses objectAtIndex:i] thumbnail]];
        poseThumbView.layer.cornerRadius = 25.0;
        poseThumbView.clipsToBounds = YES;
        poseThumbView.contentMode = UIViewContentModeScaleAspectFill;
        poseThumbView.backgroundColor = [UIColor colorWithRed:0.5/i green:0.5 blue:0.5 alpha:1];
        poseThumbButton = [[UIButton alloc] initWithFrame:CGRectMake(xOrigin, 0, 100, 100)];
        poseThumbButton.layer.cornerRadius = 25.0;
        [poseThumbButton addTarget:self action:@selector(darkenButton:) forControlEvents:UIControlEventTouchDown];
        [poseThumbButton addTarget:self action:@selector(unDarkenButton:) forControlEvents:UIControlEventTouchDragOutside];
        poseThumbButton.tag = i;
        [poseThumbButton addTarget:self action:@selector(moveToPoseFromButton:) forControlEvents:UIControlEventTouchUpInside];
        poseThumbButton.enabled = YES;
        [self.poseScrollView addSubview:poseThumbView];
        [self.poseScrollView addSubview:poseThumbButton];
        
    }
    self.poseScrollView.contentSize = CGSizeMake(125 * poses.count, 100);
    self.notesTextView.layer.cornerRadius = 25.0;
    self.notesTextView.backgroundColor = [[UIColor alloc] initWithRed:0.9 green:0.9 blue:0.9 alpha:0.6];
    self.notesTextView.textColor = [UIColor darkTextColor];
    [self.view bringSubviewToFront:self.notesTextView];
    [self.view addSubview:self.poseScrollView];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
        if (zoomed)
        {
            [self zoomToPoseImage];
        }
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}

-(IBAction) prevPose:(id) sender{

	if(self.currentIndexPath.row >0){
		if (self.activityIndicator.isAnimating == NO) [self.activityIndicator startAnimating];
		
		[self.view bringSubviewToFront:self.activityIndicator];
		[self performSelector:@selector(movePrevious) withObject:nil afterDelay:0];
										
		/*
		[self spinAndSave];
		self.currentIndexPath = [NSIndexPath indexPathForRow:currentIndexPath.row-1 inSection:currentIndexPath.section];
		
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:.8];	
		[UIView setAnimationTransition:UIViewAnimationTransitionCurlDown forView:self.view cache:YES];
		
		[self populateViewWithPoseItem:self.currentIndexPath];
		[UIView commitAnimations];
		 */
	}

}

-(void) movePrevious {
	[self saveCurrentPose];
	drawImage.image=nil;
	self.currentIndexPath = [NSIndexPath indexPathForRow:currentIndexPath.row-1 inSection:currentIndexPath.section];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.8];	
	[UIView setAnimationTransition:UIViewAnimationTransitionCurlDown forView:self.view cache:YES];
	for (UIView *extView in extWindow.subviews) {
		[extView removeFromSuperview];
	}
	
	[self populateViewWithPoseItem:self.currentIndexPath];
	[UIView commitAnimations];
}
	

-(IBAction) nextPose:(id) sender{
	
	if(self.currentIndexPath.row < [[self.fetchedResultsController fetchedObjects] count]-1){
		if (self.activityIndicator.isAnimating == NO) [self.activityIndicator startAnimating];
		[self.view bringSubviewToFront:self.activityIndicator];
		[self performSelector:@selector(moveNext) withObject:nil afterDelay:0];
	}

 }

-(void) moveNext {
	[self saveCurrentPose];
		drawImage.image=nil;
	self.currentIndexPath = [NSIndexPath indexPathForRow:currentIndexPath.row+1 inSection:currentIndexPath.section];
	
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.8];	
	[UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.view cache:YES];
	for (UIView *extView in extWindow.subviews) {
		[extView removeFromSuperview];
	}
	
	[self populateViewWithPoseItem:self.currentIndexPath];
	[UIView commitAnimations];
}



-(IBAction) clearDefaults:(UITextField *) sender{
//	NSLog(@"Sender Name: %i", sender.tag);
//	NSLog(@"Sender text: [%@]", sender.text);
	if(sender.tag == 33){
		if([sender.text isEqualToString:@"New Pose Title"]){
			sender.text=@"";
		}
	}/*else if (sender.tag == 34) && (sender.text == "This is a pose note"){
		sender.text="";
	}*/
	
	
}

-(void)textViewDidBeginEditing:(UITextView *)sender{
//	NSLog(@"Sender Name: %i", sender.tag);
//	NSLog(@"Sender text: [%@]", sender.text);
	if((self.interfaceOrientation == UIInterfaceOrientationPortrait) || (self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)){
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:.8];	
		
		sender.frame=CGRectMake(14, 373, 740, 264);
		[self.view bringSubviewToFront:sender];
		[UIView commitAnimations];
	}
	if(sender.tag == 34){
		if([sender.text isEqualToString:@"This is a pose note"]){
			sender.text=@"";
		}
	}
}

-(void)textViewDidEndEditing:(UITextView *)textView{
		if((self.interfaceOrientation == UIInterfaceOrientationPortrait) || (self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)){
			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationDuration:.8];	
			[UIView	setAnimationDidStopSelector:@selector(sendTextViewToBack:)];
			
            self.notesTextView.frame = CGRectMake(10,550,750,270);
            
//			textView.frame = CGRectMake(14,628,740,264);
			[UIView commitAnimations];

		}
}

-(void)sendTextViewToBack{
			[self.view sendSubviewToBack:notesTextView];	
}
	

-(IBAction) getPhoto:(id) sender{
	if(self.popOverController.popoverVisible){
		[popOverController dismissPopoverAnimated:YES];
	}else{
		[self.popOverController presentPopoverFromBarButtonItem:[self.buttons objectAtIndex:0] permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
		//[self.popOverController setPopoverContentSize:CGSizeMake(600, 400)];
	}
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
	
	poseImageView.image =[info objectForKey:@"UIImagePickerControllerOriginalImage"];
	self.imageChanged = YES;
	//NSString *tempURL = [[NSString alloc] initWithContentsOfURL:[info objectForKey:@"UIImagePickerControllerMediaURL"]];
	
	//NSLog(@"URL: %@", tempURL);
	
//	imageNameTextField.text=tempURL;
	[picker dismissModalViewControllerAnimated:YES];
	[popOverController dismissPopoverAnimated:YES];
	//[tempURL release];
	
}

-(void) populateViewWithPoseItem:(NSIndexPath *) indexPath{
	self.currentIndexPath = indexPath;
	self.selectedPose = [self.fetchedResultsController objectAtIndexPath:currentIndexPath];

	NSLog(@"Pose Title: %@", selectedPose.title);
	NSLog(@"Pose notes: %@", selectedPose.notes);
	NSLog(@"Pose Image Path: %@", selectedPose.imagePath);

	//pageChanger.numberOfPages = [[self.fetchedResultsController fetchedObjects] count];
	//pageChanger.currentPage = self.currentIndexPath.row;

    self.title = self.selectedPose.title;
	notesTextView.text = self.selectedPose.notes;
    if (self.selectedPose.checked)
    {
        checked = true;
        [self.checkButton setImage:[UIImage imageNamed:@"Green-Check.png"] forState:UIControlStateNormal];
    }
    else
    {
        checked = false;
        [self.checkButton setImage:[UIImage imageNamed:@"Gray-Check.png"] forState:UIControlStateNormal];
    }
	if([[NSFileManager defaultManager] fileExistsAtPath:self.selectedPose.imagePath]) {
		poseImageView.image=[UIImage imageWithContentsOfFile:selectedPose.imagePath];
		NSLog(@"dvc (popWithPI): Image Size: %f x %f",poseImageView.image.size.width, poseImageView.image.size.height);
	}else{
		//NSString *imgPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.jpg", fileName]];		
		NSString *fileName =[[[[selectedPose objectID] URIRepresentation] path] substringFromIndex:13];
		NSLog(@"Pose ID: %@", fileName);
		NSString *imgPath = [[self documentsDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.jpg", fileName]];		
		if([[NSFileManager defaultManager] fileExistsAtPath:imgPath]) {
					poseImageView.image=[UIImage imageWithContentsOfFile:imgPath];
		}else{
			poseImageView.image=[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource: @"ImageNotFound"  ofType: @"png"]];
		}
		
	}	
	drawImage.image=[UIImage imageWithData:selectedPose.lightingDiagram];
	[self populateExternalView];
	[self showDiagnostics];
}

-(void) populateExternalView{
/*	
	for (UIScreen *extScreen in UIScreen.screens) {
		if(extScreen != [UIScreen mainScreen]){
			self.diagnosticLabel.text=[self.diagnosticLabel.text stringByAppendingFormat:@"\nTrying to set image for view"];
			extImageView.image=nil;
			if([[NSFileManager defaultManager] fileExistsAtPath:self.selectedPose.imagePath]) {
				extImageView.image=[UIImage imageWithContentsOfFile:selectedPose.imagePath];
				self.diagnosticLabel.text=[self.diagnosticLabel.text stringByAppendingFormat:@"\nTrying to set image for view"];
			}else{
				self.extImageView.image=[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource: @"ImageNotFound"  ofType: @"png"]];
			}
			self.diagnosticLabel.text=[self.diagnosticLabel.text stringByAppendingFormat:@"\nImage Set"];
	
		}
	}
 */
}
-(void)bookAddDidEditName
{
    self.title = [self.selectedPose title];
}
-(void)bookWasCanceled
{
    [self dismissModalViewControllerAnimated:YES];
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    poseSummary *pose = self.selectedPose;
    if (buttonIndex == actionSheet.destructiveButtonIndex)
    {
        //NSLog(@"Delete");
        
        NSManagedObject *goneObject = pose;      
        [self.managedObjectContext deleteObject:goneObject];
        NSError *error;
        if ([managedObjectContext save:&error])
        {
            [actionSheet dismissWithClickedButtonIndex:[actionSheet cancelButtonIndex] animated:YES];
            deleted = YES;
            [self.navigationController popViewControllerAnimated:YES];
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
    else if (buttonIndex == 2){
        [self bookPickerShow];
    }
    menuIsVisible = NO;
}
//-(void)
-(void)poseMenu:(id)sender
{
        if (!menuIsVisible)
        {
            self.menu = [[UIActionSheet alloc] initWithTitle:@"Pose Menu" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"Delete Pose" otherButtonTitles:@"Edit Pose Name",@"Move Pose To New Book", nil];
            self.menu.actionSheetStyle = UIActionSheetStyleBlackOpaque;
            [self.menu showFromBarButtonItem:sender animated:YES];
//            self.menu;
            menuIsVisible = YES;
        }
        else
        {
            NSLog(@"dismiss");
            [self.menu  dismissWithClickedButtonIndex:menu.cancelButtonIndex animated:YES];
            menuIsVisible = NO;
        }
}
-(void) populateViewWithPoseFromObject:(poseSummary *) buttonPose{
	
	self.currentIndexPath = [self.fetchedResultsController indexPathForObject:buttonPose];
	NSLog(@"INdex Path for chosen pose: %@", self.currentIndexPath);
	self.selectedPose = [self.fetchedResultsController objectAtIndexPath:currentIndexPath];
	
	 NSLog(@"Pose Title: %@", selectedPose.title);
	 NSLog(@"Pose notes: %@", selectedPose.notes);
	 NSLog(@"Pose Image Path: %@", selectedPose.imagePath);
	 
	//pageChanger.numberOfPages = [[self.fetchedResultsController fetchedObjects] count];
	//pageChanger.currentPage = self.currentIndexPath.row;
	
    if (self.selectedPose.checked)
    {
        checked = true;
        [self.checkButton setImage:[UIImage imageNamed:@"Green-Check.png"] forState:UIControlStateNormal];
    }
    else
    {
        checked = false;
        [self.checkButton setImage:[UIImage imageNamed:@"Gray-Check.png"] forState:UIControlStateNormal];
    }
    self.title = self.selectedPose.title;
	notesTextView.text = self.selectedPose.notes;
	//UIImage *tempImage;
	if([[NSFileManager defaultManager] fileExistsAtPath:self.selectedPose.imagePath]) {
		//		tempImage = [[UIImage alloc] initWithContentsOfFile:self.selectedPose.imagePath];
		poseImageView.image=[UIImage imageWithContentsOfFile:selectedPose.imagePath];
		NSLog(@"dvc (popWithPI): Image Size: %f x %f",poseImageView.image.size.width, poseImageView.image.size.height);
	}else{
		//		tempImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource: @"ImageNotFound"  ofType: @"png"]];
		//poseImageView.image=[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource: @"ImageNotFound"  ofType: @"png"]];
		//NSString *imgPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.jpg", fileName]];		
		NSString *fileName =[[[[selectedPose objectID] URIRepresentation] path] substringFromIndex:13];
		NSLog(@"Pose ID: %@", fileName);
		NSString *imgPath = [[self documentsDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.jpg", fileName]];		
		if([[NSFileManager defaultManager] fileExistsAtPath:imgPath]) {
			poseImageView.image=[UIImage imageWithContentsOfFile:imgPath];
		}else{
			poseImageView.image=[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource: @"ImageNotFound"  ofType: @"png"]];
		}
		
	}
	//poseImageView.image = tempImage;
	//[tempImage release];
	drawImage.image=[UIImage imageWithData:selectedPose.lightingDiagram ];
	[self populateExternalView];
	[self showDiagnostics];


	
}

-(void) showDiagnostics{
	NSString *currentFile;
	if([[NSFileManager defaultManager] fileExistsAtPath:selectedPose.imagePath]) {
		currentFile = [NSString stringWithFormat:@"Current File:%@ :YES", selectedPose.imagePath];
	}else{
		currentFile = [NSString stringWithFormat:@"Current File:%@ :NO", selectedPose.imagePath];
	}
	diagnosticLabel.text =currentFile;
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *oldPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.jpg", self.selectedPose.title]];
	NSString *oldFile;
	if([[NSFileManager defaultManager] fileExistsAtPath:oldPath]) {
		oldFile = [NSString stringWithFormat:@"Old FileName:%@ :YES", oldPath];
	}else{
		oldFile = [NSString stringWithFormat:@"Old FileName:%@ :NO", oldPath];
	}
	diagnosticLabel.text = [diagnosticLabel.text stringByAppendingFormat:@"\n%@", oldFile];
	
	
	NSString *newFileName=[[[[selectedPose objectID] URIRepresentation] path] substringFromIndex:13];
	NSString *newImgPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.jpg", newFileName]];		
	NSString *newFile;
	if([[NSFileManager defaultManager] fileExistsAtPath:newImgPath]) {
		newFile = [NSString stringWithFormat:@"New FileName:%@ :YES", newImgPath];
	}else{
		newFile = [NSString stringWithFormat:@"New FileName:%@ :NO", newImgPath];
	}
	diagnosticLabel.text = [diagnosticLabel.text stringByAppendingFormat:@"\n%@", newFile];
		
}

-(void) viewWillAppear:(BOOL)animated{
	if((self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) || (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft)){
		[self createHorizView];
	}else if((self.interfaceOrientation == UIInterfaceOrientationPortrait) || (self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)){
		[self createVertView];
        //[self zoomToPoseImage];
	}
    deleted = NO;
	[self.activityIndicator stopAnimating];
	NSUserDefaults *prefs= [NSUserDefaults standardUserDefaults];
	if([prefs boolForKey:@"displayPinchMessage"]){

		myTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(hidePinchMessage) userInfo:nil repeats:NO];

		//[self performSelectorInBackground:@selector(hidePinchMessage) withObject:nil];
	}
    
    UIToolbar* tools = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 167, 44.01)];
    
    // create the array to hold the buttons, which then gets added to the toolbar
    buttons = [[NSMutableArray alloc] initWithCapacity:5];
    
    UIBarButtonItem *bi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(getPhoto:)];
    
    [buttons addObject:bi];
    
    bi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:NULL];
    bi.width=15;
    [buttons addObject:bi];
    
    
    bi = [[UIBarButtonItem alloc] 
                           initWithImage:[UIImage imageNamed:@"draw-icon.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(drawCommand)];
    [buttons addObject:bi];
    
    bi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:NULL];
    bi.width=5;
    [buttons addObject:bi];
    
    bi = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings-icon.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(poseMenu:)];
    [buttons addObject:bi];
    
    // stick the buttons in the toolbar
    [tools setItems:buttons animated:NO];
    tools.barStyle = UIBarStyleBlackOpaque;
    //[buttons release];
    
    // and put the toolbar in the nav bar
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:tools];

    self.checkButton.layer.cornerRadius = 25.0;
    [self.checkButton setBackgroundImage:[UIImage imageNamed:@"Gray-Check.png"] forState:UIControlStateNormal];
    
	[super viewWillAppear:animated];
}

-(void) hidePinchMessage{
		pinchMessageLabel.hidden=YES;
}

-(void) saveCurrentPose{
	NSError *error;
    
    if (checked)
    {
        self.selectedPose.checked = [NSNumber numberWithInt:1];
        [self checkButtonPressed:self.checkButton];
    }
    else
    {
        self.selectedPose.checked = 0;
    }
    NSError *checkError;
    [self.managedObjectContext save:&checkError];
	if(![self.selectedPose.notes isEqualToString:notesTextView.text] 
	   || self.imageChanged){
	
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [paths objectAtIndex:0];

		
		CGSize iconSize;
		iconSize.width=200;
		iconSize.height=200;
		UIGraphicsBeginImageContext(iconSize); 
		[poseImageView.image drawInRect:CGRectMake(0, 0, iconSize.width, iconSize.height)]; 
		UIImage *iconImg = UIGraphicsGetImageFromCurrentImageContext (); 
		UIGraphicsEndImageContext();
		
		poseImageView.image = [poseImageView.image resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake([UIScreen mainScreen].applicationFrame.size.width , [UIScreen mainScreen].applicationFrame.size.height) interpolationQuality:kCGInterpolationHigh];

		
		NSString *oldPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.jpg", self.selectedPose.title]];
	
		/*if(![titleTextField.text isEqualToString:@""]){
			self.selectedPose.title=titleTextField.text;
		}*/
		NSString *fileName =[[[[selectedPose objectID] URIRepresentation] path] substringFromIndex:13];
		NSLog(@"Pose ID: %@", fileName);
		NSString *imgPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.jpg", fileName]];		
		//If name has changed, move photo
		if(![[selectedPose objectID] isTemporaryID]){
			if([[NSFileManager defaultManager] fileExistsAtPath:imgPath]){
				if(![[NSFileManager	defaultManager] moveItemAtPath:oldPath toPath:imgPath error:&error]) NSLog(@"Error moving old file: %@ (%@)",oldPath,[error localizedDescription]);
			}
		}
		/*if(![titleTextField.text isEqualToString:@""]){
			self.selectedPose.title=titleTextField.text;
		}*/
		

		
		self.selectedPose.notes=notesTextView.text;
		
		
		NSData *data =  UIImageJPEGRepresentation(poseImageView.image, .7);
		[data writeToFile:imgPath atomically:YES];

		
		self.selectedPose.thumbnail=UIImageJPEGRepresentation(iconImg, .7);
		
		selectedPose.lightingDiagram=UIImagePNGRepresentation(drawImage.image);
		NSLog(@"DrawImage.Image= %@", drawImage.image);
		self.selectedPose.imagePath=imgPath;

		/*
		NSLog(@"Pose Title: %@", selectedPose.title);
		NSLog(@"Pose notes: %@", self.selectedPose.notes);
		NSLog(@"Pose Image Path: %@", self.selectedPose.imagePath);
		*/
		
		if (![self.managedObjectContext save:&error]) NSLog(@"Error: %@", [error localizedDescription]);
//		if (![self.fetchedResultsController performFetch:&error]) NSLog(@"Error re-fetching results: %@", [error localizedDescription]);
		
	}
	self.imageChanged = NO;

	 if (self.activityIndicator.isAnimating) [self.activityIndicator stopAnimating];
	
}

-(void) viewWillDisappear:(BOOL)animated{
	if (self.activityIndicator.isAnimating == NO) [self.activityIndicator startAnimating];
	[self.view bringSubviewToFront:self.activityIndicator];
//[self performSelector:@selector(saveCurrentPose) withObject:nil afterDelay:0];
//	[self spinAndSave];
    if (!deleted)
    {
        [self saveCurrentPose];
    }
	[super viewWillDisappear:animated];
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    self.diagramVC = nil;
    self.poseScrollView = nil;
    self.subView = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    
    //[[NSNotificationCenter defaultCenter] removeObserver:self];
    //[[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
	
	
	
	
	
	
	
	
	
	
	extImageView.image=nil;
	
}


@end
