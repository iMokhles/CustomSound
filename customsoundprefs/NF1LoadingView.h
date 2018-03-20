//
//  NF1LoadingView.h
//  iPhone
//
//  Created by kuldeep Tyagi.
//  Copyright 2014. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface NF1LoadingView : UIView {

	UIImageView* backgroundView;
	UIActivityIndicatorView* activityView;
	NSMutableArray* descriptionLabels;
}

- (id) initWithDescriptionsArray: (NSArray*) descriptions;
- (id) initWithDescriptionsCount: (unsigned int) descriptionsCount;

- (void) updateWithDescriptionsArray: (NSArray*) descriptions;

- (void) updateDescription: (NSString*) descriptionString forRow: (unsigned int) row;
- (void) setDescriptionsCount: (unsigned int) descriptionsCount;

@property (nonatomic) BOOL isDisplayed;
@end
