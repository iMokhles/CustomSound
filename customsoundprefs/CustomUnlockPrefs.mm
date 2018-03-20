// #import <Preferences/Preferences.h>
#import <Twitter/Twitter.h>
#import <Preferences/PSSpecifier.h>
#import <objc/runtime.h>
#import <Preferences/PSTableCell.h>
#import <Preferences/PSSwitchTableCell.h>
// #import "SVProgressHUD.h"
#import <UIKit/UIKit.h>
#import "NSTask.h"
#include "CustomRingPrefsSounds.h"
#import "ASMyToneViewControllerLS.h"
#import "ASMyToneViewController.h"

// static NSBundle* getBundle() {
//     return [NSBundle bundleWithPath:@"/Library/PreferenceBundles/CustomSoundPrefs.bundle"];
// }

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_5 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0)
#define IS_RETINA ([[UIScreen mainScreen] scale] == 2.0)

#define SIDELOADERTINT [UIColor colorWithRed: 255.0/255.0 green: 45.0/255.0 blue: 85.0/255.0 alpha: 1.0]

#define kUrl_FollowOnTwitter @"https://twitter.com/imokhles"
#define kUrl_VisitWebSite @"http://imokhles.com"
#define kUrl_MakeDonation @"https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=F4ZGWKWBKT82Y"

#define kCustomSoundSettingsFile [NSString stringWithFormat:@"%@/Library/Preferences/%@.plist", NSHomeDirectory(), SETTINGSFILE]
#define SETTINGSFILE @"com.imokhles.customsoundprefs"
#define TWEAKENABLEDKEY @"EnablesoundPrefsKey"
#define kEnableRingsPrefs @"EnableringsPrefsKey"
#define PREFERENCES_CHANGED_NOTIFICATION @"com.imokhles.customsoundprefs.preferences-changed"

#define LOCLIZE_VERSION_KEY @"VERSION"

#define yearMade @"2014"
#define VERSION_KEY @"1.0-7"

#define FOLLOW_KEY @"IMOKHLES"
#define VSITE_KEY @"IMOKHLESSITE"
#define DONATTO_KEY @"DONATETO"

@interface PSSpecifier (Actions)
- (SEL)action;
- (void)setAction:(SEL)action;
@end

@implementation PSSpecifier (Actions)
- (SEL)action {
	return action;
}
- (void)setAction:(SEL)a {
	action = a;
}
@end

@interface PSTableCell()
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier;
@end

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

@interface CustomSoundBannerCell : PSTableCell {
    UIImageView *_imageView;
}
@end

@interface CustomSoundPrefsListController: PSListController {
	NSMutableDictionary *settingsDictionary;
	PSSpecifier *banner;
	PSSpecifier *enableSpecifier;
	PSSpecifier *enableRingsSpecifier;
	PSSpecifier *soundsListLinkCell;
	PSSpecifier *ringtsListLinkCell;
	PSSpecifier *versionCell;
    PSSpecifier *followCell;
    PSSpecifier *vSiteCell;
    PSSpecifier *donateToCell;
	PSSpecifier *spacer;
	PSSpecifier *footer;
}
-(void)shareTapped:(UIBarButtonItem *)sender;
@end

@implementation CustomSoundPrefsListController

- (id)init {
	if (self = [super init]) settingsDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:[kCustomSoundSettingsFile stringByExpandingTildeInPath]];
	return self;
}

-(void)loadView {
    UIBarButtonItem *tweet = [[UIBarButtonItem alloc] initWithImage:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/CustomSoundPrefs.bundle/hearts.png"] style:UIBarButtonItemStylePlain target:self action:@selector(shareTapped:)];
	UIGraphicsBeginImageContextWithOptions(CGSizeMake(22, 22), NO, 0.0);
	UIImage *blank = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	[tweet setBackgroundImage:blank forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
	self.navigationItem.rightBarButtonItem = tweet;
    [super loadView];
    
}

- (void)viewDidLoad {
	[super viewDidLoad];
	UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 29, 29)];
	[image setImage:[[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/CustomSoundPrefs.bundle/CustomSoundPrefs.png"] imageWithRenderingMode:nil]];
	self.navigationItem.titleView = image;
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

- (void)followOnTwitter:(PSSpecifier*)specifier {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:kUrl_FollowOnTwitter]];
}

- (void)visitWebSite:(PSSpecifier*)specifier {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:kUrl_VisitWebSite]];
}

