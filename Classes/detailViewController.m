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


@implementation detailViewController

@synthesize pageChanger,pinchRecognizer,nextPoseBtn,prevPoseBtn,toolbar,swipeLeftRecognizer,titleLabel,notesLabel,choosePhotoBtn,titleTextField,notesTextView,poseImageView,popOverController;
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




 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {

		/*
		 Create a swipe gesture recognizer to recognize right swipes (the default).
		 We're only interested in receiving messages from this recognizer, and the view will take ownership of it, so we don't need to keep a reference to it.
		 */
		rightSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
		[self.view addGestureRecognizer:rightSwipeRecognizer];
		
		/*
		 Create a swipe gesture recognizer to recognize left swipes.
		 Keep a reference to the recognizer so that it can be added to and removed from the view in takeLeftSwipeRecognitionEnabledFrom:.
		 Add the recognizer to the view if the segmented control shows that left swipe recognition is allowed.
		 */
		
		self.swipeLeftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
		swipeLeftRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
		
		[self.view addGestureRecognizer:swipeLeftRecognizer];
		
		UIGestureRecognizer *recognizer;
		recognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchFrom:)];
		[self.view addGestureRecognizer:recognizer];
		
		self.pinchRecognizer = ((UIPinchGestureRecognizer *)recognizer);
		[recognizer release];
		
		UIImagePickerController *picker =[[UIImagePickerController alloc] init];
		picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
		picker.delegate = self;
		
		UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:picker];
		self.popOverController = popover;
		popOverController.delegate = self;
		
		[picker release];
		[popover release];
		
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

	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.8];	
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.view cache:YES];
	
	if(graphPaperImage.hidden){
	
		NSLog(@"Flip Page and start to draw");
		self.notesLabel.hidden= YES;
		self.notesTextView.hidden= YES;
		self.poseImageView.hidden= YES;
		
		pinchMessageLabel.hidden=YES;
		titleLabel.hidden=YES;
		titleTextField.hidden=YES;
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
		[self.view removeGestureRecognizer:rightSwipeRecognizer];
		[self.view removeGestureRecognizer:swipeLeftRecognizer];
	}else{
		self.notesLabel.hidden= NO;
		self.notesTextView.hidden= NO;
		self.poseImageView.hidden= NO;
		titleLabel.hidden=NO;
		titleTextField.hidden=NO;
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
		
		[self.view addGestureRecognizer:rightSwipeRecognizer];
		[self.view addGestureRecognizer:swipeLeftRecognizer];
		
		[self.view setNeedsDisplay];
		
	}
		
	
	[UIView commitAnimations];
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

-(void) createHorizView{
	/*
	self.notesLabel.frame = CGRectMake(680,56,68,35);
	self.notesTextView.frame = CGRectMake(680,88,320,548);
	self.poseImageView.frame = CGRectMake(9,68,671,364);
	self.pageChanger.frame = CGRectMake(847,12,38,36);	
	 */
	self.notesLabel.frame = CGRectMake(680,56,68,35);
	self.notesTextView.frame = CGRectMake(680,88,320,548);
	self.poseImageView.frame = CGRectMake(7,49,657,596);
	self.pageChanger.frame = CGRectMake(847,12,38,36);
	self.pageChanger.hidden=YES;

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
		self.notesLabel.hidden= YES;
		self.notesTextView.hidden= YES;
		self.poseImageView.hidden= YES;
		
		pinchMessageLabel.hidden=YES;
		titleLabel.hidden=YES;
		titleTextField.hidden=YES;
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
	self.notesLabel.frame = CGRectMake(14,598,68,35);
	self.notesTextView.frame = CGRectMake(14,628,740,264);
	self.poseImageView.frame = CGRectMake(9,56,750,517);
	self.pageChanger.frame = CGRectMake(365,888,38,36);
	self.pageChanger.hidden=NO;
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
		self.notesLabel.hidden= YES;
		self.notesTextView.hidden= YES;
		self.poseImageView.hidden= YES;
		
		pinchMessageLabel.hidden=YES;
		titleLabel.hidden=YES;
		titleTextField.hidden=YES;
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

-(IBAction) bookPickerShow:(id) sender {
	bookPickerViewController *bookPickVC = [[bookPickerViewController alloc] initWithNibName:@"bookPickerViewController" bundle:nil];
	bookPickVC.delegate = self;
	bookPickVC.managedObjectContext = self.managedObjectContext;
	bookPickVC.selectedPose = self.selectedPose;
 	
	[self presentModalViewController:bookPickVC animated:YES];
	[bookPickVC populatePicker];
	
	
	//	[self.navigationController pushViewController:bookAddVC animated:YES];
	//[self.view addSubview:bookAddVC.view];
	[bookPickVC release];
	
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

		 
-(void)handlePinchFrom:(UIPinchGestureRecognizer *)recognizer {		
	if(recognizer.scale > 1){
		NSUserDefaults *prefs= [NSUserDefaults standardUserDefaults];
		NSLog(@"detailVC(handlePinchFrom): Turning off pinchMessage.");
		[prefs setBool:NO forKey:@"displayPinchMessage"];
		[prefs synchronize];
		[self.view bringSubviewToFront:poseImageView];
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:.8];	
//		[UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.view cache:YES];
		
		//expand Image 
		if((self.interfaceOrientation == UIInterfaceOrientationPortrait) || (self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)){
			self.poseImageView.frame = CGRectMake(0, 0, 780, 900);

		}else if((self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) || (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft)){
			self.poseImageView.frame = CGRectMake(0, 0, 1024, 660);
		}
		
		[UIView commitAnimations];
		
//		testView.transform = CGAffineTransformMakeScale(2, 2);
		//NSLog(@"Expand pinch: %f",test);
//		[testView release];
	}else if(recognizer.scale<1){
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:.8];	

		//testView.transform = CGAffineTransformMakeScale(.5, .5);
		if((self.interfaceOrientation == UIInterfaceOrientationPortrait) || (self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)){
			self.poseImageView.frame =  CGRectMake(9,56,750,517);
			self.polaroidImageView.alpha = 1;
		}else if((self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) || (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft)){
			self.poseImageView.frame = CGRectMake(7,49,657,596);
			self.polaroidImageView.alpha = 1;
		}
		[UIView commitAnimations];
		
//		NSLog(@"Shrink pinch: %f",test);
		//shrink image
//		[testView release];
	}
	

}
							
