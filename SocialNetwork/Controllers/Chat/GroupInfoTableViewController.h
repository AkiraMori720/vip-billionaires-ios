//
//  GroupInfoTableViewController.h
//  VIP Billionaires
//
//  Created by jts on 18/06/18.
//  Copyright © 2018 Eric Schanet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddGroupViewController.h"

@interface GroupInfoTableViewController : UITableViewController<UIAlertViewDelegate,AddGroupDelegate>
{
    Firebase *firebase;
}
@property(nonatomic,strong)NSString *groupId;
@property(nonatomic,strong)NSString *groupTitle;
@property(nonatomic,strong)NSString *groupIcon;
@property(nonatomic,strong)NSString *recentId;
@property(nonatomic,strong)NSString *groupAdminId;


@property(nonatomic,strong)NSMutableArray *groupMemberList;

- (void)loadGroupMembers;

@end