- (void)makeDonation:(PSSpecifier *)specifier {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:kUrl_MakeDonation]];
}

- (NSString *)versionValue:(PSSpecifier *)specifier {
    
	NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath: @"/bin/sh"];
    [task setArguments:[NSArray arrayWithObjects: @"-c", @"dpkg -s com.imokhles.CustomSound | grep 'Version'", nil]];
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput:pipe];
    [task launch];
    NSData *data = [[[task standardOutput] fileHandleForReading] readDataToEndOfFile];
    NSString *version = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    NSString *subString = [version substringFromIndex:[version length] - 6];
    //[pipe release]; //crashes
    return subString;
}

-(void)shareTapped:(UIBarButtonItem *)sender {
    NSString *text;

    NSString *btnTitle;
    NSString *language = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
    if ([language isEqualToString:@"ar"]) {
        text = @"انا استخدم اداة #CustomSound بواسطة @iMokhles لتخصيص صوت فتح القفل للاصدار #iOS7";
    } else {
        text = @"I like #CustomSound by @iMokhles to customize my unlock sound for #iOS7";
    } 

	if (objc_getClass("UIActivityViewController")) {
		UIActivityViewController *viewController = [[UIActivityViewController alloc] initWithActivityItems:[NSArray arrayWithObjects:text, nil] applicationActivities:nil];
		[self.navigationController presentViewController:viewController animated:YES completion:NULL];
	} else {
		text = [text stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://twitter.com/intent/tweet?text=%@", text]]];
	}
}
// - (void)openColorPicker:(PSSpecifier*)specifier {
//     NSString *saveKey = [[specifier properties] objectForKey:@"saveKey"];
//     NSString *notification = [specifier propertyForKey:@"PostNotification"];
    
//     CustomSoundPrefsSoundsListController *custonSoundsTable = [[CustomSoundPrefsSoundsListController alloc] init];
//     // [colorPickerPrefs colorFromDefaults:tweak_defaults withKey:saveKey];
//     custonSoundsTable.viewTitle = @"Sounds List";
    
//     [self pushController:custonSoundsTable animate:YES];
// }

- (PSSpecifier *)footer {

    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath: @"/bin/sh"];
    [task setArguments:[NSArray arrayWithObjects: @"-c", @"dpkg -s com.imokhles.CustomSound | grep 'Version'", nil]];
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput:pipe];
    [task launch];
    
    NSData *data = [[[task standardOutput] fileHandleForReading] readDataToEndOfFile];
    NSString *version = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];


	// [task release];
	//[pipe release]; //crashes

    footer = [PSSpecifier preferenceSpecifierNamed:@"" target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
    [footer setProperty:[NSString stringWithFormat:@"© iMokhles %@", [self dynamicYear]] forKey:@"footerText"];
    [footer setProperty:@"1" forKey:@"footerAlignment"];

	//[data release]; crashes
	// [version release];

    return footer;
}

