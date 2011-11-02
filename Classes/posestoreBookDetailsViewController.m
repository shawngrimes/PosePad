    //
//  posestoreBookDetailsViewController.m
//  PosePad
//
//  Created by shawn on 5/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "posestoreBookDetailsViewController.h"
//#import "JSON.h"
#import "SBJson.h"
#import <SystemConfiguration/SCNetworkReachability.h>
#include <netinet/in.h>
#include <StoreKit/StoreKit.h>

@implementation posestoreBookDetailsViewController

@synthesize bookInformation;



 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		// Custom initialization

		
		
    }
    return self;
}


-(void) willAnimateSecondHalfOfRotationFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation duration:(NSTimeInterval)duration{
	if((self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) || (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft)){
		[self createHorizView];
	}else if((self.interfaceOrientation == UIInterfaceOrientationPortrait) || (self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)){
		[self createVertView];		
	}
	
	
}


-(void)createHorizView{
	bookDescriptionTextView.frame=CGRectMake(7, 75, 494, 496);
	polaroidView.frame=CGRectMake(503, 55, 534, 561);
	
}

-(void)createVertView{
	bookDescriptionTextView.frame=CGRectMake(7, 75, 751, 217);
	polaroidView.frame=CGRectMake(111, 273, 534, 561);	
}

-(void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
	NSLog(@"Book Information: %@", bookInformation);
	bookNameLabel.text = [bookInformation objectForKey:@"name"];
	bookPriceLabel.text=[NSString stringWithFormat:@"$%@",[bookInformation objectForKey:@"price"]];
	bookDescriptionTextView.text = [bookInformation objectForKey:@"description"];
	bookImageCount.text = [[bookInformation objectForKey:@"number_of_poses"] stringByAppendingFormat:@" images"] ;
	[self getPoses];
	if((self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) || (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft)){
		[self createHorizView];
	}else if((self.interfaceOrientation == UIInterfaceOrientationPortrait) || (self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)){
		[self createVertView];		
	}
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

-(IBAction) purchasePoseBook{
	SKPayment *payment = [SKPayment paymentWithProductIdentifier:[bookInformation objectForKey:@"itunesID"]];
	[[SKPaymentQueue defaultQueue] addPayment:payment];	
}

-(void) getPoses{
	NSString *urlString=[@"https://www.posepad.com/posestore/getPoses.php?itunesID=" stringByAppendingFormat:@"%@",[bookInformation objectForKey:@"itunesID"]];
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
	NSLog(@"psBDTVC(connectionDidFinishLoading): Downloading books...");
	NSString *jsonString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
	NSDictionary *results = [jsonString JSONValue];
		NSLog(@"Results: %@", results);
	//int bookAddCount=0;

	NSArray *poses = [[results objectForKey:@"poses"] objectForKey:@"pose"];
	[self performSelectorInBackground:@selector(generateImageSlideShow:) withObject:poses];
//	[self performSelector:@selector(generateImageSlideShow:) withObject:poses];
//	[self performSelector:@selector(movePrevious) withObject:nil afterDelay:0];
}


-(void) generateImageSlideShow:(NSArray *)poses {
//	id POOL = [[NSAutoreleasePool alloc] init];
	NSMutableArray *poseImages = [[NSMutableArray alloc] init];
	for (NSDictionary *pose in poses){
		NSLog(@"psBDTVC(generateImageSlideShow): Pose: %@", pose);
		NSData *imageData=[[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:[pose objectForKey:@"imagePath"]]];
		UIImage *tempImage=[[UIImage alloc] initWithData:imageData];
		CGSize iconSize;
		iconSize.width=409;
		iconSize.height=331;
		UIGraphicsBeginImageContext(iconSize); 
		[tempImage drawInRect:CGRectMake(0, 0, iconSize.width, iconSize.height)];
		UIImage *iconImg = UIGraphicsGetImageFromCurrentImageContext (); 
		UIGraphicsEndImageContext();
		[poseImages addObject:iconImg];
		bookPhotoImageView.image=iconImg;
		[self performSelectorInBackground:@selector(setPolaroidImage:) withObject:iconImg];
//		[self setPolaroidImage:iconImg];
	
		//[iconImg release];
		//[poseDictionary setObject:pose forKey:[pose objectForKey:@"sortIndex"]];
		NSLog(@"psBDTVC(connectionDidFinishLoading):ImagePath: %@", [pose objectForKey:@"imagePath"]);
	}
	[self performSelector:@selector(startImagesSlideShow:) withObject:poseImages];
	
	
	NSLog(@"pose count: %i", [poseImages count]);
	
	
	
//	[POOL release];
	[activityIndicator stopAnimating];
	loadingImagesLabel.hidden=YES;
	
}

-(void) setPolaroidImage:(UIImage *) poseImage{
//	id POOL = [[NSAutoreleasePool alloc] init];
	bookPhotoImageView.image=nil;
	bookPhotoImageView.image=poseImage;
//	[POOL release];
}
	

-(void) startImagesSlideShow:(NSArray *) poseImages{
//	id POOL = [[NSAutoreleasePool alloc] init];
	bookPhotoImageView.animationImages=poseImages;
	bookPhotoImageView.animationDuration=[poseImages count]*3;
	bookPhotoImageView.animationRepeatCount=0;
	[bookPhotoImageView startAnimating];
//	[POOL release];
	
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





@end
