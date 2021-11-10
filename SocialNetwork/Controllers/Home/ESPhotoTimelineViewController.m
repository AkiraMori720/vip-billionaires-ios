//
//  ESPhotoTimelineViewController.m
//  D'Netzwierk
//
//  Created by Eric Schanet on 6/05/2014.
//  Copyright (c) 2014 Eric Schanet. All rights reserved.
//

#import "ESPhotoTimelineViewController.h"
#import "ESPhotoCell.h"
#import "ESAccountViewController.h"
#import "ESPhotoDetailsViewController.h"
#import "ESVideoDetailViewController.h"
#import "ESUtility.h"
#import "ESLoadMoreCell.h"
#import "AppDelegate.h"
#import "UIViewController+ScrollingNavbar.h"
#import "ESVideoTableViewCell.h"
#import "ESTextPostCell.h"
#import "ESEditPhotoViewController.h"
#import "ESEditVedioViewController.h"

BOOL easter = YES;

BOOL toggle = NO;

@interface ESPhotoTimelineViewController ()
//@property NSMutableDictionary* cachedImages;
@property AVPlayer *currentPlayingPlayer;
@property NSMutableArray* currentPlayingPlayers;
@end

@implementation ESPhotoTimelineViewController
@synthesize reusableSectionHeaderViews;
@synthesize reusableSectionFooterViews;
@synthesize shouldReloadOnAppear;
@synthesize outstandingSectionHeaderQueries, outstandingCountQueries, outstandingFollowQueries;
@synthesize outstandingSectionFooterQueries;
@synthesize activityIndicator, tapOnce, tapTwice;

#pragma mark - Initialization

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ESTabBarControllerDidFinishEditingPhotoNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ESUtilityUserFollowingChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ESPhotoDetailsViewControllerUserLikedUnlikedPhotoNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ESUtilityUserLikedUnlikedPhotoCallbackFinishedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ESPhotoDetailsViewControllerUserCommentedOnPhotoNotification object:nil];
    // [[NSNotificationCenter defaultCenter] removeObserver:self name:ESPhotoDetailsViewControllerUserReportedPhotoNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ESPhotoDetailsViewControllerUserDeletedPhotoNotification object:nil];
}

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
//        _cachedImages = [NSMutableDictionary new];
        self.outstandingSectionHeaderQueries = [NSMutableDictionary dictionary];
        self.outstandingSectionFooterQueries = [NSMutableDictionary dictionary];
        
        // The className to query on
        self.parseClassName = kESPhotoClassKey;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // The number of objects to show per page
        self.objectsPerPage = 10;
        
        // Improve scrolling performance by reusing UITableView section headers
        self.reusableSectionHeaderViews = [NSMutableSet setWithCapacity:3];
        self.reusableSectionFooterViews = [NSMutableSet setWithCapacity:3];
        self.loadingViewEnabled = YES;
        self.shouldReloadOnAppear = NO;        
    }
    return self;
}

-(void)loadView {
    [super loadView];
    
}
#pragma mark - UIViewController

-(void)stopAllPlayers:(BOOL)animated {
   
    for (AVPlayer* player in _currentPlayingPlayers) {
        if (player.timeControlStatus == AVPlayerTimeControlStatusPlaying) {
            [player pause];
        }
    }
}
- (void)viewWillAppear:(BOOL)animated {
    _currentPlayingPlayers = [NSMutableArray new];
}

- (void)viewDidLoad {
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.tableView.delaysContentTouches = TRUE;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [super viewDidLoad];
    _currentPlayingPlayers = [NSMutableArray new];
    [self.tableView setScrollsToTop:YES];
    
    self.refreshControl = [[UIRefreshControl alloc]init];
    self.refreshControl.tintColor = def_Golden_Color;
    [self.refreshControl addTarget:self action:@selector(loadObjects) forControlEvents:UIControlEventValueChanged];
    self.refreshControl.layer.zPosition = self.tableView.backgroundView.layer.zPosition + 1;
    self.tableView.backgroundColor = [UIColor clearColor];
    UIColor *backgroundColor = [UIColor colorWithWhite:0.90 alpha:1];
    self.tableView.backgroundView = [[UIView alloc]initWithFrame:self.tableView.bounds];
    self.tableView.backgroundView.backgroundColor = backgroundColor;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidPublishPhoto:) name:ESTabBarControllerDidFinishEditingPhotoNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userFollowingChanged:) name:ESUtilityUserFollowingChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidDeletePhoto:) name:ESPhotoDetailsViewControllerUserDeletedPhotoNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLikeOrUnlikePhoto:) name:ESPhotoDetailsViewControllerUserLikedUnlikedPhotoNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLikeOrUnlikePhoto:) name:ESUtilityUserLikedUnlikedPhotoCallbackFinishedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidCommentOnPhoto:) name:ESPhotoDetailsViewControllerUserCommentedOnPhotoNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidPublishPhoto:) name:@"videoUploadEnds" object:nil];
    
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.bounds.size.width, 0.01f)];

    tapOnce = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(didTapOnPhotoAction:)];
    tapTwice = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(userDidLikeOrUnlikePhoto:)];
    
    tapOnce.numberOfTapsRequired = 1;
    tapTwice.numberOfTapsRequired = 2;
    //stops tapOnce from overriding tapTwice
    [tapOnce requireGestureRecognizerToFail:tapTwice];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.shouldReloadOnAppear) {
        self.shouldReloadOnAppear = NO;
        [self loadObjects];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger sections = self.objects.count;
    if (self.paginationEnabled && [self _shouldShowPaginationCell] && sections != 0)
        sections++;
    return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


#pragma mark - UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (section == self.objects.count) {
        // Load More section
        return nil;
    }
    
    ESPhotoHeaderView *headerView = [self dequeueReusableSectionHeaderView];
    
    if (!headerView) {
        headerView = [[ESPhotoHeaderView alloc] initWithFrame:CGRectMake( 0.0f, 0.0f, self.view.bounds.size.width, 40.0f) buttons:ESPhotoHeaderButtonsDefault];
        [headerView.editButton addTarget:self action:@selector(btnEditPressed:) forControlEvents:UIControlEventTouchUpInside];
        headerView.delegate = self;
        [self.reusableSectionHeaderViews addObject:headerView];
    }
    [headerView.editButton setTag:section];
    headerView.topMargin = section == 0? 10 : 21;
    PFObject *photo = [self.objects objectAtIndex:section];
    [headerView setPhoto:photo];
    
    return headerView;
}
-(IBAction)btnEditPressed:(UIButton*)sender
{
    NSLog(@"btnEditPressed %ld",(long)sender.tag);
    
    PFObject *object = [self.objects objectAtIndex:sender.tag];
    NSLog(@"%@",object);
    
    self.photo = object;
    
   self.currentUserOwnsPhoto = [[[object objectForKey:kESPhotoUserKey] objectId] isEqualToString:[[PFUser currentUser] objectId]];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
    actionSheet.delegate = self;
    
    if ([self currentUserOwnsPhoto]) {
        // Else we only want to show an action button if the user owns the photo and has permission to delete it.
        actionSheet.destructiveButtonIndex = [actionSheet addButtonWithTitle:NSLocalizedString(@"Delete", nil)];
        actionSheet.tag = ThisIsUserTag;
    }
    else {
        actionSheet.destructiveButtonIndex = [actionSheet addButtonWithTitle:NSLocalizedString(@"Report", nil)];
        actionSheet.tag = MainActionSheetTag;
    }
    if (NSClassFromString(@"UIActivityViewController")) {
        [actionSheet addButtonWithTitle:NSLocalizedString(@"Share", nil)];
    }
    if ([self currentUserOwnsPhoto]) {
        [actionSheet addButtonWithTitle:NSLocalizedString(@"Edit", nil)];
    }
    
    actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
    

}
- (void)activityButtonAction:(id)sender {
    if (NSClassFromString(@"UIActivityViewController")) {
        
        if ([[self.photo objectForKey:@"type"] isEqualToString:@"video"])
        {
            if ([[self.photo objectForKey:kESVideoFileKey] isDataAvailable]) {
                [self showShareSheet];
            }
            else {
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                [[self.photo objectForKey:kESVideoFileKey] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    if (!error) {
                        [self showShareSheet];
                    }
                }];
            }
            
        }
        else
        {
            if ([[self.photo objectForKey:kESPhotoPictureKey] isDataAvailable]) {
                [self showShareSheet];
            } else if ([[self.photo objectForKey:@"type"] isEqualToString:@"text"]) {
                [self showShareSheet];
            }
            else {
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                [[self.photo objectForKey:kESPhotoPictureKey] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    if (!error) {
                        [self showShareSheet];
                    }
                }];
            }
        }
        // TODO: Need to do something when the photo hasn't finished downloading!
        
        
    }
}
#pragma mark - ()

