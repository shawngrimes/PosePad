    //
//  posestoreMainTableViewController.m
//  PosePad
//
//  Created by shawn on 5/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "posestoreMainViewController.h"
#import "JSON.h"
#import <SystemConfiguration/SCNetworkReachability.h>
#include <netinet/in.h>
#import "posestoreBookDetailsViewController.h"
#import "getSamplesViewController.h"

@implementation posestoreMainViewController

@synthesize responseData;
@synthesize bookDictionary;
@synthesize activityIndicator;
@synthesize statusMessageLabel;
@synthesize storeTable;
@synthesize managedObjectContext;


 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
		storeTable.delegate=self;
		storeTable.dataSource=self;
    }
    return self;
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[activityIndicator startAnimating];
	
	[self getBooksFromPosestore];
}

-(IBAction)getFreeSamples:(id) sender{
	getSamplesViewController *getSamplesVC = [[getSamplesViewController alloc] initWithNibName:@"getSamplesViewController" bundle:nil];
	getSamplesVC.managedObjectContext = managedObjectContext;
	
	[self presentModalViewController:getSamplesVC animated:YES];
	[getSamplesVC release]; 
	
}

-(void) requestProductDataFromAppStore{
	SKProductsRequest *request= [[SKProductsRequest alloc] initWithProductIdentifiers: [NSSet setWithArray:[bookDictionary allKeys]]];
	//NSSet *productIdentifiers= [NSSet setWithObject:@"com.shawnsbits.posepad.1100"];
	//SKProductsRequest *request= [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
	NSLog(@"psMTVC(requestProductDataFromAppStore): Array of books: %@", [bookDictionary allKeys]);
	request.delegate = self;
	[request start];
	statusMessageLabel.text=[statusMessageLabel.text stringByAppendingFormat:@"\nWaiting for response from App Store"];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSArray *myProduct = response.products;
	NSLog(@"psMTVC(ProductsRequest):In PR");
	for (SKProduct *product in myProduct){
		NSLog(@"psMTVC(ProductsRequest):product found in app store: %@", product.localizedTitle);
		//NSLog(@"psMTVC(ProductsRequest):product found in app store: %@", product.priceLocale);
		NSMutableDictionary *bookProperties = [bookDictionary objectForKey:product.productIdentifier];
		[bookProperties setValue:product.price forKey:@"price"];
		//[bookProperties setValue:product.localizedDescription forKey:@"description"];
//		[bookProperties setValue:product.localizedDescription forKey:@"description"];
		[bookDictionary setValue:bookProperties forKey:product.productIdentifier];
		NSLog(@"psMTVC(ProductsRequest): Book Information Dump: %@", bookDictionary);
	}
	
	
	[storeTable reloadData];
	self.statusMessageLabel.text = [self.statusMessageLabel.text stringByAppendingString:@"\nYou are ready to shop!"];
	
    // populate UI
    [request autorelease];
	
	[activityIndicator stopAnimating];
}

-(void)request:(SKProductsRequest *)request didFailWithError:(NSError *)error
{
	statusMessageLabel.text=[statusMessageLabel.text stringByAppendingFormat:@"\nError connecting to App Store: %@", [error localizedDescription]];
	NSLog(@"Error connecting to App Store: %@", [error localizedDescription]);
	
}

-(void) getBooksFromPosestore{
	NSString *urlString=@"https://www.posepad.com/posestore/getBooks.php";
	NSURL *url = [NSURL URLWithString:urlString];
	NSURLRequest *request = [[NSURLRequest alloc] initWithURL: url];
	self.statusMessageLabel.text =@"Checking for Internet connection...";
	NSLog(@"psMTVC(getAvailablePoseBooks):Checking for Internet connection...");
	if([self connectedToNetwork]){
		self.statusMessageLabel.text = [self.statusMessageLabel.text stringByAppendingString:@"\nConnected."];
		NSLog(@"psMTVC(getAvailablePoseBooks):Connected");
		self.statusMessageLabel.text = [self.statusMessageLabel.text stringByAppendingString:@"\nFetching samples..."];
		responseData = [[NSMutableData data] retain];
		NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
		[connection release];
	}else{
		self.statusMessageLabel.text = [self.statusMessageLabel.text stringByAppendingString:@"\nNo Connection Found."];
		NSLog(@"psMTVC(getAvailablePoseBooks):No connection found.");
		[activityIndicator stopAnimating];
	}
	[request release];
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

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	//[self.returnButton setHidden:YES];
	//[self.activityIndicator startAnimating];
	self.statusMessageLabel.text = [self.statusMessageLabel.text stringByAppendingString:@"\nDownloading books..."];
	NSString *jsonString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
	NSDictionary *results = [jsonString JSONValue];
//	NSLog(@"Results: %@", results);
	//int bookAddCount=0;
	bookDictionary=[[NSMutableDictionary alloc] init];
	NSArray *books;
	@try {
		books = [[results objectForKey:@"books"] objectForKey:@"book"];
	}
	@catch (NSException * e) {
		books=[[NSMutableArray alloc] initWithCapacity:1];
	}
	@finally {
		
	}
	//NSArray *books = [[results objectForKey:@"books"] objectForKey:@"book"];
	for (NSDictionary *book in books){
		NSLog(@"psMTVC(connectionDidFinishLoading): Book: %@", book);
		[bookDictionary setObject:book forKey:[book objectForKey:@"itunesID"]];
		NSLog(@"psMTVC(connectionDidFinishLoading):itunesID: %@", [book objectForKey:@"itunesID"]);
		//[bookInformation addObject:[book objectForKey:@"itunesID"]];
	}
	
	NSLog(@"bookIDs count: %i", [bookDictionary count]);
	self.statusMessageLabel.text = [self.statusMessageLabel.text stringByAppendingString:@"\nGetitng information from App Store..."];
	[self requestProductDataFromAppStore];
	[responseData release];
	[jsonString release];
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



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [bookDictionary count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"posestoreTableCell";
	static NSString *CellNib = @"posestoreCellView";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        //cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		NSArray *nib =[[NSBundle mainBundle] loadNibNamed:CellNib owner:self options:nil];
		cell = (UITableViewCell *)[nib objectAtIndex:0];
    }
    NSArray *keys=[bookDictionary allKeys];
	NSLog(@"Key: %@", [keys objectAtIndex:indexPath.row]);
	NSDictionary *bookInfo=[bookDictionary objectForKey:[keys objectAtIndex:indexPath.row]];
	bookNameLabel.text=[bookInfo objectForKey:@"name"];
	bookDescriptionLabel.text=[bookInfo objectForKey:@"description"];
	NSString *priceText=@"$";
	NSLog(@"Price: %@",[bookInfo objectForKey:@"price"]);
	bookPriceLabel.text=[priceText stringByAppendingFormat:@"%@",[bookInfo objectForKey:@"price"]];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	
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


/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */


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
	/*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
	
	posestoreBookDetailsViewController *posestoreDetailVC = [[posestoreBookDetailsViewController alloc] initWithNibName:@"posestoreBookDetailsViewController" bundle:nil];
	NSArray *keys=[bookDictionary allKeys];
	NSLog(@"posestoreMVC(didSelectRowAtIndexPath): Selected posebook= %@", [keys objectAtIndex:indexPath.row]);
	posestoreDetailVC.bookInformation = [bookDictionary objectForKey:[keys objectAtIndex:indexPath.row]];
	[self.navigationController pushViewController:posestoreDetailVC animated:YES];
	[posestoreDetailVC release];
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
	[bookDictionary release];
    [super dealloc];
}


@end
