    //
//  bookAddViewController.m
//  PosePad
//
//  Created by shawn on 4/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "bookAddViewController.h"
#import "poseBooks.h"
#import "mainBookViewController.h"



@implementation bookAddViewController

@synthesize bookNameTextField;
@synthesize managedObjectContext;
@synthesize fetchedResultsController;
@synthesize saveBookButton;
@synthesize bookNameLabel;

@synthesize delegate;



 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization

    }
    return self;
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	self.title=@"New Book";
    [super viewDidLoad];
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}

-(IBAction) saveBook:(id) sender{
	NSLog(@"Save Book: %@", self.bookNameTextField);
	if(![self.bookNameTextField.text isEqualToString:@""] ){
		poseBooks *newBook = (poseBooks	*)[NSEntityDescription insertNewObjectForEntityForName:@"poseBooks" inManagedObjectContext:managedObjectContext];
		newBook.name =self.bookNameTextField.text;
		
		NSError *error;
		if (![self.managedObjectContext save:&error]) NSLog(@"Error: %@", [error localizedDescription]);
	}

		//[self fetchResults];
		
		//[self.tableView reloadData];
		
		//[newBook release];
	if(self.delegate != NULL){
		[delegate bookWasAdded];
	}
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


- (void)dealloc {
	[bookNameTextField release];
	[managedObjectContext release];
	[fetchedResultsController release];
	[saveBookButton release];
	[bookNameLabel release];
    [super dealloc];
}


@end
