//
//  ESFindFriendsViewController.m
//  D'Netzwierk
//
//  Created by Eric Schanet on 6/05/2014.
//  Copyright (c) 2014 Eric Schanet. All rights reserved.
//

#import "ESFindFriendsViewController.h"

#import <CoreText/CoreText.h>

@implementation ESFindFriendsViewController
@synthesize headerView,searchQuery, searchTerm;
@synthesize followStatus;
@synthesize selectedEmailAddress;
@synthesize outstandingFollowQueries;
@synthesize outstandingCountQueries;
#pragma mark - Initialization

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        
        self.outstandingFollowQueries = [NSMutableDictionary dictionary];
        self.outstandingCountQueries = [NSMutableDictionary dictionary];
        
        self.selectedEmailAddress = @"";
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        self.loadingViewEnabled = YES;
        self.paginationEnabled = YES;
        
        // The number of objects to show per page
        self.objectsPerPage = 25;
        
        // Used to determine Follow/Unfollow All button status
        self.followStatus = ESFindFriendsFollowingSome;
    }
    return self;
}


#pragma mark - UIViewController
- (void)viewWillAppear:(BOOL)animated {
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    delegate.container.panMode = MFSideMenuPanModeDefault;
    
    self.navigationItem.backBarButtonItem.tintColor = def_Golden_Color;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.followingMeUsers = [NSMutableArray new];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"", nil) style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.title = NSLocalizedString(@"Find Friends", nil);
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:def_Golden_Color,
       NSFontAttributeName:[UIFont fontWithName:@"Montserrat-Medium" size:21]}];
    [self.tableView setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed: @"background_splash_black_itle"]]];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.backgroundColor = [UIColor clearColor];

    self.refreshControl.layer.zPosition = self.tableView.backgroundView.layer.zPosition + 1;
    self.refreshControl.tintColor = [UIColor blackColor];
    
//    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TitleFindFriends"]];
    
    if (false && ([MFMailComposeViewController canSendMail] || [MFMessageComposeViewController canSendText])) {
        
        self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 67)];
        [self.headerView setBackgroundColor:[UIColor clearColor]];
        UIButton *clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [clearButton setBackgroundColor:[UIColor clearColor]];
        [clearButton addTarget:self action:@selector(inviteFriendsButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [clearButton setFrame:self.headerView.frame];
        [self.headerView addSubview:clearButton];
        NSString *inviteString = NSLocalizedString(@"Invite friends", @"Invite friends");
        CGRect boundingRect = [inviteString boundingRectWithSize:CGSizeMake(310.0f, CGFLOAT_MAX)
                                                         options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin
                                                      attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Montserrat-Bold" size:18.0f]}
                                                         context:nil];
        CGSize inviteStringSize = boundingRect.size;
        
        UILabel *inviteLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, (self.headerView.frame.size.height-inviteStringSize.height)/2, inviteStringSize.width, inviteStringSize.height)];
        [inviteLabel setText:inviteString];
        [inviteLabel setFont:[UIFont fontWithName:@"Montserrat-Bold" size:18]];
        [inviteLabel setTextColor:[UIColor colorWithRed:87.0f/255.0f green:72.0f/255.0f blue:49.0f/255.0f alpha:1.0]];
        [inviteLabel setBackgroundColor:[UIColor clearColor]];
        [self.headerView addSubview:inviteLabel];
//        self.searchResultsTableView.separatorColor = [UIColor clearColor];
        UIImageView *separatorImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SeparatorTimeline"]];
        [separatorImage setFrame:CGRectMake(0, self.headerView.frame.size.height-2, [UIScreen mainScreen].bounds.size.width, 2)];
