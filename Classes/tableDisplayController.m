//
//  tableDisplayController.m
//  Poser
//
//  Created by colin on 7/11/11.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "tableDisplayController.h"
#import "PoseBookAppDelegate.h"
#import "poseSummary.h"
#import "detailViewController.h"
#import "poseBooks.h"
#import <QuartzCore/QuartzCore.h>
#import "bookAddViewController.h"

#import "UIImage+Resize.h"

@implementation tableDisplayController

@synthesize managedObjectContext;
@synthesize fetchedResultsController;
@synthesize poseTableView; 
@synthesize popOverController;
@synthesize buttons;
@synthesize selectedBook;
@synthesize menu;

detailViewController *dvc;

#pragma mark -
#pragma mark Initialization

-(UITableView *)poseTableView
{
    if (!poseTableView)
        poseTableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] style:UITableViewStylePlain];
    return poseTableView;
}
- (id)init {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
	if((self=[super init])){
		//[super viewDidLoad];
		UIImagePickerController *picker =[[UIImagePickerController alloc] init];
		picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
		picker.delegate = self;
		
		UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:picker];
		self.popOverController = popover;
		popOverController.delegate = self;
        
	}	
    return self;
}


-(void) returnThumbnailView{
	[self.navigationController setToolbarHidden:YES];
	[self.view removeFromSuperview];
	
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
	
	[self.poseTableView reloadData];
	
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
    if (self.fetchedResultsController == nil)
        self.fetchedResultsController = [[NSFetchedResultsController alloc] init];
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
	
	[self.fetchedResultsController initWithFetchRequest:request managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    self.fetchedResultsController.delegate = self;
	
	
	NSError *error;
	if (![[self fetchedResultsController] performFetch:&error])
        NSLog(@"Error Fetching: %@", [error localizedDescription]);	
	NSLog(@"mainTVC:(fetchResults) found %i results", [[self.fetchedResultsController fetchedObjects] count]);
    
}

#pragma mark -
#pragma mark View lifecycle

-(void)bookAddDidEditName
{
    self.title = [self.selectedBook name];
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.destructiveButtonIndex)
    {
        //NSLog(@"Delete");
        
        NSManagedObject *goneObject = self.selectedBook;      
        [self.managedObjectContext deleteObject:goneObject];
        NSError *error;
        if ([managedObjectContext save:&error])
        {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
        else
        {
            NSLog(@"Error saving Delete"); 
        }
    }
    else if (buttonIndex == actionSheet.firstOtherButtonIndex)
    {
        bookAddViewController *editVC = [[bookAddViewController alloc] initWithPosebook:self.selectedBook];
        editVC.delegate = self;
        editVC.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentModalViewController:editVC animated:YES];
    }
    menuIsVisible = NO;
}
-(void)settings:(id)sender
{
    if (!menuIsVisible)
    {
        self.menu = [[UIActionSheet alloc] initWithTitle:@"Book Menu" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"Delete Book" otherButtonTitles:@"Edit Book Name", nil];
        self.menu.actionSheetStyle = UIActionSheetStyleBlackOpaque;
        [self.menu showFromBarButtonItem:sender animated:YES];
        self.menu;
        menuIsVisible = YES;
    }
    else
    {
        [self.menu  dismissWithClickedButtonIndex:menu.cancelButtonIndex animated:YES];
        menuIsVisible = NO;
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.poseTableView.delegate = self;
    self.poseTableView.dataSource = self;
    
    //Customize TableView
    self.poseTableView.layer.cornerRadius = 25.0;
    self.poseTableView.rowHeight = 80.0;
    self.poseTableView.separatorColor = [UIColor grayColor];
    
    /*self.poseTableView.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.poseTableView.layer.shadowOffset = CGSizeMake(0, 1);
    self.poseTableView.layer.shadowOpacity = 1.0;*/
    
    self.poseTableView.backgroundColor = [[UIColor alloc] initWithRed:0.9 green:0.9 blue:0.9 alpha:0.4];
    
    // create a toolbar to have two buttons in the right
    UIToolbar* tools = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 170, 44.01)];
    tools.barStyle = UIBarStyleBlackOpaque;
    // create the array to hold the buttons, which then gets added to the toolbar
    buttons = [[NSMutableArray alloc] initWithCapacity:5];
    
    UIBarButtonItem *bi = self.editButtonItem;
    
    [buttons addObject:bi];
    
    bi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:NULL];
    bi.width=5;
    [buttons addObject:bi];
    
    // create a standard "add" button
    bi = [[UIBarButtonItem alloc]
                           initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(add)];
    bi.style = UIBarButtonItemStyleBordered;
    [buttons addObject:bi];
    
    bi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:NULL];
    bi.width=5;
    [buttons addObject:bi];
    
    bi = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings-icon.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(settings:)];
    [buttons addObject:bi];
    
    // stick the buttons in the toolbar
    [tools setItems:buttons animated:NO];
    
    //[buttons release];
    
    // and put the toolbar in the nav bar
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:tools];
    
    [self.navigationController setToolbarHidden:YES];

    
    // Uncomment the following line to preserve selection between presentations.
    //self.clearsSelectionOnViewWillAppear = NO;
    
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [self.poseTableView setEditing:editing animated:animated];
}
- (void)viewWillAppear:(BOOL)animated {
	
    [self.navigationController setToolbarHidden:YES];
	
	[self fetchResults];
	
	self.title = [self.selectedBook name];
    //	NSError *error;
    //	if (![[self fetchedResultsController] performFetch:&error]) NSLog(@"Error Fetching: %@", [error localizedDescription]);	
	
	[self.poseTableView reloadData];
	
	[super viewWillAppear:animated];
    
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}



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
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
	poseSummary *poseInfo = [self.fetchedResultsController objectAtIndexPath:indexPath];
	cell.textLabel.text = poseInfo.title;
	NSData *thumbnailData = poseInfo.thumbnail;
	if (thumbnailData == nil){
		NSString * defaultFileName=[[NSBundle mainBundle] pathForResource: @"NewPose"  ofType: @"png"];
		cell.imageView.image= [UIImage imageWithContentsOfFile:defaultFileName];
	}else{
        NSLog(@"poseName: %@", poseInfo.title);
//        NSLog(@"PoseThumbnail: %@", poseInfo.thumbnail);
		cell.imageView.image= [UIImage imageWithData:poseInfo.thumbnail];
        
	}
	int sortSetting=[self.selectedBook.alphaSorted intValue];
	if (sortSetting==0){
		poseInfo.sortIndex=[NSNumber numberWithInt:indexPath.row+1];
        cell.detailTextLabel.text=[NSString stringWithFormat:@"%@",poseInfo.sortIndex];
		NSError *error;
		if (![self.managedObjectContext save:&error]) NSLog(@"Error: %@", [error localizedDescription]);
	}
	
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.textColor = [UIColor grayColor];
    cell.textLabel.font = [UIFont systemFontOfSize:22.0];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:20];
    
	/*
     NSLog(@"Pose Title: %@", poseInfo.title);
     NSLog(@"Pose notes: %@", poseInfo.notes);
     NSLog(@"Pose sortIndex: %@", poseInfo.sortIndex);
     */
	
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
	dvc = [[detailViewController alloc] initWithNibName:nil bundle:nil managedObjectContest:managedObjectContext fetchedResultsController:fetchedResultsController];
	//dvc.managedObjectContext = managedObjectContext;
	//dvc.fetchedResultsController = fetchedResultsController;
	
	[dvc populateViewWithPoseItem:indexPath];
	[self.navigationController setToolbarHidden:YES];
	[self.navigationController pushViewController:dvc animated:YES];
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
    buttons = nil;
    // For example: self.myOutlet = nil;
}


-(void)bookWasAdded{}
-(void)bookWasCanceled
{
    [self dismissModalViewControllerAnimated:YES];
}

@end

