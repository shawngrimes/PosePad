//
//  InAppPurchaseManager.m
//  PosePad
//
//  Created by shawn on 5/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "InAppPurchaseManager.h"
#import "poseBooks.h"
#import "poseSummary.h"
#import "PoseBookDownloadProgressView.h"
#import "UIImage+Resize.h"
//#import "JSON.h"
#import "SBJson.h"
#import <SystemConfiguration/SCNetworkReachability.h>
#include <netinet/in.h>



@implementation InAppPurchaseManager

@synthesize managedObjectContext;
@synthesize bookfromJSON;
@synthesize window;

NSArray *storeTransactions;

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
	storeTransactions=[NSArray arrayWithArray:transactions];
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
    }
}

- (void) completeTransaction: (SKPaymentTransaction *)transaction
{
	// Your application should implement these two methods.
    //[self recordTransaction: transaction];
	NSLog(@"Record Transaction: %@", transaction);
		NSLog(@"Record Transaction: %@", transaction.payment.productIdentifier);
	//[self performSelectorInBackground:@selector(getPoses:) withObject:transaction];
	[self getPoses:transaction];
//	[self getPoses: transaction.payment.productIdentifier];
    //[self provideContent: transaction.payment.productIdentifier];
	
	
	// Remove the transaction from the payment queue.
 //   [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void) restoreTransaction: (SKPaymentTransaction *)transaction
{
    //[self recordTransaction: transaction];
    //[self provideContent: transaction.originalTransaction.payment.productIdentifier];
	[self performSelectorInBackground:@selector(getPoses:) withObject:transaction];
//    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void) failedTransaction: (SKPaymentTransaction *)transaction
{
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        // Optionally, display an error here.
		NSLog(@"Transaction Error: %@", transaction.error);
    }
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

-(void) getPoses: (SKPaymentTransaction *)transaction{
//	id POOL = [[NSAutoreleasePool alloc] init];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	NSString *itunesID=transaction.payment.productIdentifier;
	NSString *urlString=[@"https://www.posepad.com/posestore/buyPoses.php?itunesID=" stringByAppendingFormat:@"%@",itunesID];
	NSURL *url = [NSURL URLWithString:urlString];
	NSURLRequest *request = [[NSURLRequest alloc] initWithURL: url];
	//self.statusMessageLabel.text =@"Checking for Internet connection...";
	NSLog(@"psBDTVC(getPoses):Checking for Internet connection...");
	if([self connectedToNetwork]){
		//self.statusMessageLabel.text = [self.statusMessageLabel.text stringByAppendingString:@"\nConnected."];
		NSLog(@"psBDTVC(getPoses):Connected");
		//self.statusMessageLabel.text = [self.statusMessageLabel.text stringByAppendingString:@"\nFetching samples..."];
		responseData = [NSMutableData data];
		NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
		NSLog(@"psBDTVC(getPoses): Getting poses from %@", urlString);
	}else{
		//self.statusMessageLabel.text = [self.statusMessageLabel.text stringByAppendingString:@"\nNo Connection Found."];
		NSLog(@"psBDTVC(getPoses):No connection found.");
	}
//	[POOL release];
}

-(void)closeTransaction:(NSString *) itunesID{
    for (SKPaymentTransaction *transaction in storeTransactions)
    {
		NSLog(@"Transacton ID: %@", transaction.payment.productIdentifier);
		if ([itunesID isEqualToString:transaction.payment.productIdentifier]){
			[[SKPaymentQueue defaultQueue] finishTransaction: transaction];
		}
	}

}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
	return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}


- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
	NSURLCredential *cred = [[NSURLCredential alloc] initWithUser:@"afjdkljfasdjklzcnmfuioouirqw" password:@"_pMy/+YcCHtG%ph" persistence:NSURLCredentialPersistencePermanent];
	[[challenge sender] useCredential:cred forAuthenticationChallenge:challenge];
	NSLog(@"Received Challenge");
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	//[self.returnButton setHidden:YES];
	//[self.activityIndicator startAnimating];
	[self performSelectorInBackground:@selector(processDownload) withObject:nil];
	
}

