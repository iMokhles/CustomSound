#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <CoreMedia/CoreMedia.h>
// #import "TKToneTableController.h"
#include <objc/runtime.h>
#import <substrate.h>
#import <MediaPlayer/MediaPlayer.h>

#define PREFERENCES_PATH @"/var/mobile/Library/Preferences/com.imokhles.customsoundprefs.plist"
#define PREFERENCES_CHANGED_NOTIFICATION "com.imokhles.customsoundprefs.preferences-changed"

static BOOL enableSoundPrefs = NO;
static BOOL enableRingsPrefs = NO;
static float volumePrefs;
#define kEnableSoundPrefs @"EnablesoundPrefsKey"
#define kEnableRingsPrefs @"EnableringsPrefsKey"
#define kVolumePrefs @"volumePrefsKey"

static NSMutableDictionary *prefs(NSString *prefPath) {
    return [[NSMutableDictionary alloc] initWithContentsOfFile:prefPath];
}

static void setPermissionsForPath(NSString *path) {
    NSFileManager *fileMgr = [NSFileManager defaultManager];

    //Set root folder's attributes
    NSDictionary *directoryAttributes = [fileMgr attributesOfItemAtPath:path error:nil];
    NSMutableDictionary *defaultDirectoryAttributes = [NSMutableDictionary dictionaryWithCapacity:[directoryAttributes count]];
    [defaultDirectoryAttributes setDictionary:directoryAttributes];

    [defaultDirectoryAttributes setObject:[NSNumber numberWithInt:666] forKey:NSFileOwnerAccountID];
    [defaultDirectoryAttributes setObject:@"mobile" forKey:NSFileOwnerAccountName];
    [defaultDirectoryAttributes setObject:[NSNumber numberWithInt:666] forKey:NSFileGroupOwnerAccountID];
    [defaultDirectoryAttributes setObject:@"mobile" forKey:NSFileGroupOwnerAccountName];

    [defaultDirectoryAttributes setObject:[NSNumber numberWithShort:0666] forKey:NSFilePosixPermissions];

    [fileMgr setAttributes:defaultDirectoryAttributes ofItemAtPath:path error:nil];

    // for (NSString *subPath in [fileMgr contentsOfDirectoryAtPath:path error:nil]) {
    //     NSDictionary *attributes = [fileMgr attributesOfItemAtPath:[path stringByAppendingPathComponent:subPath] error:nil];
    //     if ([[attributes objectForKey:NSFileType] isEqualToString:NSFileTypeRegular]) {
    //         NSMutableDictionary *defaultAttributes = [NSMutableDictionary dictionaryWithCapacity:[directoryAttributes count]];
    //         [defaultAttributes setDictionary:directoryAttributes];

    //         [defaultAttributes setObject:[NSNumber numberWithInt:501] forKey:NSFileOwnerAccountID];
    //         [defaultAttributes setObject:@"mobile" forKey:NSFileOwnerAccountName];
    //         [defaultAttributes setObject:[NSNumber numberWithInt:501] forKey:NSFileGroupOwnerAccountID];
    //         [defaultAttributes setObject:@"mobile" forKey:NSFileGroupOwnerAccountName];

    //         if (executablePath && [[path stringByAppendingPathComponent:subPath] isEqualToString:executablePath])
    //             [defaultAttributes setObject:[NSNumber numberWithShort:0755] forKey:NSFilePosixPermissions];
    //         else
    //             [defaultAttributes setObject:[NSNumber numberWithShort:0644] forKey:NSFilePosixPermissions];

    //         [fileMgr setAttributes:defaultAttributes ofItemAtPath:[path stringByAppendingPathComponent:subPath] error:nil];
    //     } else if ([[attributes objectForKey:NSFileType] isEqualToString:NSFileTypeDirectory]) {
    //         setPermissionsForPath([path stringByAppendingPathComponent:subPath], executablePath);
    //     } else {
    //         //Ignore symblic links
    //     }
    // }
}

@interface TKToneTableController : NSObject <MPMediaPickerControllerDelegate>
@end

@interface RingtoneController : UIViewController
-(void)applicationWillSuspend;
-(void)viewDidAppear:(BOOL)arg1 ;
-(void)viewWillDisappear:(BOOL)arg1 ;
-(void)willBecomeActive;
@end

@interface NSTimer (Blocks)
+(id)scheduledTimerWithTimeInterval:(NSTimeInterval)inTimeInterval block:(void (^)())inBlock repeats:(BOOL)inRepeats;
+(id)timerWithTimeInterval:(NSTimeInterval)inTimeInterval block:(void (^)())inBlock repeats:(BOOL)inRepeats;
@end

@implementation NSTimer (Blocks)

