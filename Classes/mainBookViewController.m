//
//  mainBookViewController.m
//  PosePad
//
//  Created by shawn on 4/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "mainBookViewController.h"
#import "poseBooks.h"
#import "bookAddViewController.h"



@implementation mainBookViewController

@synthesize managedObjectContext;
@synthesize fetchedResultsController;
@synthesize navBar;

@synthesize delegate;

#pragma mark -
#pragma mark Initialization


- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if ((self = [super initWithStyle:style])) {
			[self createView];
    }
	

    return self;
}

-(void) createView{
	self.title = @"Book List";

	//UINavigationBar *navBar = [[UINavigationBar alloc] init];
	self.navigationItem.rightBarButtonItem = self.editButtonItem;
	UIBarButtonItem *addButton = [[UIBarButtonItem alloc] 
								  initWithBarButtonSystemItem:UIBarButtonSystemItemAdd 
								  target:self 
								  action:@selector(add)];
	UIBarButtonItem *flexSpace =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	
	self.navigationItem.leftBarButtonItem=addButton;
	
	UIToolbar *toolBar = [UIToolbar new];
	toolBar.barStyle = UIBarStyleDefault;
	NSArray *items=[NSArray arrayWithObjects:addButton,flexSpace,self.editButtonItem,  nil];
	[toolBar setItems:items animated:NO];
	
	[toolBar sizeToFit];
    CGFloat toolbarHeight = [toolBar frame].size.height;
//    CGRect mainViewBounds = self.view.bounds;
	[toolBar setFrame:CGRectMake(0,
								 0,
                                 300,
                                 toolbarHeight)];
	//[self.tableView sizeToFit];
	   
    //[self.view addSubview:toolBar];
//	[self.tableView removeFromSuperview];
	[self.tableView setFrame:CGRectMake(0, toolbarHeight, 50, 600)];
	[self.tableView sizeToFit];
//	[self.view addSubview:self.tableView];

	


	[addButton release];
	[flexSpace release];
	
}

-(void)bookWasAdded{
	[self fetchResults];
	[self.tableView reloadData];
}

-(void) add{
	bookAddViewController *bookAddVC = [[bookAddViewController alloc] initWithNibName:@"bookAddViewController" bundle:nil];
	bookAddVC.delegate = self;
	bookAddVC.managedObjectContext = managedObjectContext;
	bookAddVC.fetchedResultsController = fetchedResultsController;
 	
	[self presentModalViewController:bookAddVC animated:YES];

	
//	[self.navigationController pushViewController:bookAddVC animated:YES];
	//[self.view addSubview:bookAddVC.view];
	[bookAddVC release];

}



-(void) fetchResults{
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"poseBooks" inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];
	[request setPredicate:nil];
	
	// Order the events by creation date, most recent first.
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[request setSortDescriptors:sortDescriptors];
	[sortDescriptor release];
	[sortDescriptors release];
	
	if(self.fetchedResultsController == NULL){
		self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
	}else{
		[self.fetchedResultsController initWithFetchRequest:request managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
	}
    self.fetchedResultsController.delegate = self;
	
	
	NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) NSLog(@"Error Fetching: %@", [error localizedDescription]);	
	NSLog(@"mainBookVC:(fetchResults)Found %i books", [[fetchedResultsController fetchedObjects] count]);
	[request release];
	
//	[self.fetchedResultsController release];
	
}





#pragma mark -
#pragma mark View lifecycle

/*
- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
*/


- (void)viewWillAppear:(BOOL)animated {
	[self fetchResults];
	
	//	NSError *error;
	//	if (![[self fetchedResultsController] performFetch:&error]) NSLog(@"Error Fetching: %@", [error localizedDescription]);	
	
	[self.tableView reloadData];
	
    
	[super viewWillAppear:animated];
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Override to allow orientations other than the default portrait orientation.
    return YES;
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
        return [[self.fetchedResultsController sections] count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
	
	NSLog(@"%i Rows", [sectionInfo numberOfObjects]);
	return [sectionInfo numberOfObjects];
	//return [[self.fetchedResultsController fetchedObjects] count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    poseBooks *poseBook = [self.fetchedResultsController objectAtIndexPath:indexPath];
	cell.textLabel.text = poseBook.name;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	/*
	 NSLog(@"Pose Title: %@", poseInfo.title);
	 NSLog(@"Pose notes: %@", poseInfo.notes);
	 NSLog(@"Pose sortIndex: %@", poseInfo.sortIndex);
	 */
		
    // Configure the cell...
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) 
	{
		[managedObjectContext deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
		NSError *error;
		if(![managedObjectContext save:&error]) NSLog(@"Error Saving After Delete: %@", [error localizedDescription]);
		
		if (![[self fetchedResultsController] performFetch:&error]) NSLog(@"Error Fetching: %@", [error localizedDescription]);	
		
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
		//		[self.tableView reloadData];
		
	}
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	
	poseBooks *selectedBook = [self.fetchedResultsController objectAtIndexPath:indexPath];
	NSLog(@"(didSelectRowAtIndexPath) Selected book: %@", selectedBook.name);
	[delegate bookWasSelected:selectedBook];
	
	
	/*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end

