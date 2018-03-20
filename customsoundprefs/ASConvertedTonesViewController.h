//
//  ASConvertedTonesViewController.h
//  iRingtone Xpert
//
//  Created by imicreation on 18/06/14.
//  Copyright (c) 2014 Appsstreet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "ASMyToneViewController.h"
#import "MDAudioFile.h"
#import "MDAudioPlayerController.h"

// @interface PSViewController : UIViewController
// -(id)initForContentSize:(CGSize)contentSize;
// -(void)setPreferenceValue:(id)value specifier:(id)specifier;
// @end

// @interface PSListController : PSViewController{
// 	NSArray *_specifiers;
// }

// - (void)viewDidAppear:(BOOL)arg1;
// - (void)viewDidLayoutSubviews;
// - (void)viewDidLoad;
// - (void)viewDidUnload;
// - (void)viewWillAppear:(BOOL)arg1;
// - (void)viewWillDisappear:(BOOL)arg1;
// -(void)loadView;
// -(void)reloadSpecifier:(PSSpecifier*)specifier animated:(BOOL)animated;
// -(void)reloadSpecifier:(PSSpecifier*)specifier;
// - (NSArray *)loadSpecifiersFromPlistName:(NSString *)name target:(id)target;
// -(PSSpecifier*)specifierForID:(NSString*)specifierID;
// @end

@interface ASConvertedTonesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, AVAudioPlayerDelegate>   {

}

@property(nonatomic, strong) UITableView* convertedTonesTableview;
@end
