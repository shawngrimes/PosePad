//
//  bookAddViewController.m
//  PosePad
//
//  Created by shawn on 4/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "poseEditViewController.h"
#import "poseBooks.h"
#import "poseSummary.h"



@implementation poseEditViewController

@synthesize bookNameTextField;
@synthesize managedObjectContext;
@synthesize fetchedResultsController;
@synthesize saveBookButton;
@synthesize bookNameLabel;

@synthesize delegate;
@synthesize pose;


// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
        
    }
    return self;
}
- (id)initWithPose:(poseSummary *)poseHere
{
    self = [super init];
    if (self)
    {
        self.pose = poseHere;
    }
    return self;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Edit Pose Name";
    self.bookNameTextField.text = self.pose.title;
    self.bookNameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}
-(IBAction)cancel:(id)sender
{
    [self.delegate bookWasCanceled];
}
-(IBAction) saveBook:(id) sender{
   
    NSString *name = self.bookNameTextField.text;
    self.pose.title=name;
    [self.delegate bookAddDidEditName];
    
	[self dismissModalViewControllerAnimated:YES];
    
    //		
	
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




@end
