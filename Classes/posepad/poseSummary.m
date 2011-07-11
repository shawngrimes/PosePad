#import "poseSummary.h"

@implementation poseSummary

// Custom logic goes here.

-(void) prepareForDeletion{
	NSLog(@"Preparing to delete: %@", self.imagePath);
	NSError *error;
	//NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	//NSString *documentsDirectory = [paths objectAtIndex:0];
	
	//NSString *imgPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.jpg", self.title]];
	if([[NSFileManager defaultManager] fileExistsAtPath:self.imagePath]){
		if(![[NSFileManager defaultManager] removeItemAtPath:self.imagePath error:&error]) NSLog(@"Error deleting old file: %@ (%@)",self.imagePath,[error localizedDescription]);
	}
	
	
}


@end
