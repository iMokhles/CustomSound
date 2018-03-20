// #import <Preferences/Preferences.h>
#include <objc/runtime.h>
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <Preferences/PSSpecifier.h>
#import "SVProgressHUD.h"
#import "EECircularMusicPlayerControl.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <CoreMedia/CoreMedia.h>
#import "MDAudioFile.h"
#import "MDAudioPlayerController.h"
#import "ASMyToneViewControllerLS.h"

// static NSBundle* getBundle() {
//     return [NSBundle bundleWithPath:@"/Library/PreferenceBundles/CustomUnlockPrefs.bundle"];
// }

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

@interface CustomSoundPrefsSoundsListController : PSViewController <UITableViewDataSource, UITableViewDelegate, EECircularMusicPlayerControlDelegate, AVAudioPlayerDelegate> {
    NSString					*cellTextLabelKey;
    NSString					*cellDetailTextLabelKey;
    NSString					*reusableCellIdentifier;
    NSString					*viewTitle;
}
// Variables that are required to be set for basic functionality
@property (nonatomic, retain) NSString					 *cellTextLabelKey;

// Variables that can be optionally set to add functionality to your NLFetchedResultsTable
@property (nonatomic, retain) NSString					 *viewTitle;
@property (nonatomic, retain) NSString					 *reusableCellIdentifier;
@property (nonatomic, retain) NSString					 *cellDetailTextLabelKey;
@property (nonatomic, strong) NSMutableArray *arrayCells;
@property (nonatomic, retain) NSString *soundFilePath;
@property (nonatomic, strong) UITableView *myTableView;
@property (nonatomic, strong) UIBarButtonItem *clearButton;
@property (strong, nonatomic) EECircularMusicPlayerControl *playerControl;
@end

@interface UITableView (Private)
- (NSArray *) indexPathsForSelectedRows;
@property(nonatomic) BOOL allowsMultipleSelectionDuringEditing;
@end

@interface PSViewController(Private)
-(void)viewWillAppear:(BOOL)animated;
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
@end