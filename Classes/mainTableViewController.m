//
//  mainTableViewController.m
//  Poser
//
//  Created by shawn on 3/24/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "mainTableViewController.h"
#import "PoseBookAppDelegate.h"
#import "poseSummary.h"
#import "detailViewController.h"
#import "poseBooks.h"

#import "UIImage+Resize.h"

@implementation mainTableViewController


@synthesize managedObjectContext;
@synthesize fetchedResultsController;

@synthesize popOverController;

@synthesize selectedBook;

detailViewController *dvc;

#pragma mark -
#pragma mark Initialization


- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
	if((self=[super initWithStyle:style])){
		//[super viewDidLoad];
		[self createView];
		
		UIImagePickerController *picker =[[UIImagePickerController alloc] init];
		picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
		picker.delegate = self;
		
		UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:picker];
		self.popOverController = popover;
		popOverController.delegate = self;

		[picker release];
		[popover release];
	}	
    return self;
}


-(void) createView{
	self.title = @"Pose List";
	self.navigationItem.rightBarButtonItem = self.editButtonItem;

	UIBarButtonItem *addButton = [[UIBarButtonItem alloc] 
								  initWithBarButtonSystemItem:UIBarButtonSystemItemAdd 
								  target:self 
								  action:@selector(add)];
	UIBarButtonItem *flexSpace=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	
	NSArray *items=[NSArray arrayWithObjects:flexSpace, addButton, flexSpace, nil];
	[self setToolbarItems:items];
	[self.navigationController setToolbarHidden:NO animated:YES];

	[addButton release];
	[flexSpace release];
	
	
    
	
}

-(void) returnThumbnailView{
	[self.navigationController setToolbarHidden:YES];
	[self.view removeFromSuperview];
	
}

-(void) add{
	if(self.popOverController.popoverVisible){
		[self.popOverController dismissPopoverAnimated:YES];
	}else{
		[self.popOverController presentPopoverFromBarButtonItem:[self.toolbarItems objectAtIndex:1] permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
		//[self.popOverController setPopoverContentSize:CGSizeMake(600, 400)];
	}
	
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
	
	NSLog(@"Selected Image: %@", [info objectForKey:@"UIImagePickerControllerOriginalImage"]);
	
	poseSummary *newPose = (poseSummary *)[NSEntityDescription insertNewObjectForEntityForName:@"poseSummary" inManagedObjectContext:managedObjectContext];
	newPose.title =@ "New Pose Title";
	
	
	//NSString  *path = [[NSBundle mainBundle] pathForResource: @"NewPose"  ofType: @"png"];
	//UIImage *tempImage = [[UIImage alloc] initWithContentsOfFile: path];
	//UIImage *tempImage = [[UIImage alloc] init];
	UIImage *tempImage=[info objectForKey:@"UIImagePickerControllerOriginalImage"];
	//Resize to screen size
	tempImage = [tempImage resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake([UIScreen mainScreen].applicationFrame.size.width , [UIScreen mainScreen].applicationFrame.size.height) interpolationQuality:kCGInterpolationHigh];

	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	if (!documentsDirectory) {
		NSLog(@"Documents directory not found!");
	}
	
	//Set filename to objectID
	NSString *fileName =[[[[newPose objectID] URIRepresentation] path] substringFromIndex:13];
	NSString *imgPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.jpg", fileName]];
	if(![[NSFileManager defaultManager] fileExistsAtPath:imgPath]) {
		NSData *data =  UIImageJPEGRepresentation(tempImage,.7);
		[data writeToFile:imgPath atomically:YES];
	}
	
	CGSize iconSize;
	iconSize.width=200;
	iconSize.height=200;
	
	UIGraphicsBeginImageContext(iconSize); 
	[tempImage drawInRect:CGRectMake(0, 0, iconSize.width, iconSize.height)]; 
	UIImage *iconImg = UIGraphicsGetImageFromCurrentImageContext (); 
	UIGraphicsEndImageContext();
	
	newPose.thumbnail = UIImageJPEGRepresentation(iconImg,.7);
	//NSLog(@"Number of objects: %i", [[self.fetchedResultsController fetchedObjects] count]);
	newPose.sortIndex = [NSNumber numberWithInt:[[self.fetchedResultsController fetchedObjects] count]];
	newPose.imagePath = imgPath;
	[newPose addBooks:[NSSet setWithObject:self.selectedBook]];
	
	NSError *error;
	if (![self.managedObjectContext save:&error]) NSLog(@"Error: %@", [error localizedDescription]);
	
	[self fetchResults];
	
	[self.tableView reloadData];
	
	//[tempImage release];
	
	//[self openDetailsForPoseAtIndexPath:[NSIndexPath indexPathForRow:[[self.fetchedResultsController fetchedObjects]count]-1 inSection:0]];
	
	
	
	//NSString *tempURL = [[NSString alloc] initWithContentsOfURL:[info objectForKey:@"UIImagePickerControllerMediaURL"]];
	
	//NSLog(@"URL: %@", tempURL);
	
	//	imageNameTextField.text=tempURL;
	//[picker dismissModalViewControllerAnimated:YES];
	//[self.popOverController dismissPopoverAnimated:YES];
	//[tempURL release];
	
}


-(void) fetchResults{
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"poseSummary" inManagedObjectContext:managedObjectContext];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF IN %@", selectedBook.pose];
	NSLog(@"mainTVC:(fetchResults) Predicate: SELF IN %@", selectedBook.name );
	[request setPredicate:predicate];
	[request setEntity:entity];
	
	
	
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
	[sortDescriptor release];
	[sortDescriptors release];
	
	[self.fetchedResultsController initWithFetchRequest:request managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    self.fetchedResultsController.delegate = self;
	
	[request release];
	
	NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) NSLog(@"Error Fetching: %@", [error localizedDescription]);	
	NSLog(@"mainTVC:(fetchResults) found %i results", [[self.fetchedResultsController fetchedObjects] count]);

}

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


