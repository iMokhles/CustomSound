// #import <Preferences/Preferences.h>
#include "CustomRingPrefsSounds.h"
#import "ASMyToneViewController.h"

#define SIDELOADERTINT [UIColor colorWithRed: 255.0/255.0 green: 45.0/255.0 blue: 85.0/255.0 alpha: 1.0]

// static NSBundle* getBundle() {
//     return [NSBundle bundleWithPath:@"/Library/PreferenceBundles/CustomUnlockPrefs.bundle"];
// }

@interface CustomRingPrefsListController ()
@property (strong, nonatomic) AVAudioPlayer *audioPlayer; // This is used by playerControl1.
@property (strong, nonatomic) NSTimer *timer; // This is used by playerControl2.
@property (nonatomic) dispatch_source_t timerSource; // This is used by playerControl3.
@end

@implementation CustomRingPrefsListController
@synthesize cellTextLabelKey;
@synthesize viewTitle, reusableCellIdentifier;
@synthesize cellDetailTextLabelKey;
@synthesize myTableView;

- (void)viewDidLoad{

   [super viewDidLoad];
// Do any additional setup after loading the view, typically from a nib.

   NSString *language = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];

   if ([language isEqualToString:@"ar"]) {
        self.navigationItem.title = @"نغمات رنين";
    } else {
        self.navigationItem.title = @"Ringtons";
    }
    // //Add a edit button
    self.myTableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] bounds] style:UITableViewStylePlain];
    [self.myTableView setFrame:[[UIScreen mainScreen] bounds]];
    [self.myTableView setDataSource:self];
    [self.myTableView setDelegate:self];


    self.arrayCells = [[NSMutableArray alloc] init];

    [self.myTableView setEditing:NO];
    [self.myTableView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.myTableView];
    
    NSFileManager *fm = [NSFileManager defaultManager];
 
    NSString *soundsDir = [@"/Library/" stringByAppendingPathComponent:@"/Ringtones/"];
    NSArray *soundFilesArray = [fm contentsOfDirectoryAtPath:soundsDir error:nil];
     
    NSEnumerator *enumerator = [soundFilesArray objectEnumerator];
    id soundFile;
    NSString *newFileName;
     
    self.arrayCells = [[NSMutableArray alloc] init];
    while (soundFile = [enumerator nextObject])
    {
        newFileName = [soundFile stringByDeletingPathExtension];
        [self.arrayCells addObject:newFileName];
    }
    [self.myTableView reloadData];
    self.playerControl = [[EECircularMusicPlayerControl alloc] init];

    NSString *buttonListen;
    if ([language isEqualToString:@"ar"]) {
        buttonListen = @"إستمع";
    } else {
        buttonListen = @"Listen";
    }
    //Add the Add button
    UIBarButtonItem * addButton = [[UIBarButtonItem alloc] initWithTitle:buttonListen style:UIBarButtonItemStyleBordered target:self action: @selector(applySelection)];

    self.navigationItem.rightBarButtonItem = addButton;
}

- (void)viewWillAppear:(BOOL)animated
{
    self.view.tintColor = SIDELOADERTINT;
    self.navigationController.navigationBar.tintColor = SIDELOADERTINT;

    [super viewWillAppear:animated];
}

