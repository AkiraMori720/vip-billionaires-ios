//
//  GroupMemberTableViewCell.h
//  VIP Billionaires
//
//  Created by jts on 18/06/18.
//  Copyright © 2018 Eric Schanet. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol GroupMemberTableViewCellDelegate;


@interface GroupMemberTableViewCell : UITableViewCell
{
    id _delegate;

}
@property (strong, nonatomic) IBOutlet PFImageView *imgUser;
@property (strong, nonatomic) IBOutlet UILabel *lblUserName;
@property (strong, nonatomic) IBOutlet UIButton *btnMember;

@property (strong, nonatomic) UIView *dummyView;
@property (nonatomic, strong) id<GroupMemberTableViewCellDelegate> delegate;
@property (nonatomic, strong) PFUser *user;

- (void)feedTheCell:(NSString *)groupId userId:(NSString *)userId;

-(IBAction)btnMemberPressed:(UIButton*)sender;

@end
@protocol GroupMemberTableViewCellDelegate <NSObject>
@optional

/*!
 Sent to the delegate when a user button is tapped
 @param aUser the PFUser of the user that was tapped
 */
- (void)cell:(GroupMemberTableViewCell *)cellView didTapUserButton:(PFUser *)aUser;
/**
 *  Sent to the delegate when a follow button is tapped
 *
 *  @param aUser    the PFUser of the user that was tapped
 */
@end
