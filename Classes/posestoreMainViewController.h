//
//  posestoreMainTableViewController.h
//  PosePad
//
//  Created by shawn on 5/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
#import <CoreData/CoreData.h>


@interface posestoreMainViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, SKProductsRequestDelegate> {

	NSManagedObjectContext *managedObjectContext;
	
	NSMutableData *responseData;
	NSMutableDictionary *bookDictionary;
	
	UIActivityIndicatorView *activityIndicator;
	UITextView *statusMessageLabel;
	
	UITableView *storeTable;
	
	IBOutlet UITableViewCell *posestoreCellView;
	IBOutlet UILabel *bookNameLabel;
	IBOutlet UILabel *bookDescriptionLabel;
	IBOutlet UILabel *bookPriceLabel;
	
	IBOutlet UIBarButtonItem *getFreeSamplesButton;
	
}
@property (nonatomic, retain) 	NSManagedObjectContext *managedObjectContext;

@property(nonatomic, retain) NSMutableData *responseData;
@property(nonatomic,retain) NSMutableDictionary *bookDictionary;

@property(nonatomic,retain) IBOutlet UIActivityIndicatorView *activityIndicator;
@property(nonatomic,retain) IBOutlet UITextView *statusMessageLabel;

@property(nonatomic,retain) IBOutlet UITableView *storeTable;

-(void) getBooksFromPosestore;
-(BOOL) connectedToNetwork;
-(void) requestProductDataFromAppStore;
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response;

-(IBAction)getFreeSamples:(id) sender;


@end