- (void)showShareSheet {
    if ([[self.photo objectForKey:@"type"] isEqualToString:@"text"]) {
        NSMutableArray *activityItems = [NSMutableArray arrayWithCapacity:3];
        
        // Prefill caption if this is the original poster of the photo, and then only if they added a caption initially.
        if ([[[PFUser currentUser] objectId] isEqualToString:[[self.photo objectForKey:kESPhotoUserKey] objectId]] && [self.objects count] > 0) {
            PFObject *firstActivity = self.objects[0];
            if ([[[firstActivity objectForKey:kESActivityFromUserKey] objectId] isEqualToString:[[self.photo objectForKey:kESPhotoUserKey] objectId]]) {
                NSString *commentString = [firstActivity objectForKey:kESActivityContentKey];
                [activityItems addObject:commentString];
            }
        }
        
        //[activityItems addObject:[NSURL URLWithString:[NSString stringWithFormat:@"https://Netzwierk.org/#pic/%@", self.photo.objectId]]];
        [activityItems addObject:[NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id1076103571"]]];
        
        UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
            activityViewController.popoverPresentationController.sourceView = self.navigationController.navigationBar;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController presentViewController:activityViewController animated:YES completion:nil];
        });
    } else if ([[self.photo objectForKey:@"type"] isEqualToString:@"video"]) {
        
        [[self.photo objectForKey:kESVideoFileKey] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                
                NSMutableArray *activityItems = [NSMutableArray arrayWithCapacity:3];
                
                // Prefill caption if this is the original poster of the photo, and then only if they added a caption initially.
                if ([[[PFUser currentUser] objectId] isEqualToString:[[self.photo objectForKey:kESPhotoUserKey] objectId]] && [self.objects count] > 0) {
                    PFObject *firstActivity = self.objects[0];
                    if ([[[firstActivity objectForKey:kESActivityFromUserKey] objectId] isEqualToString:[[self.photo objectForKey:kESPhotoUserKey] objectId]]) {
                        NSString *commentString = [firstActivity objectForKey:kESActivityContentKey];
                        [activityItems addObject:commentString];
                    }
                }
                
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *documentsDirectory = [paths objectAtIndex:0];
                NSString *appFile = [documentsDirectory stringByAppendingPathComponent:@"MyFile.m4v"];
                [data writeToFile:appFile atomically:YES];
                NSURL *movieUrl = [NSURL fileURLWithPath:appFile];
                
                [activityItems addObject:movieUrl];
                //[activityItems addObject:[NSURL URLWithString:[NSString stringWithFormat:@"https://Netzwierk.org/#pic/%@", self.photo.objectId]]];
                [activityItems addObject:[NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id1076103571"]]];
                
                UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
                if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
                    activityViewController.popoverPresentationController.sourceView = self.navigationController.navigationBar;
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.navigationController presentViewController:activityViewController animated:YES completion:nil];
                });
                
            }
            else
            {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                
            }
        }];
    }
    else
    {
        [[self.photo objectForKey:kESPhotoPictureKey] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                
                NSMutableArray *activityItems = [NSMutableArray arrayWithCapacity:3];
                
                // Prefill caption if this is the original poster of the photo, and then only if they added a caption initially.
                if ([[[PFUser currentUser] objectId] isEqualToString:[[self.photo objectForKey:kESPhotoUserKey] objectId]] && [self.objects count] > 0) {
                    PFObject *firstActivity = self.objects[0];
                    if ([[[firstActivity objectForKey:kESActivityFromUserKey] objectId] isEqualToString:[[self.photo objectForKey:kESPhotoUserKey] objectId]]) {
                        NSString *commentString = [firstActivity objectForKey:kESActivityContentKey];
                        [activityItems addObject:commentString];
                    }
                }
                
                [activityItems addObject:[UIImage imageWithData:data]];
                //[activityItems addObject:[NSURL URLWithString:[NSString stringWithFormat:@"https://Netzwierk.org/#pic/%@", self.photo.objectId]]];
                [activityItems addObject:[NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id1076103571"]]];
                
                UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
                if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
                    activityViewController.popoverPresentationController.sourceView = self.navigationController.navigationBar;
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.navigationController presentViewController:activityViewController animated:YES completion:nil];
                });
                
            }
        }];
        
    }
    
}
- (void)shouldDeletePhoto {
    // Delete all activites related to this photo
    PFQuery *query = [PFQuery queryWithClassName:kESActivityClassKey];
    [query whereKey:kESActivityPhotoKey equalTo:self.photo];
    [query findObjectsInBackgroundWithBlock:^(NSArray *activities, NSError *error) {
        if (!error) {
            for (PFObject *activity in activities) {
                [activity deleteEventually];
            }
        }
        
        // Delete photo
        [self.photo deleteInBackgroundWithBlock:^(BOOL result, NSError *error){
            if (!error) {
                NSLog(@"gay");
            }
        }];
    }];
    [[NSNotificationCenter defaultCenter] postNotificationName:ESPhotoDetailsViewControllerUserDeletedPhotoNotification object:[self.photo objectId]];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)shouldReportPhoto {
    PFObject *object = [PFObject objectWithClassName:@"Report"];
    [object setObject:self.photo forKey:@"ReportedPhoto"];
    [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            SCLAlertView *alert = [[SCLAlertView alloc] init];
            alert.backgroundType = Blur;
            [alert showNotice:self.tabBarController title:NSLocalizedString(@"Notice", nil) subTitle:NSLocalizedString(@"Photo has been successfully reported.", nil) closeButtonTitle:@"OK" duration:0.0f];
            
        }
        else {
            SCLAlertView *alert = [[SCLAlertView alloc] init];
            [alert showError:self.tabBarController title:NSLocalizedString(@"Hold On...", nil)
                    subTitle:NSLocalizedString(@"Check your internet connection.", nil)
            closeButtonTitle:@"OK" duration:0.0f];
            NSLog(@"error %@",error);
        }
        
    }];
    
}
#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (actionSheet.tag == MainActionSheetTag) {
        if ([actionSheet destructiveButtonIndex] == buttonIndex) {
            
            if ([[self.photo objectForKey:@"type"] isEqualToString:@"video"])
            {
                UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Are you sure you want to report this video? This can not be undone and might have consequences for the author.", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:NSLocalizedString(@"Yes, report this video", nil) otherButtonTitles:nil];
                actionSheet.tag = ReportPhotoActionSheetTag;
                [actionSheet showFromTabBar:self.tabBarController.tabBar];
            }
            else
            {
                UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Are you sure you want to report this photo? This can not be undone and might have consequences for the author.", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:NSLocalizedString(@"Yes, report this photo", nil) otherButtonTitles:nil];
                actionSheet.tag = ReportPhotoActionSheetTag;
                [actionSheet showFromTabBar:self.tabBarController.tabBar];
            }
        } else if (buttonIndex == 1){
            [self activityButtonAction:actionSheet];
        }
        
    }
    else if (actionSheet.tag == ThisIsUserTag) {
        if ([actionSheet destructiveButtonIndex] == buttonIndex) {
            // prompt to delete
            if ([[self.photo objectForKey:@"type"] isEqualToString:@"text"]) {
                
                UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Are you sure you want to delete this post? This can not be undone.", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:NSLocalizedString(@"Yes, delete post", nil) otherButtonTitles:nil];
                actionSheet.tag = ConfirmDeleteActionSheetTag;
                [actionSheet showFromTabBar:self.tabBarController.tabBar];
            }
            else if ([[self.photo objectForKey:@"type"] isEqualToString:@"video"])
            {
                UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Are you sure you want to delete this video? This can not be undone.", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:NSLocalizedString(@"Yes, delete video", nil) otherButtonTitles:nil];
                actionSheet.tag = ConfirmDeleteActionSheetTag;
                [actionSheet showFromTabBar:self.tabBarController.tabBar];
            }
            else {
                UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Are you sure you want to delete this photo? This can not be undone.", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:NSLocalizedString(@"Yes, delete photo", nil) otherButtonTitles:nil];
                actionSheet.tag = ConfirmDeleteActionSheetTag;
                [actionSheet showFromTabBar:self.tabBarController.tabBar];
            }
            
        } else if (buttonIndex == 1){
            [self activityButtonAction:actionSheet];
        }
        else if (buttonIndex == 2){
            [self editPost];
            
        }
        
    }
    else if (actionSheet.tag == ConfirmDeleteActionSheetTag) {
        if ([actionSheet destructiveButtonIndex] == buttonIndex) {
            
            [self shouldDeletePhoto];
        }
    } else if (actionSheet.tag == ReportPhotoActionSheetTag) {
        if ([actionSheet destructiveButtonIndex] == buttonIndex) {
            
            [self shouldReportPhoto];
        }
    }
    else if (actionSheet.tag == ReportUserCommentTag) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"What do you want the user to be reported for?", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Sexual content", nil), NSLocalizedString(@"Offensive content", nil), NSLocalizedString(@"Spam", nil), NSLocalizedString(@"Other", nil), nil];
        //actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
        actionSheet.tag = ReportUserReasonTag;
        [actionSheet showInView:self.view];
        
    }
    
    
}