//        [self.headerView addSubview:separatorImage];
        [self.tableView setTableHeaderView:self.headerView];
        return;
        
    }
    
    
    //Search friends
    self.searchTerm = @"";
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    self.searchBar.barTintColor = [UIColor blackColor];
    self.searchBar.delegate = self;
    self.tableView.tableHeaderView = self.searchBar;
    
    UITextField* textFieldSearchBar = (UITextField*)[self.searchBar valueForKey:@"searchField"];
    textFieldSearchBar.textColor = [UIColor whiteColor];
    textFieldSearchBar.placeholder = NSLocalizedString(@"Search", nil);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.bounces = NO;
    [UISearchBar appearance].tintColor = def_Golden_Color;

    self.searchResults = [NSMutableArray array];
}

//search query
-(void)filterResults:(NSString *)searchTerm {
    if ([searchTerm isEqualToString:@""]) {
        self.searchResults = [NSMutableArray array];
        [self.tableView reloadData];
        return;
    }

    [ProgressHUD show:@""];
    
    dispatch_queue_t backgroundQueue = dispatch_queue_create("com.mycompany.myqueue", 0);
    
    dispatch_async(backgroundQueue, ^{
        
   // Send Request to server for Data
        [self.searchResults removeAllObjects];
        
        PFQuery* searchQuery = [PFUser query];
        self.searchQuery = searchQuery;
        [searchQuery whereKeyExists:kESUserDisplayNameKey];  //this is based on whatever query you are trying to accomplish
        [searchQuery whereKeyExists:@"username"]; //this is based on whatever query you are trying to accomplish
        [searchQuery whereKey:kESUserDisplayNameLowerKey containsString:[searchTerm lowercaseString]];
    //    [searchQuery whereKey:@"block" notEqualTo:@"1"];
        [searchQuery whereKey:kESUserObjectIdKey notEqualTo:[PFUser currentUser].objectId];
        NSLog(@"%ld", [searchQuery findObjects].count);
        PFQuery *blockQuery = [[PFQuery queryWithClassName:@"block_table"] whereKey:@"block_userId" equalTo:[PFUser currentUser].objectId];
        NSArray *blockUsersArray = [blockQuery findObjects];
        NSMutableArray *arrayBlockUserIds = [NSMutableArray array];
        for (PFObject *object in blockUsersArray) {
            [arrayBlockUserIds addObject:object[@"UserID"]];
        }
        [searchQuery whereKey:@"objectId" notContainedIn:arrayBlockUserIds];
        
        
        PFQuery* followingMeQuery = [PFQuery queryWithClassName:kESActivityClassKey];
        [followingMeQuery whereKey:@"type" equalTo:@"follow"];
        [followingMeQuery whereKey:@"fromUser" equalTo:[PFUser currentUser]];
        
        NSMutableArray *arrayFollowingUsers = [[NSMutableArray alloc] init];
        
        NSArray* objects1 = [followingMeQuery  findObjects];
        
        for (PFObject *object in objects1) {
            PFObject* user = object[@"toUser"];
            [arrayFollowingUsers addObject:user.objectId];
        }
        
        self.followingMeUsers = arrayFollowingUsers;
        
        [searchQuery findObjectsInBackgroundWithBlock:^(NSArray
                                                             *objects, NSError *error)
         {
            
            if (searchQuery == self.searchQuery) {
                [self.searchResults removeAllObjects];
                [self.searchResults addObjectsFromArray:objects];
                [self.tableView reloadData];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [ProgressHUD dismiss];
                });
                
                self.searchQuery = nil;
            }
         }];
        
    });
}

-(void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    self.searchTerm = searchController.searchBar.text;
    [self filterResults:searchTerm];
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    self.searchTerm = searchBar.text;
    [self filterResults:searchTerm];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self searchBarCancelled];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelled
{
    self.searchBar.text = @"";
    [self.searchBar resignFirstResponder];
    
    self.searchTerm = @"";
    [self filterResults:searchTerm];
}

#pragma mark - PFQueryTableViewController

