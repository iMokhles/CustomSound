//
//  ASMyToneViewController.m
//  iRingtone Xpert
//
//  Created by imicreation on 13/06/14.
//  Copyright (c) 2014 Appsstreet. All rights reserved.
//

#import "ASMyToneViewControllerLS.h"
#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "ASConvertedTonesViewControllerLS.h"

NSString* ApplicationDidFinishRingtoneConversionLS = @"ApplicationDidFinishRingtoneConversionLS";
NSString * ApplicationDidStartPlayingSongLS = @"ApplicationDidStartPlayingSongLS";


@interface ASMyToneViewControllerLS (){
    AudioBufferList *readBuffer;
    NSTimer* audioPlayerTimer;
}
@end

@interface ASMyToneViewControllerLS ()

@property(nonatomic, retain) NSURL* mediaUrl;
@property(nonatomic, retain) NSTimer* convertingTimer;
@property (strong, nonatomic, getter=theNewRingtoneName) NSString*newRingtoneName;
@property(nonatomic, retain) UIImageView* logoImageView;

@end

#define checkResult(result,operation) (_checkResult((result),(operation),__FILE__,__LINE__))
static inline BOOL _checkResult(OSStatus result, const char *operation, const char* file, int line) {
    if ( result != noErr ) {
        NSLog(@"%s:%d: %s result %d %08X %4.4s\n", file, line, operation, (int)result, (int)result, (char*)&result);
        return NO;
    }
    return YES;
}

