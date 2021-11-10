//
//  SideViewController.m
//  d'Netzwierk
//
//  Created by Eric Schanet on 26.06.14.
//
//

#import "SideViewController.h"
#import "MMSideDrawerTableViewCell.h"
#import "MMSideDrawerSectionHeaderView.h"
#import "ESFindFriendsCell.h"
#import "ESAccountViewController.h"
#import "ESProfileImageView.h"
#import "MFSideMenu.h"
#import "ESSideTableViewCell.h"
#import "MBProgressHUD.h"


@implementation SideViewController
@synthesize _tableView,navController,hud, mbhud;
#pragma mark - Initialization

- (id)initWithNavigationController:(UINavigationController *)navigationController {
    self = [super init];
    if (self) {

    }
    return self;
}
-(void)viewDidAppear:(BOOL)animated {
    [self._tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    /*if ([[PFUser currentUser] objectForKey:@"profileColor"]) {
        NSArray *components = [[[PFUser currentUser] objectForKey:@"profileColor"] componentsSeparatedByString:@","];
        CGFloat r = [[components objectAtIndex:0] floatValue];
        CGFloat g = [[components objectAtIndex:1] floatValue];
        CGFloat b = [[components objectAtIndex:2] floatValue];
        CGFloat a = [[components objectAtIndex:3] floatValue];
        UIColor *color = [UIColor colorWithRed:r green:g blue:b alpha:a];
        self.view.backgroundColor = color;
    }
    else {*/
        self.view.backgroundColor = def_TopBar_Color;
    //}
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 120, self.view.bounds.size.width-45, self.view.bounds.size.height) style:UITableViewStylePlain];
    
    [self._tableView setDelegate:self];
    [self._tableView setDataSource:self];
    self._tableView.scrollEnabled = NO;
    [self.view addSubview:self._tableView];
    
//    [self._tableView setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background_splash"]]];
    
    UIImageView * logo = [[UIImageView alloc]initWithFrame:CGRectMake(50, 30, 120, 80)];
    logo.contentMode = UIViewContentModeScaleAspectFit;
    logo.image = [UIImage imageNamed:@"logo"];
    [self.view addSubview:logo];
    
    self._tableView.backgroundColor = [UIColor whiteColor];
    self._tableView.separatorColor = [UIColor colorWithWhite:0 alpha:0.2];
    self.view.backgroundColor = [UIColor whiteColor];
    self._tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAutomatic;
    [self.view addSubview:_tableView];
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
//    self._tableView.contentInset = UIEdgeInsetsMake(, 0, -20, 0);
    
//    _tableView.contentInset.top = -20;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(menuStateEventOccurred:)
                                                 name:MFSideMenuStateNotificationEvent
                                               object:nil];
    
    UIButton* logOutView = [UIButton buttonWithType:UIButtonTypeCustom];
    UIView* grayBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 100)];
    grayBackgroundView.backgroundColor = [UIColor colorWithWhite:(245.0 / 255) alpha:1];
    logOutView.backgroundColor =[UIColor colorWithWhite:(245.0 / 255) alpha:1];
    [self.view addSubview:logOutView];
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = NSLocalizedString(@"Log Out", nil);
//            UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"popular_text"]];
    [logOutView addSubview:titleLabel];
    [titleLabel setFont:[UIFont fontWithName:@"Montserrat-SemiBold" size:17]];
    titleLabel.textColor = def_Golden_Color;
    UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logout"]];
    [logOutView addSubview:imageView];
    imageView.frame = CGRectMake(20, 15, 18, 18);
//    UIImageView* imageViewLabel = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Logout_text"]];
//    [logOutView addSubview:imageViewLabel];
    titleLabel.frame = CGRectMake(48, 15, 90, 18);
    titleLabel.textAlignment = NSTextAlignmentLeft;