- (PFQuery *)queryForTable {
    
    
    // Use cached facebook friend ids
    NSArray *facebookFriends = [[ESCache sharedCache] facebookFriends];
    
    // Query for all friends you have on facebook and who are using the app
    PFQuery *friendsQuery = [PFUser query];
    
    //Comment out following line for facebook friends query only
    if (facebookFriends.count > 0) {
        [friendsQuery whereKey:kESUserFacebookIDKey containedIn:facebookFriends];
    }
    else {
        //NSArray *array = [[NSUserDefaults standardUserDefaults]arrayForKey:@"friendsArray"];
        //[friendsQuery whereKey:kESUserObjectIdKey containedIn:array];
    }
    
    PFQuery *query = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:friendsQuery, nil]];
    

     query.cachePolicy = kPFCachePolicyNetworkOnly;
    
    if (self.objects.count == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    if (facebookFriends.count > 0) {
        [query orderByAscending:kESUserDisplayNameKey];
    }
    else {
       // [query orderByDescending:@"createdAt"];
        
        [query orderByAscending:kESUserDisplayNameKey];

    }
    NSMutableArray *arrayBlockUserIds = [[NSMutableArray alloc] init];

    PFQuery *blockQuery = [[PFQuery queryWithClassName:@"block_table"] whereKey:@"block_userId" equalTo:[PFUser currentUser].objectId];
//    [blockQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
//
//        for (PFObject *object in objects) {
//            [arrayBlockUserIds addObject:object[@"UserID"]];
//        }
//    }];
    
    NSArray *objects = [blockQuery findObjects];
    for (PFObject *object in objects) {
        [arrayBlockUserIds addObject:object[@"UserID"]];
    }
    PFQuery* followingMeQuery = [PFQuery queryWithClassName:kESActivityClassKey];
    [followingMeQuery whereKey:@"type" equalTo:@"follow"];
    [followingMeQuery whereKey:@"fromUser" equalTo:[PFUser currentUser]];
    
    NSMutableArray *arrayFollowingUsers = [[NSMutableArray alloc] init];
    
    objects = [followingMeQuery findObjects];
    
    for (PFObject *object in objects) {
        PFObject* user = object[@"toUser"];
        [arrayFollowingUsers addObject:user.objectId];
    }
    
    [query whereKey:@"objectId" containedIn:arrayFollowingUsers];
    [query whereKey:@"objectId" notContainedIn:arrayBlockUserIds];
    
    return query;
}

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    
    PFQuery *isFollowingQuery = [PFQuery queryWithClassName:kESActivityClassKey];
    [isFollowingQuery whereKey:kESActivityFromUserKey equalTo:[PFUser currentUser]];
    [isFollowingQuery whereKey:kESActivityTypeKey equalTo:kESActivityTypeFollow];
    [isFollowingQuery whereKey:kESActivityToUserKey containedIn:self.objects];
    [isFollowingQuery setCachePolicy:kPFCachePolicyNetworkOnly];
    
    [isFollowingQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
//        if (!error) {
//            if (number == self.objects.count) {
//                self.followStatus = ESFindFriendsFollowingAll;
//                //    [self configureUnfollowAllButton];
//                for (PFUser *user in self.objects) {
//                    [[ESCache sharedCache] setFollowStatus:YES user:user];
//                }
//            } else if (number == 0) {
//                self.followStatus = ESFindFriendsFollowingNone;
//                //    [self configureFollowAllButton];
//                for (PFUser *user in self.objects) {
//                    [[ESCache sharedCache] setFollowStatus:NO user:user];
//                }
//            } else {
//                self.followStatus = ESFindFriendsFollowingSome;
//                //    [self configureFollowAllButton];
//            }
//        }
        
        if (self.objects.count == 0) {
            self.navigationItem.rightBarButtonItem = nil;
        }
    }];
    
    if (self.objects.count == 0) {
        self.navigationItem.rightBarButtonItem = nil;
    }
}
- (PFObject *)objectAtIndexPath:(NSIndexPath *)indexPath {
    // overridden, since we want to implement sections
    if (indexPath.section < self.objects.count) {
        return [self.objects objectAtIndex:indexPath.section];
    }
    
    return nil;
}