#pragma mark -
#pragma mark TableView Delegates

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    return [self.arrayCells count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        // self.playerControl.delegate = self;
        // self.playerControl.progressTrackRatio = 0.25f;
        // self.playerControl.trackTintColor = [UIColor clearColor];
        // self.playerControl.highlightedTrackTintColor = [UIColor clearColor];
        // self.playerControl.disabledTrackTintColor = [UIColor clearColor];
        // self.playerControl.progressTintColor = [UIColor colorWithRed:0.0f/255.0f green:88.0f/255.0f blue:219.0f/255.0f alpha:1.0f];
        // self.playerControl.highlightedProgressTintColor = [UIColor colorWithRed:11.0f/255.0f green:76.0f/255.0f blue:176.0f/255.0f alpha:1.0f];
        // self.playerControl.disabledProgressTintColor = [UIColor lightGrayColor];
        // self.playerControl.buttonTopTintColor = [UIColor clearColor];
        // self.playerControl.highlightedButtonTopTintColor = [UIColor clearColor];
        // self.playerControl.disabledButtonTopTintColor = [UIColor clearColor];
        // self.playerControl.buttonBottomTintColor = [UIColor clearColor];
        // self.playerControl.highlightedButtonBottomTintColor = [UIColor clearColor];
        // self.playerControl.disabledButtonBottomTintColor = [UIColor clearColor];
        // self.playerControl.iconColor = [UIColor colorWithRed:0.0f/255.0f green:88.0f/255.0f blue:219.0f/255.0f alpha:1.0f];
        // self.playerControl.highlightedIconColor = [UIColor colorWithRed:11.0f/255.0f green:76.0f/255.0f blue:176.0f/255.0f alpha:1.0f];
        // self.playerControl.disabledIconColor = [UIColor lightGrayColor];
        // self.playerControl.borderColor = [UIColor colorWithRed:0.0f/255.0f green:88.0f/255.0f blue:219.0f/255.0f alpha:1.0f];
        // self.playerControl.highlightedBorderColor = [UIColor colorWithRed:11.0f/255.0f green:76.0f/255.0f blue:176.0f/255.0f alpha:1.0f];
        // self.playerControl.disabledBorderColor = [UIColor lightGrayColor];
        // self.playerControl.borderWidth = 1.0f;
        // [self.playerControl addTarget:self action:@selector(playOrPauseSound:)  forControlEvents:UIControlEventTouchUpInside];
        // cell.accessoryView = self.playerControl;
    }
    NSString *cellString = [self.arrayCells objectAtIndex:[indexPath row]]; // [NSString stringWithFormat:];
    [[cell textLabel] setText:cellString];
    [cell.textLabel setTextColor:[UIColor darkTextColor]];
    [cell.detailTextLabel setTextColor:[UIColor darkTextColor]];
    // self.playerControl1.duration = self.audioPlayer.duration;
    return cell;
}
// - (void)playOrPauseSound:(UIControl *)sender {
//     UITableViewCell *cell = (UITableViewCell *)sender.superview;
//     NSIndexPath *indexPath = [self.myTableView indexPathForCell:cell];
//     NSString *cellSoundPath = [NSString stringWithFormat:@"/var/mobile/Library/CustomUnlock/Sounds/%@.caf", [self.arrayCells objectAtIndex:[indexPath row]]];
//     NSURL *url = [NSURL fileURLWithPath:cellSoundPath];
//     self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
//     self.audioPlayer.delegate = self;
//     [self.audioPlayer prepareToPlay];
//     self.playerControl.duration = self.audioPlayer.duration;
//     BOOL startsPlaying = !self.audioPlayer.playing;
//     self.playerControl.playing = startsPlaying;
//     if (startsPlaying) {
//         [self.audioPlayer play];
//     } else {
//         [self.audioPlayer stop];
//         self.audioPlayer.currentTime = 0.0;
//         [self.audioPlayer prepareToPlay];
//     }
// }
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	//UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [SVProgressHUD show];
	// NSString *cellName = [self.arrayCells objectAtIndex:indexPath.row];
 //    NSString *cafPath = [@"/var/mobile/Library/CustomSound/ActiveSound/" stringByAppendingPathComponent:@"sound.caf"];
 //    if ([[NSFileManager defaultManager] fileExistsAtPath:cafPath] == YES) {
 //        [[NSFileManager defaultManager] removeItemAtPath:cafPath error:nil];
 //    }
 //    NSString *resourcePath = [NSString stringWithFormat:@"/var/mobile/Library/CustomSound/Sounds/%@.caf", cellName];
 //    [[NSFileManager defaultManager] copyItemAtPath:resourcePath toPath:cafPath error:nil];
    
	// UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Test" message:[NSString stringWithFormat:@"%@", resourcePath] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
 //    [alert show];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // time-consuming task
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
    });
    [tableView deselectRowAtIndexPath:indexPath animated:true];

    // NSString *cellName = [self.arrayCells objectAtIndex:indexPath.row];
    // NSString *cafPath = [@"/Library/Application Support/CustomUnlock/ActiveSound/" stringByAppendingPathComponent:@"Sound.caf"];
    // if ([[NSFileManager defaultManager] fileExistsAtPath:cafPath] == YES) {
    //     [[NSFileManager defaultManager] removeItemAtPath:cafPath error:nil];
    // }
    // NSString *resourcePath = [NSString stringWithFormat:@"/Library/Application Support/CustomUnlock/Sounds/%@.caf", cellName];
    // NSData *dataSoundFile = [NSData dataWithContentsOfURL:[NSURL URLWithString:resourcePath]];
    // [dataSoundFile writeToFile:cafPath atomically:YES];
    
    
}

// // #pragma mark - EECircularMusicPlayerControlDelegate
// // - (NSTimeInterval)currentTime
// // {
// //     return self.audioPlayer.currentTime;
// // }

// // #pragma mark - AVAudioPlayerDelegate
// // - (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
// // {
// //     self.playerControl.playing = NO;
// //     [self.audioPlayer prepareToPlay];
// // }

-(void)applySelection {

    ASMyToneViewController *custonSoundsTable = [[ASMyToneViewController alloc] init];
    // [colorPickerPrefs colorFromDefaults:tweak_defaults withKey:saveKey];    
    [self.navigationController pushViewController:custonSoundsTable animated:YES]; //completion:nil];

    // UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:getBundle()];
    // UIViewController *vc = [sb instantiateInitialViewController];
    // // vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    // [self presentViewController:vc animated:YES completion:NULL];
    // [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"CSoundApp://"]];
        //Display a UIAlertView
    // NSMutableArray *songs = [[NSMutableArray alloc] init];
    
    // for (NSString *song in self.arrayCells)
    // {
    //     MDAudioFile *audioFile = [[MDAudioFile alloc] initWithPath:[NSURL fileURLWithPath:[NSString stringWithFormat:@"/var/mobile/Library/CustomUnlock/Sounds/%@.caf", song]]];
    //     [songs addObject:audioFile];
    // }
    // MDAudioPlayerController *audioPlayer = [[MDAudioPlayerController alloc] initWithSoundFiles:songs atPath:@"/var/mobile/Library/CustomUnlock/Sounds/" andSelectedIndex:nil];
    // [self presentViewController:audioPlayer animated:YES completion:nil];

    // NSMutableArray *songs = [[NSMutableArray alloc] init];
    
    // for (NSString *song in self.arrayCells)
    // {
    //     MDAudioFile *audioFile = [[MDAudioFile alloc] initWithPath:[NSURL fileURLWithPath:[NSString stringWithFormat:@"/Library/Ringtones/%@.m4r", song]]];
    //     [songs addObject:audioFile];
    // }
    
    // MDAudioPlayerController *audioPlayer = [[MDAudioPlayerController alloc] initWithSoundFiles:songs atPath:@"/Library/Ringtones/" andSelectedIndex:nil];
    // [self presentViewController:audioPlayer animated:YES completion:nil];

}

// -(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
//     return NO;

// }

@end
