//
//  ASConvertedTonesViewController.m
//  iRingtone Xpert
//
//  Created by imicreation on 18/06/14.
//  Copyright (c) 2014 Appsstreet. All rights reserved.
//

#import "ASConvertedTonesViewController.h"
#import "PKGCell.h"
#import "ASMyToneViewController.h"

BOOL didDeleteCell;

@interface ASConvertedTonesViewController ()

@property(nonatomic, retain) AVAudioPlayer *audioPlayer;

@property(nonatomic, retain) NSMutableArray* myRingtonestableviewDatasource;
@property(nonatomic) NSInteger playerCellTag;
@end

@implementation ASConvertedTonesViewController
@synthesize convertedTonesTableview;
@synthesize myRingtonestableviewDatasource;
@synthesize audioPlayer;
@synthesize playerCellTag;

-(void) dealloc {
   [NSNotificationCenter.defaultCenter removeObserver:self name:ApplicationEndPlayingRingtone object:nil];
    [NSNotificationCenter.defaultCenter removeObserver:self name:ApplicationStartsPlayingRingtone object:nil];
    [NSNotificationCenter.defaultCenter removeObserver:self name:ApplicationDidFinishRingtoneConversion object:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    // //Add a edit button
    self.convertedTonesTableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    // [self.convertedTonesTableview setFrame:[[UIScreen mainScreen] bounds]];
    [self.convertedTonesTableview setDataSource:self];
    [self.convertedTonesTableview setDelegate:self];


    // self.arrayCells = [[NSMutableArray alloc] init];
    NSString *language = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];

    [self.convertedTonesTableview setEditing:NO];
    [self.convertedTonesTableview setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.convertedTonesTableview];

    // convertedTonesTableview.backgroundColor = [UIColor clearColor];
    [super viewDidLoad];
    UIView *view = [[UIView alloc] init];
    self.convertedTonesTableview.tableFooterView = view;
    [self reloadtableData];
    playerCellTag = -1;

    UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 29, 29)];
    [image setImage:[[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/CustomSoundPrefs.bundle/CustomSoundPrefs.png"] imageWithRenderingMode:nil]];
    self.navigationItem.titleView = image;
    
    NSString *buttonListen;
    if ([language isEqualToString:@"ar"]) {
        buttonListen = @"إستماع";
    } else {
        buttonListen = @"Listen";
    }
    //Add the Add button
    UIBarButtonItem * addButton = [[UIBarButtonItem alloc] initWithTitle:buttonListen style:UIBarButtonItemStyleBordered target:self action: @selector(applySelection)];

    self.navigationItem.rightBarButtonItem = addButton;

    // Do any additional setup after loading the view.
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(stopPlaying:) name:ApplicationEndPlayingRingtone object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(startPlaying:) name:ApplicationStartsPlayingRingtone object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(stopPlayingRingtone:) name:ApplicationDidStartPlayingSong object:nil];
    
     [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(successfullyFinishRingtoneConversion:) name:ApplicationDidFinishRingtoneConversion object:nil];
}

- (void)applySelection {
    NSMutableArray *songs = [[NSMutableArray alloc] init];
    
    for (NSString *song in self.myRingtonestableviewDatasource) {
        NSString *path = [@"/var/mobile/Library/CustomSound/Ringtones/" stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",  song]];
        MDAudioFile *audioFile = [[MDAudioFile alloc] initWithPath:[NSURL fileURLWithPath:path]];
        [songs addObject:audioFile];
    }
    
    MDAudioPlayerController *audioPlayer = [[MDAudioPlayerController alloc] initWithSoundFiles:songs atPath:@"/var/mobile/Library/CustomSound/Ringtones/" andSelectedIndex:nil];
    [self presentViewController:audioPlayer animated:YES completion:nil];
}

-(void) successfullyFinishRingtoneConversion:(NSNotification*) notification {
    [self reloadtableData];
    [self.convertedTonesTableview reloadData];
}

-(void) stopPlaying:(NSNotification*) notification {
    if ( audioPlayer ) {
        [audioPlayer stop];
        audioPlayer = nil;
    }
    playerCellTag = -1;
}

-(void) stopPlayingRingtone:(NSNotification*) notification  {
    NSString* filName = [[[audioPlayer url] absoluteString] lastPathComponent];
    
    [NSNotificationCenter.defaultCenter postNotificationName:ApplicationSuccessfullyPlayingRingtone object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:filName, @"fileName", nil]];
    if ( audioPlayer ) {
        [audioPlayer stop];
        audioPlayer = nil;
    }
    playerCellTag = -1;
}

-(void) startPlaying:(NSNotification*) notification {
    NSString* fileName = [[notification userInfo] objectForKey:@"fileName"];
    
    NSArray *libraryFolders = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *path = [@"/var/mobile/Library/CustomSound/Ringtones/" stringByAppendingPathComponent:fileName];
    
    if ( audioPlayer ) {
        [audioPlayer stop];
        audioPlayer = nil;
    }

    if(playerCellTag != -1) {
        PKGCell* cell = (PKGCell*)[self.convertedTonesTableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:playerCellTag inSection:0]];
        [cell setPlayerButtonToPauseMode];
    }
    
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:path] error:NULL];
    audioPlayer.delegate = self;
    [audioPlayer play];
    playerCellTag = [[[notification userInfo] objectForKey:@"tag"] integerValue];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    NSString* filName = [[[player url] absoluteString] lastPathComponent];
    
    [NSNotificationCenter.defaultCenter postNotificationName:ApplicationSuccessfullyPlayingRingtone object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:filName, @"fileName", nil]];
    audioPlayer = nil;
    playerCellTag = -1;
}