#pragma mark - UITableViewDelegate and DataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.searchTerm == nil || self.searchTerm.length == 0) {
        if (indexPath.section < self.objects.count) {
            
            if (indexPath.section == 0) {
                
                if ([MFMailComposeViewController canSendMail] || [MFMessageComposeViewController canSendText]) {


                }
                else
                {
                    if (tableView == self.tableView) {

                    return 0;
                    }

                }
            }
            
            return [ESFindFriendsCell heightForCell];

            
        } else {
            return 44.0f;
        }
    } else {
        return [ESFindFriendsCell heightForCell];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
    
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.searchTerm == nil || self.searchTerm.length == 0) {
        //if (tableView == self.searchDisplayController.searchResultsTableView) {
        NSInteger rows = self.objects.count;
        if (self.paginationEnabled && [self _shouldShowPaginationCell] && rows != 0)
            rows++;
        return rows;
    } else {
        return self.searchResults.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    if (self.searchTerm == nil || self.searchTerm.length == 0) {
        if (indexPath.section == 0) {
            if ([MFMailComposeViewController canSendMail] || [MFMessageComposeViewController canSendText]) {
                self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 67)];
                
                UIButton *clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
                [clearButton setBackgroundColor:[UIColor clearColor]];
                [clearButton addTarget:self action:@selector(inviteFriendsButtonAction:) forControlEvents:UIControlEventTouchUpInside];
                [clearButton setFrame:self.headerView.frame];
                [self.headerView addSubview:clearButton];
                NSString *inviteString = NSLocalizedString(@"Invite friends", @"Invite friends");
                CGRect boundingRect = [inviteString boundingRectWithSize:CGSizeMake(310.0f, CGFLOAT_MAX)
                                                                 options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin
                                                              attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Montserrat-Bold" size:18.0f]}
                                                                 context:nil];
                CGSize inviteStringSize = boundingRect.size;
                
                UILabel *inviteLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, (self.headerView.frame.size.height-inviteStringSize.height)/2, inviteStringSize.width, inviteStringSize.height)];
                
                NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:inviteString];
                [attString addAttribute:(NSString*)kCTUnderlineStyleAttributeName
                                  value:[NSNumber numberWithInt:kCTUnderlineStyleSingle]
                                  range:(NSRange){0,[attString length]}];
                inviteLabel.attributedText = attString;
                
//                [inviteLabel setText:inviteString];
                [inviteLabel setFont:[UIFont fontWithName:@"Montserrat-Bold" size:18]];
                [inviteLabel setTextColor:[UIColor blackColor]];
                [inviteLabel setBackgroundColor:[UIColor clearColor]];
                [self.headerView addSubview:inviteLabel];
                
                UIImageView *separatorImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SeparatorTimeline"]];
                [separatorImage setFrame:CGRectMake(0, self.headerView.frame.size.height, [UIScreen mainScreen].bounds.size.width, 1)];