-(void)editPost
{
    
    if ([[self.photo objectForKey:@"type"] isEqualToString:@"video"]) {
        
        ESEditVedioViewController *viewController = [[ESEditVedioViewController alloc] initWithImage:nil url:nil isEditView:TRUE];
        viewController.isEdit = TRUE;
        viewController.photoFile = [self.photo objectForKey:kESVideoFileThumbnailKey];
        viewController.thumbnailFile = [self.photo objectForKey:kESVideoFileThumbnailKey];
        viewController.descriptionPhoto = [self.photo objectForKey:kESEditPhotoViewControllerDescriptionKey];
        viewController.editVideoObject = self.photo;
        viewController.hidesBottomBarWhenPushed = true;
        [viewController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
        [self.navigationController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
        [self stopAllPlayers:YES];
        [self.navigationController pushViewController:viewController animated:NO];
    }
    else
    {
        ESEditPhotoViewController *viewController = [[ESEditPhotoViewController alloc] initWithImage:nil isEditView:TRUE];
        viewController.isEdit = TRUE;
        viewController.photoFile = [self.photo objectForKey:kESPhotoPictureKey];
        viewController.thumbnailFile = [self.photo objectForKey:kESPhotoThumbnailKey];
        viewController.descriptionPhoto = [self.photo objectForKey:kESEditPhotoViewControllerDescriptionKey];
        viewController.editPhotoObject = self.photo;
        viewController.hidesBottomBarWhenPushed = true;
        [viewController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
        [self.navigationController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
        [self stopAllPlayers:YES];
        [self.navigationController pushViewController:viewController animated:NO];
    }
    
    
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == self.objects.count) {
        // Load More section
        return nil;
    }
    
    ESPhotoFooterView *headerView = [self dequeueReusableSectionFooterView];
    
    if (!headerView) {
        headerView = [[ESPhotoFooterView alloc] initWithFrame:CGRectMake( 0.0f, 0.0f, self.view.bounds.size.width, 64.0f) buttons:ESPhotoFooterButtonsDefault];
        headerView.delegate = self;
        [self.reusableSectionFooterViews addObject:headerView];
    }
    
    PFObject *photo = [self.objects objectAtIndex:section];
    [headerView setPhoto:photo];
    headerView.tag = section;
    [headerView.likeButton setTag:section];
    
    NSDictionary *attributesForPhoto = [[ESCache sharedCache] attributesForPhoto:photo];
    
    if (attributesForPhoto) {
        [headerView setLikeStatus:[[ESCache sharedCache] isPhotoLikedByCurrentUser:photo]];
        [headerView.likeImage setTitle:[[[ESCache sharedCache] likeCountForPhoto:photo] description] forState:UIControlStateNormal];
        NSString *commentCount = [[[ESCache sharedCache] commentCountForPhoto:photo] description];
        if ([[[[ESCache sharedCache] likeCountForPhoto:photo] description] isEqualToString:@"1"]) {
            [headerView.labelButton setTitle:NSLocalizedString(@"like", nil) forState:UIControlStateNormal];
        }
        else {
            [headerView.labelButton setTitle:NSLocalizedString(@"likes", nil) forState:UIControlStateNormal];
        }
        if ([[[[ESCache sharedCache] commentCountForPhoto:photo] description] isEqualToString:@"1"]) {
            [headerView.labelComment setTitle:[commentCount stringByAppendingFormat:@" %@", NSLocalizedString(@"comments", nil)] forState:UIControlStateNormal];
        }
        else {
            [headerView.labelComment setTitle:[commentCount stringByAppendingFormat:@" %@", NSLocalizedString(@"comments", nil)] forState:UIControlStateNormal];
        }
        
//        if (headerView.likeButton.alpha < 1.0f || headerView.commentButton.alpha < 1.0f) {
//            [UIView animateWithDuration:0.500f animations:^{
//                headerView.likeButton.alpha = 1.0f;
//            }];
//        }
    } else {
        //headerView.likeButton.alpha = 0.0f;
        
        @synchronized(self) {
            // check if we can update the cache
            NSNumber *outstandingSectionFooterQueryStatus = [self.outstandingSectionFooterQueries objectForKey:@(section)];
            if (!outstandingSectionFooterQueryStatus) {
                PFQuery *query = [ESUtility queryForActivitiesOnPhoto:photo cachePolicy:kPFCachePolicyNetworkOnly];
                 if ([photo objectForKey:kESVideoFileKey]) {
                    query = [ESUtility queryForActivitiesOnVideo:photo cachePolicy:kPFCachePolicyNetworkOnly];
                }
                if ([[photo objectForKey:@"type"] isEqualToString:@"text"])
                {
                    query = [ESUtility queryForActivitiesOnPost:photo cachePolicy:kPFCachePolicyNetworkOnly];
                }
                [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    @synchronized(self) {
                        [self.outstandingSectionHeaderQueries removeObjectForKey:@(section)];
                        
                        if (error) {
                            return;
                        }
                        
                        NSMutableArray *likers = [NSMutableArray array];
                        NSMutableArray *commenters = [NSMutableArray array];
                        
                        BOOL isLikedByCurrentUser = NO;
                        
                        for (PFObject *activity in objects) {
                            if (([[activity objectForKey:kESActivityTypeKey] isEqualToString:kESActivityTypeLikePhoto] || [[activity objectForKey:kESActivityTypeKey] isEqualToString:kESActivityTypeLikeVideo] || [[activity objectForKey:kESActivityTypeKey] isEqualToString:kESActivityTypeLikePost])&& [activity objectForKey:kESActivityFromUserKey]) {
                                [likers addObject:[activity objectForKey:kESActivityFromUserKey]];
                            } else if (([[activity objectForKey:kESActivityTypeKey] isEqualToString:kESActivityTypeCommentPhoto]||[[activity objectForKey:kESActivityTypeKey] isEqualToString:kESActivityTypeCommentVideo] || [[activity objectForKey:kESActivityTypeKey] isEqualToString:kESActivityTypeCommentPost]) && [activity objectForKey:kESActivityFromUserKey]) {
                                [commenters addObject:[activity objectForKey:kESActivityFromUserKey]];
                            }
                            
                            if ([[[activity objectForKey:kESActivityFromUserKey] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
                                if ([[activity objectForKey:kESActivityTypeKey] isEqualToString:kESActivityTypeLikePhoto] || [[activity objectForKey:kESActivityTypeKey] isEqualToString:kESActivityTypeLikeVideo]|| [[activity objectForKey:kESActivityTypeKey] isEqualToString:kESActivityTypeLikePost]) {
                                    isLikedByCurrentUser = YES;
                                }
                            }
                        }
                        
                        
                        [[ESCache sharedCache] setAttributesForPhoto:photo likers:likers commenters:commenters likedByCurrentUser:isLikedByCurrentUser];
                        
                        if (headerView.tag != section) {
                            return;
                        }
                        
                        [headerView setLikeStatus:[[ESCache sharedCache] isPhotoLikedByCurrentUser:photo]];
                        [headerView.likeImage setTitle:[[[ESCache sharedCache] likeCountForPhoto:photo] description] forState:UIControlStateNormal];
                        NSString *commentCount = [[[ESCache sharedCache] commentCountForPhoto:photo] description];
                        if ([[[[ESCache sharedCache] likeCountForPhoto:photo] description] isEqualToString:@"1"]) {
                            [headerView.labelButton setTitle:NSLocalizedString(@"like", nil) forState:UIControlStateNormal];
                        }
                        else {
                            [headerView.labelButton setTitle:NSLocalizedString(@"likes", nil) forState:UIControlStateNormal];
                        }
                        if ([[[[ESCache sharedCache] commentCountForPhoto:photo] description] isEqualToString:@"1"]) {
                            [headerView.labelComment setTitle:[commentCount stringByAppendingFormat:@" %@", NSLocalizedString(@"comments", nil)] forState:UIControlStateNormal];
                        }
                        else {
                            [headerView.labelComment setTitle:[commentCount stringByAppendingFormat:@" %@", NSLocalizedString(@"comments", nil)] forState:UIControlStateNormal];
                        }
//                        if (headerView.likeButton.alpha < 1.0f || headerView.commentButton.alpha < 1.0f) {
//                            [UIView animateWithDuration:0.500f animations:^{
//                                headerView.likeButton.alpha = 1.0f;
//                            }];
//                        }
                    }
                }];
            }
        }
    }
    
    return headerView;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == self.objects.count) {
        return 0.0f;
    }
    
    if (section == 0) return 50;
    return 60.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == self.objects.count) {
        return 0.0f;
    }
    return 80.0f;   //mod:16.0f
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section >= self.objects.count) {
        // Load More Section
        return 44.0f;
    }
    PFObject *object = [self.objects objectAtIndex:indexPath.section];
    if ([[object objectForKey:@"type"] isEqualToString:@"text"]) {
        CGSize labelSize = [[object objectForKey:@"text"] sizeWithFont:[UIFont fontWithName:@"Montserrat-Regular" size:16]
                                                         constrainedToSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 50, 100)
                                                             lineBreakMode:NSLineBreakByWordWrapping];
        CGFloat labelHeight = labelSize.height;
        return labelHeight + 20;
    }
    else
    {
//        return SCR_W - 40;
        CGFloat ratio = 1;
        CGFloat height;
        if ([[object objectForKey:@"type"] isEqualToString:@"video"])
            ratio = 1;
        else {
            PFFile *file = [object objectForKey:kESPhotoPictureKey];
            if (file != nil) {
                NSURL *url = [NSURL URLWithString:file.url];
                UIImage *cachedImage = [[PFImageCache sharedCache] imageForURL:url];
                
                if (cachedImage != nil) {
                    ratio = cachedImage.size.height / cachedImage.size.width;
                }
            }
        }
        
        if (ratio >= 100000) height =  (SCR_W - 40) + 20;
        else
            height =  (SCR_W - 40) * ratio + 20;
        
        
        
        NSString *strDsc = [object objectForKey:kESEditPhotoViewControllerDescriptionKey];
        strDsc = [strDsc stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

        if (strDsc.length > 0) {
            CGSize labelSize = [strDsc sizeWithFont:[UIFont fontWithName:@"Montserrat-Regular" size:15]
                constrainedToSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 40, 9999999)
                lineBreakMode:NSLineBreakByWordWrapping];
            return labelSize.height + 20 + height;
        }
        return height;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == self.objects.count && self.paginationEnabled) {
        // Load More Cell
//        [self loadNextPage];
    }
    else {
      
        self.photo = [self.objects objectAtIndex:indexPath.section];
        
        if (self.photo) {
            
            if ([[self.photo objectForKey:@"type"] isEqualToString:@"video"]) {
                
                ESVideoDetailViewController *photoDetailsVC = [[ESVideoDetailViewController alloc] initWithPhoto:self.photo];
                photoDetailsVC.hidesBottomBarWhenPushed = true;
                [self stopAllPlayers:YES];
                [self.navigationController pushViewController:photoDetailsVC animated:YES];
            }
            else
            {
                ESPhotoDetailsViewController *photoDetailsVC = [[ESPhotoDetailsViewController alloc] initWithPhoto:self.photo];
                photoDetailsVC.hidesBottomBarWhenPushed = true;
                [self stopAllPlayers:YES];
                [self.navigationController pushViewController:photoDetailsVC animated:YES];
                
                
            }
        }
      
        
    }
    
}

