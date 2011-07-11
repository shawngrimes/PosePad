//
//  getSamplesViewController.m
//
//  Created by shawn on 4/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "getSamplesViewController.h"
#import "JSON.h"
#import "poseBooks.h"
#import "poseSummary.h"
#import <SystemConfiguration/SCNetworkReachability.h>
#include <netinet/in.h>


@implementation getSamplesViewController

@synthesize statusTitleLabel;
@synthesize statusMessageLabel;
@synthesize activityIndicator;
@synthesize returnButton;
@synthesize managedObjectContext;
@synthesize responseData;
@synthesize newBookfromJSON;
@synthesize progressView;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
		self.progressView.progress=0.0;
	}
	
    return self;
}

-(void) viewWillAppear:(BOOL)animated{
	[self.activityIndicator startAnimating];
	[self.returnButton setHidden:YES];
	//[self getSamplePoses];
}

-(void) viewDidAppear:(BOOL)animated{
	[super viewDidAppear:animated];
	[self getSamplePoses];
	
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	self.title =@"Fetch Poses";
	[self.activityIndicator startAnimating];
	[self.view bringSubviewToFront:self.activityIndicator];
	responseData = [[NSMutableData data] retain];
	//[self performSelector:@selector(getSamplePoses) withObject:nil afterDelay:5];
	

    [super viewDidLoad];
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
	return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}


- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
	
	NSURLCredential *cred = [[NSURLCredential alloc] initWithUser:@"afjdkljfasdjklzcnmfuioouirqw" password:@"_pMy/+YcCHtG%ph" persistence:NSURLCredentialPersistencePermanent];
	[[challenge sender] useCredential:cred forAuthenticationChallenge:challenge];
	NSLog(@"Received Challenge");
	[cred release];
}


-(void) getSamplePoses{	
	
	self.statusMessageLabel.text =@"Checking for Internet connection...";
	if([self connectedToNetwork]){
		self.statusMessageLabel.text = [self.statusMessageLabel.text stringByAppendingString:@"\nConnected."];
		self.statusMessageLabel.text = [self.statusMessageLabel.text stringByAppendingString:@"\nFetching samples..."];
		
		[self.returnButton setHidden:YES];
		[self.activityIndicator startAnimating];
		NSString *urlString=@"http://www.posepad.com/getPoses-new.php";
		NSURL *url = [NSURL URLWithString:urlString];
		self.statusMessageLabel.text = [self.statusMessageLabel.text stringByAppendingString:@"\nBeginning connection..."];
		NSData *poseData=[NSData dataWithContentsOfURL:url];
		self.statusMessageLabel.text=[self.statusMessageLabel.text stringByAppendingString:@"\nReceived data..."];
		[self performSelectorInBackground:@selector(startDownload:) withObject:poseData];
		
	
	}else{
		self.statusMessageLabel.text = [self.statusMessageLabel.text stringByAppendingString:@"\nNo Connection Found."];
	}
}

