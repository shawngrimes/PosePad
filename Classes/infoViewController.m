    //
//  infoViewController.m
//  PosePad
//
//  Created by shawn on 5/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "infoViewController.h"


@implementation infoViewController

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/
-(IBAction) changePinchMessage:(id) sender{
	NSUserDefaults *prefs= [NSUserDefaults standardUserDefaults];
	//NSLog(@"settingsVC(changePinchMessage): Display pinchMessage: %d", pinchMessageSwitch.on);
	[prefs setBool:pinchMessageSwitch.on forKey:@"displayPinchMessage"];
	[prefs synchronize];
	
}
-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
	[self becomeFirstResponder];
	[self dismissModalViewControllerAnimated:YES];
}


-(IBAction) rateCommand{
	NSURL *url = [NSURL URLWithString:@"http://itunes.apple.com/us/app/posepad/id365203804?mt=8"];
	[[UIApplication sharedApplication] openURL:url];
}

-(IBAction) sendFeedbackCommand{
	MFMailComposeViewController *mailVC = [[MFMailComposeViewController alloc] init];
	[mailVC setSubject:[NSString stringWithFormat:@"PosePad v%@ Feedback", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]];
	[mailVC setToRecipients:[NSArray arrayWithObject:@"feedback@posepad.com"]];
	mailVC.mailComposeDelegate=self;
	mailVC.modalPresentationStyle=UIModalPresentationFormSheet;
	//	mailVC.modalTransitionStyle=UIModalTransitionStylePartialCurl;	
	[self presentModalViewController:mailVC animated:YES];
}

-(IBAction) requestFeatureCommand{
	MFMailComposeViewController *mailVC = [[MFMailComposeViewController alloc] init];
	[mailVC setSubject:[NSString stringWithFormat:@"PosePad v%@ Feature Request", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]];
	[mailVC setToRecipients:[NSArray arrayWithObject:@"features@posepad.com"]];
	mailVC.mailComposeDelegate=self;
	mailVC.modalPresentationStyle=UIModalPresentationFormSheet;
	//	mailVC.modalTransitionStyle=UIModalTransitionStylePartialCurl;	
	[self presentModalViewController:mailVC animated:YES];
	
}

-(IBAction) sendToFriendCommand{
	MFMailComposeViewController *mailVC = [[MFMailComposeViewController alloc] init];
	[mailVC setSubject:@"PosePad for the iPad"];
//	[mailVC setToRecipients:[NSArray arrayWithObject:@"features@posepad.com"]];
	[mailVC setMessageBody:@"Hi, I've been trying a new photography app for the iPad called PosePad and am very happy with it.  It is very much like a photographer's journal or a posing guide.  You can store images/poses along with notes about lighting or the setup. You can organize your shots/images into books or albums and group them how you want.  It's a great way for managing your workflow during a portrait session.  Here is the appstore link: <a href=\"http://itunes.apple.com/us/app/posepad/id365203804?mt=8\">http://itunes.apple.com/us/app/posepad/id365203804?mt=8</a> or you can visit their website and see a video overview: <a href=\"http://www.posepad.com\">http://www.posepad.com</a>" isHTML:YES];
	mailVC.mailComposeDelegate=self;
	mailVC.modalPresentationStyle=UIModalPresentationFormSheet;
	//	mailVC.modalTransitionStyle=UIModalTransitionStylePartialCurl;	
	[self presentModalViewController:mailVC animated:YES];
}

-(IBAction) seeTwitterCommand{
	NSURL *url = [NSURL URLWithString:@"http://www.twitter.com/shawnsbits"];
	[[UIApplication sharedApplication] openURL:url];
}
-(IBAction) visitWebCommand{
	NSURL *url = [NSURL URLWithString:@"http://www.posepad.com"];
	[[UIApplication sharedApplication] openURL:url];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    NSUserDefaults *prefs= [NSUserDefaults standardUserDefaults];
    [pinchMessageSwitch setOn:[prefs boolForKey:@"displayPinchMessage"] animated:NO];

}
- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}




@end
