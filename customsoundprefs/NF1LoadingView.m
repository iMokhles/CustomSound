//
//  NF1LoadingView.m
//  iPhone
//
//  Created by kuldeep Tyagi.
//  Copyright 2014 Imicreation. All rights reserved.
//

#import "NF1LoadingView.h"

#define AlertBackgroundImage @"round_corners.png"

@interface NF1LoadingView ()

- (void) initialize;
- (void) addLabelWithText: (NSString*) text;
- (void) updateLabelWithText: (NSString*) descriptionString
					 atIndex: (unsigned int) row;
@end

@implementation NF1LoadingView

@synthesize isDisplayed;

- (id) initWithDescriptionsArray: (NSArray*) descriptions {
    if ((self = [super initWithFrame: CGRectZero])) {

		[self initialize];
		[self updateWithDescriptionsArray: descriptions];
        isDisplayed = NO;
    }
    return self;
}

- (id) initWithDescriptionsCount: (unsigned int) descriptionsCount {
    if ((self = [super initWithFrame: CGRectZero])) {
		
		[self initialize];

		descriptionLabels = [[NSMutableArray alloc] initWithCapacity: descriptionsCount];
		for (unsigned int i = 0; i < descriptionsCount; i++) {
			[self addLabelWithText: @""];
		}
	}
    return self;
}

- (void) initialize {
	self.backgroundColor = [UIColor clearColor];
	
	backgroundView = [[UIImageView alloc] initWithFrame: CGRectZero];
	UIImage* stretchedImage = [[UIImage imageNamed:AlertBackgroundImage] stretchableImageWithLeftCapWidth: 12.0														
																							  topCapHeight: 12.0];
	[backgroundView setImage: stretchedImage];
    backgroundView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
	backgroundView.alpha = 0.8
    ;
    backgroundView.layer.cornerRadius = 12;
	[self addSubview: backgroundView];

	activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhite];
	[activityView startAnimating];
	[backgroundView addSubview: activityView];
}

- (void)dealloc {
    descriptionLabels = NULL;
    backgroundView = NULL;
    activityView = NULL;

}

- (void) addLabelWithText: (NSString*) text {
	
	UILabel* label = [[UILabel alloc] initWithFrame: CGRectZero];
	label.backgroundColor = [UIColor clearColor];
	label.textAlignment = NSTextAlignmentCenter;
	label.contentMode = UIViewContentModeCenter;
	label.textColor = [UIColor colorWithRed: 0.9709
									  green: 0.9709
									   blue: 0.9709
									  alpha: 1.0];
	label.font = [UIFont boldSystemFontOfSize: 18.0];
	label.text = text;
	[descriptionLabels addObject: label];
	[backgroundView addSubview: label];
}

- (void) updateLabelWithText: (NSString*) descriptionString
					 atIndex: (unsigned int) row {
	
	UILabel* label = [descriptionLabels objectAtIndex: row];
	label.text = descriptionString;
}

- (void) updateWithDescriptionsArray: (NSArray*) descriptions {
	
	for (unsigned int i = 0; i < [descriptionLabels count]; i++) {
		UILabel* label = [descriptionLabels objectAtIndex: i];
		[label removeFromSuperview];
	}
	// TODO: removeAllObjects is redundant
	[descriptionLabels removeAllObjects];
	
	descriptionLabels = [[NSMutableArray alloc] initWithCapacity: [descriptions count]];
	for (unsigned int i = 0; i < [descriptions count]; i++) {
		[self addLabelWithText: [descriptions objectAtIndex: i]];
	}
	
	[self layoutSubviews];
}

- (void) updateDescription: (NSString*) descriptionString
					forRow: (unsigned int) row {
	
	int sizeDiff = (int)[descriptionLabels count] - row - 1; // "-1" cuz index started from "0"
	if (sizeDiff < 0) {
		unsigned int missedEmptyObjectsCount = (int)(-sizeDiff) - 1;  // "-1" cuz last object we will add with "descriptionString" value
		for (unsigned int i = 0; i < missedEmptyObjectsCount; i++) {
			[self addLabelWithText: @""];
		}		
		[self addLabelWithText: descriptionString];

	} else {
		[self updateLabelWithText: descriptionString
						  atIndex: row];
	}
	
	[self layoutSubviews];
}

- (void) setDescriptionsCount: (unsigned int) descriptionsCount {
}

- (void) layoutSubviews {
	
	[super layoutSubviews];

	// all this magic needs to dynamic changing message area size and reposition all subviews
	// cuz view can have different label count and different text label width
	
	// ----------
	// -activity-
	// ----------
	// - label  -
	// -  ...   -
	// - label  -
	// ----------
	
	// init coordinates and sizes
	
	float margin = 30.0;
	float activitySize = 60.0;
	float labelHeight = 20.0;
	float maxWidth = 300.0;
	float minWidth = margin * 2 + activitySize;
	float verticalOffset = margin + activitySize + labelHeight;
	
	// calculate label size with minimum width
	for (unsigned int i = 0; i < [descriptionLabels count]; i++) {

		UILabel* label = [descriptionLabels objectAtIndex: i];
		CGSize labelSize = [label.text sizeWithFont: [label font]];
		minWidth = fmax(minWidth, labelSize.width);
      	minWidth = fmin(minWidth, maxWidth);
	}
	
	// update labels width
	for (unsigned int i = 0; i < [descriptionLabels count]; i++) {
		
		UILabel* label = [descriptionLabels objectAtIndex: i];
		label.frame = CGRectMake(margin - 25, verticalOffset - 40, minWidth, labelHeight);
		
		if ([label.text isEqualToString: @""]) {
			verticalOffset += labelHeight / 2.0;
		} else {
			verticalOffset += labelHeight;
		}
	}
	
	verticalOffset += margin;
	
	CGRect screenRect = [[UIApplication sharedApplication] keyWindow].frame;
	float barVerticalOffset = 30.0;//40.0
	float messageVerticalOffset = -40.0;//-40.0; // loading view will be displayed little upper than center of screen
	self.frame = CGRectMake(0, barVerticalOffset, screenRect.size.width, screenRect.size.height - barVerticalOffset + margin/2.0);
	backgroundView.bounds = CGRectMake(0, 0, minWidth + margin * 2.0 - 46, verticalOffset - 30);
	backgroundView.center = CGPointMake(self.center.x, self.center.y - barVerticalOffset + messageVerticalOffset - 30);
	activityView.frame = CGRectMake((backgroundView.bounds.size.width - activitySize) / 2.0 , 2 * margin - 40, activitySize, activitySize);
}
@end