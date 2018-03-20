//
//  PKGCell.h
//  Created by kuldeep Tyagi.
//
//  Created by KULDEEP TYAGI on 24/01/13.
//
//

#import <UIKit/UIKit.h>

extern NSString * ApplicationStartsPlayingRingtoneLS;
extern NSString * ApplicationEndPlayingRingtoneLS;
extern NSString * ApplicationSuccessfullyPlayingRingtoneLS;

@interface PKGCellLS : UITableViewCell    {

}
-(void)initializeTableCellFileName:(NSString*)fileName;
-(void) setPlayerButtonToPlayMode ;
-(void)setPlayerButtonToPauseMode;
@end
