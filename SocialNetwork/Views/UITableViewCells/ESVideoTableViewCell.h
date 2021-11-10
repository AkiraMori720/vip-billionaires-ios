//
//  ESVideoTableViewCell.h
//  d'Netzwierk
//
//  Created by Eric Schanet on 07.12.14.
//
//
#import <MediaPlayer/MediaPlayer.h>
#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
/**
 *  Interface of the ESVideoTableViewCell, the cell that contains the video in the timeline
 */
@interface ESVideoTableViewCell : PFTableViewCell
/**
 *  Movieplayer used to play the video
 */
@property (nonatomic, retain) AVPlayerViewController *movie;
@property (nonatomic, strong) UILabel *lblDescription;
@property (nonatomic, strong) UIButton *btnEdit;
@property (nonatomic, strong) PFObject *object;

/**
 *  Button on top the video used to catch taps
 */
@property (nonatomic, strong) UIButton *mediaItemButton;
/**
 *  Imageview containing the thumbnail image of the video. The thumbnail is displayed as static image and the video starts as soon as the play button is tapped
 */
@property (nonatomic, strong) PFImageView *thumbnail;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier object:(PFObject*)object;
@end
