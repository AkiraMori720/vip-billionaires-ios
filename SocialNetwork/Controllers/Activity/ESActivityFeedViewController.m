//
//  ESActivityFeedViewController.m
//  D'Netzwierk
//
//  Created by Eric Schanet on 6/05/2014.
//  Copyright (c) 2014 Eric Schanet. All rights reserved.
//

#import "ESActivityFeedViewController.h"

@implementation ESActivityFeedViewController

@synthesize settingsActionSheetDelegate;
@synthesize lastRefresh;
@synthesize blankTimelineView;

#pragma mark - Initialization

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // The className to query on
        self.parseClassName = kESActivityClassKey;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        self.loadingViewEnabled = YES;
        
        // The number of objects to show per page
        self.objectsPerPage = 15;
    }
    return self;
}

#pragma mark - UIViewController

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [self.tabBarController.view bringSubviewToFront:delegate.vipButton];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [self.tabBarController.view bringSubviewToFront:delegate.vipButton];
    delegate.vipButton.hidden = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    delegate.container.panMode = MFSideMenuPanModeDefault;
    [self loadObjects];
    self.navigationItem.title = @"VIP Billionaires";
    /*if ([[PFUser currentUser] objectForKey:@"profileColor"]) {
        NSArray *components = [[[PFUser currentUser] objectForKey:@"profileColor"] componentsSeparatedByString:@","];
        CGFloat r = [[components objectAtIndex:0] floatValue];
        CGFloat g = [[components objectAtIndex:1] floatValue];
        CGFloat b = [[components objectAtIndex:2] floatValue];
        CGFloat a = [[components objectAtIndex:3] floatValue];
        UIColor *color = [UIColor colorWithRed:r green:g blue:b alpha:a];
        self.navigationController.navigationBar.barTintColor = color;
    }
    else {*/
        self.navigationController.navigationBar.barTintColor = def_TopBar_Color;
   // }
}
- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationItem.title = @"VIP Billionaires";
    
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [self.tabBarController.view bringSubviewToFront:delegate.vipButton];
    delegate.vipButton.hidden = YES;
}
- (void)viewDidLoad {
    
    MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(tapBtn)];
    [self.navigationItem setLeftBarButtonItem:leftDrawerButton animated:YES];
    [self.navigationItem.leftBarButtonItem setTintColor:def_Golden_Color];
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.refreshControl.layer.zPosition = self.tableView.backgroundView.layer.zPosition + 1;
    self.refreshControl.tintColor = [UIColor darkGrayColor];
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    [super viewDidLoad];
    
    [self.tableView setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background_splash"]]];
    self.navigationItem.title = NSLocalizedString(@"VIP Billionaires", nil);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidReceiveRemoteNotification:) name:ESAppDelegateApplicationDidReceiveRemoteNotification object:nil];
    
    self.blankTimelineView = [[UIView alloc] initWithFrame:self.tableView.bounds];
    
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.alignment = NSTextAlignmentCenter;
    UILabel *label =[[UILabel alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2 - 253/2, 103.0f, 253.0f, 165.0f)];
    label.textColor = [UIColor blackColor];
    NSString * strWelcom = NSLocalizedString(@"Your friends are either not very active or don't like what you post.", nil);
    NSDictionary *attributes = @{ NSParagraphStyleAttributeName : paragraph,
                                  NSFontAttributeName : label.font,
                                  NSBaselineOffsetAttributeName : [NSNumber numberWithFloat:0] };
    
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:strWelcom
                                                              attributes:attributes];
    
    label.attributedText = str;
    label.numberOfLines = 5;
    label.font = [UIFont fontWithName:@"Montserrat-Light" size:18];
    
    [self.blankTimelineView addSubview:label];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:[UIImage imageNamed:@"btn_activity_blank"] forState:UIControlStateNormal];
    [button setFrame:CGRectMake( [UIScreen mainScreen].bounds.size.width/2 - [UIScreen mainScreen].bounds.size.width / 4/2, 250, [UIScreen mainScreen].bounds.size.width / 4, [UIScreen mainScreen].bounds.size.width / 4 /  2)];
    [button addTarget:self action:@selector(inviteFriendsButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.blankTimelineView addSubview:button];
    
    lastRefresh = [[NSUserDefaults standardUserDefaults] objectForKey:kESUserDefaultsActivityFeedViewControllerLastRefreshKey];
    
}
-(void)tapBtn {
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
        //[self setupMenuBarButtonItems];
    }];
}
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.objects.count) {
        PFObject *object = [self.objects objectAtIndex:indexPath.row];
        NSString *activityString = [ESActivityFeedViewController stringForActivityType:(NSString*)[object objectForKey:kESActivityTypeKey]];
        
        PFUser *user = (PFUser*)[object objectForKey:kESActivityFromUserKey];
        NSString *nameString = NSLocalizedString(@"Someone", nil);
        if (user && [user objectForKey:kESUserDisplayNameKey] && [[user objectForKey:kESUserDisplayNameKey] length] > 0) {
            nameString = [user objectForKey:kESUserDisplayNameKey];
        }
        
        return [ESActivityCell heightForCellWithName:nameString contentString:activityString];
    } else {
        return 44.0f;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row < self.objects.count) {
        PFObject *activity = [self.objects objectAtIndex:indexPath.row];
        if ([activity objectForKey:kESActivityPhotoKey]) {
            PFObject *photo = [activity objectForKey:kESActivityPhotoKey];
            if ([photo objectForKeyedSubscript:@"videoThumbnail"]) {
                ESVideoDetailViewController *photoViewController = [[ESVideoDetailViewController alloc] initWithPhoto:photo];
                photoViewController.hidesBottomBarWhenPushed = true;
                [self.navigationController pushViewController:photoViewController animated:YES];
            }
            else {
                ESPhotoDetailsViewController *photoViewController = [[ESPhotoDetailsViewController alloc] initWithPhoto:photo];
                photoViewController.hidesBottomBarWhenPushed = true;
                [self.navigationController pushViewController:photoViewController animated:YES];
            }

        } else if ([activity objectForKey:kESActivityFromUserKey]) {
            PFUser * user = [activity objectForKey:kESActivityFromUserKey];
            if (user != nil && ![[user objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
                ESAccountViewController *detailViewController = [[ESAccountViewController alloc] initWithStyle:UITableViewStylePlain];
                detailViewController.hidesBottomBarWhenPushed = true;
                [detailViewController setUser:user];
                [self.navigationController pushViewController:detailViewController animated:YES];
            }
        }
    } else if (self.paginationEnabled) {
        // load more
        [self loadNextPage];
    }
}

#pragma mark - PFQueryTableViewController

- (PFQuery *)queryForTable {
    if (![PFUser currentUser]) {
        PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
        [query setLimit:0];
        return query;
    }
    PFQuery *mentionQuery = [PFQuery queryWithClassName:self.parseClassName];
    [mentionQuery whereKey:@"mentions" equalTo:[PFUser currentUser]];
    //[mentionQuery whereKey:kESActivityFromUserKey notEqualTo:[PFUser currentUser]];
    [mentionQuery whereKeyExists:kESActivityFromUserKey];
    
    [mentionQuery setCachePolicy:kPFCachePolicyNetworkOnly];

    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    [query whereKey:kESActivityToUserKey equalTo:[PFUser currentUser]];
    [query whereKey:kESActivityFromUserKey notEqualTo:[PFUser currentUser]];
    [query whereKeyExists:kESActivityFromUserKey];
      
    [query setCachePolicy:kPFCachePolicyNetworkOnly];
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    //
    // If there is no network connection, we will hit the cache first.
    if (self.objects.count == 0 || ![[[UIApplication sharedApplication]delegate] performSelector:@selector(isParseReachable)]) {
        [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
    }
    
    PFQuery *endQuery = [PFQuery orQueryWithSubqueries:@[mentionQuery,query]];
    [endQuery orderByDescending:@"createdAt"];
    [endQuery includeKey:kESActivityFromUserKey];
    [endQuery includeKey:kESActivityPhotoKey];
    //[endQuery includeKey:@"mentions"];


    return endQuery;
}


- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    
    lastRefresh = [NSDate date];
    [[NSUserDefaults standardUserDefaults] setObject:lastRefresh forKey:kESUserDefaultsActivityFeedViewControllerLastRefreshKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    if (self.objects.count == 0 && ![[self queryForTable] hasCachedResult]) {
        self.tableView.scrollEnabled = NO;
        self.navigationController.tabBarItem.badgeValue = nil;
        
        if (!self.blankTimelineView.superview) {
            self.blankTimelineView.alpha = 0.0f;
            self.tableView.tableHeaderView = self.blankTimelineView;
            
            [UIView animateWithDuration:0.200f animations:^{
                self.blankTimelineView.alpha = 1.0f;
            }];
        }
    } else {
        self.tableView.tableHeaderView = nil;
        self.tableView.scrollEnabled = YES;
        
        NSUInteger unreadCount = 0;
        for (PFObject *activity in self.objects) {
            if ([lastRefresh compare:[activity createdAt]] == NSOrderedAscending && ![[activity objectForKey:kESActivityTypeKey] isEqualToString:kESActivityTypeJoined]) {
                unreadCount++;
            }
        }
        
        if (unreadCount > 0) {
            self.navigationController.tabBarItem.badgeValue = [NSString stringWithFormat:@"%lu",(unsigned long)unreadCount];
        } else {
            self.navigationController.tabBarItem.badgeValue = nil;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    NSString *CellIdentifier = [NSString stringWithFormat:@"ActivityCell_%ld_%ld", indexPath.section, indexPath.row];
    
    ESActivityCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[ESActivityCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell setDelegate:self];
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    }
    
    [cell setActivity:object];
    
    if ([lastRefresh compare:[object createdAt]] == NSOrderedAscending) {
        [cell setIsNew:YES];
    } else {
        [cell setIsNew:NO];
    }
    
    [cell hideSeparator:(indexPath.row == self.objects.count - 1)];
    
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *LoadMoreCellIdentifier = @"LoadMoreCell";
    
    ESLoadMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:LoadMoreCellIdentifier];
    if (!cell) {
        cell = [[ESLoadMoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LoadMoreCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.hideSeparatorBottom = YES;
        cell.mainView.backgroundColor = [UIColor clearColor];
    }
    return cell;
}


#pragma mark - ESActivityCellDelegate Methods

- (void)cell:(ESActivityCell *)cellView didTapActivityButton:(PFObject *)activity {
    // Get image associated with the activity
    PFObject *photo = [activity objectForKey:kESActivityPhotoKey];
    if ([photo objectForKeyedSubscript:@"videoThumbnail"]) {
        ESVideoDetailViewController *photoViewController = [[ESVideoDetailViewController alloc] initWithPhoto:photo];
        photoViewController.hidesBottomBarWhenPushed = true;
        [self.navigationController pushViewController:photoViewController animated:YES];
    }
    else {
        ESPhotoDetailsViewController *photoViewController = [[ESPhotoDetailsViewController alloc] initWithPhoto:photo];
        photoViewController.hidesBottomBarWhenPushed = true;
        [self.navigationController pushViewController:photoViewController animated:YES];
    }
}

- (void)cell:(ESBaseTextCell *)cellView didTapUserButton:(PFUser *)user {
    // Push account view controller
    if (user != nil && ![[user objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
        ESAccountViewController *accountViewController = [[ESAccountViewController alloc] initWithStyle:UITableViewStylePlain];
        [accountViewController setUser:user];
        accountViewController.hidesBottomBarWhenPushed = true;
        self.navigationItem.title = @"";
        [self.navigationController pushViewController:accountViewController animated:YES];
    }
}


#pragma mark - ESActivityFeedViewController

+ (NSString *)stringForActivityType:(NSString *)activityType {
    if ([activityType isEqualToString:kESActivityTypeLikePhoto]) {
        return NSLocalizedString(@"liked your photo", nil);
    } else if ([activityType isEqualToString:kESActivityTypeLikeVideo]) {
        return NSLocalizedString(@"liked your video", nil);
    } else if ([activityType isEqualToString:kESActivityTypeLikePost]) {
        return NSLocalizedString(@"liked your post", nil);
    } else if ([activityType isEqualToString:kESActivityTypeCommentVideo]) {
        return NSLocalizedString(@"commented on your video", nil);
    } else if ([activityType isEqualToString:kESActivityTypeCommentPost]) {
        return NSLocalizedString(@"commented on your post", nil);
    } else if ([activityType isEqualToString:kESActivityTypeFollow]) {
        return NSLocalizedString(@"started following you", nil);
    } else if ([activityType isEqualToString:kESActivityTypeCommentPhoto]) {
        return NSLocalizedString(@"commented on your photo", nil);
    } else if ([activityType isEqualToString:kESActivityTypeJoined]) {
        return NSLocalizedString(@"joined d'Netzwierk", nil);
    } else if ([activityType isEqualToString:kESActivityTypeMention]) {
        return NSLocalizedString(@"mentioned you in a comment", nil);
    } else {
        return nil;
    }
}


#pragma mark - ()

- (void)settingsButtonAction:(id)sender {
    settingsActionSheetDelegate = [[ESSettingsActionSheetDelegate alloc] initWithNavigationController:self.navigationController];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:settingsActionSheetDelegate cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"My Profile", nil), NSLocalizedString(@"Find Friends", nil), NSLocalizedString(@"Log Out", nil), nil];
    
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}

- (void)inviteFriendsButtonAction:(id)sender {
    ESFindFriendsViewController *detailViewController = [[ESFindFriendsViewController alloc] init];
    detailViewController.hidesBottomBarWhenPushed = true;
    [self.navigationController pushViewController:detailViewController animated:YES];
}

- (void)applicationDidReceiveRemoteNotification:(NSNotification *)note {
    [self loadObjects];
}
@end