@implementation ASMyToneViewControllerLS
@synthesize startTimeLbl;
@synthesize endTimeLbl;
@synthesize timerSeeker;
@synthesize SongNameLbl;
@synthesize convertingLbl;
@synthesize ringtoneStartTimeLbl;
@synthesize ringtoneendTimeLbl;
@synthesize mediaUrl;
@synthesize ringtoneStartTimeLblString;
@synthesize ringtoneendTimeLblString;
@synthesize ringtoneNameLbl;
@synthesize startConvertingButton;
@synthesize ringtoneProgressView;
@synthesize convertingTimer;
@synthesize audioPlayBtn;
@synthesize seperatorLbl;
@synthesize newRingtoneName;
@synthesize audioPlot = _audioPlot;
@synthesize audioFile = _audioFile;
@synthesize eof = _eof;
@synthesize logoImageView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // if (self.audioPlot == nil && self.startConvertingButton == nil && self.audioPlayBtn == nil && self.ringtoneStartTimeLbl == nil && sel.ringtoneendTimeLbl == nil && self.ringtoneStartTimeLblString == nil && _ringtoneendTimeLblString == nil && _startTimeLbl == nil && _endTimeLbl == nil && _SongNameLbl == nil && _ringtoneNameLbl == nil && _convertingLbl == nil && _startConvertingButton == nil && _audioPlayBtn == nil && _seperatorLbl == nil && _timerSeeker == nil && _ringtoneProgressView == nil) {
    	self.startTimeLbl = [[UILabel alloc]initWithFrame:CGRectMake(222, 286, 40, 21)];
	    self.startTimeLbl.text = @"00.00";
	    self.startTimeLbl.font = [UIFont boldSystemFontOfSize:13];
	    [self.startTimeLbl setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
	    // self.startTimeLbl.numberOfLines = 1;
	    self.startTimeLbl.baselineAdjustment = UIBaselineAdjustmentAlignBaselines; // or UIBaselineAdjustmentAlignCenters, or UIBaselineAdjustmentNone
	    // self.startTimeLbl.adjustsFontSizeToFitWidth = YES;
	    // self.startTimeLbl.adjustsLetterSpacingToFitWidth = YES;
	    // self.startTimeLbl.minimumScaleFactor = 10.0f/12.0f;
	    self.startTimeLbl.clipsToBounds = YES;
	    self.startTimeLbl.backgroundColor = [UIColor clearColor];
	    self.startTimeLbl.textColor = [UIColor blackColor];
	    self.startTimeLbl.textAlignment = NSTextAlignmentCenter;
	    // [self.startTimeLbl sizeToFit];
	    [self.view addSubview:self.startTimeLbl];

	    self.endTimeLbl = [[UILabel alloc]initWithFrame:CGRectMake(268, 286, 40, 21)];
	    self.endTimeLbl.text = @"00.00";
	    self.endTimeLbl.font = [UIFont boldSystemFontOfSize:13];
	    [self.endTimeLbl setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
	    // self.startTimeLbl.numberOfLines = 1;
	    self.endTimeLbl.baselineAdjustment = UIBaselineAdjustmentAlignBaselines; // or UIBaselineAdjustmentAlignCenters, or UIBaselineAdjustmentNone
	    // self.startTimeLbl.adjustsFontSizeToFitWidth = YES;
	    // self.startTimeLbl.adjustsLetterSpacingToFitWidth = YES;
	    // self.startTimeLbl.minimumScaleFactor = 10.0f/12.0f;
	    self.endTimeLbl.clipsToBounds = YES;
	    self.endTimeLbl.backgroundColor = [UIColor clearColor];
	    self.endTimeLbl.textColor = [UIColor blackColor];
	    self.endTimeLbl.textAlignment = NSTextAlignmentCenter;
	    // [self.endTimeLbl sizeToFit];
	    [self.view addSubview:self.endTimeLbl];

	    self.ringtoneStartTimeLblString = [[UILabel alloc]initWithFrame:CGRectMake(21, 309, 80, 21)];
	    self.ringtoneStartTimeLblString.text = @"Start Time:";
	    self.ringtoneStartTimeLblString.font = [UIFont boldSystemFontOfSize:13];
	    [self.ringtoneStartTimeLblString setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
	    // self.startTimeLbl.numberOfLines = 1;
	    self.ringtoneStartTimeLblString.baselineAdjustment = UIBaselineAdjustmentAlignBaselines; // or UIBaselineAdjustmentAlignCenters, or UIBaselineAdjustmentNone
	    // self.startTimeLbl.adjustsFontSizeToFitWidth = YES;
	    // self.startTimeLbl.adjustsLetterSpacingToFitWidth = YES;
	    // self.startTimeLbl.minimumScaleFactor = 10.0f/12.0f;
	    self.ringtoneStartTimeLblString.clipsToBounds = YES;
	    self.ringtoneStartTimeLblString.backgroundColor = [UIColor clearColor];
	    self.ringtoneStartTimeLblString.textColor = [UIColor blackColor];
	    self.ringtoneStartTimeLblString.textAlignment = NSTextAlignmentCenter;
	    // [self.ringtoneStartTimeLblString sizeToFit];
	    [self.view addSubview:self.ringtoneStartTimeLblString];

	    self.ringtoneStartTimeLbl = [[UILabel alloc]initWithFrame:CGRectMake(100, 309, 40, 21)];
	    self.ringtoneStartTimeLbl.text = @"00:00";
	    self.ringtoneStartTimeLbl.font = [UIFont boldSystemFontOfSize:13];
	    [self.ringtoneStartTimeLbl setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
	    // self.startTimeLbl.numberOfLines = 1;
	    self.ringtoneStartTimeLbl.baselineAdjustment = UIBaselineAdjustmentAlignBaselines; // or UIBaselineAdjustmentAlignCenters, or UIBaselineAdjustmentNone
	    // self.startTimeLbl.adjustsFontSizeToFitWidth = YES;
	    // self.startTimeLbl.adjustsLetterSpacingToFitWidth = YES;
	    // self.startTimeLbl.minimumScaleFactor = 10.0f/12.0f;
	    self.ringtoneStartTimeLbl.clipsToBounds = YES;
	    self.ringtoneStartTimeLbl.backgroundColor = [UIColor clearColor];
	    self.ringtoneStartTimeLbl.textColor = [UIColor blackColor];
	    self.ringtoneStartTimeLbl.textAlignment = NSTextAlignmentCenter;
	    // [self.ringtoneStartTimeLbl sizeToFit];
	    [self.view addSubview:self.ringtoneStartTimeLbl];

	    self.ringtoneendTimeLblString = [[UILabel alloc]initWithFrame:CGRectMake(190, 309, 65, 21)];
	    self.ringtoneendTimeLblString.text = @"End Time:";
	    self.ringtoneendTimeLblString.font = [UIFont boldSystemFontOfSize:13];
	    [self.ringtoneendTimeLblString setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
	    // self.startTimeLbl.numberOfLines = 1;
	    self.ringtoneendTimeLblString.baselineAdjustment = UIBaselineAdjustmentAlignBaselines; // or UIBaselineAdjustmentAlignCenters, or UIBaselineAdjustmentNone
	    // self.startTimeLbl.adjustsFontSizeToFitWidth = YES;
	    // self.startTimeLbl.adjustsLetterSpacingToFitWidth = YES;
	    // self.startTimeLbl.minimumScaleFactor = 10.0f/12.0f;
	    self.ringtoneendTimeLblString.clipsToBounds = YES;
	    self.ringtoneendTimeLblString.backgroundColor = [UIColor clearColor];
	    self.ringtoneendTimeLblString.textColor = [UIColor blackColor];
	    self.ringtoneendTimeLblString.textAlignment = NSTextAlignmentCenter;
	    // [self.ringtoneendTimeLblString sizeToFit];
	    [self.view addSubview:self.ringtoneendTimeLblString];

	    self.ringtoneendTimeLbl = [[UILabel alloc]initWithFrame:CGRectMake(255, 309, 40, 21)];
	    self.ringtoneendTimeLbl.text = @"00:07";
	    self.ringtoneendTimeLbl.font = [UIFont boldSystemFontOfSize:13];
	    [self.ringtoneendTimeLbl setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
	    // self.startTimeLbl.numberOfLines = 1;
	    self.ringtoneendTimeLbl.baselineAdjustment = UIBaselineAdjustmentAlignBaselines; // or UIBaselineAdjustmentAlignCenters, or UIBaselineAdjustmentNone
	    // self.startTimeLbl.adjustsFontSizeToFitWidth = YES;
	    // self.startTimeLbl.adjustsLetterSpacingToFitWidth = YES;
	    // self.startTimeLbl.minimumScaleFactor = 10.0f/12.0f;
	    self.ringtoneendTimeLbl.clipsToBounds = YES;
	    self.ringtoneendTimeLbl.backgroundColor = [UIColor clearColor];
	    self.ringtoneendTimeLbl.textColor = [UIColor blackColor];
	    self.ringtoneendTimeLbl.textAlignment = NSTextAlignmentCenter;
	    // [self.ringtoneendTimeLbl sizeToFit];
	    [self.view addSubview:self.ringtoneendTimeLbl];

	    // NEW

	    self.SongNameLbl = [[UILabel alloc]initWithFrame:CGRectMake(25, 110, 271, 21)];
	    self.SongNameLbl.text = @"My song.mp3";
	    self.SongNameLbl.font = [UIFont boldSystemFontOfSize:13];
	    [self.SongNameLbl setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
	    // self.startTimeLbl.numberOfLines = 1;
	    self.SongNameLbl.baselineAdjustment = UIBaselineAdjustmentAlignBaselines; // or UIBaselineAdjustmentAlignCenters, or UIBaselineAdjustmentNone
	    // self.startTimeLbl.adjustsFontSizeToFitWidth = YES;
	    // self.startTimeLbl.adjustsLetterSpacingToFitWidth = YES;
	    // self.startTimeLbl.minimumScaleFactor = 10.0f/12.0f;
	    self.SongNameLbl.clipsToBounds = YES;
	    self.SongNameLbl.backgroundColor = [UIColor clearColor];
	    self.SongNameLbl.textColor = [UIColor blackColor];
	    self.SongNameLbl.textAlignment = NSTextAlignmentCenter;
	    // [self.SongNameLbl sizeToFit];
	    [self.view addSubview:self.SongNameLbl];

	    self.ringtoneNameLbl = [[UILabel alloc]initWithFrame:CGRectMake(3, 445, 310, 21)];
	    self.ringtoneNameLbl.text = @"My Ringtone.mp3";
	    self.ringtoneNameLbl.font = [UIFont boldSystemFontOfSize:13];
	    [self.ringtoneNameLbl setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
	    // self.startTimeLbl.numberOfLines = 1;
	    self.ringtoneNameLbl.baselineAdjustment = UIBaselineAdjustmentAlignBaselines; // or UIBaselineAdjustmentAlignCenters, or UIBaselineAdjustmentNone
	    // self.startTimeLbl.adjustsFontSizeToFitWidth = YES;
	    // self.startTimeLbl.adjustsLetterSpacingToFitWidth = YES;
	    // self.startTimeLbl.minimumScaleFactor = 10.0f/12.0f;
	    self.ringtoneNameLbl.clipsToBounds = YES;
	    self.ringtoneNameLbl.backgroundColor = [UIColor clearColor];
	    self.ringtoneNameLbl.textColor = [UIColor blackColor];
	    self.ringtoneNameLbl.textAlignment = NSTextAlignmentCenter;
	    // [self.ringtoneNameLbl sizeToFit];
	    [self.view addSubview:self.ringtoneNameLbl];

	    self.convertingLbl = [[UILabel alloc]initWithFrame:CGRectMake(109, 407, 103, 21)];
	    self.convertingLbl.text = @"Converting....";
	    self.convertingLbl.font = [UIFont boldSystemFontOfSize:13];
	    [self.convertingLbl setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
	    // self.startTimeLbl.numberOfLines = 1;
	    self.convertingLbl.baselineAdjustment = UIBaselineAdjustmentAlignBaselines; // or UIBaselineAdjustmentAlignCenters, or UIBaselineAdjustmentNone
	    // self.startTimeLbl.adjustsFontSizeToFitWidth = YES;
	    // self.startTimeLbl.adjustsLetterSpacingToFitWidth = YES;
	    // self.startTimeLbl.minimumScaleFactor = 10.0f/12.0f;
	    self.convertingLbl.clipsToBounds = YES;
	    self.convertingLbl.backgroundColor = [UIColor clearColor];
	    self.convertingLbl.textColor = [UIColor blackColor];
	    self.convertingLbl.textAlignment = NSTextAlignmentCenter;
	    // [self.convertingLbl sizeToFit];
	    [self.view addSubview:self.convertingLbl];

	    self.seperatorLbl = [[UILabel alloc]initWithFrame:CGRectMake(261, 286, 8, 21)];
	    self.seperatorLbl.text = @"/";
	    self.seperatorLbl.font = [UIFont boldSystemFontOfSize:13];
	    [self.seperatorLbl setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
	    // self.startTimeLbl.numberOfLines = 1;
	    self.seperatorLbl.baselineAdjustment = UIBaselineAdjustmentAlignBaselines; // or UIBaselineAdjustmentAlignCenters, or UIBaselineAdjustmentNone
	    // self.startTimeLbl.adjustsFontSizeToFitWidth = YES;
	    // self.startTimeLbl.adjustsLetterSpacingToFitWidth = YES;
	    // self.startTimeLbl.minimumScaleFactor = 10.0f/12.0f;
	    self.seperatorLbl.clipsToBounds = YES;
	    self.seperatorLbl.backgroundColor = [UIColor clearColor];
	    self.seperatorLbl.textColor = [UIColor blackColor];
	    self.seperatorLbl.textAlignment = NSTextAlignmentCenter;
	    // [self.seperatorLbl sizeToFit];
	    [self.view addSubview:self.seperatorLbl];

	    // Slider
	    self.timerSeeker = [[UISlider alloc] initWithFrame:CGRectMake(39, 268, 269, 31)];
	    [self.timerSeeker addTarget:self action:@selector(sliderValueChange:) forControlEvents:UIControlEventValueChanged];
	    [self.timerSeeker setBackgroundColor:[UIColor clearColor]];
	    [self.timerSeeker setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
	    self.timerSeeker.minimumValue = 0.0;
	    self.timerSeeker.maximumValue = 1;
	    // slider.continuous = YES;
	    self.timerSeeker.value = 0.5;
	    // [self.timerSeeker sizeToFit];
	    [self.timerSeeker setThumbImage:[UIImage imageNamed:@"/Library/PreferenceBundles/CustomSoundPrefs.bundle/SliderThumb.png"] forState:UIControlStateNormal];
	    [self.view addSubview:self.timerSeeker];

	    //Progress
	    self.ringtoneProgressView = [[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleBar];
	    //add the progressView to our main view.
	    [self.ringtoneProgressView setFrame:CGRectMake(47, 397, 227, 2)];
	    [self.ringtoneProgressView setProgress:0.5 animated:NO];
	    [self.ringtoneProgressView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
	    // [self.ringtoneProgressView sizeToFit];
	    [self.view addSubview: self.ringtoneProgressView];

	    // Buttons
	    self.audioPlayBtn = [DBTileButton buttonWithType:UIButtonTypeRoundedRect];
        [self.audioPlayBtn addTarget:self action:@selector(playBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        // [self.audioPlayBtn setTitle:@"Select a song" forState:UIControlStateNormal];
        self.audioPlayBtn.frame = CGRectMake(9.0, 266.0, 25.0, 23.0);
        [self.audioPlayBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        // self.audioPlayBtn.backgroundColor = SIDELOADERTINT;
        [self.audioPlayBtn setImage:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/CustomSoundPrefs.bundle/playRing.png"] forState:UIControlStateNormal];
        // [self.audioPlayBtn sizeToFit];
        [self.audioPlayBtn setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
        [self.view addSubview:self.audioPlayBtn];

        self.startConvertingButton = [DBTileButton buttonWithType:UIButtonTypeRoundedRect];
        [self.startConvertingButton addTarget:self action:@selector(StartConvertingBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.startConvertingButton setTitle:@"convert song" forState:UIControlStateNormal];
        self.startConvertingButton.frame = CGRectMake(84.0, 352.0, 153.0, 28.0);
        // [self.startConvertingButton setImage:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/CustomSoundPrefs.bundle/startConverting.png"] forState:UIControlStateNormal];
        // [self.startConvertingButton sizeToFit];
        [self.startConvertingButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.startConvertingButton.backgroundColor = SIDELOADERTINT;
        [self.startConvertingButton setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
        [self.view addSubview:self.startConvertingButton];

        self.audioPlot = [[EZAudioPlot alloc] init];
        self.audioPlot.frame = CGRectMake(0.0, 139.0, 320.0, 119.0);
        [self.audioPlot setBackgroundColor:[UIColor blueColor]];
        // [self.audioPlot sizeToFit];
        [self.audioPlot setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
        [self.view addSubview:self.audioPlot];

        DBTileButton *selectSongButton = [DBTileButton buttonWithType:UIButtonTypeRoundedRect];
	    [selectSongButton addTarget:self action:@selector(openMediaLibraryBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
	    [selectSongButton setTitle:@"Select a song" forState:UIControlStateNormal];
	    // [selectSongButton setImage:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/CustomSoundPrefs.bundle/OpenSong.png"] forState:UIControlStateNormal];
	    selectSongButton.frame = CGRectMake(93.0, 75.0, 135.0, 27.0);
	    // [selectSongButton sizeToFit];
	    [selectSongButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        selectSongButton.backgroundColor = SIDELOADERTINT;
	    [selectSongButton setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
	    [self.view addSubview:selectSongButton];

	    //Add the Add button
	    UIBarButtonItem * addButton = [[UIBarButtonItem alloc] initWithTitle:@"Songs" style:UIBarButtonItemStyleBordered target:self action: @selector(openConvertedSongs)];
	    self.navigationItem.rightBarButtonItem = addButton;

	    UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 29, 29)];
		[image setImage:[[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/CustomSoundPrefs.bundle/CustomSoundPrefs.png"] imageWithRenderingMode:nil]];
		self.navigationItem.titleView = image;

    // }
    
    // logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(25, 132, 270, 293)];
    // [logoImageView setImage:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/CustomSoundPrefs.bundle/logoImg.png"]];
    // [self.view addSubview:logoImageView];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    // Do any additional setup after loading the view
    audioPlayer = nil;
    /*
     Customizing the audio plot's look
     */
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(startPlayingRingtone:) name:ApplicationStartsPlayingRingtoneLS object:nil];
    
    // Background color
    self.audioPlot.backgroundColor = [UIColor colorWithRed: 0.1490 green: 0.2588 blue: 0.3961 alpha: 1.0];
    // Waveform color
    self.audioPlot.color           = [UIColor colorWithRed:0.2667 green:0.5843 blue:0.8235 alpha:0.0];
    // Plot type
    self.audioPlot.plotType        = EZPlotTypeBuffer;
    // Fill
    self.audioPlot.shouldFill      = YES;
    // Mirror
    self.audioPlot.shouldMirror    = YES;    
    [self resettingAllControls];
    
    // Initialise audio session, and register an interruption listener, important for AAC conversion
    if ( !checkResult(AudioSessionInitialize(NULL, NULL, interruptionListener,(__bridge void*) self), "initialise audio session") ) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Converting audio", @"")
                                     message:NSLocalizedString(@"Couldn't initialise audio session!", @"")
                                    delegate:nil
                           cancelButtonTitle:nil
                           otherButtonTitles:NSLocalizedString(@"OK", @""), nil] show];
        return;
    }
    
    [AVAudioSession sharedInstance];
    // register for notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(interruption:)
                                                 name:AVAudioSessionInterruptionNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(routeChange:)
                                                 name:AVAudioSessionRouteChangeNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [UISegmentedControl appearanceWhenContainedIn:self.class, nil].tintColor = SIDELOADERTINT;
    [[UISwitch appearanceWhenContainedIn:self.class, nil] setOnTintColor:SIDELOADERTINT];
    self.view.tintColor = SIDELOADERTINT;
    self.navigationController.navigationBar.tintColor = SIDELOADERTINT;

    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    self.view.tintColor = nil;
    self.navigationController.navigationBar.tintColor = nil;
}

- (void)openConvertedSongs {
	ASConvertedTonesViewControllerLS *convertedSongs = [[ASConvertedTonesViewControllerLS alloc] init];
    // [colorPickerPrefs colorFromDefaults:tweak_defaults withKey:saveKey];    
    [self.navigationController pushViewController:convertedSongs animated:YES]; //completion:nil];
}
-(void) startPlayingRingtone:(NSNotification*) notification {
    if(audioPlayer && audioPlayer.playing) {
        if(audioPlayerTimer)    {
            [audioPlayerTimer invalidate];
            audioPlayerTimer = nil;
        }
        [audioPlayBtn setImage:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/CustomSoundPrefs.bundle/playRing.png"] forState:UIControlStateNormal];
        audioPlayBtn.tag = 0;
        
        if(audioPlayer)
            [audioPlayer stop];
    }
}

-(void)openFileWithFilePathURL:(NSURL*)filePathURL {
    [self localpresentLoadingSpinnerWithText:@"Creating equalizer graph..." onView:self.view];
    self.audioPlot.hidden = YES;
    self.audioPlot.color = [UIColor colorWithRed:0.2667 green:0.5843 blue:0.8235 alpha:0.0];

    self.audioFile          = [EZAudioFile audioFileWithURL:filePathURL];
    self.eof                = NO;
    
    // Plot the whole waveform
    self.audioPlot.plotType        = EZPlotTypeBuffer;
    self.audioPlot.shouldFill      = YES;
    self.audioPlot.shouldMirror    = YES;
    [self.audioFile getWaveformDataWithCompletionBlock:^(float *waveformData, UInt32 length) {
        [self.audioPlot updateBuffer:waveformData withBufferSize:length];
        self.audioPlot.color = [UIColor colorWithRed:0.2667 green:0.5843 blue:0.8235 alpha:1.0];
        self.audioPlot.hidden = NO;
        [self removeLoadingSpinner];
    }];
}

- (void)routeChange:(NSNotification*)notification {
    
    NSDictionary *interuptionDict = notification.userInfo;
    
    NSInteger routeChangeReason = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    
    switch (routeChangeReason) {
        case AVAudioSessionRouteChangeReasonUnknown:
            NSLog(@"routeChangeReason : AVAudioSessionRouteChangeReasonUnknown");
            break;
            
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            // a headset was added or removed
            NSLog(@"routeChangeReason : AVAudioSessionRouteChangeReasonNewDeviceAvailable");
            break;
            
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
            // a headset was added or removed
            NSLog(@"routeChangeReason : AVAudioSessionRouteChangeReasonOldDeviceUnavailable");
            break;
            
        case AVAudioSessionRouteChangeReasonCategoryChange:
            // called at start - also when other audio wants to play
            NSLog(@"routeChangeReason : AVAudioSessionRouteChangeReasonCategoryChange");//AVAudioSessionRouteChangeReasonCategoryChange
            break;
            
        case AVAudioSessionRouteChangeReasonOverride:
            NSLog(@"routeChangeReason : AVAudioSessionRouteChangeReasonOverride");
            break;
            
        case AVAudioSessionRouteChangeReasonWakeFromSleep:
            NSLog(@"routeChangeReason : AVAudioSessionRouteChangeReasonWakeFromSleep");
            break;
            
        case AVAudioSessionRouteChangeReasonNoSuitableRouteForCategory:
            NSLog(@"routeChangeReason : AVAudioSessionRouteChangeReasonNoSuitableRouteForCategory");
            break;
            
        default:
            break;
    }
}

- (void)interruption:(NSNotification*)notification {
    // get the user info dictionary
    NSDictionary *interuptionDict = notification.userInfo;
    // get the AVAudioSessionInterruptionTypeKey enum from the dictionary
    NSInteger interuptionType = [[interuptionDict valueForKey:AVAudioSessionInterruptionTypeKey] integerValue];
    // decide what to do based on interruption type here...
    switch (interuptionType) {
        case AVAudioSessionInterruptionTypeBegan:
            NSLog(@"Audio Session Interruption case started.");
            // fork to handling method here...
            // EG:[self handleInterruptionStarted];
            break;
            
        case AVAudioSessionInterruptionTypeEnded:
            NSLog(@"Audio Session Interruption case ended.");
            // fork to handling method here...
            // EG:[self handleInterruptionEnded];
            break;
            
        default:
            NSLog(@"Audio Session Interruption Notification case default.");
            break;
    }
}

-(void) resettingAllControls    {
    timerSeeker.value =0.00;
    timerSeeker.maximumValue = 0.00;
    timerSeeker.minimumValue = 0.00;
    mediaUrl = nil;
    startTimeLbl.hidden = YES;
    endTimeLbl.hidden = YES;
    SongNameLbl.hidden = YES;
    timerSeeker.hidden = YES;
    convertingLbl.hidden = YES;
    ringtoneStartTimeLbl.hidden = YES;
    ringtoneendTimeLbl.hidden = YES;
    ringtoneStartTimeLblString.hidden = YES;
    ringtoneendTimeLblString.hidden = YES;
    ringtoneNameLbl.hidden = YES;
    startConvertingButton.hidden = YES;
    ringtoneProgressView.hidden = YES;
    convertingTimer = nil;
    convertingLbl.text = @"Converting .";
    self.newRingtoneName = nil;
    self.audioPlot.hidden = YES;
    self.audioPlayBtn.hidden = YES;
    self.seperatorLbl.hidden = YES;
    self.audioPlayBtn.tag = 0; // paly audio
    if(audioPlayerTimer)    {
        [audioPlayerTimer invalidate];
        audioPlayerTimer = nil;
    }
    audioPlayerTimer = nil;
    ringtoneStartTimeLbl.text = [NSString stringWithFormat:@"%02d:%02d", 0, 0];
    ringtoneendTimeLbl.text = [NSString stringWithFormat:@"%02d:08", 0];
    
    logoImageView.hidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma Local mathods and IBACTIOn Mathods

-(void)showMessage:(NSString *)message  {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentLoadingSpinnerWithText:message];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self removeLoadingSpinner];
    });
}

- (void) presentLoadingSpinnerWithText:(NSString*)text {
    [self localpresentLoadingSpinnerWithText:text onView:self.view];
}

-(void) localpresentLoadingSpinnerWithText:(NSString*)text onView:(UIView*) view  {
    NSArray* descriptions = [[NSArray alloc] initWithObjects:text, nil];
    if (genericLoadingView == nil){
        genericLoadingView = [[NF1LoadingView alloc] initWithDescriptionsArray:descriptions];
        CGRect loadingFrame = CGRectMake(100, 100, 75, 750);
        genericLoadingView.frame = loadingFrame;
        genericLoadingView.alpha = 0.0;
        [view addSubview:genericLoadingView];
        [view bringSubviewToFront:genericLoadingView];
    }
    
    [genericLoadingView updateWithDescriptionsArray:descriptions];
    
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self.view cache:YES];
	[UIView setAnimationDelegate:self];
    
    genericLoadingView.alpha = 1.0;
    
	[UIView commitAnimations];
}

- (void) removeLoadingSpinner {
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self.view cache:YES];
	[UIView setAnimationDelegate:self];
    
    genericLoadingView.alpha = 0.0;
    
	[UIView commitAnimations];
}


-(IBAction)openMediaLibraryBtnPressed:(id) sender   {
    [self localpresentLoadingSpinnerWithText:@"Opening Media..." onView:self.view];
    MPMediaPickerController *soundPicker=[[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeAnyAudio];
    soundPicker.delegate=self;
    soundPicker.view.backgroundColor = [UIColor blackColor];
    soundPicker.view.opaque = NO;
    soundPicker.allowsPickingMultipleItems=NO;
    [self presentViewController:soundPicker animated:YES completion:nil];
}

-(IBAction)StartConvertingBtnPressed:(id) sender    {
    if(audioPlayer && audioPlayer.playing) {
        if(audioPlayerTimer)    {
            [audioPlayerTimer invalidate];
            audioPlayerTimer = nil;
        }
        [audioPlayBtn setImage:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/CustomSoundPrefs.bundle/playRing.png"] forState:UIControlStateNormal];
        audioPlayBtn.tag = 0;
        
        if(audioPlayer)
            [audioPlayer stop];
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Name of ringtone" message:@"Please provide the name of new ringtone." delegate:self cancelButtonTitle:@"Start Converting" otherButtonTitles:nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.delegate = self;
    [alert textFieldAtIndex:0].delegate = self;
    [alert show];
}

-(NSString*)getTempMediaFileURL    {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *libraryCachesDirectory;// = [paths objectAtIndex:0];
    libraryCachesDirectory = [@"/var/mobile/Library/CustomSound/LSSounds/" stringByAppendingPathComponent:@"Caches"];
    
    return [NSString stringWithFormat:@"%@%@",libraryCachesDirectory,@"/abc.m4a"];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSLog(@"%@",[textField text]);
    
    if([[textField text] isEqualToString:@""])  {
        [self showMessage:@"Please enter name of new ringtone"];
    }
    else    {
        self.newRingtoneName =[NSString stringWithFormat:@"%@",textField.text];
        self.ringtoneNameLbl.text = [NSString stringWithFormat:@"%@.caf", newRingtoneName];
        
        [self localpresentLoadingSpinnerWithText:@"Converting to ringtone..." onView:self.view];
        
        convertingLbl.hidden = NO;
        ringtoneNameLbl.hidden = NO;
        ringtoneProgressView.hidden = NO;
        ringtoneProgressView.progress = 0.00;
        
        if(convertingTimer) {
            [convertingTimer invalidate];
            convertingTimer = nil;
        }
        
        convertingTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(changeConvertngLabelText) userInfo:nil repeats:YES];
        [convertingTimer fire];
        
        
        if(self.mediaUrl)   {
            [self deleteAlltempFilesOnCompletion:^(BOOL iFlag)   {
                [self trimVideoWithURL:self.mediaUrl];
            }];
        }
    }
}

-(IBAction)playBtnPressed:(id)sender    {
    
    if(audioPlayBtn.tag == 0)   {
        [audioPlayBtn setImage:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/CustomSoundPrefs.bundle/pauseRing.png"] forState:UIControlStateNormal];
        audioPlayBtn.tag = 1;
        if ( audioPlayer ) {
            [audioPlayer stop];
            audioPlayer = nil;
        }
        audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:mediaUrl error:NULL];
        if(audioPlayerTimer)    {
            [audioPlayerTimer invalidate];
            audioPlayerTimer = nil;
        }
        audioPlayerTimer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(updateTime:) userInfo:nil repeats:YES];

        audioPlayer.delegate = self;
        double value = timerSeeker.value;
        int minutes = (int)value;
        int seconds = (int) ((value- minutes)*60);
        audioPlayer.currentTime = (double)(minutes*60 +(double)seconds);
        [audioPlayer prepareToPlay];
        [audioPlayer play];
        
        // broadcast notification
        [NSNotificationCenter.defaultCenter postNotificationName:ApplicationDidStartPlayingSongLS object:nil userInfo:nil];
    }
    else    {
        if(audioPlayerTimer)    {
            [audioPlayerTimer invalidate];
            audioPlayerTimer = nil;
        }
        [audioPlayBtn setImage:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/CustomSoundPrefs.bundle/playRing.png"] forState:UIControlStateNormal];
        audioPlayBtn.tag = 0;
        
        if(audioPlayer)
            [audioPlayer stop];
    }
}

- (void)updateTime:(NSTimer *)timer {
    int minutes = audioPlayer.currentTime / 60;
    int seconds = (int)audioPlayer.currentTime % 60;
    int endSeconds = ((seconds + 8)>=60)?((seconds + 8)%60):(seconds + 8);
    int endMinutes = ((seconds + 8)>=60)?(minutes+1):(minutes);
    
    [self.timerSeeker setValue: (double)(minutes +(double)seconds/60) animated:YES];
    ringtoneStartTimeLbl.text = [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
    ringtoneendTimeLbl.text = [NSString stringWithFormat:@"%02d:%02d", endMinutes, endSeconds];
}


-(IBAction)sliderValueChange:(id)sender {

    @synchronized(self)
    {
        double value = timerSeeker.value;
        int minutes = (int)value;
        int seconds = (int) ((value- minutes)*60);
        
        int endSeconds = ((seconds + 8)>=60)?((seconds + 8)%60):(seconds + 8);
        int endMinutes = ((seconds + 8)>=60)?(minutes+1):(minutes);
        
        ringtoneStartTimeLbl.text = [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
        ringtoneendTimeLbl.text = [NSString stringWithFormat:@"%02d:%02d", endMinutes, endSeconds];
        
        // See if playback is active prior to skipping
        BOOL skipWhilePlaying = audioPlayer.playing;
        
        // NOTE: This stop,set,prepare,(play) sequence produces reliable results on the simulator and device.
        if(audioPlayer) {
            [audioPlayer stop];
            [audioPlayer setCurrentTime:(double)(minutes*60 +(double)seconds)];

            [audioPlayer prepareToPlay];
            // Resume playback if it was active prior to skipping
            if ( skipWhilePlaying ) {
                [audioPlayer play];
            }
        }
    }
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    if(audioPlayerTimer)    {
        [audioPlayerTimer invalidate];
        audioPlayerTimer = nil;
    }
    [audioPlayBtn setImage:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/CustomSoundPrefs.bundle/playRing.png"] forState:UIControlStateNormal];
    audioPlayBtn.tag = 0;
    [self.timerSeeker setValue: (double)0.0 animated:YES];
    
    if(audioPlayer)
        [audioPlayer stop];
    
    ringtoneStartTimeLbl.text = [NSString stringWithFormat:@"%02d:%02d", 0, 0];
    ringtoneendTimeLbl.text = [NSString stringWithFormat:@"%02d:%02d", 0, 8];
}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker {
    [mediaPicker dismissViewControllerAnimated:YES completion:nil];
    [self removeLoadingSpinner];
}

-(void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection
{
    MPMediaItem *item = [[mediaItemCollection items] objectAtIndex:0];
    NSURL *url = [item valueForProperty:MPMediaItemPropertyAssetURL];
    NSString* mediaTitle = [item valueForProperty:MPMediaItemPropertyTitle];
    [mediaPicker dismissViewControllerAnimated:YES completion:nil];
    AVPlayerItem *playerItem=[AVPlayerItem playerItemWithURL:url];
    AVPlayer *player=[[AVPlayer alloc] initWithPlayerItem:playerItem];
    AVPlayerLayer *playerLayer=[AVPlayerLayer playerLayerWithPlayer:player];
    playerLayer.frame=CGRectMake(0, 0, 10, 10);
    [self.view.layer addSublayer:playerLayer];
    self.SongNameLbl.text = mediaTitle;
    
    NSNumber *songTrackLength = [item valueForProperty:MPMediaItemPropertyPlaybackDuration];
    int minutes = floor([songTrackLength floatValue] / 60);
    int seconds = trunc([songTrackLength floatValue] - minutes * 60);
    self.endTimeLbl.text = [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
    double maxvalue = (double)(minutes +(double)seconds/60);
    
    logoImageView.hidden = YES;
    
    timerSeeker.maximumValue = maxvalue;
    timerSeeker.minimumValue = 0.00;
    
    startTimeLbl.hidden = NO;
    endTimeLbl.hidden = NO;
    SongNameLbl.hidden = NO;
    timerSeeker.hidden = NO;
    ringtoneStartTimeLbl.hidden = NO;
    ringtoneendTimeLbl.hidden = NO;
    ringtoneStartTimeLblString.hidden = NO;
    ringtoneendTimeLblString.hidden = NO;
    startConvertingButton.hidden = NO;
    self.audioPlayBtn.hidden = NO;
    self.seperatorLbl.hidden = NO;

    [self removeLoadingSpinner];
    
    [self openFileWithFilePathURL:url]; 

    self.mediaUrl = url;
    url = nil;
}

-(void) changeConvertngLabelText    {
    NSString* string = convertingLbl.text;
    unsigned long numberOfOccurences = [[string componentsSeparatedByString:@" ."] count]-1;
    
    if(numberOfOccurences == 1)
        string = @"Converting . .";
    else if(numberOfOccurences == 2)
        string = @"Converting . . .";
    else if(numberOfOccurences == 3)
        string = @"Converting . . . .";
    else if(numberOfOccurences == 4)
        string = @"Converting .";
    
    convertingLbl.text = string;
}

-(void) deleteAlltempFilesOnCompletion:(BooleanClosure)iCompletion  {
    NSString *strOutputFilePath = [self getTempMediaFileURL];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    BOOL fileExists = [fileManager fileExistsAtPath:strOutputFilePath];
    NSLog(@"Is deletable file at path: %d", [fileManager isDeletableFileAtPath:strOutputFilePath]);
    if (fileExists)
    {
        BOOL success = [fileManager removeItemAtPath:strOutputFilePath error:&error];
        if (!success) NSLog(@"Error: %@", [error localizedDescription]);
    }
    iCompletion(YES);
}

-(BOOL) trimVideoWithURL:(NSURL*) assetURL    {
    NSString *strOutputFilePath = [self getTempMediaFileURL];
    NSURL *audioFileOutput = [NSURL fileURLWithPath:strOutputFilePath];
    
    AVAsset *asset = [AVAsset assetWithURL:assetURL];
    AVAssetExportSession *exportSession = [AVAssetExportSession exportSessionWithAsset:asset
                                                                            presetName:AVAssetExportPresetAppleM4A];
    
    if (exportSession == nil)
    {
        return NO;
    }
//    float startTrimTime = 0;
//    float endTrimTime = 30;
    
    double value = timerSeeker.value;
    int minutes = (int)value;
    int seconds = (int) ((value- minutes)*60);
    float startTrimTime = minutes*60+seconds;
    float endTrimTime = (minutes*60+seconds) + 8;
    
    CMTime t= [asset duration];
    
    Float64 SongDuration = CMTimeGetSeconds(t);
    
    if (SongDuration < endTrimTime) {
        ringtoneProgressView.hidden = YES;
        
        if(convertingTimer) {
            [convertingTimer invalidate];
            convertingTimer = nil;
        }
        convertingLbl.hidden = YES;
        ringtoneNameLbl.hidden = YES;

        [self showMessage:@"Duration exceeds the limit..."];
        return NO;
    }

    CMTime startTime = CMTimeMake((int)(floor(startTrimTime * 100)), 100);
    CMTime stopTime = CMTimeMake((int)(ceil(endTrimTime * 100)), 100);
    CMTimeRange exportTimeRange = CMTimeRangeFromTimeToTime(startTime, stopTime);
    
    exportSession.outputURL = audioFileOutput;
    exportSession.outputFileType = AVFileTypeAppleM4A;
    exportSession.timeRange = exportTimeRange;
    
    [exportSession exportAsynchronouslyWithCompletionHandler:^
     {
         if (AVAssetExportSessionStatusCompleted == exportSession.status)
         {
             [self.ringtoneProgressView setProgress:0.20 animated:YES];
             NSLog(@"Success!");
             NSString *strOutputFilePath = [self getTempMediaFileURL];
             
             NSFileManager *fileManager = [NSFileManager defaultManager];
             if([fileManager fileExistsAtPath:strOutputFilePath])    {
                 [self convertAudioToRingtoneWithURL:strOutputFilePath];
             }
             else{
                 NSLog(@"Some Error Occured");
             }
         }
         else if (AVAssetExportSessionStatusFailed == exportSession.status)
         {
             NSLog(@"failed");
            [self removeLoadingSpinner];
         }
     }];
    
    return YES;
}

// Converter Library

// Callback to be notified of audio session interruptions (which have an impact on the conversion process)
static void interruptionListener(void *inClientData, UInt32 inInterruption)
{
	ASMyToneViewControllerLS *THIS = (__bridge ASMyToneViewControllerLS *)inClientData;
	
	if (inInterruption == kAudioSessionEndInterruption) {
		// make sure we are again the active session
		checkResult(AudioSessionSetActive(true), "resume audio session");
        if ( THIS->audioConverter ) [THIS->audioConverter resume];
	}
	
	if (inInterruption == kAudioSessionBeginInterruption) {
        if ( THIS->audioConverter ) [THIS->audioConverter interrupt];
    }
}

-(void)convertAudioToRingtoneWithURL:(NSString*) url   {
    if ( ![TPAACAudioConverter AACConverterAvailable] ) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Converting audio", @"")
                                     message:NSLocalizedString(@"Couldn't convert audio: Not supported on this device", @"")
                                    delegate:nil
                           cancelButtonTitle:nil
                           otherButtonTitles:NSLocalizedString(@"OK", @""), nil] show];
        return;
    }
    
    // Set up an audio session compatible with AAC conversion.  Note that AAC conversion is incompatible with any session that provides mixing with other device audio.
    UInt32 audioCategory = kAudioSessionCategory_MediaPlayback;
  
    if ( !checkResult(AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(audioCategory), &audioCategory), "setup session category") ) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Converting audio", @"")
                                     message:NSLocalizedString(@"Couldn't setup audio category!", @"")
                                    delegate:nil
                           cancelButtonTitle:nil
                           otherButtonTitles:NSLocalizedString(@"OK", @""), nil] show];
        return;
    }

    NSArray *documentsFolders = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    audioConverter = [[TPAACAudioConverter alloc] initWithDelegate:self
                                                             source: url
                                                        destination:[@"/var/mobile/Library/CustomSound/Sounds/" stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.caf", self.newRingtoneName]]];
    [audioConverter start];
}

#pragma mark - Audio converter delegate

-(void)AACAudioConverter:(TPAACAudioConverter *)converter didMakeProgress:(float)progress {
     [self.ringtoneProgressView setProgress:progress animated:YES];
}

-(void)AACAudioConverterDidFinishConversion:(TPAACAudioConverter *)converter {
    ringtoneProgressView.hidden = YES;
    
    if(convertingTimer) {
        [convertingTimer invalidate];
        convertingTimer = nil;
    }
    convertingLbl.text = @"Converted . . .";
    
    audioConverter = nil;
    // Delay execution of my block for 10 seconds.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,  1* NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self removeLoadingSpinner];
        [NSNotificationCenter.defaultCenter postNotificationName:ApplicationDidFinishRingtoneConversionLS object:nil userInfo:nil];
        [self openConvertedSongs];
        [self resettingAllControls];
    });
}

-(void)AACAudioConverter:(TPAACAudioConverter *)converter didFailWithError:(NSError *)error {
    [self removeLoadingSpinner];
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Converting audio", @"")
                                 message:[NSString stringWithFormat:NSLocalizedString(@"Couldn't convert audio: %@", @""), [error localizedDescription]]
                                delegate:nil
                       cancelButtonTitle:nil
                       otherButtonTitles:NSLocalizedString(@"OK", @""), nil] show];
    // self.convertButton.enabled = YES;
    audioConverter = nil;
}

@end