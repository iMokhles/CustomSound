//
//  PKGCell.h
//  Created by kuldeep Tyagi.
//
//  Created by KULDEEP TYAGI on 24/01/13.
//
//

#import <UIKit/UIKit.h>

extern NSString * ApplicationStartsPlayingRingtone;
extern NSString * ApplicationEndPlayingRingtone;
extern NSString * ApplicationSuccessfullyPlayingRingtone;

@interface PKGCell : UITableViewCell    {

}
-(void)initializeTableCellFileName:(NSString*)fileName;
-(void) setPlayerButtonToPlayMode ;
-(void)setPlayerButtonToPauseMode;
@end
