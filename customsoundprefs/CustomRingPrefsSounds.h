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
#include "CustomLockPrefsSounds.h"

@interface CustomRingPrefsListController : PSViewController <UITableViewDataSource, UITableViewDelegate, EECircularMusicPlayerControlDelegate, AVAudioPlayerDelegate> {
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

// @interface UITableView (Private)
// - (NSArray *) indexPathsForSelectedRows;
// @property(nonatomic) BOOL allowsMultipleSelectionDuringEditing;
// @end

// @interface PSViewController(Private)
// -(void)viewWillAppear:(BOOL)animated;
// -(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
// @end