//                [self.headerView addSubview:separatorImage];
                [self.headerView setBackgroundColor:[UIColor clearColor]];
                
                UITableViewCell *cell = [[UITableViewCell alloc]init];
                cell.backgroundColor = [UIColor clearColor];
                [cell addSubview:self.headerView];
                return cell;
            }
            else {
                UITableViewCell *cell = [[UITableViewCell alloc]init];
                cell.backgroundColor = [UIColor clearColor];

                return cell;
            }
            
        }
        
        else {
            
            NSString *FriendCellIdentifier = [NSString stringWithFormat:@"FriendCell_%@", object.objectId];
            
            if ([self _shouldShowPaginationCell] && indexPath.section== self.objects.count) {
                // this behavior is normally handled by PFQueryTableViewController, but we are using sections for each object and we must handle this ourselves
                UITableViewCell *cell = [self tableView:tableView cellForNextPageAtIndexPath:indexPath];
                cell.backgroundColor = [UIColor clearColor];

                return cell;
            } else {
                
                ESFindFriendsCell *cell = [tableView dequeueReusableCellWithIdentifier:FriendCellIdentifier];
                if (cell == nil) {
                    cell = [[ESFindFriendsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:FriendCellIdentifier];
                    [cell setDelegate:self];
                }
                
                [cell setUser:(PFUser*)object];
                [cell.photoLabel setText:NSLocalizedString(@"0 photos", nil)];
                
                NSDictionary *attributes = [[ESCache sharedCache] attributesForUser:(PFUser *)object];
                
                if (attributes) {
                    // set them now
                    NSNumber *number = [[ESCache sharedCache] photoCountForUser:(PFUser *)object];
                    [cell.photoLabel setText:[NSString stringWithFormat:@"%@ photo%@", number, [number intValue] == 1 ? @"": NSLocalizedString(@"s", nil)]];
                } else {
                    @synchronized(self) {
                        NSNumber *outstandingCountQueryStatus = [self.outstandingCountQueries objectForKey:indexPath];
                        if (!outstandingCountQueryStatus) {
                            [self.outstandingCountQueries setObject:[NSNumber numberWithBool:YES] forKey:indexPath];
                            PFQuery *photoNumQuery = [PFQuery queryWithClassName:kESPhotoClassKey];
                            [photoNumQuery whereKey:kESPhotoUserKey equalTo:object];
                            [photoNumQuery setCachePolicy:kPFCachePolicyCacheThenNetwork];
                            [photoNumQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
                                @synchronized(self) {
                                    [[ESCache sharedCache] setPhotoCount:[NSNumber numberWithInt:number] user:(PFUser *)object];
                                    [self.outstandingCountQueries removeObjectForKey:indexPath];
                                }
                                ESFindFriendsCell *actualCell = (ESFindFriendsCell*)[tableView cellForRowAtIndexPath:indexPath];
                                NSString *photoString = [NSString stringWithFormat:NSLocalizedString(@"photo", nil)];
                                [actualCell.photoLabel setText:[NSString stringWithFormat:@"%d %@%@", number, photoString, number == 1 ? @"" : NSLocalizedString(@"s", nil)]];
                            }];
                        };
                    }
                }
                
                
                cell.tag = indexPath.section;
                cell.followButton.selected = YES;
                
                return cell;
            }
        }
    }
    else {
        NSString *uniqueIdentifier = @"peopleCell";
        ESFindFriendsCell *cell = nil;
        
        //cell = (UITableViewCell *) [self.tableView dequeueReusableCellWithIdentifier:uniqueIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:uniqueIdentifier];
        
        if (!cell) {
            cell = [[ESFindFriendsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:uniqueIdentifier];
            [cell setDelegate:self];
        }
        PFUser *obj2 = [self.searchResults objectAtIndex:indexPath.section];
        [cell setUser:(PFUser *)obj2];
        cell.followButton.selected = NO;
        cell.tag = indexPath.section;
        NSDictionary *attributes = [[ESCache sharedCache] attributesForUser:(PFUser *)obj2];
        [cell.photoLabel setText:NSLocalizedString(@"0 photos", nil)];
        
        if (attributes) {
            // set them now
            NSNumber *number = [[ESCache sharedCache] photoCountForUser:(PFUser *)obj2];
            [cell.photoLabel setText:[NSString stringWithFormat:@"%@ photo%@", number, [number intValue] == 1 ? @"": NSLocalizedString(@"s", nil)]];
        } else {
            @synchronized(self) {
                NSNumber *outstandingCountQueryStatus = [self.outstandingCountQueries objectForKey:indexPath];
                if (!outstandingCountQueryStatus) {
                    [self.outstandingCountQueries setObject:[NSNumber numberWithBool:YES] forKey:indexPath];
                    PFQuery *photoNumQuery = [PFQuery queryWithClassName:kESPhotoClassKey];
                    [photoNumQuery whereKey:kESPhotoUserKey equalTo:(PFObject *)obj2];
                    [photoNumQuery setCachePolicy:kPFCachePolicyCacheThenNetwork];
                    [photoNumQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
                        @synchronized(self) {
                            [[ESCache sharedCache] setPhotoCount:[NSNumber numberWithInt:number] user:(PFUser *)obj2];
                            [self.outstandingCountQueries removeObjectForKey:indexPath];
                        }
                        ESFindFriendsCell *actualCell = (ESFindFriendsCell*)[tableView cellForRowAtIndexPath:indexPath];
                        NSString *photoString = [NSString stringWithFormat:NSLocalizedString(@"photo", nil)];
                        [actualCell.photoLabel setText:[NSString stringWithFormat:@"%d %@%@", number, photoString, number == 1 ? @"" : NSLocalizedString(@"s", nil)]];
                    }];
                };
            }
        }
        
        [cell.followButton setSelected:[self.followingMeUsers containsObject:((PFObject*)_searchResults[indexPath.section]).objectId]];
        return cell;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *LoadMoreCellIdentifier = @"LoadMoreCell";
    
    [self loadNextPage];
    
    ESLoadMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:LoadMoreCellIdentifier];
    if (!cell) {
        cell = [[ESLoadMoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LoadMoreCellIdentifier];
        cell.selectionStyle =UITableViewCellSelectionStyleGray;
        cell.separatorImageTop.image = [UIImage imageNamed:@"SeparatorTimelineDark"];
        cell.hideSeparatorBottom = YES;
        cell.mainView.backgroundColor = [UIColor clearColor];
        
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == self.objects.count && self.paginationEnabled) {
        // Load More Cell
//        [self loadNextPage];
    }
}


