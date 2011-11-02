//
//  diagramViewController.m
//  PosePad
//
//  Created by Colin Francis on 7/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "diagramViewController.h"


@implementation diagramViewController

@synthesize drawing, delegate, managedObjectContext, fetchedResultsController, selectedPose;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    graphPaperImage.hidden=NO;
    return self;
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	if(graphPaperImage.hidden==NO){
		UITouch *touch=[touches anyObject];
		lastPoint=[touch locationInView:self.view];
		//lastPoint.y-=20;
	}
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
	if(graphPaperImage.hidden==NO){
		imageChanged=YES;
		UITouch *touch=[touches anyObject];
		CGPoint currentPoint=[touch locationInView:self.view];
		currentPoint.x -=10;
		
		if(CGRectContainsPoint(graphPaperImage.frame, currentPoint))
		{
            //NSLog(@"RECTCONTAINSPOINT");
			UIGraphicsBeginImageContext(drawImage.frame.size);
			[drawImage.image drawInRect:CGRectMake(0, 0, drawImage.frame.size.width, drawImage.frame.size.height)];
			CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
			CGContextSetLineWidth(UIGraphicsGetCurrentContext(), drawSizeSlider.value);
			if(eraseMode){
				NSInteger halfEraserSize=(eraseSizeSlider.value/2);
				NSLog(@"Eraser Size: %i", halfEraserSize);
				//NSLog(@"Current X: %i Half Current X: %i",currentPoint.x, currentPoint.x-halfEraserSize);
				CGContextClearRect(UIGraphicsGetCurrentContext(), CGRectMake(currentPoint.x - halfEraserSize, currentPoint.y - halfEraserSize+70, eraseSizeSlider.value*2,eraseSizeSlider.value*2));
			}else{
				CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0, 0, 0, 1.0);
				CGContextBeginPath(UIGraphicsGetCurrentContext());
				CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y+70);
				CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y+70);
				CGContextStrokePath(UIGraphicsGetCurrentContext());
			}
			drawImage.image=UIGraphicsGetImageFromCurrentImageContext();
			UIGraphicsEndImageContext();
			lastPoint=currentPoint;
		}
	}
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	if(graphPaperImage.hidden==NO){
		imageChanged=YES;
		UITouch *touch=[touches anyObject];
		CGPoint currentPoint=[touch locationInView:self.view];
		currentPoint.x -=10;
		
		if(CGRectContainsPoint(graphPaperImage.frame, currentPoint))
		{
            
			UIGraphicsBeginImageContext(drawImage.frame.size);
			[drawImage.image drawInRect:CGRectMake(0, 0, drawImage.frame.size.width, drawImage.frame.size.height)];
			CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
			CGContextSetLineWidth(UIGraphicsGetCurrentContext(),drawSizeSlider.value);
			if(eraseMode){
				NSInteger halfEraserSize=(eraseSizeSlider.value/2);
				NSLog(@"Eraser Size: %i", halfEraserSize);
				//NSLog(@"Current X: %f Half Current X: %f",currentPoint.x, currentPoint.x-halfEraserSize);
				CGContextClearRect(UIGraphicsGetCurrentContext(), CGRectMake(currentPoint.x - halfEraserSize, currentPoint.y - halfEraserSize+70, eraseSizeSlider.value*2,eraseSizeSlider.value*2));
			}else{
				CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0, 0, 0, 1.0);
				CGContextBeginPath(UIGraphicsGetCurrentContext());
				CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y+70);
				CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y+70);
				CGContextStrokePath(UIGraphicsGetCurrentContext());
			}
			CGContextFlush(UIGraphicsGetCurrentContext());
			drawImage.image=UIGraphicsGetImageFromCurrentImageContext();
			UIGraphicsEndImageContext();
		}
	}	
}
-(IBAction)switchEraseMode:(id)sender{
	if(drawEraseSegmentControl.selectedSegmentIndex==0){
		NSLog(@"detailVC(switchEraseMode): Selected draw mode");
		eraseMode=NO;
	}else if(drawEraseSegmentControl.selectedSegmentIndex==1){
		NSLog(@"detailVC(switchEraseMode): Selected erase mode");
		eraseMode=YES;
	}
	
}
- (void)dealloc
{
    self.drawing;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (NSString *)getPrivateDocsDir
{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    documentsDirectory = [documentsDirectory stringByAppendingPathComponent:@"Drawing Files"];
    documentsDirectory = [documentsDirectory stringByAppendingPathComponent:[self.delegate getBookTitle]];
    
    NSError *error;
    [[NSFileManager defaultManager] createDirectoryAtPath:documentsDirectory withIntermediateDirectories:YES attributes:nil error:&error];   
    
    return documentsDirectory;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *path = [[self getPrivateDocsDir] stringByAppendingPathComponent:[self.delegate getfileName]];
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSLog(@"%@",path);

    if ([fileManager fileExistsAtPath:path])
    {
        NSData *imageData = [fileManager contentsAtPath:path];
        self.drawing = [[UIImage alloc] initWithData:imageData];
        //[imageData release];
    }
     
    //self.drawing = selectedPose.
    
    drawImage.image = self.drawing;
    self.title = [self.delegate getTitle];
    //Load image if saved
    // Do any additional setup after loading the view from its nib.
}
- (void)viewWillAppear:(BOOL)animated
{
    drawImage.image = self.drawing;
}
- (void)viewWillDisappear:(BOOL)animated
{
    self.drawing = drawImage.image;
    
    //Save image
    NSData *imageData = UIImagePNGRepresentation(self.drawing);
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSString *path = [[self getPrivateDocsDir] stringByAppendingPathComponent:[self.delegate getfileName]];
    NSLog(@"%@",path);
    [fileManager createFileAtPath:path contents:imageData attributes:nil];
    //[imageData release];
}
- (void)viewDidUnload
{
    self.drawing = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

@end
