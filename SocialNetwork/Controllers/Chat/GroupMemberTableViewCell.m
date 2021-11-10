//
//  GroupMemberTableViewCell.m
//  VIP Billionaires
//
//  Created by jts on 18/06/18.
//  Copyright © 2018 Eric Schanet. All rights reserved.
//

#import "GroupMemberTableViewCell.h"

@implementation GroupMemberTableViewCell

@synthesize imgUser, lblUserName,dummyView;

- (void)feedTheCell:(NSString *)groupId userId:(NSString *)userId
{
    imgUser.layer.cornerRadius = imgUser.frame.size.width/2;
    imgUser.layer.masksToBounds = YES;
    dummyView = [[UIView alloc]init];
    dummyView.frame = imgUser.frame;
    dummyView.backgroundColor = [UIColor clearColor];
    self.lblUserName.textColor = def_Golden_Color;
    [self.contentView addSubview:dummyView];
        [imgUser setImage:[UIImage imageNamed:@"AvatarPlaceholderProfile"]];
        //NSString *otherUserId = [groupId stringByReplacingOccurrencesOfString:[PFUser currentUser].objectId withString:@""];
        PFQuery *query = [PFQuery queryWithClassName:kESUserClassNameKey];
        [query whereKey:kESUserObjectIdKey equalTo:userId];
        [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
         {
             if (error == nil)
             {
                 PFUser *user = [objects firstObject];
                 self.user = user;
                 if ([user objectForKey:kESUserProfilePicMediumKey]) {
                     [imgUser setFile:[user objectForKey:kESUserProfilePicMediumKey]];
                     [imgUser loadInBackground];
                 }
                 if ([[PFUser currentUser].objectId isEqualToString:user.objectId]) {
                     
                     self.lblUserName.text = @"You";

                 }
                 else
                 {
                     self.lblUserName.text = [user objectForKey:@"displayName"];

                 }
                 
                 
             }
         }];
        
}
-(IBAction)btnMemberPressed:(UIButton*)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(cell:didTapUserButton:)]) {
        [self.delegate cell:self didTapUserButton:self.user];
    }
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