- (void)viewWillAppear:(BOOL)animated {
	
		[self.navigationController setToolbarHidden:NO];
	
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

- (void)viewWillDisappear:(BOOL)animated {
	[self.navigationController setToolbarHidden:YES animated:YES];
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Override to allow orientations other than the default portrait orientation.
    return YES;
}



#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
	//NSLog(@"%i Sections", [[self.fetchedResultsController sections] count]);
    return [[self.fetchedResultsController sections] count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
	
	//NSLog(@"%i Rows", [sectionInfo numberOfObjects]);
	return [sectionInfo numberOfObjects];
	//return [[self.fetchedResultsController fetchedObjects] count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }

	poseSummary *poseInfo = [self.fetchedResultsController objectAtIndexPath:indexPath];
	cell.textLabel.text = poseInfo.title;
	NSData *thumbnailData = poseInfo.thumbnail;
	if (thumbnailData == nil){
		NSString * defaultFileName=[[NSBundle mainBundle] pathForResource: @"NewPose"  ofType: @"png"];
		cell.imageView.image= [[UIImage alloc] initWithContentsOfFile:defaultFileName];
	}else{
		cell.imageView.image= [[UIImage alloc] initWithData:[poseInfo valueForKey:@"thumbnail"]];

	}
	NSUserDefaults *prefs= [NSUserDefaults standardUserDefaults];
	NSString *sortSetting=[prefs objectForKey:@"sortBy"];
	if((sortSetting==nil) || (sortSetting==0)){
		poseInfo.sortIndex=[NSNumber numberWithInt:indexPath.row+1];
		NSError *error;
		if (![self.managedObjectContext save:&error]) NSLog(@"Error: %@", [error localizedDescription]);
	}
	
	cell.detailTextLabel.text=[NSString stringWithFormat:@"%@",poseInfo.sortIndex];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

	

	/*
	NSLog(@"Pose Title: %@", poseInfo.title);
	NSLog(@"Pose notes: %@", poseInfo.notes);
	NSLog(@"Pose sortIndex: %@", poseInfo.sortIndex);
	*/
	
	[thumbnailData release];
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
//	[self createView];
	
	//else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    //}   
}




// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	NSError *error;
	poseSummary *tempPose = [self.fetchedResultsController objectAtIndexPath:fromIndexPath];
	poseSummary *ndxPose;
	//NSLog(@"From Index: %i", fromIndexPath.row);
	//NSLog(@"To Index: %i", toIndexPath.row);
	//NSLog(@"Setting tempPose sortIndex = %@", replacePose.sortIndex);
	tempPose.sortIndex = [NSNumber numberWithInt:toIndexPath.row];
	//replacePose.sortIndex--;
	//NSLog(@"tempPose sortIndex = %@", tempPose.sortIndex);
	if(fromIndexPath.row < toIndexPath.row){
		for(int ndx=(toIndexPath.row);ndx>(fromIndexPath.row);ndx--){
			//NSLog(@"NDX: %i", ndx);
			ndxPose = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:ndx inSection:toIndexPath.section]];
			//NSLog(@"ndxPose title: %@", ndxPose.title);
			//NSLog(@"ndxPose sortIndex = %@", ndxPose.sortIndex);
			//NSLog(@"Changing sortIndex to: %i", ndx-1);
			ndxPose.sortIndex=[NSNumber numberWithInt:ndx-1];
			//NSLog(@"ndxPose sortIndex changed to  %@", ndxPose.sortIndex);
			if (![self.managedObjectContext save:&error]) NSLog(@"Error: %@", [error localizedDescription]);
									
		}
	}else{
		for(int ndx=(toIndexPath.row);ndx<(fromIndexPath.row);ndx++){
//			NSLog(@"NDX: %i",ndx);
			ndxPose = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:ndx inSection:toIndexPath.section]];