-(void)processDownload{
	
	//poseThumbnailViewController *thumbnailVC = [[poseThumbnailViewController alloc] initWithNibName:nil bundle:nil];	
	//PoseBookDownloadProgressView *pbdpV=[[PoseBookDownloadProgressView alloc] initWithNibName:@"PoseBookDownloadProgressView" bundle:nil];
	
//	NSLog(@"window stats: %i", [window.subviews count]);
//	UIView *currentView=[window.subviews objectAtIndex:0];
	//UINavigationController *navController=[[UINavigationController alloc] initWithNibName:nil bundle:nil];
	//[navController pushViewController:pbdpV animated:YES];
	//[window addSubview:navController.view];

	
//	[window makeKeyAndVisible];
	
	
//	id POOL = [[NSAutoreleasePool alloc] init];
	NSLog(@"InAppPurchaseMgr(connectionDidFinishLoading): Downloading books...");
	NSString *jsonString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
	NSDictionary *results = [jsonString JSONValue];
	NSLog(@"Results: %@", results);
	
	NSLog(@"Book: %@",[[results objectForKey:@"books"] objectForKey:@"book"]);
	NSDictionary *book = [[results objectForKey:@"books"] objectForKey:@"book"];
	
	//pbdpV.statusLabel.text=[NSString stringWithFormat:@"Downloading PoseBook: @%", [book objectForKey:@"name"]];
	
	NSLog(@"InAppPurchaseMgr:(connectionDidFinish): Book Name: %@", [book objectForKey:@"name"]);
	if(![self checkBookName:[book objectForKey:@"name"]]){
		NSLog(@"InAppPurchaseMgr:(connectionDidFinish):Creating Book");
		poseBooks *newBook = (poseBooks	*)[NSEntityDescription insertNewObjectForEntityForName:@"poseBooks" inManagedObjectContext:managedObjectContext];
		newBook.name =[book objectForKey:@"name"];
			
		NSError *error;
		if (![self.managedObjectContext save:&error]) NSLog(@"Error: %@", [error localizedDescription]);
	}
	
	
	NSArray *sampleposes = [[results objectForKey:@"poses"] objectForKey:@"pose"];
	int poseDownloadCount=0;
	for (NSDictionary *pose in sampleposes){
		//pbdpV.statusLabel.text=[NSString stringWithFormat:@"Downloading pose %i of %i", poseDownloadCount, [sampleposes count]];
		//pbdpV.progressBar.progress=(poseDownloadCount/[sampleposes count]);
		NSString *poseTitle = [pose objectForKey:@"title"];
		NSString *poseBook = [book objectForKey:@"name"];
		NSLog(@"InAppPurchaseMgr:(connectionDidFinish): Pose Name: %@ (%@)", poseTitle, poseBook);
		if(![self checkPoseExists:poseTitle]){
			//Create Pose
			NSLog(@"InAppPurchaseMgr:(connectionDidFinish):create pose");
			
			//Download image file
			NSURL *imageURL=[NSURL URLWithString:[pose objectForKey:@"imagePath"]];
			NSLog(@"InAppPurchaseMgr:(connectionDidFinish):imageURL: %@", imageURL);
			
			NSData *imageData=[NSData dataWithContentsOfURL:imageURL];
			UIImage *tempImage = [[[UIImage alloc] initWithData:imageData] resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake([UIScreen mainScreen].applicationFrame.size.width , [UIScreen mainScreen].applicationFrame.size.height) interpolationQuality:kCGInterpolationHigh];
			
			
			
			NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
			NSString *documentsDirectory = [paths objectAtIndex:0];
			if (!documentsDirectory) {
				NSLog(@"Documents directory not found!");
			}
			
			poseSummary *newPose = (poseSummary *)[NSEntityDescription insertNewObjectForEntityForName:@"poseSummary" inManagedObjectContext:managedObjectContext];
			newPose.title =poseTitle;
			NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
			newPose.sortIndex = [formatter numberFromString:[pose objectForKey:@"sortIndex"]];
			newPose.notes = [pose objectForKey:@"notes"];
			
			NSError *error;
			if (![self.managedObjectContext save:&error]) NSLog(@"Error: %@", [error localizedDescription]);
			
			if(![[newPose objectID] isTemporaryID]){
				NSString *fileName=[[[[newPose objectID] URIRepresentation] path] substringFromIndex:13];
				NSString *imgPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.jpg", fileName]];
				if(![[NSFileManager defaultManager] fileExistsAtPath:imgPath]) {
					NSData *data =  UIImageJPEGRepresentation(tempImage,.7);
					[data writeToFile:imgPath atomically:YES];
					data=nil;
				}
				CGSize iconSize;
				iconSize.width=200;
				iconSize.height=200;
			
				UIGraphicsBeginImageContext(iconSize); 
				[tempImage drawInRect:CGRectMake(0, 0, iconSize.width, iconSize.height)]; 
				UIImage *iconImg = UIGraphicsGetImageFromCurrentImageContext (); 
				UIGraphicsEndImageContext();
				newPose.thumbnail = UIImageJPEGRepresentation(iconImg,.7);
				newPose.imagePath = imgPath;

			}
			
			[self getBookObject:poseBook];
			
			NSLog(@"InAppPurchaseMgr:(connectionDidFinish):Adding pose to book: %@", self.bookfromJSON.name);
			
			if(self.bookfromJSON) {
				[newPose addBooks:[NSSet setWithObject:self.bookfromJSON]];
			}
			
			if (![self.managedObjectContext save:&error]) NSLog(@"Error: %@", [error localizedDescription]);
			tempImage=nil;
			imageData=nil;
			poseDownloadCount++;
			//[imageData release];

			
			//[imageData release];
			
		}
	}
	[self closeTransaction:[book objectForKey:@"itunesID"]];
	//[pbdpV.view removeFromSuperview];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	UIAlertView *finishedLoadingAlert = [[UIAlertView alloc] initWithTitle:@"New Pose Book Downloaded" message:[NSString stringWithFormat:@"Your new pose book(%@) has been downloaded", self.bookfromJSON.name] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	[finishedLoadingAlert show];
	responseData=nil;
//	[POOL release];
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
	
	NSFetchedResultsController *bookCheckFRC = [[NSFetchedResultsController alloc] initWithFetchRequest:checkBookNamerequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
	
	NSError *error;
	if (![bookCheckFRC performFetch:&error]) NSLog(@"Error Fetching: %@", [error localizedDescription]);	
	NSLog(@"getSampleVC:(checkBookName)Found %i books", [[bookCheckFRC fetchedObjects] count]);
	if([[bookCheckFRC fetchedObjects] count] > 0){
		poseBooks *chosenBook=[[bookCheckFRC fetchedObjects] objectAtIndex:0];
		self.bookfromJSON=chosenBook;
	}else{
		self.bookfromJSON=nil;
	}
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	NSLog(@"Setting responseData to 0 length");
	[responseData setLength:0];
}

-(void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
	NSLog(@"Data length: %d", [data length]);
	[responseData appendData:data];
	NSLog(@"Response Data Received Data: %d", [responseData length]);
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
	
	NSFetchedResultsController *bookCheckFRC = [[NSFetchedResultsController alloc] initWithFetchRequest:checkBookNamerequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
	
	NSError *error;
	if (![bookCheckFRC performFetch:&error]) NSLog(@"Error Fetching: %@", [error localizedDescription]);	
	NSLog(@"getSampleVC:(checkBookName)Found %i books", [[bookCheckFRC fetchedObjects] count]);
	if([[bookCheckFRC fetchedObjects] count] > 0){
		return YES;
	}else{
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
	
	NSFetchedResultsController *bookCheckFRC = [[NSFetchedResultsController alloc] initWithFetchRequest:checkBookNamerequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
	
	NSError *error;
	if (![bookCheckFRC performFetch:&error]) NSLog(@"Error Fetching: %@", [error localizedDescription]);	
	NSLog(@"getSampleVC:(checkBookName)Found %i books", [[bookCheckFRC fetchedObjects] count]);
	if([[bookCheckFRC fetchedObjects] count] > 0){
		return YES;
	}else{
		return NO;
	}
}

@end
