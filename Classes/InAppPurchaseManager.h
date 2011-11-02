//
//  InAppPurchaseManager.h
//  PosePad
//
//  Created by shawn on 5/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import <CoreData/CoreData.h>
#import "poseBooks.h"

// add a couple notifications sent out when the transaction completes
#define kInAppPurchaseManagerTransactionFailedNotification @"kInAppPurchaseManagerTransactionFailedNotification"
#define kInAppPurchaseManagerTransactionSucceededNotification @"kInAppPurchaseManagerTransactionSucceededNotification"



@interface InAppPurchaseManager : UIViewController <SKPaymentTransactionObserver>{
	NSManagedObjectContext *managedObjectContext;
	poseBooks *bookfromJSON;
	NSMutableData *responseData;
	UIWindow *window;
}
@property (nonatomic, retain) poseBooks *bookfromJSON;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) IBOutlet UIWindow *window;


- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions;
- (void) failedTransaction: (SKPaymentTransaction *)transaction;
- (void) completeTransaction: (SKPaymentTransaction *)transaction;
- (void) restoreTransaction: (SKPaymentTransaction *)transaction;
-(void) getPoses: (SKPaymentTransaction *)transaction;

- (BOOL) connectedToNetwork;
-(BOOL) checkPoseExists:(NSString *) possiblePoseName;
-(BOOL) checkBookName:(NSString *) possibleBookName;
-(void) getBookObject:(NSString *) bookName;

@end
