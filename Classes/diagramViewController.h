//
//  diagramViewController.h
//  PosePad
//
//  Created by Colin Francis on 7/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "poseSummary.h"

@protocol diagramViewDelegate <NSObject>

-(NSString *)getTitle;
-(NSString *)getBookTitle;
-(NSString *)getfileName;
@end

@interface diagramViewController : UIViewController {
    IBOutlet UIImageView *graphPaperImage;
	IBOutlet UIImageView *drawImage;
	CGPoint lastPoint;
	BOOL imageChanged;
	IBOutlet UISlider *drawSizeSlider;
	IBOutlet UISlider *eraseSizeSlider;
	BOOL eraseMode;
	IBOutlet UISegmentedControl *drawEraseSegmentControl;
}

@property (nonatomic, retain) UIImage *drawing;
@property (nonatomic, retain) id <diagramViewDelegate> delegate;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) poseSummary *selectedPose;

-(IBAction)switchEraseMode:(id)sender;

@end
