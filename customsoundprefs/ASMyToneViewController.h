//
//  ASMyToneViewController.h
//  iRingtone Xpert
//
//  Created by imicreation on 13/06/14.
//  Copyright (c) 2014 Appsstreet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "NF1LoadingView.h"
#import "TPAACAudioConverter.h"
#import "EZAudio.h"
#import "PKGCell.h"
#import <Preferences/PSSpecifier.h>
#include <objc/runtime.h>
#import "ASConvertedTonesViewController.h"
#import "Headers.h"

extern NSString * ApplicationDidFinishRingtoneConversion;
extern NSString * ApplicationDidStartPlayingSong;

typedef void (^BooleanClosure)(BOOL iFlag);

@class AVAudioPlayer;
@interface ASMyToneViewController : PSViewController <MPMediaPickerControllerDelegate, TPAACAudioConverterDelegate, UITextFieldDelegate, UIAlertViewDelegate, AVAudioPlayerDelegate>  {
    NF1LoadingView* genericLoadingView;
    AVAudioPlayer *audioPlayer;
    TPAACAudioConverter *audioConverter;
}

/**
 The EZAudioFile representing of the currently selected audio file
 */
@property (nonatomic,strong) EZAudioFile *audioFile;

/**
 The CoreGraphics based audio plot
 */
@property (nonatomic, strong) EZAudioPlot *audioPlot;

/**
 A BOOL indicating whether or not we've reached the end of the file
 */
@property (nonatomic,assign) BOOL eof;

@property(nonatomic, strong) UILabel* ringtoneStartTimeLbl;
@property(nonatomic, strong) UILabel* ringtoneendTimeLbl;
@property(nonatomic, strong) UILabel* ringtoneStartTimeLblString;
@property(nonatomic, strong) UILabel* ringtoneendTimeLblString;

@property(nonatomic, strong) UILabel* startTimeLbl;
@property(nonatomic, strong) UILabel* endTimeLbl;
@property(nonatomic, strong) UILabel* SongNameLbl; // Reste
@property(nonatomic, strong) UILabel* ringtoneNameLbl; // Reste
@property(nonatomic, strong) UILabel* convertingLbl; // Reste
@property(nonatomic, strong) DBTileButton* startConvertingButton; // Reste
@property(nonatomic, strong) DBTileButton* audioPlayBtn; // Reste
@property(nonatomic, strong) UILabel* seperatorLbl; // Reste

@property(nonatomic, strong) UISlider* timerSeeker; // Reste
@property(nonatomic, strong) UIProgressView* ringtoneProgressView; // Reste

-(void) localpresentLoadingSpinnerWithText:(NSString*)text onView:(UIView*) view;
- (void) removeLoadingSpinner;
@end