+(id)scheduledTimerWithTimeInterval:(NSTimeInterval)inTimeInterval block:(void (^)())inBlock repeats:(BOOL)inRepeats {
    void (^block)() = [inBlock copy];
    id ret = [self scheduledTimerWithTimeInterval:inTimeInterval target:self selector:@selector(jdExecuteSimpleBlock:) userInfo:block repeats:inRepeats];
    return ret;
}

+(id)timerWithTimeInterval:(NSTimeInterval)inTimeInterval block:(void (^)())inBlock repeats:(BOOL)inRepeats {
    void (^block)() = [inBlock copy];
    id ret = [self timerWithTimeInterval:inTimeInterval target:self selector:@selector(jdExecuteSimpleBlock:) userInfo:block repeats:inRepeats];
    return ret;
}

+(void)jdExecuteSimpleBlock:(NSTimer *)inTimer;
{
    if([inTimer userInfo])
    {
        void (^block)() = (void (^)())[inTimer userInfo];
        block();
    }
}
@end

@interface SBMediaController
+(id)sharedInstance;
@property(nonatomic, getter=isRingerMuted) BOOL ringerMuted;
-(BOOL)isPlaying;
-(float)volume;
-(void)setVolume:(float)volume;
- (BOOL)togglePlayPause;
@end

// Settings --> Taken from DailyPaper Tweak open source here (https://github.com/hbang/DailyPaper)
#define GET_BOOL(key, default) (prefs(PREFERENCES_PATH)[key] ? ((NSNumber *)prefs(PREFERENCES_PATH)[key]).boolValue : default)
#define GET_FLOAT(key, default) (prefs(PREFERENCES_PATH)[key] ? ((NSNumber *)prefs(PREFERENCES_PATH)[key]).floatValue : default)
#define GET_INT(key, default) (prefs(PREFERENCES_PATH)[key] ? ((NSNumber *)prefs(PREFERENCES_PATH)[key]).intValue : default)

%group LSSounds
%hook SBLockScreenViewController

- (void)finishUIUnlockFromSource:(int)arg1 {

    %orig();
    NSURL *fileURL = [NSURL fileURLWithPath:@"/var/mobile/Library/CustomSound/ActiveSound/sound.caf" isDirectory:NO];
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:fileURL options:nil];
    CMTime time = asset.duration;
    double durationInSeconds = CMTimeGetSeconds(time);

    if (enableSoundPrefs && ![[%c(SBMediaController) sharedInstance] isPlaying] && ![[%c(SBMediaController) sharedInstance] isRingerMuted]) {
        [[%c(SBMediaController) sharedInstance] setVolume:20];
        SystemSoundID soundID;
        AudioServicesCreateSystemSoundID((__bridge_retained CFURLRef)fileURL,&soundID);
        AudioServicesPlaySystemSound(soundID);
    } else if (enableSoundPrefs && [[%c(SBMediaController) sharedInstance] isPlaying]){
    	//
        [[%c(SBMediaController) sharedInstance] pause];
        SystemSoundID soundID;
        AudioServicesCreateSystemSoundID((__bridge_retained CFURLRef)fileURL,&soundID);
        AudioServicesPlaySystemSound(soundID);
        [NSTimer scheduledTimerWithTimeInterval:durationInSeconds block:^{
            [[%c(SBMediaController) sharedInstance] togglePlayPause];
        } repeats:NO];
    } else if (!enableSoundPrefs || [[%c(SBMediaController) sharedInstance] isRingerMuted]) {
        %orig;
    }
    setPermissionsForPath(@"/Library/Ringtones/");

}
%end
%end

%group DVRingtones
%hook TKToneTableController