-(void) startDownload:(NSData *)poseData{
	NSAutoreleasePool *pool=[[NSAutoreleasePool alloc] init];
	
	
	
	NSString *jsonString = [[NSString alloc] initWithData:poseData encoding:NSUTF8StringEncoding];
	NSDictionary *results = [jsonString JSONValue];
	NSLog(@"Results: %@", results);
	int bookAddCount=0;
	NSArray *books = [[results objectForKey:@"books"] objectForKey:@"book"];
	for (NSDictionary *book in books){
		NSLog(@"getSampleVC:(connection): Book Name: %@", [book objectForKey:@"name"]);
		if(![self checkBookName:[book objectForKey:@"name"]]){
			NSLog(@"getSampleVC:(connection):Creating Book");
			bookAddCount++;
			poseBooks *newBook = (poseBooks	*)[NSEntityDescription insertNewObjectForEntityForName:@"poseBooks" inManagedObjectContext:managedObjectContext];
			newBook.name =[book objectForKey:@"name"];
			
			NSError *error;
			if (![self.managedObjectContext save:&error]) NSLog(@"Error: %@", [error localizedDescription]);
		}
		//		NSLog(@"Book: %@", book);
	}
	
	//self.statusMessageLabel.text = [self.statusMessageLabel.text stringByAppendingString:[NSString stringWithFormat:@"\n Added %i new books of %i available books",bookAddCount,[books count]]];
	
	int poseAddCount=0;
	NSArray *sampleposes = [[results objectForKey:@"poses"] objectForKey:@"pose"];
	int newPoseCount=[sampleposes count];
	NSLog(@"Adding %i new poses", newPoseCount);
	
	for (NSDictionary *pose in sampleposes){
		NSString *poseTitle = [pose objectForKey:@"title"];
		NSString *poseBook = [pose objectForKey:@"bookOwner"];
		NSLog(@"getSampleVC:(connection): Pose Name: %@ (%@)", poseTitle, poseBook);
		if(![self checkPoseExists:poseTitle]){
			//Create Pose
			NSLog(@"getSampleVC:(connection):create pose");
			poseAddCount++;
			
			//Download image file
			NSURL *imageURL=[NSURL URLWithString:[pose objectForKey:@"imagePath"]];
			NSLog(@"getSampleVC:(connection):imageURL: %@", imageURL);
			NSData *imageData=[NSData dataWithContentsOfURL:imageURL];
			UIImage *tempImage = [[UIImage alloc] initWithData:imageData];
			NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
			NSString *documentsDirectory = [paths objectAtIndex:0];
			if (!documentsDirectory) {
				NSLog(@"Documents directory not found!");
			}
			NSString *imgPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.jpg", poseTitle]];
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
			
			poseSummary *newPose = (poseSummary *)[NSEntityDescription insertNewObjectForEntityForName:@"poseSummary" inManagedObjectContext:managedObjectContext];
			newPose.title =poseTitle;
			NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
			newPose.sortIndex = [formatter numberFromString:[pose objectForKey:@"sortIndex"]];
			[formatter release];
			newPose.thumbnail = UIImageJPEGRepresentation(iconImg,.7);
			newPose.imagePath = imgPath;
			newPose.notes = [pose objectForKey:@"notes"];
			
			[self getBookObject:poseBook];
			
			NSLog(@"getSampleVC:(connection):Adding pose to book: %@", self.newBookfromJSON.name);
			
			if(self.newBookfromJSON) {
				[newPose addBooks:[NSSet setWithObject:self.newBookfromJSON]];
			}
			
			NSError *error;
			if (![self.managedObjectContext save:&error]) NSLog(@"Error: %@", [error localizedDescription]);
			
			
			[tempImage release];
			
			[self performSelectorOnMainThread:@selector(setProgress:) withObject:[NSNumber numberWithFloat:(float)poseAddCount/newPoseCount] waitUntilDone:YES];
			
			
			//[imageData release];
			
		}
	}
	[self performSelectorOnMainThread:@selector(finishedDownload) withObject:nil waitUntilDone:YES];
	[jsonString release];
	[pool drain];
}	