/*
 In response to a swipe gesture, show the image view appropriately then move the image view in the direction of the swipe as it fades out.
 */
- (void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer {
	
    //[self showImageWithText:@"swipe" atPoint:location];
    if (recognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
		
		[self nextPose:self ];
    }
    else if (recognizer.direction == UISwipeGestureRecognizerDirectionRight){
        [self prevPose:self];
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	if(graphPaperImage.hidden==NO){
		UITouch *touch=[touches anyObject];
		lastPoint=[touch locationInView:self.view];
		//lastPoint.y-=20;
	}
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
	if(graphPaperImage.hidden==NO){
		imageChanged=YES;
		UITouch *touch=[touches anyObject];
		CGPoint currentPoint=[touch locationInView:self.view];
		currentPoint.x -=10;
		
		if(CGRectContainsPoint(graphPaperImage.frame, currentPoint))
		{
		
			UIGraphicsBeginImageContext(drawImage.frame.size);
			[drawImage.image drawInRect:CGRectMake(0, 0, drawImage.frame.size.width, drawImage.frame.size.height)];
			CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
			CGContextSetLineWidth(UIGraphicsGetCurrentContext(),drawSizeSlider.value);
			if(eraseMode){
				NSInteger halfEraserSize=(eraseSizeSlider.value/2);
				NSLog(@"Eraser Size: %i", halfEraserSize);
				//NSLog(@"Current X: %i Half Current X: %i",currentPoint.x, currentPoint.x-halfEraserSize);
				CGContextClearRect(UIGraphicsGetCurrentContext(), CGRectMake(currentPoint.x - halfEraserSize, currentPoint.y - halfEraserSize, eraseSizeSlider.value,eraseSizeSlider.value));
			}else{
				CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0, 0, 0, 1.0);
				CGContextBeginPath(UIGraphicsGetCurrentContext());
				CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
				CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
				CGContextStrokePath(UIGraphicsGetCurrentContext());
			}
			drawImage.image=UIGraphicsGetImageFromCurrentImageContext();
			UIGraphicsEndImageContext();
			lastPoint=currentPoint;
		}
	}
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	if(graphPaperImage.hidden==NO){
		imageChanged=YES;
		UITouch *touch=[touches anyObject];
		CGPoint currentPoint=[touch locationInView:self.view];
		currentPoint.x -=10;
		
		if(CGRectContainsPoint(graphPaperImage.frame, currentPoint))
		{
		
			UIGraphicsBeginImageContext(drawImage.frame.size);
			[drawImage.image drawInRect:CGRectMake(0, 0, drawImage.frame.size.width, drawImage.frame.size.height)];
			CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
			CGContextSetLineWidth(UIGraphicsGetCurrentContext(),drawSizeSlider.value);
			if(eraseMode){
				NSInteger halfEraserSize=(eraseSizeSlider.value/2);
				NSLog(@"Eraser Size: %i", halfEraserSize);
				//NSLog(@"Current X: %f Half Current X: %f",currentPoint.x, currentPoint.x-halfEraserSize);
				CGContextClearRect(UIGraphicsGetCurrentContext(), CGRectMake(currentPoint.x - halfEraserSize, currentPoint.y - halfEraserSize, eraseSizeSlider.value,eraseSizeSlider.value));
			}else{
				CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0, 0, 0, 1.0);
				CGContextBeginPath(UIGraphicsGetCurrentContext());
				CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
				CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
				CGContextStrokePath(UIGraphicsGetCurrentContext());
			}
			CGContextFlush(UIGraphicsGetCurrentContext());
			drawImage.image=UIGraphicsGetImageFromCurrentImageContext();
			UIGraphicsEndImageContext();
		}
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

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
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
			
			textView.frame = CGRectMake(14,628,740,264);
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
		[self.popOverController presentPopoverFromBarButtonItem:choosePhotoBtn permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
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

	pageChanger.numberOfPages = [[self.fetchedResultsController fetchedObjects] count];
	pageChanger.currentPage = self.currentIndexPath.row;

	
	titleTextField.text = self.selectedPose.title;
	notesTextView.text = self.selectedPose.notes;
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

-(void) populateViewWithPoseFromObject:(poseSummary *) buttonPose{
	
	self.currentIndexPath = [self.fetchedResultsController indexPathForObject:buttonPose];
	NSLog(@"INdex Path for chosen pose: %@", self.currentIndexPath);
	self.selectedPose = [self.fetchedResultsController objectAtIndexPath:currentIndexPath];
	
	 NSLog(@"Pose Title: %@", selectedPose.title);
	 NSLog(@"Pose notes: %@", selectedPose.notes);
	 NSLog(@"Pose Image Path: %@", selectedPose.imagePath);
	 
	pageChanger.numberOfPages = [[self.fetchedResultsController fetchedObjects] count];
	pageChanger.currentPage = self.currentIndexPath.row;
	
	
	titleTextField.text = self.selectedPose.title;
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
	}
	[self.activityIndicator stopAnimating];
	NSUserDefaults *prefs= [NSUserDefaults standardUserDefaults];
	if([prefs boolForKey:@"displayPinchMessage"]){

		myTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(hidePinchMessage) userInfo:nil repeats:NO];

		//[self performSelectorInBackground:@selector(hidePinchMessage) withObject:nil];
	}

	[super viewWillAppear:animated];
}

-(void) hidePinchMessage{
		pinchMessageLabel.hidden=YES;
}

-(void) saveCurrentPose{
	NSError *error;
	if(![self.selectedPose.title isEqualToString:titleTextField.text] 
	   || ![self.selectedPose.notes isEqualToString:notesTextView.text] 
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
	
		if(![titleTextField.text isEqualToString:@""]){
			self.selectedPose.title=titleTextField.text;
		}
		NSString *fileName =[[[[selectedPose objectID] URIRepresentation] path] substringFromIndex:13];
		NSLog(@"Pose ID: %@", fileName);
		NSString *imgPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.jpg", fileName]];		
		//If name has changed, move photo
		if(![[selectedPose objectID] isTemporaryID]){
			if([[NSFileManager defaultManager] fileExistsAtPath:imgPath]){
				if(![[NSFileManager	defaultManager] moveItemAtPath:oldPath toPath:imgPath error:&error]) NSLog(@"Error moving old file: %@ (%@)",oldPath,[error localizedDescription]);
			}
		}
		if(![titleTextField.text isEqualToString:@""]){
			self.selectedPose.title=titleTextField.text;
		}
		

		
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
	[self saveCurrentPose];
	[super viewWillDisappear:animated];
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [titleLabel release];
	[notesLabel release];
	[titleTextField release];
	[imageNameTextField release];
	[notesTextView release];
	[poseImageView release];
	[polaroidImageView release];
	[choosePhotoBtn release];
	[nextPoseBtn release];
	[prevPoseBtn release];
	[popOverController release];
	[toolbar release];
	[pageChanger release];
	
	[currentIndexPath release];
	
	[rightSwipeRecognizer release];
	[swipeLeftRecognizer release];
	[pinchRecognizer release];
	
	[managedObjectContext release];
	[fetchedResultsController release];
	
	[activityIndicator release];
	
	[changeBookButton release];
	
	
	
	[pinchMessageLabel release];
	
	[graphPaperImage release];
	[paperBackgroundImage release];
	[drawImage release];
	[drawEraseSegmentControl release];
	[drawSizeLabel release];
	[eraseSizeLabel release];
	[drawSizeSlider release];
	[eraseSizeSlider release];
	
	[extWindow release];
	extImageView.image=nil;
	[extImageView release];
	[diagnosticLabel release];
	
    [super dealloc];
}


@end