#pragma mark - ESFindFriendsCellDelegate

- (void)cell:(ESFindFriendsCell *)cellView didTapUserButton:(PFUser *)aUser {
    // Push account view controller
    if (aUser != nil && ![[aUser objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
        ESAccountViewController *accountViewController = [[ESAccountViewController alloc] initWithStyle:UITableViewStylePlain];
        [accountViewController setUser:aUser];
        [self.navigationController pushViewController:accountViewController animated:YES];
    }
}

- (void)cell:(ESFindFriendsCell *)cellView didTapFollowButton:(PFUser *)aUser {
    [self shouldToggleFollowFriendForCell:cellView];
}


#pragma mark - ABPeoplePickerDelegate

/* Called when the user cancels the address book view controller. We simply dismiss it. */
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/* Called when a member of the address book is selected, we return YES to display the member's details. */
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person {
    return YES;
}

/* Called when the user selects a property of a person in their address book (ex. phone, email, location,...)
 This method will allow them to send a text or email inviting them to d'Netzwierk.  */
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
    
    if (property == kABPersonEmailProperty) {
        
        ABMultiValueRef emailProperty = ABRecordCopyValue(person,property);
        NSString *email = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(emailProperty,identifier);
        self.selectedEmailAddress = email;
        
        if ([MFMailComposeViewController canSendMail]) {
            // go directly to mail
            [self presentMailComposeViewController:email];
        } else if ([MFMessageComposeViewController canSendText]) {
            // go directly to iMessage
            [self presentMessageComposeViewController:email];
        }
        
    } else if (property == kABPersonPhoneProperty) {
        ABMultiValueRef phoneProperty = ABRecordCopyValue(person,property);
        NSString *phone = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(phoneProperty,identifier);
        
        if ([MFMessageComposeViewController canSendText]) {
            [self presentMessageComposeViewController:phone];
        }
    }
    
    return NO;
}

#pragma mark - MFMailComposeDelegate

/* Simply dismiss the MFMailComposeViewController when the user sends an email or cancels */
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - MFMessageComposeDelegate

/* Simply dismiss the MFMessageComposeViewController when the user sends a text or cancels */
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    
    if (buttonIndex == 0) {
        [self presentMailComposeViewController:self.selectedEmailAddress];
    } else if (buttonIndex == 1) {
        [self presentMessageComposeViewController:self.selectedEmailAddress];
    }
}