-(void) finishedDownload{
	self.statusMessageLabel.text = [self.statusMessageLabel.text stringByAppendingString:@"\n Complete!"];
	[self.activityIndicator stopAnimating];
	self.progressView.progress=1.0;
	[self.returnButton setHidden:NO];
	
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	[self.returnButton setHidden:YES];
	[self.activityIndicator startAnimating];
	self.statusMessageLabel.text = [self.statusMessageLabel.text stringByAppendingString:@"\nBeginning connection..."];
	NSString *jsonString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
	NSDictionary *results = [jsonString JSONValue];
	NSLog(@"Results: %@", results);
	int bookAddCount=0;
	NSArray *books = [[results objectForKey:@"books"] objectForKey:@"book"];
	for (NSDictionary *book in books){
		NSLog(@"getSampleVC:(connection): Book Name: %@", [book objectForKey:@"name"]);
		if(![self checkBookName:[book objectForKey:@"name"]]){
			NSLog(@"getSampleVC:(connection):Creating Book");
			bookAddCount++;
			poseBooks *newBook = (poseBooks	*)[NSEntityDescription insertNewObjectForEntityForName:@"poseBooks" inManagedObjectContext:managedObjectContext];
			newBook.name =[book objectForKey:@"name"];
			
			NSError *error;
			if (![self.managedObjectContext save:&error]) NSLog(@"Error: %@", [error localizedDescription]);
		}
		//		NSLog(@"Book: %@", book);
	}
	
	self.statusMessageLabel.text = [self.statusMessageLabel.text stringByAppendingString:[NSString stringWithFormat:@"\n Added %i new books of %i available books",bookAddCount,[books count]]];
	
	int poseAddCount=0;
	NSArray *sampleposes = [[results objectForKey:@"poses"] objectForKey:@"pose"];
	int newPoseCount=[sampleposes count];
	NSLog(@"Adding %i new poses", newPoseCount);
	
	for (NSDictionary *pose in sampleposes){
		NSString *poseTitle = [pose objectForKey:@"title"];
		NSString *poseBook = [pose objectForKey:@"bookOwner"];
		NSLog(@"getSampleVC:(connection): Pose Name: %@ (%@)", poseTitle, poseBook);
		if(![self checkPoseExists:poseTitle]){
			//Create Pose
			NSLog(@"getSampleVC:(connection):create pose");
			poseAddCount++;
			
			//Download image file
			NSURL *imageURL=[NSURL URLWithString:[pose objectForKey:@"imagePath"]];
			NSLog(@"getSampleVC:(connection):imageURL: %@", imageURL);
			NSData *imageData=[NSData dataWithContentsOfURL:imageURL];
			UIImage *tempImage = [[UIImage alloc] initWithData:imageData];
			NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
			NSString *documentsDirectory = [paths objectAtIndex:0];
			if (!documentsDirectory) {
				NSLog(@"Documents directory not found!");
			}
			NSString *imgPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.jpg", poseTitle]];
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
			
			poseSummary *newPose = (poseSummary *)[NSEntityDescription insertNewObjectForEntityForName:@"poseSummary" inManagedObjectContext:managedObjectContext];
			newPose.title =poseTitle;
			NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
			newPose.sortIndex = [formatter numberFromString:[pose objectForKey:@"sortIndex"]];
			[formatter release];
			newPose.thumbnail = UIImageJPEGRepresentation(iconImg,.7);
			newPose.imagePath = imgPath;
			newPose.notes = [pose objectForKey:@"notes"];
			
			[self getBookObject:poseBook];
			
			NSLog(@"getSampleVC:(connection):Adding pose to book: %@", self.newBookfromJSON.name);
			
			if(self.newBookfromJSON) {
				[newPose addBooks:[NSSet setWithObject:self.newBookfromJSON]];
			}
			
			NSError *error;
			if (![self.managedObjectContext save:&error]) NSLog(@"Error: %@", [error localizedDescription]);
			
			
			[tempImage release];
			
			[self performSelectorOnMainThread:@selector(setProgress:) withObject:[NSNumber numberWithFloat:(float)poseAddCount/newPoseCount] waitUntilDone:YES];
			
			
			//[imageData release];
			
		}
	}
	self.statusMessageLabel.text = [self.statusMessageLabel.text stringByAppendingString:[NSString stringWithFormat:@"\n Added %i new poses of %i available poses",poseAddCount,[sampleposes count]]];
	self.statusMessageLabel.text = [self.statusMessageLabel.text stringByAppendingString:@"\n Complete!"];
	//[jsonString release];
	[self.activityIndicator stopAnimating];
	
	[self.returnButton setHidden:NO];
}

-(void) setProgress:(NSNumber *) progress{
		self.progressView.progress=[progress floatValue];

}

- (BOOL) connectedToNetwork
{
    // Create zero addy
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
	
    // Recover reachability flags
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
	
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
	
    if (!didRetrieveFlags)
    {
        printf("Error. Could not recover network reachability flags\n");
        return 0;
    }
	
    BOOL isReachable = flags & kSCNetworkFlagsReachable;
    BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
	BOOL nonWiFi = flags & kSCNetworkReachabilityFlagsTransientConnection;

	return ((isReachable && !needsConnection) || nonWiFi) ? YES : NO;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	[responseData setLength:0];
}


-(IBAction) closeView:(id) sender
{
	[self dismissModalViewControllerAnimated:YES];
}

-(void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
	[responseData appendData:data];
}