- (id)loadRingtonesFromPlist {
        // %orig;
    NSString *toneEnablerPath = @"/Librar/MobileSubstrate/DynamicLibraries/ToneEnabler.dylib";
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:toneEnablerPath];
    if (!fileExists) {
        NSDictionary *defRingtones = [NSDictionary dictionaryWithContentsOfFile:@"/System/Library/PrivateFrameworks/ToneKit.framework/TKRingtones.plist"];
        NSMutableDictionary *allRings = [NSMutableDictionary dictionary];
        NSMutableArray *clascRingtones = [NSMutableArray arrayWithArray:[defRingtones objectForKey:@"classic"]];
        NSMutableArray *modnRingtones = [NSMutableArray arrayWithArray:[defRingtones objectForKey:@"modern"]];
        
        NSString *tonesDirectory = @"/Library/Ringtones";
        NSFileManager *localFiles = [[NSFileManager alloc] init];
        NSDirectoryEnumerator *dirEnumTones2  = [localFiles enumeratorAtPath:tonesDirectory];

        NSString *fileTones2;
        while ((fileTones2 = [dirEnumTones2 nextObject]))
        {
            if ([[fileTones2 pathExtension] isEqualToString: @"m4r"]) {
                NSString *properToneIdentifier = [NSString stringWithFormat:@"system:%@",[fileTones2 stringByDeletingPathExtension]];
                BOOL isClascTone = [clascRingtones containsObject:properToneIdentifier];
                BOOL isModnTone  = [modnRingtones containsObject:properToneIdentifier];
                
                if(!isClascTone && !isModnTone)
                {
                    [modnRingtones addObject:properToneIdentifier];
                }
            }
        }
        
        [allRings setObject:clascRingtones forKey:@"classic"];
        [allRings setObject:modnRingtones  forKey:@"modern"];

        return allRings;
    }
    // NSString *toneEnablerPath = @"/Librar/MobileSubstrate/DynamicLibraries/ToneEnabler.dylib";

    // BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:toneEnablerPath];

    // if (fileExists) {
    //     %orig;
    //     NSDictionary *custDefRingtones = [NSDictionary dictionaryWithContentsOfFile:@"/System/Library/PrivateFrameworks/ToneKit.framework/TKRingtones.plist"];
    //     NSMutableDictionary *allRingtones = [NSMutableDictionary dictionary];
    //     NSMutableArray *classRingtones = [NSMutableArray arrayWithArray:[custDefRingtones objectForKey:@"classic"]];
    //     NSMutableArray *modeRingtones = [NSMutableArray arrayWithArray:[custDefRingtones objectForKey:@"modern"]];
    //     NSString *customRingPath = @"/var/mobile/Library/CustomSound/ConvertedRingtones/";
    //     NSFileManager *localFileRings = [[NSFileManager alloc] init];
    //     NSDirectoryEnumerator *ringDirEnum  = [localFileRings enumeratorAtPath:customRingPath];
    //     NSString *fileCustomRings;
    //     while ((fileCustomRings = [ringDirEnum nextObject])) {
    //         if ([[fileCustomRings pathExtension] isEqualToString: @"m4r"]) {
    //             NSString *properToneIdentifier = [NSString stringWithFormat:@"system:%@",[fileCustomRings stringByDeletingPathExtension]];
    //             BOOL isClassicTone = [classRingtones containsObject:properToneIdentifier];
    //             BOOL isModernTone  = [modeRingtones containsObject:properToneIdentifier];
                
    //             if(!isClassicTone && !isModernTone) {
    //                 [modeRingtones addObject:properToneIdentifier];
    //             }
    //         }
    //     }
    //     [allRingtones setObject:classRingtones forKey:@"classic"];
    //     [allRingtones setObject:modeRingtones  forKey:@"modern"];

    //     return allRingtones;
    // } else {
    // }
}
-(BOOL)_canShowStore {
    if (enableRingsPrefs) {
        return NO;
    } else {
        return %orig;
    }
}
%end

%hook RingtoneController
-(void)viewDidAppear:(BOOL)arg1 {
    %orig;
    if (enableRingsPrefs) {
        NSString *language = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
        NSString *buttonListen;
        if ([language isEqualToString:@"ar"]) {
            buttonListen = @"CustomSound";
        } else {
            buttonListen = @"CusstomSound";
        }
        UIBarButtonItem * addButton = [[UIBarButtonItem alloc] initWithTitle:buttonListen style:UIBarButtonItemStyleBordered target:self action: @selector(openSoundPicker)];
        self.navigationItem.rightBarButtonItem = addButton;
    } else {
        %orig;
    }
}
%new
- (void)openSoundPicker {
    NSURL *url;
    if ([[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/PreferenceOrganizer2.dylib"]) {
            // this is broken... https://github.com/angelXwind/PreferenceOrganizer2/issues/3
            url = [NSURL URLWithString:@"prefs:root=Tweaks&path=CustomSound"];
        } else {
            url = [NSURL URLWithString:@"prefs:root=CustomSound"];
        }

        [[UIApplication sharedApplication] openURL:url];
}
%end
%end

#pragma mark - Preferences

void LoadPrefs() {
	prefs(PREFERENCES_PATH);
	enableSoundPrefs = GET_BOOL(kEnableSoundPrefs, NO);
    enableRingsPrefs = GET_BOOL(kEnableRingsPrefs, NO);
    volumePrefs = GET_FLOAT(kVolumePrefs, 5);
	if (!prefs(PREFERENCES_PATH)) {
		[@{} writeToFile:PREFERENCES_PATH atomically:YES];
	}
}
%ctor {
    dlopen("/Library/MobileSubstrate/DynamicLibraries/ToneEnabler.dylib", RTLD_NOW);
    if ([[[NSBundle mainBundle] bundleIdentifier] isEqual:@"com.apple.springboard"]) {
        %init(LSSounds);
    } else if ([[[NSBundle mainBundle] bundleIdentifier] isEqual:@"com.apple.Preferences"]) {
        %init(DVRingtones);
    }
    %init();
	LoadPrefs();
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)LoadPrefs, CFSTR(PREFERENCES_CHANGED_NOTIFICATION), NULL, kNilOptions);
}