#pragma mark - ()

- (void)backButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)inviteFriendsButtonAction:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        ESPhoneContacts *addressBookView = [[ESPhoneContacts alloc] init];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:addressBookView];
        [self presentViewController:navController animated:YES completion:nil];
    });
}

- (void)shouldToggleFollowFriendForCell:(ESFindFriendsCell*)cell {
    PFUser *cellUser = cell.user;
    if ([cell.followButton isSelected]) {
        // Unfollow
        cell.followButton.selected = NO;
        [ESUtility unfollowUserEventually:cellUser];
        [[NSNotificationCenter defaultCenter] postNotificationName:ESUtilityUserFollowingChangedNotification object:nil];
    } else {
        // Follow
        cell.followButton.selected = YES;
        [ESUtility followUserEventually:cellUser block:^(BOOL succeeded, NSError *error) {
            if (!error) {
                [[NSNotificationCenter defaultCenter] postNotificationName:ESUtilityUserFollowingChangedNotification object:nil];
            } else {
                cell.followButton.selected = NO;
            }
        }];
    }
}

- (void)presentMailComposeViewController:(NSString *)recipient {
    // Create the compose email view controller
    MFMailComposeViewController *composeEmailViewController = [[MFMailComposeViewController alloc] init];
    
    // Set the recipient to the selected email and a default text
    [composeEmailViewController setMailComposeDelegate:self];
    [composeEmailViewController setSubject:NSLocalizedString(@"Join me on VIP Billionaires", nil)];
    [composeEmailViewController setToRecipients:[NSArray arrayWithObjects:recipient, nil]];
    [composeEmailViewController setMessageBody:@"<h2>Share your pictures, share your story.</h2><p><a href=\"itms-apps://itunes.apple.com/app/id1076103571\">VIP Billionaires</a> is the easiest way to share photos with your friends. Get the app and share your fun photos with the world.</p><p><a href=\"itms-apps://itunes.apple.com/app/id1076103571\">VIP Billionaires</a> is fully powered by the ZED Technosolutions." isHTML:YES];

    // Dismiss the current modal view controller and display the compose email one.
    // Note that we do not animate them. Doing so would require us to present the compose
    // mail one only *after* the address book is dismissed.
    [self dismissViewControllerAnimated:NO completion:nil];
    [self presentViewController:composeEmailViewController animated:NO completion:nil];
}

- (void)presentMessageComposeViewController:(NSString *)recipient {
    // Create the compose text message view controller
    MFMessageComposeViewController *composeTextViewController = [[MFMessageComposeViewController alloc] init];
    
    // Send the destination phone number and a default text
    [composeTextViewController setMessageComposeDelegate:self];
    [composeTextViewController setRecipients:[NSArray arrayWithObjects:recipient, nil]];
    [composeTextViewController setBody:NSLocalizedString(@"Check out VIP Billionaires! itms-apps://itunes.apple.com/app/id1076103571", nil)];
    
    // Dismiss the current modal view controller and display the compose text one.
    // See previous use for reason why these are not animated.
    [self dismissViewControllerAnimated:NO completion:nil];
    [self presentViewController:composeTextViewController animated:NO completion:nil];
}

- (NSIndexPath *)_indexPathForPaginationCell {
    return [NSIndexPath indexPathForRow:0 inSection:[self.objects count]];
    
}
@end
