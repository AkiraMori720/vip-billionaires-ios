//
//  ESFindFriendsCell.h
//  D'Netzwierk
//
//  Created by Eric Schanet on 6/05/2014.
//  Copyright (c) 2014 Eric Schanet. All rights reserved.
//
#import "AppDelegate.h"

@class ESProfileImageView;
@protocol ESFindFriendsCellDelegate;

@interface UnBlockCell : UITableViewCell {
    id _delegate;
}
/**
 *  @name delegate
 */
@property (nonatomic, strong) id<ESFindFriendsCellDelegate> delegate;

/*! The user represented in the cell */
@property (nonatomic, strong) PFUser *user;
/**
 *  Indicating how many photos a user has uploaded yet
 */
@property (nonatomic, strong) UILabel *photoLabel;
/**
 *  Actual follow/unfollow button
 */
@property (nonatomic, strong) UIButton *unBlockButton;
@property (nonatomic,strong) AppDelegate *app;
@property (nonatomic) Boolean flag;



/**
 *  Setting a PFUser to a FindFriendsCell
 *
 *  @param user PFUser of the user
 */
- (void)setUser:(PFUser *)user;
/**
 *  Called when the username of a FindFriendsCell is tapped
 *
 *  @param sender id of the button
 */
- (void)didTapUserButtonAction:(id)sender;
/**
 *  Called when the follow button is tapped
 *
 *  @param sender id of the button
 */
- (void)didTapFollowButtonAction:(id)sender;

/*! Static Helper methods */
+ (CGFloat)heightForCell;

@end

/*!
 The protocol defines methods a delegate of a ESFindFriendsCell should implement.
 */

