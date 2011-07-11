//
//  PoseBookDownloadProgressView.h
//  PosePad
//
//  Created by shawn on 6/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PoseBookDownloadProgressView : UIViewController {
	UIProgressView *progressBar;
	UIActivityIndicatorView *activityIndicator;
	UILabel *titleLabel;
	UILabel *statusLabel;

}

@property(nonatomic, retain) IBOutlet UIProgressView *progressBar;
@property(nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;
@property(nonatomic, retain) IBOutlet UILabel *titleLabel;
@property(nonatomic, retain) IBOutlet UILabel *statusLabel;

@end