- (NSString *)dynamicYear {
   
    NSString *dynamicYear = @"";
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    [dateFormatter setDateFormat:@"yyyy"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSDate *date = [NSDate date];
    NSString *dateString = [dateFormatter stringFromDate:date];
    if([yearMade isEqual:dateString]){
    dynamicYear = dateString;
    } else {
    dynamicYear = [NSString stringWithFormat:@"%@ - %@", yearMade, dateString];
    }

return dynamicYear;
}

- (id)specifiers {
	if(_specifiers == nil) {
		// _specifiers = [self loadSpecifiersFromPlistName:@"CustomSoundPrefs" target:self];
		banner = [PSSpecifier preferenceSpecifierNamed:@"CS" target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
	    [banner setProperty:@"CustomSoundBannerCell" forKey:@"headerCellClass"];

		spacer = [PSSpecifier preferenceSpecifierNamed:@"" target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil];

		NSString *language = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
	    if ([language isEqualToString:@"ar"]) {
	    	enableSpecifier = [PSSpecifier preferenceSpecifierNamed:@"تفعيل" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSSwitchCell edit:nil];
	    } else {
	    	enableSpecifier = [PSSpecifier preferenceSpecifierNamed:@"Enable" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSSwitchCell edit:nil];
	    }
		[enableSpecifier setProperty:SETTINGSFILE forKey:@"defaults"];
		[enableSpecifier setProperty:TWEAKENABLEDKEY forKey:@"key"];
		[enableSpecifier setProperty:@"0" forKey:@"hasIcon"];
		[enableSpecifier setProperty:PREFERENCES_CHANGED_NOTIFICATION forKey:@"postNotification"];

	    if ([language isEqualToString:@"ar"]) {
	    	enableRingsSpecifier = [PSSpecifier preferenceSpecifierNamed:@"تفعيل" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSSwitchCell edit:nil];
	    } else {
	    	enableRingsSpecifier = [PSSpecifier preferenceSpecifierNamed:@"Enable" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSSwitchCell edit:nil];
	    }
		[enableRingsSpecifier setProperty:SETTINGSFILE forKey:@"defaults"];
		[enableRingsSpecifier setProperty:kEnableRingsPrefs forKey:@"key"];
		[enableRingsSpecifier setProperty:@"0" forKey:@"hasIcon"];
		[enableRingsSpecifier setProperty:PREFERENCES_CHANGED_NOTIFICATION forKey:@"postNotification"];

		if ([language isEqualToString:@"ar"]) {
			soundsListLinkCell = [PSSpecifier preferenceSpecifierNamed:@"قائمة الصوتيات" target:self set:nil get:nil detail:[ASMyToneViewControllerLS class] cell:PSLinkCell edit:nil];
	    } else {
			soundsListLinkCell = [PSSpecifier preferenceSpecifierNamed:@"Sounds List" target:self set:nil get:nil detail:[ASMyToneViewControllerLS class] cell:PSLinkCell edit:nil];
	    }
		[soundsListLinkCell setProperty:@"0" forKey:@"hasIcon"];

		if ([language isEqualToString:@"ar"]) {
			ringtsListLinkCell = [PSSpecifier preferenceSpecifierNamed:@"نغمات رنين" target:self set:nil get:nil detail:[ASMyToneViewController class] cell:PSLinkCell edit:nil];
	    } else {
			ringtsListLinkCell = [PSSpecifier preferenceSpecifierNamed:@"RingTons" target:self set:nil get:nil detail:[ASMyToneViewController class] cell:PSLinkCell edit:nil];
	    }
		[ringtsListLinkCell setProperty:@"0" forKey:@"hasIcon"];
		// [soundsListLinkCell setProperty:@"/Library/PreferenceBundles/SideLoaderPrefs.bundle/Images/flipswitch_options.png" forKey:@"icon"];
		// [soundsListLinkCell setupIconImageWithPath:@"/Library/PreferenceBundles/SideLoaderPrefs.bundle/Images/flipswitch_options.png"];

		if ([language isEqualToString:@"ar"]) {
			versionCell = [PSSpecifier preferenceSpecifierNamed:@"الإصدار" target:self set:nil get:@selector(versionValue:) detail:nil cell:PSTitleValueCell edit:nil];
	    } else {
			versionCell = [PSSpecifier preferenceSpecifierNamed:@"version" target:self set:nil get:@selector(versionValue:) detail:nil cell:PSTitleValueCell edit:nil];
	    }
		[versionCell setProperty:@"0" forKey:@"hasIcon"];
        
        if ([language isEqualToString:@"ar"]) {
        	followCell = [PSSpecifier preferenceSpecifierNamed:@"تابعني @iMokhles" target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
	    } else {
        	followCell = [PSSpecifier preferenceSpecifierNamed:@"Follow @iMokhles" target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
	    }
		[followCell setProperty:@"1" forKey:@"hasIcon"];
        [followCell setAction:@selector(followOnTwitter:)];
        [followCell setProperty:@"/Library/PreferenceBundles/CustomSoundPrefs.bundle/Images/Twitter.png" forKey:@"icon"];
		[followCell setupIconImageWithPath:@"/Library/PreferenceBundles/CustomSoundPrefs.bundle/Images/Twitter.png"];
        
        if ([language isEqualToString:@"ar"]) {
        	vSiteCell = [PSSpecifier preferenceSpecifierNamed:@"قم بزيارة موقعي" target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
	    } else {
        	vSiteCell = [PSSpecifier preferenceSpecifierNamed:@"visit my site" target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
	    }
		[vSiteCell setProperty:@"1" forKey:@"hasIcon"];
        [vSiteCell setAction:@selector(visitWebSite:)];
        [vSiteCell setProperty:@"/Library/PreferenceBundles/CustomSoundPrefs.bundle/Images/Site.png" forKey:@"icon"];
		[vSiteCell setupIconImageWithPath:@"/Library/PreferenceBundles/CustomSoundPrefs.bundle/Images/Site.png"];
        
        if ([language isEqualToString:@"ar"]) {
        	donateToCell = [PSSpecifier preferenceSpecifierNamed:@"قم بدعمي" target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
	    } else {
        	donateToCell = [PSSpecifier preferenceSpecifierNamed:@"Donate to me" target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
	    }
		[donateToCell setProperty:@"1" forKey:@"hasIcon"];
        [donateToCell setAction:@selector(makeDonation:)];
		[donateToCell setProperty:@"/Library/PreferenceBundles/CustomSoundPrefs.bundle/Images/Donate.png" forKey:@"icon"];
		[donateToCell setupIconImageWithPath:@"/Library/PreferenceBundles/CustomSoundPrefs.bundle/Images/Donate.png"];


		_specifiers = [NSArray arrayWithObjects:banner, [self footerUNSound], enableSpecifier, soundsListLinkCell, [self footerRGSound], enableRingsSpecifier, ringtsListLinkCell, spacer, versionCell, [self footerMY], followCell, vSiteCell, donateToCell, [self footer], nil];
	}
	return _specifiers;
}

- (PSSpecifier *)footerUNSound {
	NSString *language = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
	PSSpecifier *footerUNSound = [PSSpecifier preferenceSpecifierNamed:@"" target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
	if ([language isEqualToString:@"ar"]) {
		[footerUNSound setProperty:@"هذه الخيارات خاصة بصوتيات شاشة القفل فقط, التي تسمح لك بتخصيص صوت خاص بك عند فتح شاشة القفل" forKey:@"footerText"];
	} else {
		[footerUNSound setProperty:@"those options for lockscreen sounds only, which let you customize your own unlock sound" forKey:@"footerText"];
	}
    [footerUNSound setProperty:@"1" forKey:@"footerAlignment"];
    return footerUNSound;
}
- (PSSpecifier *)footerRGSound {
	PSSpecifier *footerRGSound = [PSSpecifier preferenceSpecifierNamed:@"" target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
	NSString *language = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
	if ([language isEqualToString:@"ar"]) {
		[footerRGSound setProperty:@"هذه الخيارات خاصة بصوتيات الرنين فقط, والتى تسمح لك بتخصيص نغمة رنين خاصة بك" forKey:@"footerText"];
	} else {
		[footerRGSound setProperty:@"those options for Ringtones sounds only, which let you customize you own ringtone." forKey:@"footerText"];
	}
    [footerRGSound setProperty:@"1" forKey:@"footerAlignment"];
    return footerRGSound;
}
- (PSSpecifier *)footerMY {
	PSSpecifier *footerMY = [PSSpecifier preferenceSpecifierNamed:@"" target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
	NSString *language = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
	if ([language isEqualToString:@"ar"]) {
		[footerMY setProperty:@"قم بدعمي اذا اردت ذلك" forKey:@"footerText"];
	} else {
		[footerMY setProperty:@"support me if you would like to do that :)" forKey:@"footerText"];
	}
    [footerMY setProperty:@"1" forKey:@"footerAlignment"];
    return footerMY;
}
@end

@implementation CustomSoundBannerCell
- (id)initWithSpecifier:(PSSpecifier *)specifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"headerCell" specifier:specifier];
    if (self) {
        [self setBackgroundColor:SIDELOADERTINT];
        if (IS_IPHONE) {
            _imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[getBundle() pathForResource:@"CustomSoundHeader" ofType:@"png"]]];
            [self addSubview:_imageView];
        } else if (IS_IPHONE_5) {
            _imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[getBundle() pathForResource:@"CustomSoundHeader" ofType:@"png"]]];
            [self addSubview:_imageView];
        }
        
        _imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[getBundle() pathForResource:@"banner" ofType:@"png"]]];
        [self addSubview:_imageView];
    }
    return self;
}

- (CGFloat)preferredHeightForWidth:(CGFloat)arg1
{
    // Return a custom cell height.
    if (IS_IPHONE) {
        return 192.0f;
    } else if (IS_IPHONE_5) {
        return 384.0f;
    } else if (IS_IPAD) {
        return 384.0f;
    } else if (IS_RETINA) {
        return 384.0f;
    }
    return 384.0f;
}
@end
// vim:ft=objc