- (void)viewWillAppear:(BOOL)animated
{
    [UISegmentedControl appearanceWhenContainedIn:self.class, nil].tintColor = SIDELOADERTINT;
    [[UISwitch appearanceWhenContainedIn:self.class, nil] setOnTintColor:SIDELOADERTINT];
    self.view.tintColor = SIDELOADERTINT;
    self.navigationController.navigationBar.tintColor = SIDELOADERTINT;
    didDeleteCell = NO;
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    self.view.tintColor = nil;
    self.navigationController.navigationBar.tintColor = nil;
}

-(void)reloadtableData  {
    if(myRingtonestableviewDatasource)  {
        [myRingtonestableviewDatasource removeAllObjects];
        myRingtonestableviewDatasource = nil;
    }
    myRingtonestableviewDatasource = [NSMutableArray arrayWithArray:[self findFiles:@"m4r"]];
}

-(NSArray *)findFiles:(NSString *)extension{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *libraryDirectory = @"/var/mobile/Library/CustomSound/Ringtones/";
    
    NSMutableArray *matches = [[NSMutableArray alloc]init];
    NSFileManager *fManager = [NSFileManager defaultManager];
    NSString *item;
    NSArray *contents = [fManager contentsOfDirectoryAtPath:libraryDirectory error:nil];
    
    // >>> this section here adds all files with the chosen extension to an array
    for (item in contents){
        if ([[item pathExtension] isEqualToString:extension]) {
            [matches addObject:item];
        }
    }
    return matches;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if(didDeleteCell == NO && [self.myRingtonestableviewDatasource count] <= 0)   {
        return 1;
    }
    else  if(didDeleteCell == YES)  {
        didDeleteCell = NO;
        return [self.myRingtonestableviewDatasource count];
    }
    else    {
         return [self.myRingtonestableviewDatasource count];
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath  {
    
    if([self.myRingtonestableviewDatasource count] <= 0)   {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"EmptyCell"];
        cell.tag = indexPath.row;
        cell.textLabel.text = @"\t\t\tNo Ringtone...";
        //cell.detailTextLabel.text = @"\n";
        cell.detailTextLabel.textAlignment = NSTextAlignmentLeft;
        cell.detailTextLabel.numberOfLines = 5;
        [cell.textLabel setFont:[UIFont fontWithName:@"Helvetica Neue" size:18.0]];
        [cell.detailTextLabel setFont:[UIFont fontWithName:@"Helvetica Neue" size:14.0]];
        cell.detailTextLabel.textColor = [UIColor lightGrayColor];
        cell.textLabel.textColor = [UIColor grayColor];
        cell.backgroundColor = [UIColor colorWithRed:0.1843 green:0.2353 blue:0.3020 alpha:1.0];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        return cell;
    }

    static NSString *CellIdentifier = @"Cell";
    PKGCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)   {
        cell = [[PKGCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    cell.tag = indexPath.row;
    [cell initializeTableCellFileName:[myRingtonestableviewDatasource objectAtIndex:indexPath.row]];
    
    // Configure the cell...
    
    if(indexPath.row == playerCellTag)   {
        [cell setPlayerButtonToPlayMode];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	// Change the height if Edit Unknown Contact is the row selected
	return 52;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSUInteger row = [indexPath row];
    NSUInteger count = [self.myRingtonestableviewDatasource count];
    
    if([self.myRingtonestableviewDatasource count] <=0){
        return UITableViewCellEditingStyleNone;
    }
    
    if (row < count) {
        return UITableViewCellEditingStyleDelete;
    }
    else    {
         return UITableViewCellEditingStyleNone;
    }
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        NSString* filName = [[[audioPlayer url] absoluteString] lastPathComponent];
        
        [NSNotificationCenter.defaultCenter postNotificationName:ApplicationSuccessfullyPlayingRingtone object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:filName, @"fileName", nil]];
        if ( audioPlayer ) {
            [audioPlayer stop];
            audioPlayer = nil;
        }
        playerCellTag = -1;
         
        [tableView beginUpdates];
        NSArray *documentsFolders = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        NSString *path = [@"/var/mobile/Library/CustomSound/Ringtones/" stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", [self.myRingtonestableviewDatasource objectAtIndex:indexPath.row]]];
        didDeleteCell = YES;
        
        [self.myRingtonestableviewDatasource removeObjectAtIndex:indexPath.row];
        [self deleteFilewithpath:path OnCompletion:^(BOOL iFlag)   {
            
        }];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [tableView endUpdates];
//        [self reloadtableData];
//        [tableView reloadData];
    }
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,  0.1* NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self.convertedTonesTableview reloadData];
        
    });
}

