//
//  tableDisplayController.h
//  PosePad
//
//  Created by Colin Francis on 7/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "poseBooks.h"
#import "bookAddViewController.h"

@interface tableDisplayController : UIViewController <NSFetchedResultsControllerDelegate,UIImagePickerControllerDelegate,UIPopoverControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, bookAddViewControllerDelegate>
{
    NSManagedObjectContext *managedObjectContext;
	NSFetchedResultsController *fetchedResultsController;
	poseBooks *selectedBook;
	
	UIPopoverController *popOverController;
	
    UITableView *tablePosesList;
    BOOL menuIsVisible;
}

@property (nonatomic, retain) NSMutableArray *buttons;
@property (nonatomic, retain) IBOutlet UITableView *poseTableView;

@property (nonatomic,retain) UIPopoverController *popOverController;

@property (nonatomic,retain) 	poseBooks *selectedBook;

@property (nonatomic,retain) 	NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) 	NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) UIActionSheet *menu;

-(void) fetchResults;
-(void) returnThumbnailView;
- (void) openDetailsForPoseAtIndexPath:(NSIndexPath *)indexPath;
@end