-(void) getBookObject:(NSString *) bookName{
	NSFetchRequest *checkBookNamerequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *bookentity = [NSEntityDescription entityForName:@"poseBooks" inManagedObjectContext:managedObjectContext];
	NSPredicate *checkbookPredicate = [NSPredicate predicateWithFormat:@"name == %@", bookName];
	[checkBookNamerequest setEntity:bookentity];
	[checkBookNamerequest setPredicate:checkbookPredicate];
	
	// Order the events by creation date, most recent first.
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[checkBookNamerequest setSortDescriptors:sortDescriptors];
	[sortDescriptor release];
	[sortDescriptors release];
	
	NSFetchedResultsController *bookCheckFRC = [[NSFetchedResultsController alloc] initWithFetchRequest:checkBookNamerequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
	
	NSError *error;
	if (![bookCheckFRC performFetch:&error]) NSLog(@"Error Fetching: %@", [error localizedDescription]);	
	NSLog(@"getSampleVC:(checkBookName)Found %i books", [[bookCheckFRC fetchedObjects] count]);
	if([[bookCheckFRC fetchedObjects] count] > 0){
		poseBooks *chosenBook=[[bookCheckFRC fetchedObjects] objectAtIndex:0];
		[bookCheckFRC release];
		[checkBookNamerequest release];
		self.newBookfromJSON=chosenBook;
	}else{
		[bookCheckFRC release];
		[checkBookNamerequest release];
		self.newBookfromJSON=nil;
	}
}

-(BOOL) checkBookName:(NSString *) possibleBookName{
	
	//Returns YES if book name already exists
	
	NSFetchRequest *checkBookNamerequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *bookentity = [NSEntityDescription entityForName:@"poseBooks" inManagedObjectContext:managedObjectContext];
	NSPredicate *checkbookPredicate = [NSPredicate predicateWithFormat:@"name == %@", possibleBookName];
	[checkBookNamerequest setEntity:bookentity];
	[checkBookNamerequest setPredicate:checkbookPredicate];
	
	// Order the events by creation date, most recent first.
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[checkBookNamerequest setSortDescriptors:sortDescriptors];
	[sortDescriptor release];
	[sortDescriptors release];
	
	NSFetchedResultsController *bookCheckFRC = [[NSFetchedResultsController alloc] initWithFetchRequest:checkBookNamerequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
	
	NSError *error;
	if (![bookCheckFRC performFetch:&error]) NSLog(@"Error Fetching: %@", [error localizedDescription]);	
	NSLog(@"getSampleVC:(checkBookName)Found %i books", [[bookCheckFRC fetchedObjects] count]);
	if([[bookCheckFRC fetchedObjects] count] > 0){
		[bookCheckFRC release];
		[checkBookNamerequest release];
		return YES;
	}else{
		[bookCheckFRC release];
		[checkBookNamerequest release];
		return NO;
	}
	
	
}

-(BOOL) checkPoseExists:(NSString *) possiblePoseName{
	NSFetchRequest *checkBookNamerequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *bookentity = [NSEntityDescription entityForName:@"poseSummary" inManagedObjectContext:managedObjectContext];
	NSPredicate *checkbookPredicate = [NSPredicate predicateWithFormat:@"title == %@", possiblePoseName];
	[checkBookNamerequest setEntity:bookentity];
	[checkBookNamerequest setPredicate:checkbookPredicate];
	
	// Order the events by creation date, most recent first.
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sortIndex" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[checkBookNamerequest setSortDescriptors:sortDescriptors];
	[sortDescriptor release];
	[sortDescriptors release];
	
	NSFetchedResultsController *bookCheckFRC = [[NSFetchedResultsController alloc] initWithFetchRequest:checkBookNamerequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
	
	NSError *error;
	if (![bookCheckFRC performFetch:&error]) NSLog(@"Error Fetching: %@", [error localizedDescription]);	
	NSLog(@"getSampleVC:(checkBookName)Found %i books", [[bookCheckFRC fetchedObjects] count]);
	if([[bookCheckFRC fetchedObjects] count] > 0){
		[bookCheckFRC release];
		[checkBookNamerequest release];
		return YES;
	}else{
		[bookCheckFRC release];
		[checkBookNamerequest release];
		return NO;
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}


@end