//			NSLog(@"ndxPose title: %@", ndxPose.title);
//			NSLog(@"ndxPose sortIndex = %@", ndxPose.sortIndex);
//			NSLog(@"Changing sortIndex to: %i", ndx+1);
			ndxPose.sortIndex=[NSNumber numberWithInt:ndx+1];
//			NSLog(@"ndxPose sortIndex changed to  %@", ndxPose.sortIndex);
			if (![self.managedObjectContext save:&error]) NSLog(@"Error: %@", [error localizedDescription]);
			
		}
	}
/*	
	NSLog(@"---------------------");
	for(int ndx=0;ndx<[[self.fetchedResultsController fetchedObjects] count];ndx++){
		NSLog(@"NDX: %i",ndx);
		ndxPose = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:ndx inSection:toIndexPath.section]];
		NSLog(@"ndxPose title: %@", ndxPose.title);
		NSLog(@"ndxPose sortIndex = %@", ndxPose.sortIndex);
		
	}
*/	
	
	if (![self.managedObjectContext save:&error]) NSLog(@"Error: %@", [error localizedDescription]);
	[self fetchResults];
	
	/*
	pose *tempPose=[[self.totalPoseList.poses objectAtIndex:fromIndexPath.row] retain];
	[self.totalPoseList.poses removeObjectAtIndex:fromIndexPath.row];
	[self.totalPoseList.poses insertObject:tempPose atIndex:toIndexPath.row];
	[tempPose release];
 
 */
//	[self reindexEntries];
	
}



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
	
	[self openDetailsForPoseAtIndexPath:indexPath];
}

- (void) openDetailsForPoseAtIndexPath:(NSIndexPath *)indexPath{
	dvc = [[detailViewController alloc] initWithNibName:nil bundle:nil];
	dvc.managedObjectContext = managedObjectContext;
	dvc.fetchedResultsController = fetchedResultsController;
	
	[dvc populateViewWithPoseItem:indexPath];
	[self.navigationController setToolbarHidden:YES];
	[self.navigationController pushViewController:dvc animated:YES];
	[dvc release];
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
	[managedObjectContext release];
    [super dealloc];
}


@end

