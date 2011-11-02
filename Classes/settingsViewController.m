    //
//  settingsViewController.m
//  PosePad
//
//  Created by shawn on 5/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "settingsViewController.h"


@implementation settingsViewController
@synthesize displayModesArray;
@synthesize extWindow;
@synthesize delegate;
@synthesize book;
UIScreen *extScreen;


 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
			self.title=@"Settings";
    }
    return self;
}
-(id)initWithPosebook:(poseBooks *)poseBook
{
    self = [super init];
    self.title = @"Settings";
    self.book = poseBook;
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {

    [super viewDidLoad];
}

-(void) viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
	NSUserDefaults *prefs= [NSUserDefaults standardUserDefaults];
	//NSLog(@"SettingsVC (VWA): sortBy Setting: %i", [prefs integerForKey:@"sortBy"]);
	sortSettingsSegmentedControl.selectedSegmentIndex=[self.book.alphaSorted intValue];
	//NSLog(@"SettingsVC (VWA): pinchMessage Setting: %d", [prefs boolForKey:@"displayPinchMessage"]);
	//BOOL pinchValue=[prefs boolForKey:@"displayPinchMessage"];
	[pinchMessageSwitch setOn:[prefs boolForKey:@"displayPinchMessage"] animated:NO];
	if([[UIScreen screens] count]>1){
		externalDisplaySwitch.enabled=YES;
		extDisplayModePicker.hidden=NO;
		externalDisplaySwitch.on=NO;
		[self changeExternalDisplaySwitch:self];
	}else{
		externalDisplaySwitch.enabled=NO;
		extDisplayModePicker.hidden=YES;
	}
}

-(IBAction) saveSettings:(id) sender{
	//NSUserDefaults *prefs= [NSUserDefaults standardUserDefaults];
	self.book.alphaSorted = [NSNumber numberWithInt:sortSettingsSegmentedControl.selectedSegmentIndex];
	//[prefs synchronize];
	[self dismissModalViewControllerAnimated:YES];
}

-(IBAction) changeExternalDisplaySwitch:(id) sender{
	if(externalDisplaySwitch){
		/*
		for (UIScreen *aScreen in UIScreen.screens) {
			if(aScreen != [UIScreen mainScreen]){
				extScreen=aScreen;
				displayModesArray=[[extScreen availableModes] mutableCopy];
				[extDisplayModePicker reloadAllComponents];
				if(extWindow==nil){
					extWindow=[[UIWindow alloc] initWithFrame:[extScreen bounds]];
				}else{
					extWindow.frame=[extScreen bounds];
				}
				[extWindow setScreen:extScreen];
				UIImageView *extImageView;
				if(extImageView=(UIImageView *)[extWindow viewWithTag:1]){
				
				}else{
					extImageView=[[UIImageView alloc] initWithFrame:[extScreen bounds]];
				}
				extImageView.image=[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource: @"TestImage" ofType: @"png"]];
				extImageView.tag=1;
				[extWindow addSubview: extImageView];
				[extImageView release];
				[extWindow makeKeyAndVisible];
				[delegate externalDisplayEnabled:extWindow];
			}
		}
		 */
	}else{
		extDisplayModePicker.hidden=YES;
	}
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
	/*
	UIScreenMode *screenMode=[displayModesArray objectAtIndex:row];
	extScreen.currentMode=screenMode;
	extWindow.frame=[extScreen bounds];
	for (UIView *extView in extWindow.subviews) {
		[extView removeFromSuperview];
		//[thumbnailItem release];
	}
	UIImageView *extImageView=[[UIImageView alloc] initWithFrame:[extScreen bounds]];
	extImageView.image=[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource: @"TestImage" ofType: @"png"]];
	[extWindow addSubview: extImageView];
	[extImageView release];
	[extWindow makeKeyAndVisible];
						
	*/
}


-(NSInteger) numberofComponentsInPickerView:(UIPickerView *) pickerView{
	return 3;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
	if(displayModesArray!=nil){
		return [displayModesArray count];
	}
	return 0;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
	UIScreenMode *screenMode=[displayModesArray objectAtIndex:row];
	
	return [NSString stringWithFormat:@"Mode: %f x %f",screenMode.size.width, screenMode.size.height];
	
}




-(IBAction) changeSort:(id) sender{
	NSLog(@"settingsVC(changeSort): Selected sort type was: %i", sortSettingsSegmentedControl.selectedSegmentIndex);
	//NSUserDefaults *prefs= [NSUserDefaults standardUserDefaults];
	self.book.alphaSorted = [NSNumber numberWithInt:sortSettingsSegmentedControl.selectedSegmentIndex];
	//prefs synchronize];
	if(sortSettingsSegmentedControl.selectedSegmentIndex==0){
		NSLog(@"settingsVC(changeSort): Selected sort type was: manual");
	}else if(sortSettingsSegmentedControl.selectedSegmentIndex==1){
		NSLog(@"settingsVC(changeSort): Selected sort type was: alpha");
	}
}

-(IBAction) changePinchMessage:(id) sender{
	NSUserDefaults *prefs= [NSUserDefaults standardUserDefaults];
	NSLog(@"settingsVC(changePinchMessage): Display pinchMessage: %d", pinchMessageSwitch.on);
	[prefs setBool:pinchMessageSwitch.on forKey:@"displayPinchMessage"];
	[prefs synchronize];
	
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


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}




@end
