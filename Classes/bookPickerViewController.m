    //
//  bookPickerViewController.m
//  PosePad
//
//  Created by shawn on 4/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "bookPickerViewController.h"
#import "poseBooks.h"
#import "poseSummary.h"


@implementation bookPickerViewController

@synthesize savePoseButton,selectBookLabel,pickerView;
@synthesize managedObjectContext,fetchedResultsController,selectedPose;
@synthesize delegate;

@synthesize books;


 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
		[self createView];

    }
    return self;
}

-(void) createView{
	//self.selectBookLabel.text = [NSString initWithFormat:@"Select book for %@ pose:", selectedPose.title];
	
	[self.view addSubview:pickerView];
	
}

-(void) populatePicker{
	[self fetchBooks];
	self.books = [[fetchedResultsController fetchedObjects] mutableCopy];
	self.selectBookLabel.text = [NSString stringWithFormat:@"Select pose book for %@ pose:", self.selectedPose.title];
	self.pickerView.hidden=NO;
	[self.pickerView reloadAllComponents];
	NSSet *booksPoses = [selectedPose valueForKeyPath:@"books"];
	NSInteger bookIndex=[self.books indexOfObject:[booksPoses anyObject]];
	NSLog(@"Pose is at %i book", bookIndex);

	
	
	

	self.pickerView.delegate=self;	
}

-(void) viewDidAppear:(BOOL)animated{
	self.pickerView.showsSelectionIndicator = YES;
	NSSet *booksPoses = [self.selectedPose valueForKeyPath:@"books"];
	NSInteger bookIndex=[self.books indexOfObject:[booksPoses anyObject]];
	NSLog(@"Pose is at %i book", bookIndex);
	
	[self.pickerView selectRow:[self.books indexOfObject:[booksPoses anyObject]] inComponent:0 animated:YES];
}

-(IBAction) savePose:(id) sender{
	poseBooks *selectedBook = [self.books objectAtIndex:[pickerView selectedRowInComponent:0]];
	[delegate bookWasChosen:selectedBook];
	[self dismissModalViewControllerAnimated:YES];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	self.title=@"Select Book";
    [super viewDidLoad];
}



-(NSInteger) numberofComponentsInPickerView:(UIPickerView *) pickerView{
	return 5;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
	if(self.books!=nil){
		return [self.books count];
	}
	return 0;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
	poseBooks *poseBook=[self.books objectAtIndex:row];
	return poseBook.name;

}

-(void) fetchBooks{
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"poseBooks" inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];
	
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[request setSortDescriptors:sortDescriptors];
	
	if(self.fetchedResultsController == NULL){
		
		self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:@"BooksPicker"];
	}else{
		[self.fetchedResultsController initWithFetchRequest:request managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:@"BooksPicker"];
	}
    self.fetchedResultsController.delegate = self;
	
	NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) NSLog(@"Error Fetching: %@", [error localizedDescription]);	
	NSLog(@"bookPickerVC:(fetchResults)Found %i books", [[fetchedResultsController fetchedObjects] count]);	
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
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
