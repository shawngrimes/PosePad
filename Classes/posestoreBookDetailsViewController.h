//
//  posestoreBookDetailsViewController.h
//  PosePad
//
//  Created by shawn on 5/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface posestoreBookDetailsViewController : UIViewController {

	IBOutlet UILabel *bookNameLabel;
	IBOutlet UITextView *bookDescriptionTextView;
	IBOutlet UILabel *bookPriceLabel;
	IBOutlet UILabel *bookImageCount;
	IBOutlet UIButton *buyButton;
	IBOutlet UIImageView *bookPhotoImageView;
	IBOutlet UIImageView *polaroidPhotos;
	IBOutlet UILabel *loadingImagesLabel;
	IBOutlet UIActivityIndicatorView *activityIndicator;
	IBOutlet UIView *polaroidView;
	
	NSMutableDictionary *bookInformation;
	
	NSMutableData *responseData;
}

@property(nonatomic,retain) 	NSMutableDictionary *bookInformation;


-(void) getPoses;
-(BOOL) connectedToNetwork;
-(IBAction) purchasePoseBook;

-(void) createVertView;
-(void) createHorizView;
-(void) generateImageSlideShow:(NSArray *) poses;
-(void) startImagesSlideShow:(NSArray *) poseImages;
-(void) setPolaroidImage:(UIImage *) poseImage;

@end
