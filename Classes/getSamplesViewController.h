//
//  getSamplesViewController.h
//
//  Created by shawn on 4/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "poseBooks.h"

@interface getSamplesViewController : UIViewController <NSFetchedResultsControllerDelegate> {
	UILabel *statusTitleLabel;
	UITextView *statusMessageLabel;
	UIActivityIndicatorView *activityIndicator;
	UIButton *returnButton;
	
	IBOutlet UIProgressView *progressView;
	
	NSManagedObjectContext *managedObjectContext;
	poseBooks *newBookfromJSON;
	NSMutableData *responseData;
	
}
@property (nonatomic, retain) poseBooks *newBookfromJSON;
@property(nonatomic, retain) 	NSMutableData *responseData;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, retain) IBOutlet UILabel *statusTitleLabel;
@property (nonatomic, retain) IBOutlet UITextView *statusMessageLabel;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) IBOutlet UIButton *returnButton;
@property (nonatomic, retain) 	IBOutlet UIProgressView *progressView;

-(IBAction) closeView:(id) sender;
-(BOOL) checkPoseExists:(NSString *) possiblePoseName;
-(BOOL) checkBookName:(NSString *) possibleBookName;
-(void) getBookObject:(NSString *) bookName;
-(void) getSamplePoses;
- (BOOL) connectedToNetwork;

@end