#pragma mark - Table view delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if([self.myRingtonestableviewDatasource count] <=0)
        return;
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Share Ringtone" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Email Ringtone", @"put in Ringtones Path", nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [actionSheet setAlpha:0.8];
    actionSheet.tag = 1;
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex    {
    
    if(buttonIndex == 0)    {
        // email the ringtone
        [self emailConverted];
    }
    else if(buttonIndex == 1)   {
        // share via iTunes.
        [self sharingRingtoneViaiTunes];
    }
    else    {
        NSIndexPath* selectedRowIndexPath = [self.convertedTonesTableview indexPathForSelectedRow];
        [self.convertedTonesTableview deselectRowAtIndexPath:selectedRowIndexPath animated:YES];
    }
}

- (void)emailConverted  {
    NSIndexPath* selectedRowIndexPath = [self.convertedTonesTableview indexPathForSelectedRow];
    [self.convertedTonesTableview deselectRowAtIndexPath:selectedRowIndexPath animated:YES];
    
    NSArray *documentsFolders = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *path = [@"/var/mobile/Library/CustomSound/Ringtones/" stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", [self.myRingtonestableviewDatasource objectAtIndex:selectedRowIndexPath.row]]];
    
    MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
    mailController.mailComposeDelegate = self;
    [mailController setSubject:NSLocalizedString(@"New ringtone", @"")];
    [mailController addAttachmentData:[NSData dataWithContentsOfMappedFile:path]
                             mimeType:@"audio/mp4a-latm"
                             fileName:[path lastPathComponent]];
    
    [self presentViewController:mailController animated:YES completion:nil];
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)sharingRingtoneViaiTunes {
    
    NSIndexPath* selectedRowIndexPath = [self.convertedTonesTableview indexPathForSelectedRow];
   
    NSArray *libraryFolders = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *path = [@"/var/mobile/Library/CustomSound/Ringtones/" stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", [self.myRingtonestableviewDatasource objectAtIndex:selectedRowIndexPath.row]]];
    
    NSArray *DocumentFolders = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *destinationPath = [@"/Library/Ringtones/" stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", [self.myRingtonestableviewDatasource objectAtIndex:selectedRowIndexPath.row]]];
    
    [self deleteFilewithpath:destinationPath OnCompletion:^(BOOL iFlag)   {
        BOOL success;
        __weak NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError __autoreleasing *error;
        success = [fileManager copyItemAtPath:path toPath:destinationPath error:&error];
        [self.convertedTonesTableview deselectRowAtIndexPath:selectedRowIndexPath animated:YES];
        
        if (!success)
        {
            NSAssert1(0, @"[[[[[[[CustomSound]]]]]]]] *** Failed to create writable database file with message '%@'.", [error localizedDescription]);
        }
    }];
}

-(void) deleteFilewithpath:(NSString*)path OnCompletion:(BooleanClosure)iCompletion  {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    BOOL fileExists = [fileManager fileExistsAtPath:path];
    NSLog(@"Is deletable file at path: %d", [fileManager isDeletableFileAtPath:path]);
    if (fileExists)
    {
        BOOL success = [fileManager removeItemAtPath:path error:&error];
        if (!success) NSLog(@"Error: %@", [error localizedDescription]);
    }
    iCompletion(YES);
}
@end