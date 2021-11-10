//
//  GroupInfoTableViewController.m
//  VIP Billionaires
//
//  Created by jts on 18/06/18.
//  Copyright © 2018 Eric Schanet. All rights reserved.
//

#import "GroupInfoTableViewController.h"
#import "GroupMemberTableViewCell.h"
#import "ESAccountViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "UIImage+ResizeAdditions.h"
#import "AFNetworking.h"
#import "JSBadgeView.h"
#import "ESSelectRecipientsViewController.h"

@interface GroupInfoTableViewController ()<GroupMemberTableViewCellDelegate,ESSelectContactsDelegate>

@end

@implementation GroupInfoTableViewController

@synthesize groupId,groupIcon,groupTitle,groupMemberList;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"GroupMemberTableViewCell" bundle:nil] forCellReuseIdentifier:@"groupmemberview"];
    [self.tableView setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background_splash"]]];
    self.tableView.separatorColor = def_Golden_Color8;
    self.navigationItem.title = self.groupTitle;
    
//    self.refreshControl = [[UIRefreshControl alloc] init];
//    self.refreshControl.tintColor = def_Golden_Color;
//    self.refreshControl.layer.zPosition = self.tableView.backgroundView.layer.zPosition + 1;
    
    if ([self.groupAdminId isEqualToString:[PFUser currentUser].objectId]) {

        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(addMemberInGroupAction)];
        [self.navigationItem.rightBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:def_Golden_Color,  UITextAttributeTextColor,nil] forState:UIControlStateNormal];
        [self.navigationItem.leftBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:def_Golden_Color,  UITextAttributeTextColor,nil] forState:UIControlStateNormal];


      //  [self getAllUsers];
        
    /*UIButton *addMemberButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
    [addMemberButton addTarget:self action:@selector(addMemberInGroupAction) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:addMemberButton];*/
        
    }
    
    //[self.refreshControl addTarget:self action:@selector(loadGroupMembers) forControlEvents:UIControlEventValueChanged];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

/*-(void)getAllUsers
{
    self.groupMemberUserList = [[NSMutableArray alloc] init];
    
    for (int i=0; i<[self.groupMemberList count]; i++) {
        
        PFQuery *query = [PFQuery queryWithClassName:kESUserClassNameKey];
        [query whereKey:kESUserObjectIdKey equalTo:self.groupMemberList[i]];
        [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
         {
             if (error == nil)
             {
                 PFUser *user = [objects firstObject];
                 
                 if (![self.groupMemberUserList containsObject:user]) {
                     
                     [self.groupMemberUserList addObject:user];

                 }

                 
             }
         }];
        
    }
    
    
}*/

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.groupMemberList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
    GroupMemberTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"groupmemberview" forIndexPath:indexPath];
    cell.delegate = self;
    [cell feedTheCell:self.groupId userId:self.groupMemberList[indexPath.row]];
    
    return cell;
}
- (void)cell:(GroupMemberTableViewCell *)cellView didTapUserButton:(PFUser *)aUser {
    // Push account view controller
    if (aUser != nil && ![[aUser objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
        ESAccountViewController *accountViewController = [[ESAccountViewController alloc] initWithStyle:UITableViewStylePlain];        
        [accountViewController setUser:aUser];
        [self.navigationController pushViewController:accountViewController animated:YES];
    }
    
}

-(void)addMemberInGroupAction
{

    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:self.groupTitle
                          message:NSLocalizedString(@"Edit group", nil)
                          delegate:self
                          cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                          otherButtonTitles:NSLocalizedString(@"Edit Member", nil), NSLocalizedString(@"Edit Group Icon", nil), nil];
    alert.tag = 3;
    [alert show];
    
   
   
    
   
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 3) {
        
        if (buttonIndex == 1) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                ESSelectRecipientsViewController *selectMultipleView = [[ESSelectRecipientsViewController alloc] init];
                selectMultipleView.delegate = self;
                selectMultipleView.isFromGroupInfoView = TRUE;
                selectMultipleView.arrExistimgMemberList = [[NSMutableArray alloc] init];
                selectMultipleView.arrExistimgMemberList = self.groupMemberList;
                UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:selectMultipleView];
                [self presentViewController:navController animated:YES completion:nil];
            });
        }
        if (buttonIndex == 2) {
            
            AddGroupViewController *objAddGroupViewController = [[AddGroupViewController alloc] init];
            objAddGroupViewController.delegate = self;
            objAddGroupViewController.groupName = self.groupTitle;
            objAddGroupViewController.groupIconStr = self.groupIcon;
            objAddGroupViewController.isEdit = TRUE;
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:objAddGroupViewController];
            [self presentViewController:navController animated:YES completion:nil];
        }
    }
}
- (void)selecteGroupNameIcon:(NSString *)groupName image:(UIImage*)image
{
    /*NSMutableArray *unique = [NSMutableArray array];
    
    for (id obj in self.groupMemberUserList) {
        if (![unique containsObject:obj]) {
            [unique addObject:obj];
        }
    }
    
    NSLog(@"%@",unique);*/
    
   if (groupName == nil || [groupName isEqualToString:@""]) {
        
        groupName = self.groupTitle;
    }
    NSMutableArray *userIds = [[NSMutableArray alloc] init];
    for (NSString *userId in self.groupMemberList)
    {
        [userIds addObject:userId];
    }
  
    
    if (image == nil) {
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.groupIcon]];
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        operation.responseSerializer = [AFImageResponseSerializer serializer];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            UIImage *img = (UIImage *)responseObject;
            
            for (id userId in self.groupMemberList)
            {
                [ESUtility updateConversationItemWitUser:userId groupId:self.groupId members:userIds andDescription:groupName image:img recentId:self.recentId];
            }
            
            [self.navigationController popToRootViewControllerAnimated:YES];
            
        }  failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"createNewPhotoMessage picture load error.");
            
            for (id userId in self.groupMemberList)
            {
                [ESUtility updateConversationItemWitUser:userId groupId:self.groupId members:userIds andDescription:groupName image:nil recentId:self.recentId];
            }
            [self.navigationController popToRootViewControllerAnimated:YES];
            
        }];
        [[NSOperationQueue mainQueue] addOperation:operation];
    }
    else
    {
        for (id userId in self.groupMemberList)
        {
            [ESUtility updateConversationItemWitUser:userId groupId:self.groupId members:userIds andDescription:groupName image:image recentId:self.recentId];
        }
        
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    
    
    
}
- (void)selectedRecipients:(NSMutableArray *)users groupName:(NSString *)groupName image:(UIImage*)image
{
    [users addObject:[PFUser currentUser]];

    NSMutableArray *userIds = [[NSMutableArray alloc] init];
    for (PFUser *user in users)
    {
        [userIds addObject:user.objectId];
    }
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.groupIcon]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFImageResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        UIImage *img = (UIImage *)responseObject;
        
        for (PFUser *user in users)
        {
            [ESUtility updateConversationItemWitUser:user.objectId groupId:self.groupId members:userIds andDescription:self.groupTitle image:img recentId:self.recentId];
        }
        
        [self.navigationController popToRootViewControllerAnimated:YES];
        
    }  failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"createNewPhotoMessage picture load error.");
        
        for (PFUser *user in users)
        {
            [ESUtility updateConversationItemWitUser:user.objectId groupId:self.groupId members:userIds andDescription:self.groupTitle image:nil recentId:self.recentId];
        }
        [self.navigationController popToRootViewControllerAnimated:YES];

    }];
    [[NSOperationQueue mainQueue] addOperation:operation];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