#pragma mark - PFQueryTableViewController

- (PFQuery *)queryForTable {
    if (![PFUser currentUser]) {
        PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
        [query setLimit:0];
        //[self.refreshControl endRefreshing];
        return query;
    }
    //
    //
    /* NOTE THAT WE DONT SET A TYPE FOR IMAGES, SO TYPE FIELD IS EMPTY FOR THEM!*/
    //
    //
    PFQuery *followingActivitiesQuery = [PFQuery queryWithClassName:kESActivityClassKey];
    [followingActivitiesQuery whereKey:kESActivityTypeKey equalTo:kESActivityTypeFollow];
    [followingActivitiesQuery whereKey:kESActivityFromUserKey equalTo:[PFUser currentUser]];
    followingActivitiesQuery.cachePolicy = kPFCachePolicyNetworkOnly;
    followingActivitiesQuery.limit = 1000;
    
    PFQuery *photosFromFollowedUsersQuery = [PFQuery queryWithClassName:self.parseClassName];
    [photosFromFollowedUsersQuery whereKey:kESPhotoUserKey matchesKey:kESActivityToUserKey inQuery:followingActivitiesQuery];
    [photosFromFollowedUsersQuery whereKeyDoesNotExist:@"type"];
    [photosFromFollowedUsersQuery whereKeyExists:kESPhotoPictureKey];
    
    PFQuery *videosFromFollowedUserQuery = [PFQuery queryWithClassName:self.parseClassName];
    [videosFromFollowedUserQuery whereKey:kESPhotoUserKey matchesKey:kESActivityToUserKey inQuery:followingActivitiesQuery];
    [videosFromFollowedUserQuery whereKeyExists:@"type"];
   // [videosFromFollowedUserQuery whereKeyExists:kESVideoFileKey];
    
    PFQuery *photosFromCurrentUserQuery = [PFQuery queryWithClassName:self.parseClassName];
    [photosFromCurrentUserQuery whereKey:kESPhotoUserKey equalTo:[PFUser currentUser]];
    [photosFromCurrentUserQuery whereKeyExists:kESPhotoPictureKey];
    [photosFromCurrentUserQuery whereKeyDoesNotExist:@"type"];
    
    PFQuery *videosFromCurrentUserQuery = [PFQuery queryWithClassName:self.parseClassName];
    [videosFromCurrentUserQuery whereKey:kESPhotoUserKey equalTo:[PFUser currentUser]];
    [videosFromCurrentUserQuery whereKeyExists:@"type"];
   // [videosFromCurrentUserQuery whereKeyExists:kESVideoFileKey];
    
    PFQuery *query = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:photosFromFollowedUsersQuery, photosFromCurrentUserQuery, videosFromCurrentUserQuery, videosFromFollowedUserQuery, nil]];
    [query includeKey:kESPhotoUserKey];
    [query orderByDescending:@"createdAt"];
    
    // A pull-to-refresh should always trigger a network request.
    [query setCachePolicy:kPFCachePolicyNetworkOnly];
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    //
    // If there is no network connection, we will hit the cache first.
    if (self.objects.count == 0 || ![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
        [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
    }
    return query;
}

- (PFObject *)objectAtIndexPath:(NSIndexPath *)indexPath {
    // overridden, since we want to implement sections
    if (indexPath.section < self.objects.count) {
        return [self.objects objectAtIndex:indexPath.section];
    }
    
    return nil;
}
- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(ESVideoTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[ESVideoTableViewCell class]]) {
        if (cell.movie.player != nil)
            [self.currentPlayingPlayers removeObject:cell.movie.player];
        [cell.movie.player pause];
        cell.imageView.hidden = NO;
        cell.movie.view.hidden = YES;
        cell.mediaItemButton.hidden = NO;
    }
    
}
- (void) dummyTapForVideo:(id)sender {
    UIButton *clicked = (UIButton *) sender;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:clicked.tag];
    [self performSelector:@selector(tableView:didSelectRowAtIndexPath:) withObject:self.tableView withObject:indexPath];
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell_%@", object.objectId];
    NSString *TextIdentifier = [NSString stringWithFormat:@"Cell1_%@", object.objectId];
    NSString *VideoIdentifier = [NSString stringWithFormat:@"Cell2_%@", object.objectId];

    
    if ([self _shouldShowPaginationCell] && indexPath.section == self.objects.count) {
        UITableViewCell *cell = [self tableView:tableView cellForNextPageAtIndexPath:indexPath];
        return cell;
    }
    else if ([[object objectForKey:@"type"] isEqualToString:@"video"]) {
        ESVideoTableViewCell *cell = (ESVideoTableViewCell *)[tableView dequeueReusableCellWithIdentifier:VideoIdentifier];
        
        if (cell == nil) {
            cell = [[ESVideoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:VideoIdentifier object:object];
//            
//            [cell.mediaItemButton addTarget:self action:@selector(dummyTapForVideo:) forControlEvents:UIControlEventTouchUpInside];
            
        }
        cell.mediaItemButton.tag = indexPath.section;
        CGFloat topPosition = 20;
        cell.lblDescription.text = @"";
        if ([object objectForKey:kESEditPhotoViewControllerDescriptionKey]) {
            if ([object objectForKey:kESEditPhotoViewControllerDescriptionKey] != nil) {
                cell.lblDescription.text = [object objectForKey:kESEditPhotoViewControllerDescriptionKey];
            }
        }
        
        NSString *strDsc = [object objectForKey:kESEditPhotoViewControllerDescriptionKey];
        strDsc = [strDsc stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        CGFloat labelHeight = 0;
        
        if (strDsc.length > 0) {
            CGSize labelSize = [strDsc sizeWithFont:[UIFont fontWithName:@"Montserrat-Regular" size:15] constrainedToSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 40, 9999999) lineBreakMode:NSLineBreakByWordWrapping];
            labelHeight = labelSize.height;
        }
        
        [cell.lblDescription setFrame:CGRectMake(20, topPosition, [UIScreen mainScreen].bounds.size.width - 40, labelHeight)];
        
        if (strDsc.length > 0) {
            topPosition += labelHeight + 20;
        }
        
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.imageView.backgroundColor = [UIColor blackColor];
        
        PFFile *file = [object objectForKey:@"videoThumbnail"];
        NSURL *url = [NSURL URLWithString:file.url];
        UIImage *cachedImage = [[PFImageCache sharedCache] imageForURL:url];
        if (cachedImage != nil) {
            cell.imageView.frame = CGRectMake(20, topPosition, SCR_W - 40,(SCR_W - 40) * cachedImage.size.height / cachedImage.size.width);
            cell.imageView.image = cachedImage;
            cell.imageView.hidden = NO;
            [cell layoutIfNeeded];
        } else if (object) {
            cell.imageView.hidden = YES;
            cell.imageView.file = [object objectForKey:@"videoThumbnail"];
            [cell.imageView loadInBackground:^(UIImage * _Nullable image, NSError * _Nullable error) {
                if (image != nil) {
                    cell.imageView.hidden = NO;
                    cell.imageView.frame = CGRectMake(20, topPosition, SCR_W - 40,(SCR_W - 40) * 1);
//                    image.size.height / image.size.width);
                    [UIView performWithoutAnimation:^{
                        [tableView beginUpdates];
                        [tableView reloadRowsAtIndexPaths:@[indexPath]
                                         withRowAnimation:UITableViewRowAnimationNone];
                        [tableView endUpdates];
                    }];
                }
            }];
            return cell;
        } else
            return cell;
        
        [cell.movie.view setFrame:CGRectMake(20, topPosition, SCR_W - 40,(SCR_W - 40) * 1)];
//        imageCell.size.height / imageCell.size.width)];
        cell.mediaItemButton.frame = CGRectMake(20, topPosition, SCR_W - 40,(SCR_W - 40) * 1);
//        imageCell.size.height / imageCell.size.width);

        /* play video stream from network directly instead downloading the video to local */
        PFFile *video =[object objectForKey:@"file"];
        NSURL *movieUrl = [NSURL URLWithString:video.url];
        AVURLAsset * asset = [[AVURLAsset alloc] initWithURL:movieUrl options:@{@"AVURLAssetOutOfBandMIMETypeKey": @"video/mp4; codecs=\"avc1.42E01E, mp4a.40.2\""}];
        AVPlayer *player = [AVPlayer playerWithPlayerItem:[AVPlayerItem playerItemWithAsset:asset]];
        cell.movie.player = player;
        [self.currentPlayingPlayers addObject:player];
            
        
        return cell;
    }
    else if ([[object objectForKey:@"type"] isEqualToString:@"text"]) {
        ESTextPostCell *cell = (ESTextPostCell *)[tableView dequeueReusableCellWithIdentifier:TextIdentifier];
        if (cell == nil) {
            cell = [[ESTextPostCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TextIdentifier];
            
            [cell.itemButton addTarget:self action:@selector(didTapOnTextPostAction:) forControlEvents:UIControlEventTouchUpInside];
            
        }
        cell.itemButton.tag = indexPath.section;
        cell.contentView.backgroundColor = [UIColor clearColor];
        // cell.imageView.hidden= YES;
        if (object) {
            CGSize labelSize = [[object objectForKey:@"text"] sizeWithFont:[UIFont fontWithName:@"Montserrat-Regular" size:16]
                                                             constrainedToSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 50, 100)
                                                                 lineBreakMode:NSLineBreakByWordWrapping];
            CGFloat labelHeight = labelSize.height;
            cell.postText.frame = CGRectMake(25, 0, [UIScreen mainScreen].bounds.size.width-50, labelHeight+10);
            cell.itemButton.frame = CGRectMake(10, 0, [UIScreen mainScreen].bounds.size.width-20, labelHeight+10);
            cell.postText.text = [object objectForKey:@"text"];
        }
        return cell;
    }
    else {
        ESPhotoCell *cell = (ESPhotoCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[ESPhotoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier object:object];
            [cell.mediaItemButton addTarget:self action:@selector(didTapOnPhotoAction:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        cell.mediaItemButton.tag = indexPath.section;
        CGFloat topPosition = 20;
        cell.lblDescription.text = @"";
        
        if ([object objectForKey:kESEditPhotoViewControllerDescriptionKey]) {
            if ([object objectForKey:kESEditPhotoViewControllerDescriptionKey] != nil) {
                cell.lblDescription.text = [object objectForKey:kESEditPhotoViewControllerDescriptionKey];
            }
        }

        PFFile *file = [object objectForKey:kESPhotoPictureKey];
        NSURL *url = [NSURL URLWithString:file.url];
        UIImage *cachedImage = [[PFImageCache sharedCache] imageForURL:url];
        if (cachedImage != nil) {
            cell.imageView.frame = CGRectMake(20, topPosition, SCR_W - 40,(SCR_W - 40) * cachedImage.size.height / cachedImage.size.width);
            cell.imageView.image = cachedImage;
            cell.imageView.hidden = NO;
            [cell layoutIfNeeded];
        } else if (object) {
            cell.imageView.hidden = YES;
            cell.imageView.file = [object objectForKey:kESPhotoPictureKey];
            [cell.imageView loadInBackground:^(UIImage * _Nullable image, NSError * _Nullable error) {
                if (image != nil) {
                    cell.imageView.hidden = NO;
                    cell.imageView.frame = CGRectMake(20, topPosition, SCR_W - 40,(SCR_W - 40) * image.size.height / image.size.width);
                    [UIView performWithoutAnimation:^{
                        [tableView beginUpdates];
                        [tableView reloadRowsAtIndexPaths:@[indexPath]
                                         withRowAnimation:UITableViewRowAnimationNone];
                        [tableView endUpdates];
                    }];
                    [cell layoutIfNeeded];
                }
            }];
        }
        return cell;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *LoadMoreCellIdentifier = @"LoadMoreCell";
    
    [self loadNextPage];
    
    ESLoadMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:LoadMoreCellIdentifier];
    if (!cell) {
        cell = [[ESLoadMoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LoadMoreCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.separatorImageTop.image = [UIImage imageNamed:@"SeparatorTimelineDark"];
        cell.hideSeparatorBottom = YES;
        cell.mainView.backgroundColor = [UIColor clearColor];
        
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView bringSubviewToFront:cell];
}

#pragma mark - ESPhotoTimelineViewController

- (ESPhotoHeaderView *)dequeueReusableSectionHeaderView {
    for (ESPhotoHeaderView *sectionHeaderView in self.reusableSectionHeaderViews) {
        if (!sectionHeaderView.superview) {
            // we found a section header that is no longer visible
            return sectionHeaderView;
        }
    }
    
    return nil;
}

- (ESPhotoFooterView *)dequeueReusableSectionFooterView {
    for (ESPhotoFooterView *sectionFooterView in self.reusableSectionFooterViews) {
        if (!sectionFooterView.superview) {
            // we found a section header that is no longer visible
            return sectionFooterView;
        }
    }
    
    return nil;
}



#pragma mark - ESPhotoHeaderViewDelegate

- (void)photoHeaderView:(ESPhotoHeaderView *)photoHeaderView didTapUserButton:(UIButton *)button user:(PFUser *)user {
    if (user != nil && ![[user objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
        ESAccountViewController *accountViewController = [[ESAccountViewController alloc] initWithStyle:UITableViewStylePlain];
        accountViewController.hidesBottomBarWhenPushed = true;
        [accountViewController setUser:user];
        [self stopAllPlayers:YES];
        [self.navigationController pushViewController:accountViewController animated:YES];
    }
    
}

#pragma mark - ESPhotoFooterViewDelegate

- (void)photoFooterView:(ESPhotoFooterView *)photoFooterView didTapUserButton:(UIButton *)button user:(PFUser *)user {
    if (user != nil && ![[user objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
        ESAccountViewController *accountViewController = [[ESAccountViewController alloc] initWithStyle:UITableViewStylePlain];
        accountViewController.hidesBottomBarWhenPushed = true;
        [accountViewController setUser:user];
        [self stopAllPlayers:YES];
        [self.navigationController pushViewController:accountViewController animated:YES];
    }
}


- (void)photoFooterView:(ESPhotoFooterView *)photoFooterView didTapLikePhotoButton:(UIButton *)button photo:(PFObject *)photo {
    // Disable the button so users cannot send duplicate requests
    [photoFooterView shouldEnableLikeButton:NO];
    NSNumber *number = [NSNumber numberWithInt:0];
    [photoFooterView shouldReEnableLikeButton:number];
    
    BOOL liked = !button.selected;
    [photoFooterView setLikeStatus:liked];
    
    NSString *originalButtonTitle = photoFooterView.likeImage.titleLabel.text;
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    
    NSNumber *likeCount = [numberFormatter numberFromString:photoFooterView.likeImage.titleLabel.text];
    if (liked) {
        likeCount = [NSNumber numberWithInt:[likeCount intValue] + 1];
        [[ESCache sharedCache] incrementLikerCountForPhoto:photo];
    } else {
        if ([likeCount intValue] > 0) {
            likeCount = [NSNumber numberWithInt:[likeCount intValue] - 1];
        }
        [[ESCache sharedCache] decrementLikerCountForPhoto:photo];
    }
    
    [[ESCache sharedCache] setPhotoIsLikedByCurrentUser:photo liked:liked];
    
    if ([[numberFormatter stringFromNumber:likeCount] isEqualToString:@"1"]) {
        [photoFooterView.labelButton setTitle:NSLocalizedString(@"like", nil) forState:UIControlStateNormal];
    }
    else {
        [photoFooterView.labelButton setTitle:NSLocalizedString(@"likes", nil) forState:UIControlStateNormal];
    }
    [photoFooterView.likeImage setTitle:[numberFormatter stringFromNumber:likeCount] forState:UIControlStateNormal];
    
    if (liked) {
        if ([photo objectForKey:kESVideoFileKey]) { //check if it is a video actually
            [ESUtility likeVideoInBackground:photo block:^(BOOL succeeded, NSError *error) {
                ESPhotoFooterView *actualHeaderView = (ESPhotoFooterView *)[self tableView:self.tableView viewForFooterInSection:button.tag];
                
                NSNumber *number = [NSNumber numberWithInt:1];
                [photoFooterView performSelector:@selector(shouldReEnableLikeButton:) withObject:number afterDelay:0.5];
                
                [actualHeaderView shouldEnableLikeButton:YES];
                [actualHeaderView setLikeStatus:succeeded];
                
                if (!succeeded) {
                    [actualHeaderView.likeImage setTitle:originalButtonTitle forState:UIControlStateNormal];
                    
                    if ([originalButtonTitle isEqualToString:@"1"]) {
                        [photoFooterView.labelButton setTitle:NSLocalizedString(@"like", nil) forState:UIControlStateNormal];
                    }
                    else {
                        [photoFooterView.labelButton setTitle:NSLocalizedString(@"likes", nil) forState:UIControlStateNormal];
                        
                    }
                }
                
            }];
        }
        else if ([[photo objectForKey:@"type"] isEqualToString:@"text"]) { //check if it is a text post actually
            [ESUtility likePostInBackground:photo block:^(BOOL succeeded, NSError *error) {
                ESPhotoFooterView *actualHeaderView = (ESPhotoFooterView *)[self tableView:self.tableView viewForFooterInSection:button.tag];
                
                NSNumber *number = [NSNumber numberWithInt:1];
                [photoFooterView performSelector:@selector(shouldReEnableLikeButton:) withObject:number afterDelay:0.5];
                
                [actualHeaderView shouldEnableLikeButton:YES];
                [actualHeaderView setLikeStatus:succeeded];
                
                if (!succeeded) {
                    [actualHeaderView.likeImage setTitle:originalButtonTitle forState:UIControlStateNormal];
                    
                    if ([originalButtonTitle isEqualToString:@"1"]) {
                        [photoFooterView.labelButton setTitle:NSLocalizedString(@"like", nil) forState:UIControlStateNormal];
                    }
                    else {
                        [photoFooterView.labelButton setTitle:NSLocalizedString(@"likes", nil) forState:UIControlStateNormal];
                        
                    }
                }
                
            }];
        }
        else {
            [ESUtility likePhotoInBackground:photo block:^(BOOL succeeded, NSError *error) {
                ESPhotoFooterView *actualHeaderView = (ESPhotoFooterView *)[self tableView:self.tableView viewForFooterInSection:button.tag];
                
                NSNumber *number = [NSNumber numberWithInt:1];
                [photoFooterView performSelector:@selector(shouldReEnableLikeButton:) withObject:number afterDelay:0.5];
                
                [actualHeaderView shouldEnableLikeButton:YES];
                [actualHeaderView setLikeStatus:succeeded];
                
                if (!succeeded) {
                    [actualHeaderView.likeImage setTitle:originalButtonTitle forState:UIControlStateNormal];
                    
                    if ([originalButtonTitle isEqualToString:@"1"]) {
                        [photoFooterView.labelButton setTitle:NSLocalizedString(@"like", nil) forState:UIControlStateNormal];
                    }
                    else {
                        [photoFooterView.labelButton setTitle:NSLocalizedString(@"likes", nil) forState:UIControlStateNormal];
                        
                    }
                }
                
            }];
        }
    } else {
        if ([photo objectForKey:kESVideoFileKey]) { //check if it is a video actually
            [ESUtility unlikeVideoInBackground:photo block:^(BOOL succeeded, NSError *error) {
                ESPhotoFooterView *actualHeaderView = (ESPhotoFooterView *)[self tableView:self.tableView viewForFooterInSection:button.tag];
                
                
                NSNumber *number = [NSNumber numberWithInt:1];
                [photoFooterView performSelector:@selector(shouldReEnableLikeButton:) withObject:number afterDelay:0.5];
                
                [actualHeaderView shouldEnableLikeButton:YES];
                [actualHeaderView setLikeStatus:!succeeded];
                
                if (!succeeded) {
                    [actualHeaderView.likeImage setTitle:originalButtonTitle forState:UIControlStateNormal];
                    if ([originalButtonTitle isEqualToString:@"1"]) {
                        [photoFooterView.labelButton setTitle:NSLocalizedString(@"like", nil) forState:UIControlStateNormal];
                    }
                    else {
                        [photoFooterView.labelButton setTitle:NSLocalizedString(@"likes", nil) forState:UIControlStateNormal];
                    }
                }
                
            }];
        } else if ([[photo objectForKey:@"type"] isEqualToString:@"text"]) { //check if it is a video actually
            [ESUtility unlikePostInBackground:photo block:^(BOOL succeeded, NSError *error) {
                ESPhotoFooterView *actualHeaderView = (ESPhotoFooterView *)[self tableView:self.tableView viewForFooterInSection:button.tag];
                
                
                NSNumber *number = [NSNumber numberWithInt:1];
                [photoFooterView performSelector:@selector(shouldReEnableLikeButton:) withObject:number afterDelay:0.5];
                
                [actualHeaderView shouldEnableLikeButton:YES];
                [actualHeaderView setLikeStatus:!succeeded];
                
                if (!succeeded) {
                    [actualHeaderView.likeImage setTitle:originalButtonTitle forState:UIControlStateNormal];
                    if ([originalButtonTitle isEqualToString:@"1"]) {
                        [photoFooterView.labelButton setTitle:NSLocalizedString(@"like", nil) forState:UIControlStateNormal];
                    }
                    else {
                        [photoFooterView.labelButton setTitle:NSLocalizedString(@"likes", nil) forState:UIControlStateNormal];
                    }
                }
                
            }];
        } else {
            [ESUtility unlikePhotoInBackground:photo block:^(BOOL succeeded, NSError *error) {
                ESPhotoFooterView *actualHeaderView = (ESPhotoFooterView *)[self tableView:self.tableView viewForFooterInSection:button.tag];
                
                
                NSNumber *number = [NSNumber numberWithInt:1];
                [photoFooterView performSelector:@selector(shouldReEnableLikeButton:) withObject:number afterDelay:0.5];
                
                [actualHeaderView shouldEnableLikeButton:YES];
                [actualHeaderView setLikeStatus:!succeeded];
                
                if (!succeeded) {
                    [actualHeaderView.likeImage setTitle:originalButtonTitle forState:UIControlStateNormal];
                    if ([originalButtonTitle isEqualToString:@"1"]) {
                        [photoFooterView.labelButton setTitle:NSLocalizedString(@"like", nil) forState:UIControlStateNormal];
                    }
                    else {
                        [photoFooterView.labelButton setTitle:NSLocalizedString(@"likes", nil) forState:UIControlStateNormal];
                    }
                }
                
            }];
        }
        
    }
}
- (void)photoHeaderView:(ESPhotoHeaderView *)photoHeaderView didTapReportPhoto:(UIButton *)button photo:(PFObject *)photo {
}

- (void)photoFooterView:(ESPhotoFooterView *)photoFooterView didTapCommentOnPhotoButton:(UIButton *)button  photo:(PFObject *)photo {
    UITableView *tableView = self.tableView; // Or however you get your table view
    NSArray *paths = [tableView indexPathsForVisibleRows];
    
    //  For getting the cells themselves
    
    for (NSIndexPath *path in paths) {
        if (path.section >= [self.objects count] || path.section < 0) {
            break;
        }
        PFObject *object = [self.objects objectAtIndex:path.section];
        if (![object isKindOfClass:[NSNull class] ]) {
            if ([object objectForKey:@"type"] && [object objectForKey:kESVideoFileKey]) {
                ESVideoTableViewCell *cell = (ESVideoTableViewCell *)[self.tableView cellForRowAtIndexPath:path];
                [cell.movie.player pause];
                cell.mediaItemButton.hidden = NO;
                cell.movie.view.hidden = YES;
                [cell.imageView setHidden:NO];
                
            }
        }
    }
    
    if ([photo objectForKey:kESVideoFileKey]) {
        ESVideoDetailViewController *videoDetailsVC = [[ESVideoDetailViewController alloc] initWithPhoto:photo];
        videoDetailsVC.hidesBottomBarWhenPushed = true;
        [self stopAllPlayers:YES];
        [self.navigationController pushViewController:videoDetailsVC animated:YES];
    }
    else {
        ESPhotoDetailsViewController *photoDetailsVC = [[ESPhotoDetailsViewController alloc] initWithPhoto:photo];
        photoDetailsVC.hidesBottomBarWhenPushed = true;
        [self stopAllPlayers:YES];
        [self.navigationController pushViewController:photoDetailsVC animated:YES];
    }
    
}
- (void)photoFooterView:(ESPhotoFooterView *)photoFooterView didTapSharePhotoButton:(UIButton *)button  photo:(PFObject *)photo {
    UITableView *tableView = self.tableView; // Or however you get your table view
    NSArray *paths = [tableView indexPathsForVisibleRows];
    
    //  For getting the cells themselves
    
    for (NSIndexPath *path in paths) {
        if (path.section >= [self.objects count] || path.section < 0) {
            break;
        }
        PFObject *object = [self.objects objectAtIndex:path.section];
        if ([object objectForKey:@"type"] && [object objectForKey:kESVideoFileKey]) {
            ESVideoTableViewCell *cell = (ESVideoTableViewCell *)[self.tableView cellForRowAtIndexPath:path];
            [cell.movie.player pause];
            cell.mediaItemButton.hidden = NO;
            cell.movie.view.hidden = YES;
            [cell.imageView setHidden:NO];
            
        }
    }
    if ([photo objectForKey:kESVideoFileKey]) {
        [[photo objectForKey:kESVideoFileThumbnailKey] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                NSMutableArray *activityItems = [NSMutableArray arrayWithCapacity:3];
                
                // Prefill caption if this is the original poster of the photo, and then only if they added a caption initially.
                if ([[[PFUser currentUser] objectId] isEqualToString:[[photo objectForKey:kESPhotoUserKey] objectId]] && [self.objects count] > 0) {
                    PFObject *firstActivity = self.objects[0];
                    if ([[[firstActivity objectForKey:kESActivityFromUserKey] objectId] isEqualToString:[[photo objectForKey:kESPhotoUserKey] objectId]]) {
                        NSString *commentString = [firstActivity objectForKey:kESActivityContentKey];
                        [activityItems addObject:commentString];
                    }
                }
                
                [activityItems addObject:[UIImage imageWithData:data]];
                [activityItems addObject:[NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id1076103571"]]];
                
                UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
                if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
                    activityViewController.popoverPresentationController.sourceView = self.navigationController.navigationBar;
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.navigationController presentViewController:activityViewController animated:YES completion:nil];
                });
                
            }
        }];
    } else if ([[photo objectForKey:@"type"] isEqualToString:@"text"]) {
        NSMutableArray *activityItems = [NSMutableArray arrayWithCapacity:3];
        
        // Prefill caption if this is the original poster of the photo, and then only if they added a caption initially.
        if ([[[PFUser currentUser] objectId] isEqualToString:[[photo objectForKey:kESPhotoUserKey] objectId]] && [self.objects count] > 0) {
            PFObject *firstActivity = self.objects[0];
            if ([[[firstActivity objectForKey:kESActivityFromUserKey] objectId] isEqualToString:[[photo objectForKey:kESPhotoUserKey] objectId]]) {
                NSString *commentString = [firstActivity objectForKey:kESActivityContentKey];
                [activityItems addObject:commentString];
            }
        }
        
        [activityItems addObject:[NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id1076103571"]]];
        
        UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
            activityViewController.popoverPresentationController.sourceView = self.navigationController.navigationBar;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController presentViewController:activityViewController animated:YES completion:nil];
        });
        

    }
    else {
        [[photo objectForKey:kESPhotoPictureKey] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                NSMutableArray *activityItems = [NSMutableArray arrayWithCapacity:3];
                
                // Prefill caption if this is the original poster of the photo, and then only if they added a caption initially.
                if ([[[PFUser currentUser] objectId] isEqualToString:[[photo objectForKey:kESPhotoUserKey] objectId]] && [self.objects count] > 0) {
                    PFObject *firstActivity = self.objects[0];
                    if ([[[firstActivity objectForKey:kESActivityFromUserKey] objectId] isEqualToString:[[photo objectForKey:kESPhotoUserKey] objectId]]) {
                        NSString *commentString = [firstActivity objectForKey:kESActivityContentKey];
                        [activityItems addObject:commentString];
                    }
                }
                
                [activityItems addObject:[UIImage imageWithData:data]];
                //[activityItems addObject:[NSURL URLWithString:[NSString stringWithFormat:@"https://Netzwierk.org/#pic/%@", self.photo.objectId]]];
                [activityItems addObject:[NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id1076103571"]]];
                
                UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
                if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
                    activityViewController.popoverPresentationController.sourceView = self.navigationController.navigationBar;
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.navigationController presentViewController:activityViewController animated:YES completion:nil];
                });
            }
        }];
    }
    
}


#pragma mark - ()

- (NSIndexPath *)indexPathForObject:(PFObject *)targetObject {
    for (int i = 0; i < self.objects.count; i++) {
        PFObject *object = [self.objects objectAtIndex:i];
        if ([[object objectId] isEqualToString:[targetObject objectId]]) {
            return [NSIndexPath indexPathForRow:0 inSection:i];
        }
    }
    
    return nil;
}

- (void)userDidLikeOrUnlikePhoto:(NSNotification *)note {
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

- (void)userDidCommentOnPhoto:(NSNotification *)note {
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

- (void)userDidDeletePhoto:(NSNotification *)note {
    // refresh timeline after a delay
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC);
    dispatch_after(time, dispatch_get_main_queue(), ^(void){
        [self loadObjects];
    });
}

- (void)userDidPublishPhoto:(NSNotification *)note {
    if (self.objects.count > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    
    [self loadObjects];
}

- (void)userFollowingChanged:(NSNotification *)note {
    self.shouldReloadOnAppear = YES;
}


- (void)didTapOnPhotoAction:(UIButton *)sender {
    PFObject *photo = [self.objects objectAtIndex:sender.tag];
    
    NSLog(@"%@",photo.objectId);
    
    if (photo) {
        ESPhotoDetailsViewController *photoDetailsVC = [[ESPhotoDetailsViewController alloc] initWithPhoto:photo];
        photoDetailsVC.hidesBottomBarWhenPushed = true;
        [self stopAllPlayers:YES];
        [self.navigationController pushViewController:photoDetailsVC animated:YES];
        
        
    }
}
- (void)didTapOnTextPostAction:(UIButton *)sender {
    PFObject *text = [self.objects objectAtIndex:sender.tag];
    if (text) {
        ESPhotoDetailsViewController *photoDetailsVC = [[ESPhotoDetailsViewController alloc] initWithPhoto:text];
        photoDetailsVC.hidesBottomBarWhenPushed = true;
        [self stopAllPlayers:YES];
        [self.navigationController pushViewController:photoDetailsVC animated:YES];
    }
}
- (void)postNotificationWithString:(NSString *)notification {
    NSString *notificationName = @"ESNotification";
    NSString *key = @"CommunicationStringValue";
    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:notification forKey:key];
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil userInfo:dictionary];
}
@end
