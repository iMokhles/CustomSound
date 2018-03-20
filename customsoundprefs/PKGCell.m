//
//  PKGCell.m
//  Created by kuldeep Tyagi.
//
//  Created by KULDEEP TYAGI on 24/01/13.
//
//

#import "PKGCell.h"
#import <QuartzCore/QuartzCore.h>

NSString* ApplicationStartsPlayingRingtone = @"ApplicationStartsPlayingRingtone";
NSString* ApplicationEndPlayingRingtone = @"ApplicationEndPlayingRingtone";
NSString* ApplicationSuccessfullyPlayingRingtone = @"ApplicationSuccessfullyPlayingRingtone";

#define COLUMN_WIDTH 200
#define TEXT_SIZE 15
#define TEXT_FONT_NAME @"Arial"

#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

@interface PKGCell ()
@property (nonatomic,retain) UIButton* importBtn;

@end

@implementation PKGCell
@synthesize importBtn;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(successfullyFinishPlaying:) name:ApplicationSuccessfullyPlayingRingtone object:nil];

        importBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [importBtn setFrame:CGRectMake(260, 8, 40, 38)];
        [importBtn setBackgroundColor:[UIColor clearColor]];
        [importBtn setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
        [importBtn addTarget:self action:@selector(PlayRingtonBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        [importBtn setTag:0];
        [self.contentView bringSubviewToFront:importBtn];
        [self.contentView addSubview:importBtn];
        
        self.backgroundColor = [UIColor colorWithRed:0.1843 green:0.2353 blue:0.3020 alpha:1.0];
        self.imageView.image = [UIImage imageNamed:@"playlistIcon.png"];
        self.textLabel.textColor = [UIColor whiteColor];
        
        UIView* separatorLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];/// change size as you need.
        separatorLineView.backgroundColor = [UIColor colorWithRed:0.1098 green:0.1608 blue:0.2314 alpha:1.0];// you can also put image here
        [self.contentView addSubview:separatorLineView];
        
        UIView *selectionColor = [[UIView alloc] init];
        selectionColor.backgroundColor = [UIColor colorWithRed:0.1098 green:0.1608 blue:0.2314 alpha:1.0];
        self.selectedBackgroundView = selectionColor;
    }
	return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated  {
    [super setSelected:selected animated:animated];
}

-(void)successfullyFinishPlaying:(NSNotification*) notification {
    NSString* fileName = [[notification userInfo] objectForKey:@"fileName"];
    
    if([fileName isEqualToString:self.textLabel.text])  {
        [importBtn setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
        importBtn.tag =0;
    }
}

#pragma mark Local mathods
-(void)initializeTableCellFileName:(NSString*)fileName  {
    if(fileName)
        [self.textLabel setText:fileName];
    
    [importBtn setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
}

-(void) setPlayerButtonToPlayMode   {
    [importBtn setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
    importBtn.tag =1;
}

-(void)setPlayerButtonToPauseMode   {
    [importBtn setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
    importBtn.tag =0;
}

-(void)PlayRingtonBtnPressed:(id)sender  {
    if(importBtn.tag == 0)  {
        [importBtn setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
        importBtn.tag =1;
        [NSNotificationCenter.defaultCenter postNotificationName:ApplicationStartsPlayingRingtone object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:self.textLabel.text, @"fileName", [NSNumber numberWithInteger:self.tag], @"tag", nil]];
    }
    else if(importBtn.tag == 1)   {
        [importBtn setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
        importBtn.tag =0;
        [NSNotificationCenter.defaultCenter postNotificationName:ApplicationEndPlayingRingtone object:nil userInfo:nil];
    }
}

-(void) dealloc {
    importBtn = NULL;
    [NSNotificationCenter.defaultCenter removeObserver:self name:ApplicationStartsPlayingRingtone object:nil];
}
@end