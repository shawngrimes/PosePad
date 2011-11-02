    //
//  bookAddViewController.m
//  PosePad
//
//  Created by shawn on 4/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "bookAddViewController.h"
#import "poseBooks.h"



@implementation bookAddViewController

@synthesize bookNameTextField;
@synthesize managedObjectContext;
@synthesize fetchedResultsController;
@synthesize saveBookButton;
@synthesize bookNameLabel;

@synthesize delegate;
@synthesize isAdd, book;


 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization

    }
    self.isAdd = YES;
    return self;
}
- (id)initWithPosebook:(poseBooks *)bookHere
{
    self = [super init];
    if (self)
    {
        self.isAdd = NO;
        self.book = bookHere;
    }
    return self;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.isAdd)
        self.title=@"New Book";
    else
        self.title = @"Edit Book Name";
    self.bookNameTextField.text = self.book.name;
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
    if (self.isAdd)
    {
	NSLog(@"Save Book: %@", self.bookNameTextField);
	if(!(([self.bookNameTextField.text isEqualToString:@""] )|| (self.bookNameTextField.text == nil)))
    {
		poseBooks *newBook = (poseBooks	*)[NSEntityDescription insertNewObjectForEntityForName:@"poseBooks" inManagedObjectContext:managedObjectContext];
		newBook.name =self.bookNameTextField.text;
		
		NSError *error;
		if (![self.managedObjectContext save:&error]) NSLog(@"Error: %@", [error localizedDescription]);
	
        if(self.delegate != NULL){
            [delegate bookWasAdded];
        }
        [self dismissModalViewControllerAnimated:YES];
    }

		//[self fetchResults];
		
		//[self.tableView reloadData];
		
		//[newBook release];
	
    }
    else
    {
        NSString *name = self.bookNameTextField.text;
        [self.book setName:name];
        [self.delegate bookAddDidEditName];
        [self dismissModalViewControllerAnimated:YES];
    }
    
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