//    [logOutView addSubview:imageViewLabel];
    
    CGFloat logoutAreaHeight = [UIScreen mainScreen].bounds.size.height > 800 ? 64 : 44;
    logOutView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - logoutAreaHeight, 1000, logoutAreaHeight);
    
    [logOutView addTarget:self action:@selector(logOutFromSideMenu:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)menuStateEventOccurred:(NSNotification *)notification {
    MFSideMenuStateEvent event = [[[notification userInfo] objectForKey:@"eventType"] intValue];
    if (event == MFSideMenuStateEventMenuDidOpen) {
        [self._tableView reloadData];
    }
}

#pragma mark - UITableView Data source and Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 1;
        case 1:
            return 4;
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [NSString stringWithFormat: @"Cell%ld_%ld", (long)indexPath.section, indexPath.row];
    
    ESSideTableViewCell *cell = (ESSideTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        
        cell = [[ESSideTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
    }
    
    cell.textLabel.textColor = def_Golden_Color;
    cell.textLabel.font = [UIFont fontWithName:@"Montserrat-SemiBold" size:16];
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.contentView.backgroundColor = [UIColor blackColor];
            UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(80, 0, cell.bounds.size.width-40, 50)];
            nameLabel.textColor = [UIColor whiteColor];
            nameLabel.backgroundColor = [UIColor clearColor];
            ESProfileImageView *avatarImageView = [[ESProfileImageView alloc] init];
            avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
            avatarImageView.layer.cornerRadius = 25;
            avatarImageView.layer.masksToBounds = YES;
            
            avatarImageView.frame = CGRectMake( [UIScreen mainScreen].bounds.size.width / 30, 0.0f, 50.0f, 50.0f);
            PFUser *user = [PFUser currentUser];
            PFFile *profilePictureSmall;
            
            if([user objectForKey:kESUserProfilePicSmallKey])
            {
                profilePictureSmall = [user objectForKey:kESUserProfilePicSmallKey];
            }
            else
            {
                profilePictureSmall = [user objectForKey:kESUserProfilePicMediumKey];
            }
            [avatarImageView setFile:profilePictureSmall];
            [cell.contentView addSubview:avatarImageView];
            [cell.contentView addSubview:nameLabel];
            if ([user objectForKey:kESUserDisplayNameKey]) {
                nameLabel.text = [user objectForKey:kESUserDisplayNameKey];
            }
            else {
                nameLabel.text = [user objectForKey:@"username"];
            }
            nameLabel.textColor = [UIColor whiteColor];
            nameLabel.font = [UIFont fontWithName:@"Montserrat-SemiBold" size:16];
//            cell.textLabel.frame = nameLabel.frame;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.offsetXLabel = 25;
        }
        return cell;
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            cell.textLabel.text = NSLocalizedString(@"Popular", nil);
            UIImageView *avatarImageView = [[UIImageView alloc] init];
            avatarImageView.frame = CGRectMake( [UIScreen mainScreen].bounds.size.width / 30, 10.0f, 18.f, 18.f);
            [avatarImageView setImage:[UIImage imageNamed:@"popular"]];
            avatarImageView.alpha = 0.5;
            cell.textLabel.textColor = [UIColor blackColor];
            [cell.contentView addSubview:avatarImageView];
        }
        else if (indexPath.row == 1) {
            cell.textLabel.text = NSLocalizedString(@"Recent", nil);
            cell.textLabel.textColor = [UIColor blackColor];
            UIImageView *avatarImageView = [[UIImageView alloc] init];
            avatarImageView.frame = CGRectMake( [UIScreen mainScreen].bounds.size.width / 30, 10.0f, 18.0f, 18.0f);
            [avatarImageView setImage:[UIImage imageNamed:@"recent"]];
            avatarImageView.alpha = 0.5;
            [cell.contentView addSubview:avatarImageView];
        }
        else if (indexPath.row == 2) {
            cell.textLabel.text = NSLocalizedString(@"Find Friends", nil);
            UIImageView *avatarImageView = [[UIImageView alloc] init];
            avatarImageView.frame = CGRectMake( [UIScreen mainScreen].bounds.size.width / 30, 10.0f, 18.0f, 18.0f);
            [avatarImageView setImage:[UIImage imageNamed:@"findfriends"]];
            avatarImageView.alpha = 0.5;
            cell.textLabel.textColor = [UIColor blackColor];
            [cell.contentView addSubview:avatarImageView];
        }
        else if (indexPath.row == 3) {
            cell.textLabel.text = NSLocalizedString(@"Settings", nil);
            cell.textLabel.textColor = [UIColor blackColor];
            UIImageView *avatarImageView = [[UIImageView alloc] init];
            avatarImageView.frame = CGRectMake( [UIScreen mainScreen].bounds.size.width / 30, 12.0f, 18.0f, 18.0f);
            [avatarImageView setImage:[UIImage imageNamed:@"settings"]];
            avatarImageView.alpha = 0.5;
            [cell.contentView addSubview:avatarImageView];
        }
    }
    
    cell.backgroundColor = [UIColor clearColor];
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Deselect row
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [self postNotificationWithString:@"ProfileOpen"];
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            [self postNotificationWithString:@"OpenPopularFeed"];
        }
        else if (indexPath.row == 1) {
            [self postNotificationWithString:@"OpenRecentFeed"];
        }
        if (indexPath.row == 2) {
            [self postNotificationWithString:@"FindFriendsOpen"];
        }
        else if (indexPath.row == 3) {
            [self postNotificationWithString:@"OpenSettings"];
        }
    }
    
}

- (IBAction)logOutFromSideMenu:(id)sender {
    self.mbhud = [MBProgressHUD showHUDAddedTo:self.parentViewController.view animated:YES];
    self.mbhud.labelText = NSLocalizedString(@"Logging out...", nil);
    self.mbhud.dimBackground = YES;
    [self performSelector:@selector(dummyLogout) withObject:nil afterDelay:0.2];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) return 60;
    return 45.0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}

- (void)postNotificationWithString:(NSString *)notification //post notification method and logic
{
    NSString *notificationName = @"ESNotification";
    NSString *key = @"CommunicationStringValue";
    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:notification forKey:key];
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil userInfo:dictionary];
}

- (void) dummyLogout {
    [self postNotificationWithString:@"LogHimOut"];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
