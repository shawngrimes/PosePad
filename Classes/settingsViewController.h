//
//  settingsViewController.h
//  PosePad
//
//  Created by shawn on 5/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "poseBooks.h"

@protocol settingsViewControllerDelegate <NSObject>
-(void)externalDisplayEnabled:(UIWindow *) extWindowSetting;
@end

@interface settingsViewController : UIViewController <UIPickerViewDelegate> {
	id<settingsViewControllerDelegate> delegate;
	
	IBOutlet UIButton *saveButton;
	IBOutlet UISegmentedControl *sortSettingsSegmentedControl;
	IBOutlet UINavigationBar *navBar;
	IBOutlet UISwitch *pinchMessageSwitch;
	IBOutlet UISwitch *externalDisplaySwitch;
	IBOutlet UIPickerView *extDisplayModePicker;

	NSMutableArray *displayModesArray;
	
	UIWindow *extWindow;
}

@property(nonatomic,retain) id<settingsViewControllerDelegate> delegate;
@property(nonatomic,retain) UIWindow *extWindow;
@property (nonatomic, retain) 	NSMutableArray *displayModesArray;
@property (nonatomic, retain) poseBooks *book;

-(id)initWithPosebook:(poseBooks *)poseBook;
-(IBAction) saveSettings:(id) sender;
-(IBAction) changeSort:(id) sender;
-(IBAction) changePinchMessage:(id) sender;
-(IBAction) changeExternalDisplaySwitch:(id) sender;

@end
