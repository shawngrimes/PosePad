//
//  infoViewController.h
//  PosePad
//
//  Created by shawn on 5/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface infoViewController : UIViewController <MFMailComposeViewControllerDelegate> {
	
	IBOutlet UIButton *rateButton;
	IBOutlet UIButton *sendFeedbackButton;
	IBOutlet UIButton *requestFeatureButton;
	IBOutlet UIButton *sendToFriendButton;
	IBOutlet UIButton *seeTwitterButton;
	IBOutlet UIButton *visitWebButton;

}

-(IBAction) rateCommand;
-(IBAction) sendFeedbackCommand;
-(IBAction) requestFeatureCommand;
-(IBAction) sendToFriendCommand;
-(IBAction) seeTwitterCommand;
-(IBAction) visitWebCommand;

@end
