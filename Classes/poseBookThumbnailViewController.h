//
//  poseBookThumbnailViewController.h
//  PosePad
//
//  Created by Colin Francis on 7/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "settingsViewController.h"
#import "bookAddViewController.h"

@interface poseBookThumbnailViewController : UIViewController <UIScrollViewDelegate, UIPopoverControllerDelegate, settingsViewControllerDelegate, bookAddViewControllerDelegate, UIActionSheetDelegate, NSFetchedResultsControllerDelegate>{
    NSMutableArray *buttons;
    int selectedBookIndex;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *frc;
@property (nonatomic, retain) IBOutlet UIScrollView *thumbnailScrollView;
@property (nonatomic, retain) UIPopoverController *popoverController;
@property (nonatomic,retain) UIWindow *extWindow;
@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic, retain) NSMutableArray *invisibleButtons;

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)moc;
- (void)getFreeSamples:(id) sender;
- (void)generateThumbnails;
-(void)fetchResults;
@end
