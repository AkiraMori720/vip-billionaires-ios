//
//  ESAccountViewController.m
//  D'Netzwierk
//
//  Created by Eric Schanet on 6/05/2014.
//  Copyright (c) 2014 Eric Schanet. All rights reserved.
//
//#define HeaderHeight 250.0f
#define IS_IPHONE5 (([[UIScreen mainScreen] bounds].size.height-568)?NO:YES)

#import "ESAccountViewController.h"
#import "ESPhotoCell.h"
#import "TTTTimeIntervalFormatter.h"
#import "ESLoadMoreCell.h"
#import "UIImage+ImageEffects.h"
#import "UIImage+ResizeAdditions.h"
#import "ESEditPhotoViewController.h"
#import "SCLAlertView.h"
#import "ESEditProfileViewController.h"

#import "MMDrawerBarButtonItem.h"
#import "MFSideMenu.h"
#import "AppDelegate.h"
#import "KILabel.h"
#import "ESFollowersViewController.h"
#import "ESMessengerView.h"

CGFloat const offset_HeaderStop = 40.0;
CGFloat const offset_B_LabelHeader = 0.0;
CGFloat const distance_W_LabelHeader = 35.0;
@interface ESAccountViewController()
//@property NSTimer* timer;
@property UIBackgroundTaskIdentifier fileUploadBackgroundTaskId ;
@end
@implementation ESAccountViewController
@synthesize headerView, user, profilePictureImageView, backgroundImageView, reportUser, userDisplayNameLabel, infoLabel, userMentionLabel, profilePictureBackgroundView, siteLabel, whiteBackground, grayLine, texturedBackgroundView, photoCountLabel, followerCountLabel, followingCountLabel, editProfileBtn, cityLabel, segmentedControl, followerBtn, followingBtn, photosBtn, messageBtn,app,blockUserArray,jobLabel,headerHeight;

#pragma mark - UIViewController
-(void)tapBtn {
    [self.menuContainerViewController setMenuState:MFSideMenuStateLeftMenuOpen completion:^{}];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ESTabBarControllerDidFinishEditingPhotoNotification object:nil];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setupHeader];
    
    //[self performSelector:@selector(getBlockStatusOfUser) withObject:nil afterDelay:0.0];
    [self getBlockStatusOfUser];
    self.tableView.tag = 2;
    self.navigationController.navigationBarHidden = NO;
    [self updateBarButtonItems:1];
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    delegate.container.panMode = MFSideMenuPanModeDefault;
   /* if ([self.user objectForKey:@"profileColor"]) {
        NSArray *components = [[self.user objectForKey:@"profileColor"] componentsSeparatedByString:@","];
        CGFloat r = [[components objectAtIndex:0] floatValue];
        CGFloat g = [[components objectAtIndex:1] floatValue];
        CGFloat b = [[components objectAtIndex:2] floatValue];
        CGFloat a = [[components objectAtIndex:3] floatValue];
        UIColor *color = [UIColor colorWithRed:r green:g blue:b alpha:a];
        self.navigationController.navigationBar.barTintColor = color;
    }
    else {*/
        self.navigationController.navigationBar.barTintColor = def_TopBar_Color;
    //}
    
    //Calculate Luminance
    CGFloat luminance;
    CGFloat red = 0.0, green = 0.0, blue = 0.0;
    
//    //Check for clear or uncalculatable color and assume white
//    if (![self.navigationController.navigationBar.barTintColor getRed:&red green:&green blue:&blue alpha:nil]) {
//        self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LogoNavigationBar"]];
//    }
    self.navigationItem.title = NSLocalizedString(@"VIP Billionaires", nil);
    
    //Relative luminance in colorimetric spaces - http://en.wikipedia.org/wiki/Luminance_(relative)
    red *= 0.2126f; green *= 0.7152f; blue *= 0.0722f;
    luminance = red + green + blue;
    
//    if (luminance > 0.5f) {
//   //     self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LogoNavigationBarDark"]];
//    }
//    else     self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LogoNavigationBar"]];
    self.navigationItem.backBarButtonItem.tintColor = def_Golden_Color;

}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [self.tabBarController.view bringSubviewToFront:delegate.vipButton];
}

- (void)viewDidAppear:(BOOL)animated {
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if ([[self.user objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
        [self.tabBarController.view bringSubviewToFront:delegate.vipButton];
        delegate.vipButton.hidden = NO;
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController.navigationBar setBackgroundImage:nil
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = nil;
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];//[UIColor colorWithHue:204.0f/360.0f saturation:76.0f/100.0f brightness:86.0f/100.0f alpha:1];
//    [self.timer invalidate];
    
    if ([[self.user objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [self.tabBarController.view bringSubviewToFront:delegate.vipButton];
        delegate.vipButton.hidden = YES;
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];

    self.headerHeight = 200;
    
    self.navigationController.navigationBar.translucent = YES;
    self.tableView.contentInset = UIEdgeInsetsZero;
    self.tableView.scrollsToTop = NO;
    self.tableView.bounces = NO;
    
    self.blockUserArray = [[NSMutableArray alloc] init];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"", nil) style:UIBarButtonItemStylePlain target:nil action:nil];
    
    if (!self.user) {
        [NSException raise:NSInvalidArgumentException format:@"user cannot be nil"];
    }
    MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(tapBtn)];
    if (self.tabBarController.selectedIndex == 1 && [[PFUser currentUser].objectId isEqualToString:self.user.objectId])
    {
        [self.navigationItem setLeftBarButtonItem:leftDrawerButton animated:YES];
    }
    
    self.navigationItem.leftBarButtonItem.tintColor = def_Golden_Color;
    // set title
    self.navigationItem.title = NSLocalizedString(@"VIP Billionaires", nil);
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:def_Golden_Color,NSFontAttributeName:[UIFont fontWithName:@"Montserrat-Regular" size:21]}];
    
    int i = 390;
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake( 0.0f, 0.0f, self.tableView.bounds.size.width, i)];
    [self.headerView setBackgroundColor:[UIColor clearColor]]; // should be clear, this will be the container for our avatar, photo count, follower count, following count, and so on
    
    
}
-(void)getBlockStatusOfUser
{
    PFQuery *blockQuery = [[PFQuery queryWithClassName:@"block_table"] whereKey:@"block_userId" equalTo:[PFUser currentUser].objectId];
    
    [blockQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error == NO) {
            for (PFObject *obj in objects) {
                [self.blockUserArray addObject:obj[@"UserID"]];
            }
        }
    }];
  /*  NSArray *blockUsersArray = [blockQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        
        for (PFObject *object in blockUsersArray) {
            [self.blockUserArray addObject:object[@"UserID"]];
            NSLog(@"%@",self.blockUserArray);
            
        }
    }];*/
    
}
- (void)updateBarButtonItems:(CGFloat)alpha
{
    [self.navigationItem.leftBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem* item, NSUInteger i, BOOL *stop) {
        item.customView.alpha = alpha;
    }];
    [self.navigationItem.rightBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem* item, NSUInteger i, BOOL *stop) {
        item.customView.alpha = alpha;
    }];
    self.navigationItem.titleView.alpha = alpha;
    self.navigationController.navigationBar.tintColor = [self.navigationController.navigationBar.tintColor colorWithAlphaComponent:alpha];
}
- (void) disableScrollsToTopPropertyOnAllSubviewsOf:(UIView *)view {
    for (UIView *subview in view.subviews) {
        if ([subview isKindOfClass:[UIScrollView class]]) {
            ((UIScrollView *)subview).scrollsToTop = NO;
        }
        [self disableScrollsToTopPropertyOnAllSubviewsOf:subview];
    }
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"", nil) style:UIBarButtonItemStylePlain target:nil action:nil];
    
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    /*CGFloat yPos = -scrollView.contentOffset.y;
    if (yPos > 0) {
        CGRect imgRect = self.imageView.frame;
        imgRect.origin.y = scrollView.contentOffset.y;
        
        imgRect.size.height = HeaderHeight+yPos;
        self.imageView.frame = imgRect;
    }*/
}

- (void)attemptOpenURL:(NSURL *)url
{
//    DZNWebViewController *webViewController = [[DZNWebViewController alloc] initWithURL:url];
//    webViewController.hideBarsWithGestures = YES;
//    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:webViewController];
//    [self presentViewController:navVC animated:YES completion:NULL];
    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];

}

# pragma mark - Header setup

- (void) setupHeader
{
    
    /*if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        switch ((int)[[UIScreen mainScreen] nativeBounds].size.height) {
            case 2436:
                printf("iPhone X");
                self.headerHeight = 230;
                break;
            default:
                printf("unknown");
                self.headerHeight = 250;

                
        }
    }*/
    

    self.imageView = [[PFImageView alloc] initWithImage:[UIImage imageNamed:@""]];
    [self.imageView setFile:[self.user objectForKey:kESUserHeaderPicMediumKey]];
    
    [self.imageView loadInBackground:^(UIImage *image, NSError *error)
    {
        if (!image)
        {
            [self.imageView setImage:[UIImage imageNamed:@"bg_logo.jpg"]];
        }
    }];
    
    self.imageView.frame = CGRectMake(0, 0, self.view.frame.size.width, headerHeight);
    UIGestureRecognizer* gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeProfilePicture)];
    self.imageView.userInteractionEnabled = YES;
    [self.imageView addGestureRecognizer:gesture];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = YES;
    self.imageView.backgroundColor = [UIColor clearColor];
    [self.headerView addSubview:self.imageView];
    
    //CGRect rect = [self frameForImage:[UIImage imageNamed:@"bg_logo.jpg"] inImageViewAspectFit:self.imageView];
    
   // [self.imageView setFrame:rect];
   // self.headerHeight = rect.size.height;
    
    //self.imageView.frame = CGRectMake(0, 0, self.view.frame.size.width, headerHeight);


    int i = 0;
    
    if (![self.user objectForKey:@"UserInfo"] || [[self.user objectForKey:@"UserInfo"] isEqualToString:@""])
    {
        i = 190;
    }
    else i = 240;
    
    int i3 = 0;
    
    if (![self.user objectForKey:@"UserInfo"] || [[self.user objectForKey:@"UserInfo"] isEqualToString:@""])
    {
        i3 = 420;
    }
    else i3 = 470;
    
    UIView* grayBackgroundView = [[UIView alloc] init];
    grayBackgroundView.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1];
    
    [UIView animateWithDuration:100
                          delay:0
                        options:UIViewAnimationOptionAllowAnimatedContent
                     animations:^{
//                         self.headerView.frame = CGRectMake(0, 0, self.tableView.bounds.size.width, i3 );
                         whiteBackground.frame = CGRectMake(0, headerHeight, [UIScreen mainScreen].bounds.size.width, i);
                     } completion:^(BOOL finished){NSLog(@"animation finished");}
     ];

    whiteBackground = [[UIView alloc]initWithFrame:CGRectMake(0, headerHeight, [UIScreen mainScreen].bounds.size.width, i)];
    [whiteBackground setBackgroundColor:[UIColor clearColor]];
    [self.headerView addSubview:grayBackgroundView];
    [self.headerView addSubview:whiteBackground];
    grayBackgroundView.frame = CGRectMake(0, self.headerView.frame.size.height - 70, self.headerView.frame.size.width, 60);
    grayLine = [[UILabel alloc]initWithFrame:CGRectMake(0, self.headerView.frame.size.height -10, [UIScreen mainScreen].bounds.size.width, 0.5)];
    [grayLine setBackgroundColor:def_Golden_Color];
    [self.headerView addSubview:grayLine];
    
    profilePictureBackgroundView = [[UIButton alloc] initWithFrame:CGRectMake(16, 206, 0,0)];
    [profilePictureBackgroundView setBackgroundColor:def_Golden_Color];
    profilePictureBackgroundView.alpha = 0.0f;
    CALayer *layer = [profilePictureBackgroundView layer];
    layer.cornerRadius = 54;
    layer.masksToBounds = YES;
    [self.headerView addSubview:profilePictureBackgroundView];

    profilePictureImageView = [[PFImageView alloc] initWithFrame:CGRectMake(20, 210.0f, 100.0f, 100.0f)];
    [self.headerView addSubview:profilePictureImageView];
    [profilePictureImageView setContentMode:UIViewContentModeScaleAspectFill];
    layer = [profilePictureImageView layer];
    layer.cornerRadius = 50.0f;
    layer.masksToBounds = YES;
    profilePictureImageView.alpha = 1.0f;

    UIImageView *profilePictureStrokeImageView = [[UIImageView alloc] initWithFrame:CGRectMake( 88.0f, 124.0f, 143.0f, 143.0f)];
    profilePictureStrokeImageView.alpha = 1.0f;
    [self.headerView addSubview:profilePictureStrokeImageView];
    
    if ([[self.user objectForKey:@"Gender"] isEqualToString:@"female"] || [[self.user objectForKey:@"Gender"] isEqualToString:@"weiblech"])
    {
        [profilePictureImageView setImage:[UIImage imageNamed:@"AvatarPlaceholderProfileFemale"]];
    }
    
    else [profilePictureImageView setImage:[UIImage imageNamed:@"AvatarPlaceholderProfile"]];
    
    PFFile *imageFile = [self.user objectForKey:kESUserProfilePicMediumKey];
    
    if (imageFile)
    {
        [profilePictureImageView setFile:imageFile];
        [profilePictureImageView loadInBackground:^(UIImage *image, NSError *error)
        {
            if (!error)
            {
                [UIView animateWithDuration:0.2f animations:^{
                    profilePictureBackgroundView.alpha = 1.0f;
                    profilePictureStrokeImageView.alpha = 1.0f;
                    profilePictureImageView.alpha = 1.0f;
                }];
                
                UIImage * imgBG = [UIImage imageNamed:@"bg_logo.jpg"];
                backgroundImageView = [[UIImageView alloc] initWithImage:[imgBG applyDarkEffect]];
                backgroundImageView.frame = self.tableView.backgroundView.bounds;
                backgroundImageView.alpha = 0.0f;
                backgroundImageView.contentMode = UIViewContentModeScaleAspectFit;
                
                if (imgBG)
                {
//                    [self.tableView.backgroundView addSubview:backgroundImageView];
                }
                
                [UIView animateWithDuration:0.2f animations:^{
                    backgroundImageView.alpha = 1.0f;
                }];
            }
        }];
    }
    
    userDisplayNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(150, 230, self.headerView.bounds.size.width, 22.0f)];
    [userDisplayNameLabel setTextAlignment:NSTextAlignmentLeft];
    [userDisplayNameLabel setBackgroundColor:[UIColor clearColor]];
    [userDisplayNameLabel setTextColor:[UIColor colorWithWhite:0 alpha:1]];
    
    if ([self.user objectForKey:kESUserDisplayNameKey])
    {
        [userDisplayNameLabel setText:[self.user objectForKey:kESUserDisplayNameKey]];
    }
    else
    {
        [userDisplayNameLabel setText:[self.user objectForKey:@"username"]];
    }
    
    [userDisplayNameLabel setFont:[UIFont fontWithName:@"Montserrat-Regular" size:18.0f]];
    [self.headerView addSubview:userDisplayNameLabel];

//    userMentionLabel = [[UILabel alloc] initWithFrame:CGRectMake( 150, 225, [UIScreen mainScreen].bounds.size.width - 15, 40)];
//    [userMentionLabel setTextAlignment:NSTextAlignmentLeft];
//    [userMentionLabel setBackgroundColor:[UIColor clearColor]];
//    [userMentionLabel setTextColor: [UIColor colorWithWhite:0 alpha:0.4]];
//    [userMentionLabel setText:[NSString stringWithFormat:@"@%@",[self.user objectForKey:@"usernameFix"]]];
//    [userMentionLabel setFont:[UIFont fontWithName:@"Montserrat-Light" size:15.0f]];
//    [self.headerView addSubview:userMentionLabel];
    
    infoLabel = [[UILabel alloc] initWithFrame:CGRectMake( 15, 320, [UIScreen mainScreen].bounds.size.width - 25, 80)];
    
    if (IS_IPHONE5)
    {
        infoLabel.frame = CGRectMake(15, 320, [UIScreen mainScreen].bounds.size.width - 25, 100);
    }
    
    [infoLabel setTextAlignment:NSTextAlignmentLeft];
    infoLabel.alpha = 1.0f;
    [infoLabel setBackgroundColor:[UIColor clearColor]];
    [infoLabel setTextColor: [UIColor blackColor]];
    [infoLabel setFont:[UIFont fontWithName:@"Montserrat-Regular" size:14.0f]];
    infoLabel.numberOfLines = 4;
    infoLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    
    if (![self.user objectForKey:@"UserInfo"])
    {
        infoLabel.text = NSLocalizedString(@"", nil);
    }
    else
    {
        infoLabel.text = [NSString stringWithFormat:@"%@", [self.user objectForKey:@"UserInfo"]];
    }
    
    CGSize maximumLabelSize = CGSizeMake(296, FLT_MAX);
    CGSize expectedLabelSize = [infoLabel.text sizeWithFont:infoLabel.font constrainedToSize:maximumLabelSize lineBreakMode:infoLabel.lineBreakMode];
    //adjust the label the the new height.
    CGRect newFrame = infoLabel.frame;
    newFrame.size.height = expectedLabelSize.height;
    if ([infoLabel.text length] == 0) newFrame.size.height = 0;
    infoLabel.frame = newFrame;
    [self.headerView addSubview:infoLabel];
    
    int i2 = 0;
    
    if (![self.user objectForKey:@"UserInfo"] || [[self.user objectForKey:@"UserInfo"] isEqualToString:@""])
    {
        i2 =  infoLabel.frame.origin.y + 5;
    }
    else i2 =  infoLabel.frame.origin.y + infoLabel.frame.size.height + 5;
    
    cityLabel = [[UILabel alloc] initWithFrame:CGRectMake( 15,i2, [UIScreen mainScreen].bounds.size.width - 300, 20)];
    [cityLabel setTextAlignment:NSTextAlignmentLeft];
    [cityLabel setBackgroundColor:[UIColor clearColor]];
   // [cityLabel setTextColor:[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1]];
    [cityLabel setTextColor: [UIColor blackColor]];

    [cityLabel setText:[self.user objectForKey:@"Location"]];
    [cityLabel setFont:[UIFont fontWithName:@"Montserrat-Regular" size:14.0f]];
    CGSize _maximumLabelSize = CGSizeMake(296, FLT_MAX);
    CGSize _expectedLabelSize = [cityLabel.text sizeWithFont:cityLabel.font constrainedToSize:_maximumLabelSize lineBreakMode:cityLabel.lineBreakMode];
    CGRect _newFrame = cityLabel.frame;
    _newFrame.size.width = _expectedLabelSize.width;
    if (cityLabel.text.length == 0) _newFrame.size.height = 0;
    cityLabel.frame = _newFrame;
    [self.headerView addSubview:cityLabel];
    
    
    siteLabel = [[KILabel alloc]initWithFrame:CGRectMake(cityLabel.frame.size.width + cityLabel.frame.origin.x + 15, i2, [UIScreen mainScreen].bounds.size.width - (cityLabel.frame.size.width + cityLabel.frame.origin.x + 15), 20)];
    
    if ([self.user objectForKey:@"Website"])
    {
        siteLabel.text = [self.user objectForKey:@"Website"];
    }
    
    [siteLabel setTextAlignment:NSTextAlignmentLeft];
    siteLabel.alpha = 1.0f;
    siteLabel.textColor = def_Golden_Color;
    [siteLabel setBackgroundColor:[UIColor clearColor]];
    [self.headerView addSubview:siteLabel];
    
    jobLabel = [[UILabel alloc] initWithFrame:CGRectMake( 15,i2+cityLabel.frame.size.height+10, [UIScreen mainScreen].bounds.size.width - 300, 20)];
    [jobLabel setTextAlignment:NSTextAlignmentLeft];
    [jobLabel setBackgroundColor:[UIColor clearColor]];
    // [cityLabel setTextColor:[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1]];
    [jobLabel setTextColor: [UIColor blackColor]];
    
    [jobLabel setText:[self.user objectForKey:@"job"]];
    [jobLabel setFont:[UIFont fontWithName:@"Montserrat-Regular" size:14.0f]];
    CGSize _maximumLabelSize1 = CGSizeMake(self.view.frame.size.width - 50, FLT_MAX);
    CGSize _expectedLabelSize1 = [jobLabel.text sizeWithFont:jobLabel.font constrainedToSize:_maximumLabelSize lineBreakMode:jobLabel.lineBreakMode];
    CGRect _newFrame1= jobLabel.frame;
    _newFrame1.size.width = _expectedLabelSize1.width;
    if ([jobLabel.text length] == 0) _newFrame1.size.height = 0;
    jobLabel.frame = _newFrame1;
    [self.headerView addSubview:jobLabel];
    
    CGRect headerViewRect = self.headerView.frame;
    headerViewRect.size.height = jobLabel.frame.origin.y + jobLabel.frame.size.height + 80;
    if (self.headerView.frame.size.height != headerViewRect.size.height) {
        self.headerView.frame = headerViewRect;
        NSArray *viewsToRemove = [self.headerView subviews];
        for (UIView *v in viewsToRemove) {
            [v removeFromSuperview];
        }
        [self setupHeader];
        return;
    }

    //Now we're preparing for the segmented control, to display photos, followers and following ...
    __block int photos;
    __block int follower;
    __block int following;
    
    PFQuery *queryPhotoCount = [PFQuery queryWithClassName:kESPhotoClassKey];
    [queryPhotoCount whereKey:kESPhotoUserKey equalTo:self.user];
    [queryPhotoCount setCachePolicy:kPFCachePolicyCacheThenNetwork];
    
    [queryPhotoCount countObjectsInBackgroundWithBlock:^(int number, NSError *error)
    {
        if (!error)
        {
            [[ESCache sharedCache] setPhotoCount:[NSNumber numberWithInt:number] user:self.user];
//            [photosBtn setTitle:[NSString stringWithFormat:@"%d\n%@%@", number,NSLocalizedString(@"post", nil), number==1?@"":NSLocalizedString(@"s", nil)] forState:UIControlStateNormal];
            NSString* countText = [NSString stringWithFormat:@"%d\n%@%@", number,NSLocalizedString(@"post", nil), number==1?@"":NSLocalizedString(@"s", nil)];
            NSString* numberText = [NSString stringWithFormat:@"%d", number];
            NSDictionary *attrs = @{
                NSFontAttributeName: [UIFont fontWithName:@"Montserrat-Bold" size: 17]
            };
            
            NSDictionary *subAttrs = @{
                NSFontAttributeName: [UIFont fontWithName:@"Montserrat-Regular" size:16]
            };
            
            const NSRange range = NSMakeRange( numberText.length, countText.length -  numberText.length);
            NSMutableAttributedString* text = [[NSMutableAttributedString alloc] initWithString: countText attributes:attrs];
            [text setAttributes:subAttrs range:range];
            [photosBtn setAttributedTitle: text forState:UIControlStateNormal];
            [photoCountLabel setAttributedText: text];
            photos = number;
        }
    }];
    
    PFQuery *queryFollowerCount = [PFQuery queryWithClassName:kESActivityClassKey];
    [queryFollowerCount whereKey:kESActivityTypeKey equalTo:kESActivityTypeFollow];
    [queryFollowerCount whereKey:kESActivityToUserKey equalTo:self.user];
    [queryFollowerCount setCachePolicy:kPFCachePolicyCacheThenNetwork];
    
    [queryFollowerCount countObjectsInBackgroundWithBlock:^(int number, NSError *error)
    {
        if (!error)
        {
            //Shweta
            //[followerBtn setTitle:[NSString stringWithFormat:@"%d %@%@", number,NSLocalizedString(@"follower", <#comment#>), number==1?@"":NSLocalizedString(@"s", nil)] forState:UIControlStateNormal];
            
            NSString* countText = [NSString stringWithFormat:@"%d\n%@%@", number,NSLocalizedString(@"follower", nil), number==1?@"":NSLocalizedString(@"s", nil)];
            NSString* numberText = [NSString stringWithFormat:@"%d", number];
            NSDictionary *attrs = @{
                NSFontAttributeName: [UIFont fontWithName:@"Montserrat-Bold" size: 17]
            };
            
            NSDictionary *subAttrs = @{
                NSFontAttributeName: [UIFont fontWithName:@"Montserrat-Regular" size:16]
            };
            
            const NSRange range = NSMakeRange( numberText.length, countText.length -  numberText.length);
            NSMutableAttributedString* text = [[NSMutableAttributedString alloc] initWithString: countText attributes:attrs];
            [text setAttributes:subAttrs range:range];
            [followerBtn setAttributedTitle: text forState:UIControlStateNormal];
            [followerCountLabel setAttributedText: text];
             follower = number;
        }
    }];
    
    PFQuery *queryFollowingCount = [PFQuery queryWithClassName:kESActivityClassKey];
    [queryFollowingCount whereKey:kESActivityTypeKey equalTo:kESActivityTypeFollow];
    [queryFollowingCount whereKey:kESActivityFromUserKey equalTo:self.user];
    [queryFollowingCount setCachePolicy:kPFCachePolicyCacheThenNetwork];
    
    [queryFollowingCount countObjectsInBackgroundWithBlock:^(int number, NSError *error)
    {
        if (!error)
        {
            NSString* countText = [NSString stringWithFormat:@"%d\n%@%@", number,NSLocalizedString(@"following", nil), number==1?@"":NSLocalizedString(@"s", nil)];
            NSString* numberText = [NSString stringWithFormat:@"%d", number];
            NSDictionary *attrs = @{
                NSFontAttributeName: [UIFont fontWithName:@"Montserrat-Bold" size: 17]
            };
            
            NSDictionary *subAttrs = @{
                NSFontAttributeName: [UIFont fontWithName:@"Montserrat-Regular" size:16]
            };
            
            const NSRange range = NSMakeRange( numberText.length, countText.length -  numberText.length);
            NSMutableAttributedString* text = [[NSMutableAttributedString alloc] initWithString: countText attributes:attrs];
            [text setAttributes:subAttrs range:range];
            [followingBtn setAttributedTitle: text forState:UIControlStateNormal];
            [followingCountLabel setAttributedText: text];
            following = number;
        }
    }];
    
    editProfileBtn = [[UIButton alloc]initWithFrame:CGRectMake(150, 270, 100, 30)];
    
    [self.headerView addSubview:editProfileBtn];

//    if (![[self.user objectId] isEqualToString:[[PFUser currentUser] objectId]])
//    {
//        float width = 75.0;
//        float padding = ([UIScreen mainScreen].bounds.size.width-(width*4))/5;
//        float xPoint = padding;
//        
//        photosBtn = [[UIButton alloc]initWithFrame:CGRectMake(xPoint, self.headerView.frame.size.height   - 50, width, 25)];
//        xPoint = xPoint + width + padding;
//        
//        followerBtn = [[UIButton alloc]initWithFrame:CGRectMake(xPoint, self.headerView.frame.size.height   - 50, width, 25)];
//        xPoint = xPoint + width + padding;
//        
//        followingBtn = [[UIButton alloc]initWithFrame:CGRectMake(xPoint, self.headerView.frame.size.height   - 50, width, 25)];
//        xPoint = xPoint + width + padding;
//        
//        messageBtn = [[UIButton alloc]initWithFrame:CGRectMake(xPoint, self.headerView.frame.size.height   - 50, width, 25)];
//        
//        [followerBtn setTitle:[NSString stringWithFormat:@"%d %@",0, NSLocalizedString(@"following", nil)] forState:UIControlStateNormal];
//        [photosBtn setTitle:[NSString stringWithFormat:@"%d %@",0, NSLocalizedString(@"photos", nil)] forState:UIControlStateNormal];
//        [followingBtn setTitle:[NSString stringWithFormat:@"%d %@",0, NSLocalizedString(@"followers", nil)] forState:UIControlStateNormal];
//        [messageBtn setTitle:[NSString stringWithFormat:@"%@", NSLocalizedString(@"message", nil)] forState:UIControlStateNormal];
//        
//        [followerBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        [photosBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        [followingBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        [messageBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        
//        followingBtn.titleLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:12];
//        followerBtn.titleLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:12];
//        photosBtn.titleLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:12];
//        messageBtn.titleLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:12];
//        
//        [followingBtn addTarget:self action:@selector(showFollowings) forControlEvents:UIControlEventTouchDown];
//        [followerBtn addTarget:self action:@selector(showFollowers) forControlEvents:UIControlEventTouchDown];
//        [messageBtn addTarget:self action:@selector(showMessageView) forControlEvents:UIControlEventTouchDown];
//        
//        photosBtn.layer.cornerRadius = 3;
//        followerBtn.layer.cornerRadius = 3;
//        followingBtn.layer.cornerRadius = 3;
//        messageBtn.layer.cornerRadius = 3;
//        
//        photosBtn.backgroundColor = def_Golden_Color;//[UIColor colorWithWhite:0.94 alpha:1];
//        followerBtn.backgroundColor = def_Golden_Color;//[UIColor colorWithWhite:0.94 alpha:1];
//        followingBtn.backgroundColor = def_Golden_Color;//[UIColor colorWithWhite:0.94 alpha:1];
//        messageBtn.backgroundColor = def_Golden_Color;
//        
//        [self.headerView addSubview:followingBtn];
//        [self.headerView addSubview:followerBtn];
//        [self.headerView addSubview:photosBtn];
//        [self.headerView addSubview:messageBtn];
//
//    }
//    else
//    {
    photosBtn = [[UIButton alloc]initWithFrame:CGRectMake(55, self.headerView.frame.size.height - 60, 100, 40)];
    followerBtn = [[UIButton alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - 50, self.headerView.frame.size.height   - 60, 100, 40)];
    followingBtn = [[UIButton alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 155, self.headerView.frame.size.height   - 60, 100, 40)];
    
    photosBtn.center = CGPointMake(40, photosBtn.center.y);
    followerBtn.center = CGPointMake([UIScreen mainScreen].bounds.size.width / 2 - 10, photosBtn.center.y);
    followingBtn.center = CGPointMake([UIScreen mainScreen].bounds.size.width / 6 * 5, photosBtn.center.y);
    
    photosBtn.titleLabel.numberOfLines = 2;
    followingBtn.titleLabel.numberOfLines = 2;
    followerBtn.titleLabel.numberOfLines = 2;
    
    photosBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    followingBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    followerBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    [followerBtn setTitle:[NSString stringWithFormat:@"%d %@",0, NSLocalizedString(@"followers", nil)] forState:UIControlStateNormal];
    [photosBtn setTitle:[NSString stringWithFormat:@"%d %@",0, NSLocalizedString(@"photos", nil)] forState:UIControlStateNormal];
    [followingBtn setTitle:[NSString stringWithFormat:@"%d %@",0, NSLocalizedString(@"following", nil)] forState:UIControlStateNormal];
    
    [followerBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [photosBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [followingBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    followingBtn.titleLabel.font = [UIFont fontWithName:@"Montserrat-Bold" size:14];
    followerBtn.titleLabel.font = [UIFont fontWithName:@"Montserrat-Bold" size:14];
    photosBtn.titleLabel.font = [UIFont fontWithName:@"Montserrat-Bold" size:14];
    
    [followingBtn addTarget:self action:@selector(showFollowings) forControlEvents:UIControlEventTouchDown];
    [followerBtn addTarget:self action:@selector(showFollowers) forControlEvents:UIControlEventTouchDown];
    
    photosBtn.layer.cornerRadius = 3;
    followerBtn.layer.cornerRadius = 3;
    followingBtn.layer.cornerRadius = 3;
    
    photosBtn.backgroundColor = [UIColor clearColor]; //def_Golden_Color;//[UIColor colorWithWhite:0.94 alpha:1];
    followerBtn.backgroundColor = [UIColor clearColor]; //def_Golden_Color;//[UIColor colorWithWhite:0.94 alpha:1];
    
    followingBtn.backgroundColor = [UIColor clearColor]; //def_Golden_Color;//[UIColor colorWithWhite:0.94 alpha:1];
    
    [self.headerView addSubview:followingBtn];
    [self.headerView addSubview:followerBtn];
    [self.headerView addSubview:photosBtn];
  //  }
    
    if (![[self.user objectId] isEqualToString:[[PFUser currentUser] objectId]])
    {
        UIActivityIndicatorView *loadingActivityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [loadingActivityIndicatorView startAnimating];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:loadingActivityIndicatorView];
        
        // check if the currentUser is following this user
        PFQuery *queryIsFollowing = [PFQuery queryWithClassName:kESActivityClassKey];
        [queryIsFollowing whereKey:kESActivityTypeKey equalTo:kESActivityTypeFollow];
        [queryIsFollowing whereKey:kESActivityToUserKey equalTo:self.user];
        [queryIsFollowing whereKey:kESActivityFromUserKey equalTo:[PFUser currentUser]];
        [queryIsFollowing setCachePolicy:kPFCachePolicyCacheThenNetwork];
        
        [queryIsFollowing countObjectsInBackgroundWithBlock:^(int number, NSError *error)
        {
            if (error && [error code] != kPFErrorCacheMiss)
            {
                self.navigationItem.rightBarButtonItem = nil;
            }
            else
            {
                if (number == 0)
                {
                    [self configureFollowButton];
                }
                else
                {
                    [self configureUnfollowButton];
                }
            }
        }];
    }
    else
    {
        [self configureSettingsButton];
    }
    
    self.refreshControl.layer.zPosition = self.tableView.backgroundView.layer.zPosition + 1;

    if (![[self.user objectId] isEqualToString:[[PFUser currentUser] objectId]])
    {
        reportUser = [[UIButton alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 40 , 210, 20, 20)];
        [reportUser setImage:[UIImage imageNamed:@"settings_icon"] forState:UIControlStateNormal];
        [reportUser setImage:[UIImage imageNamed:@"settings_icon"] forState:UIControlStateHighlighted];
        [reportUser addTarget:self action:@selector(ReportTap) forControlEvents:UIControlEventTouchUpInside];
        [self.headerView addSubview:reportUser];
    }

    __unsafe_unretained typeof(self) weakSelf = self;
    
    self.siteLabel.linkTapHandler = ^(KILinkType linkType, NSString *string, NSRange range)
    {
        if (linkType == KILinkTypeURL)
        {
            // Open URLs
            [weakSelf attemptOpenURL:[NSURL URLWithString:string]];
            NSLog(@"URL:%@",string);
        }
        else if (linkType == KILinkTypeHashtag)
        {
            //What do you want to happen?
            
        }
        else
        {
            //Same here...
            
        }
    };
    
    [self.tableView reloadData];
}
-(CGRect)frameForImage:(UIImage*)image inImageViewAspectFit:(UIImageView*)imageView
{
    float imageRatio = image.size.width / image.size.height;
    float viewRatio = imageView.frame.size.width / imageView.frame.size.height;
    if(imageRatio < viewRatio)
    {
        float scale = imageView.frame.size.height / image.size.height;
        float width = scale * image.size.width;
        float topLeftX = (imageView.frame.size.width - width) * 0.5;
        return CGRectMake(topLeftX, 0, width, imageView.frame.size.height);
    }
    else
    {
        float scale = imageView.frame.size.width / image.size.width;
        float height = scale * image.size.height;
        float topLeftY = (imageView.frame.size.height - height) * 0.5;
        
        return CGRectMake(0, topLeftY, imageView.frame.size.width, height);
    }
}
# pragma mark - UIActionSheet delegate


- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == ChangeHeaderPictureTag) {
        
        if (buttonIndex == 0) {
            [self shouldStartCameraController];
        } else if (buttonIndex == 1) {
            [self shouldStartPhotoLibraryPickerController];
        }
        
    }
    
    if (actionSheet.tag == ReportUserTag)
    {
        if (buttonIndex == 0)
        {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"What do you want the user to be reported for?", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Sexual content", nil), NSLocalizedString(@"Offensive content", nil), NSLocalizedString(@"Spam", nil), NSLocalizedString(@"Other", nil), nil];
            //actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
            actionSheet.tag = ReportReasonTag;
            [actionSheet showInView:self.headerView];
        }
        else if (buttonIndex == 1)
        {
            NSString *msg=[self.user objectForKey:@"displayName"];

            NSLog(@"%@",self.blockUserArray);
            NSLog(@"%@",self.user.objectId);
            
            if ([self.blockUserArray containsObject:self.user.objectId]) {
                msg=[msg stringByAppendingString: @" is unblocked"];
            }
            else
            {
                msg=[msg stringByAppendingString: @" is blocked"];
            }

            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Waring"
                                                            message:msg
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            
            //sdfds
        }
    }
    else if (actionSheet.tag == ReportReasonTag)
    {
        if (buttonIndex == 0)
        {
            [self reportUser:0];
        }
        else if (buttonIndex == 1)
        {
            [self reportUser:1];
        }
        else if (buttonIndex == 2)
        {
            [self reportUser:2];
        }
        else if (buttonIndex == 3)
        {
            [self reportUser:3];
        }
    }
}


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    // the user clicked OK
    if (buttonIndex == 0) {
        
        if ([self.blockUserArray containsObject:self.user.objectId]) {
            
            [self.blockUserArray removeObject:self.user.objectId];

            PFQuery *query=[[PFQuery alloc] initWithClassName:@"block_table"];
            [query whereKey:@"block_userId" equalTo:[PFUser currentUser].objectId];
            [query whereKey:@"UserID" equalTo:self.user.objectId];
            [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                if (error == NO) {
                    for (PFObject *obj in objects) {
                        [obj deleteInBackground];
                    }
                }
            }];
        }
        else
        {
            [(AppDelegate *)[[UIApplication sharedApplication] delegate] ChangeBlock:self.user];
        }
        
        ESFindFriendsViewController *findfriendviewcontroller = [[ESFindFriendsViewController alloc] init];
        findfriendviewcontroller.hidesBottomBarWhenPushed = true;
        [self.navigationController pushViewController:findfriendviewcontroller animated:YES];
    }
}


- (void)willPresentActionSheet:(UIActionSheet *)actionSheet
{
    for (UIView *subview in actionSheet.subviews) {
        if ([subview isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)subview;
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }
    }

}

#pragma mark - PFQueryTableViewController

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    
    self.tableView.tableHeaderView = headerView;
}

- (PFQuery *)queryForTable {
    if (!self.user) {
        PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
        [query setLimit:0];
        return query;
    }
    
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    query.cachePolicy = kPFCachePolicyNetworkOnly;
    
    if (self.objects.count == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
    [query whereKey:kESPhotoUserKey equalTo:self.user];
    [query orderByDescending:@"createdAt"];
    [query includeKey:kESPhotoUserKey];
    
    return query;
}

# pragma mark - UITableView

- (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *LoadMoreCellIdentifier = @"LoadMoreCell";
    
    [self loadNextPage];
    
    ESLoadMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:LoadMoreCellIdentifier];
    if (!cell) {
        cell = [[ESLoadMoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LoadMoreCellIdentifier];
        cell.selectionStyle =UITableViewCellSelectionStyleGray;
        //cell.separatorImageTop.image = [UIImage imageNamed:@"SeparatorTimelineDark"];
        cell.hideSeparatorBottom = YES;
        cell.mainView.backgroundColor = [UIColor clearColor];
    }
    return cell;
}


#pragma mark - ()

- (void)followButtonAction:(id)sender {
    UIActivityIndicatorView *loadingActivityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [loadingActivityIndicatorView startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:loadingActivityIndicatorView];
    
    [self configureUnfollowButton];
    
    [ESUtility followUserEventually:self.user block:^(BOOL succeeded, NSError *error) {
        if (error) {
            [self configureFollowButton];
        }
    }];
}

- (void)unfollowButtonAction:(id)sender {
    UIActivityIndicatorView *loadingActivityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [loadingActivityIndicatorView startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:loadingActivityIndicatorView];
    
    [self configureFollowButton];
    
    [ESUtility unfollowUserEventually:self.user];
}
- (void)configureSettingsButton {
    NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
    if ([language isEqualToString:@"lb"]) {
        editProfileBtn.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 150, 270, 135, 30);
    }
    
    [editProfileBtn addTarget:self action:@selector(editProfileBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    [editProfileBtn setTitle:NSLocalizedString(@"Edit Profile",nil) forState:UIControlStateNormal];
    [editProfileBtn sizeToFit];
    [editProfileBtn setBackgroundImage:[UIImage imageNamed:@"edit btn"] forState:UIControlStateNormal];
    [editProfileBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [editProfileBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    editProfileBtn.titleLabel.textColor = [UIColor whiteColor];
    editProfileBtn.tintColor = [UIColor grayColor];
    editProfileBtn.titleLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:14];
    editProfileBtn.layer.borderWidth = 0;
    editProfileBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    editProfileBtn.layer.cornerRadius = 4;
    editProfileBtn.layer.borderWidth = 0;
    editProfileBtn.layer.masksToBounds = YES;
}

- (void)configureFollowButton
{
    editProfileBtn.frame = CGRectMake(150 + ([UIScreen mainScreen].bounds.size.width - 150 - 40) / 2 + 20, 270, ([UIScreen mainScreen].bounds.size.width - 150 - 40) / 2, 30);
    [editProfileBtn addTarget:self action:@selector(followButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [editProfileBtn setTitle:NSLocalizedString(@"Follow",nil) forState:UIControlStateNormal];
    [editProfileBtn setBackgroundImage:[UIImage imageNamed:@"folowing.png"] forState:UIControlStateNormal];
    [editProfileBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [editProfileBtn setTitleColor:[UIColor colorWithRed:32/255.0f green:131/255.0f blue:251/255.0f alpha:1] forState:UIControlStateHighlighted];
    editProfileBtn.backgroundColor = [UIColor clearColor];
    editProfileBtn.titleLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:14];
    editProfileBtn.layer.borderWidth = 0;
    editProfileBtn.layer.borderColor = [UIColor clearColor].CGColor; //[UIColor colorWithRed:32.0f/255.0f green:131.0f/255.0f blue:251.0f/255.0f alpha:1].CGColor;
    editProfileBtn.layer.cornerRadius = 5;
    editProfileBtn.layer.masksToBounds = YES;
    [[ESCache sharedCache] setFollowStatus:NO user:self.user];
    
    UIActivityIndicatorView *loadingActivityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:loadingActivityIndicatorView];
    [loadingActivityIndicatorView stopAnimating];
    
    messageBtn = [[UIButton alloc]initWithFrame:CGRectMake(150, 270, ([UIScreen mainScreen].bounds.size.width - 150 - 40) / 2, 30)];
    [messageBtn setTitle:[NSString stringWithFormat:@"%@", NSLocalizedString(@"Message", nil)] forState:UIControlStateNormal];
    [messageBtn setBackgroundImage:[UIImage imageNamed:@"follow.png"] forState:UIControlStateNormal];
    [messageBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    messageBtn.titleLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:14];
    [messageBtn addTarget:self action:@selector(showMessageView) forControlEvents:UIControlEventTouchDown];
    messageBtn.layer.cornerRadius = 3;
//    messageBtn.backgroundColor = def_Golden_Color;
    [self.headerView addSubview:messageBtn];
}

- (void)configureUnfollowButton {
    editProfileBtn.frame = CGRectMake(150 + ([UIScreen mainScreen].bounds.size.width - 150 - 40) / 2 + 20, 270, ([UIScreen mainScreen].bounds.size.width - 150 - 40) / 2, 30);
    [editProfileBtn addTarget:self action:@selector(unfollowButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [editProfileBtn setTitle:NSLocalizedString(@"Following",nil) forState:UIControlStateNormal];
    [editProfileBtn setBackgroundImage:[UIImage imageNamed:@"folowing.png"] forState:UIControlStateNormal];
    [editProfileBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [editProfileBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    editProfileBtn.titleLabel.textColor = [UIColor whiteColor];
    editProfileBtn.tintColor = [UIColor whiteColor];
    editProfileBtn.backgroundColor = [UIColor clearColor]; //[UIColor colorWithRed:32.0f/255.0f green:131.0f/255.0f blue:251.0f/255.0f alpha:1];
    editProfileBtn.titleLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:14];
    editProfileBtn.layer.borderColor = [UIColor clearColor].CGColor; //[UIColor colorWithRed:32.0f/255.0f green:131.0f/255.0f blue:251.0f/255.0f alpha:1].CGColor;
    editProfileBtn.layer.cornerRadius = 5;
//    editProfileBtn.layer.borderColor = [UIColor colorWithRed:32.0f/255.0f green:131.0f/255.0f blue:251.0f/255.0f alpha:1].CGColor;
    
    editProfileBtn.layer.masksToBounds = YES;
    [[ESCache sharedCache] setFollowStatus:YES user:self.user];
    
    UIActivityIndicatorView *loadingActivityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:loadingActivityIndicatorView];
    [loadingActivityIndicatorView stopAnimating];
    
    messageBtn = [[UIButton alloc]initWithFrame:CGRectMake(150, 270, ([UIScreen mainScreen].bounds.size.width - 150 - 40) / 2, 30)];
    [messageBtn setTitle:[NSString stringWithFormat:@"%@", NSLocalizedString(@"Message", nil)] forState:UIControlStateNormal];
    [messageBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [messageBtn setBackgroundImage:[UIImage imageNamed:@"follow.png"] forState:UIControlStateNormal];
    messageBtn.titleLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:14];
    [messageBtn addTarget:self action:@selector(showMessageView) forControlEvents:UIControlEventTouchDown];
    messageBtn.layer.cornerRadius = 3;
    messageBtn.backgroundColor = [UIColor clearColor]; //def_Golden_Color;
    [self.headerView addSubview:messageBtn];
}

-(void)reportUser:(int)i {
    PFObject *object = [PFObject objectWithClassName:@"Report"];
    [object setObject:user forKey:@"ReportedUser"];
    
    if (i == 0) {
        NSString *reason = [NSString stringWithFormat:NSLocalizedString(@"Sexual", nil)];
        [object setObject:reason forKey:@"Reason"];
    }
    else if (i == 1) {
        NSString *reason = [NSString stringWithFormat:NSLocalizedString(@"Offensive", nil)];
        [object setObject:reason forKey:@"Reason"];
    }
    else if (i == 2) {
        NSString *reason = [NSString stringWithFormat:NSLocalizedString(@"Spam", nil)];
        [object setObject:reason forKey:@"Reason"];
    }
    else if (i == 3) {
        NSString *reason = [NSString stringWithFormat:NSLocalizedString(@"Other", nil)];
        [object setObject:reason forKey:@"Reason"];
    }
    
    [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            SCLAlertView *alert = [[SCLAlertView alloc] init];
            
            [alert showNotice:self.tabBarController title:NSLocalizedString(@"Notice", nil)
                    subTitle:NSLocalizedString(@"User has been successfully reported.", nil)
            closeButtonTitle:@"OK" duration:0.0f];
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

- (void) editProfileBtnTapped {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        ESEditProfileViewController *profileViewController = [[ESEditProfileViewController alloc] initWithNibName:nil bundle:nil andOptionForTutorial:@"NO"];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:profileViewController];
        navController.modalPresentationStyle = UIModalPresentationFullScreen;
        

        [self presentViewController:navController animated:YES completion:nil];
    });
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didDismissSecondViewController)
                                                 name:@"SecondViewControllerDismissed"
                                               object:nil];
    
    
}
- (void) didDismissSecondViewController {
    [self setupHeader];
}
- (void) ReportTap {
    
    
    UIActionSheet *actionSheet;
    
    if ([self.blockUserArray containsObject:self.user.objectId]) {
        
        actionSheet= [[UIActionSheet alloc]initWithTitle:NSLocalizedString(@"Do you want to report the user for infringing our terms of use?", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:NSLocalizedString(@"Report", nil) otherButtonTitles: NSLocalizedString(@"Unblock", nil) ,nil];
        actionSheet.tag = ReportUserTag;
       
        
    }
    else
    {
        actionSheet= [[UIActionSheet alloc]initWithTitle:NSLocalizedString(@"Do you want to report the user for infringing our terms of use?", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:NSLocalizedString(@"Report", nil) otherButtonTitles: NSLocalizedString(@"Block", nil) ,nil];
        actionSheet.tag = ReportUserTag;
        
    }
    
    [actionSheet showInView:self.headerView];
}


-(void)showFollowers {
    ESFollowersViewController *followerView = [[ESFollowersViewController alloc] initWithStyle:UITableViewStyleGrouped andOption:NSLocalizedString(@"Followers",nil) andUser:self.user];
    followerView.hidesBottomBarWhenPushed = true;
    [self.navigationController pushViewController:followerView animated:YES];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];

}
-(void)showFollowings {
    ESFollowersViewController *followerView = [[ESFollowersViewController alloc] initWithStyle:UITableViewStyleGrouped andOption:NSLocalizedString(@"Following",nil) andUser:self.user];
    followerView.hidesBottomBarWhenPushed = true;
    [self.navigationController pushViewController:followerView animated:YES];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];

}

-(void)showMessageView
{
    NSLog(@"User:- %@",self.user);
    
    NSMutableArray *selectedUsers = [[NSMutableArray alloc] init];
    
    [selectedUsers addObject:self.user];
    
    NSString *groupId = [ESUtility createConversation:selectedUsers groupName:@"" image:nil];
    NSString *description = [[NSString alloc]init];
    
    if (groupId.length == 20)
    {
        for (PFUser *userTemp in selectedUsers)
        {
            if (![userTemp.objectId isEqualToString:[PFUser currentUser].objectId])
            {
                description = [userTemp objectForKey:kESUserDisplayNameKey];
                break;
            }
        }
        
        ESMessengerView *messengerView = [[ESMessengerView alloc] initWith:groupId andName:description];
        messengerView.hidesBottomBarWhenPushed = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController pushViewController:messengerView animated:YES];
        });
    }
    else
    {
        ESMessengerView *messengerView = [[ESMessengerView alloc] initWith:groupId andName:NSLocalizedString(@"Group", nil)];
        messengerView.hidesBottomBarWhenPushed = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController pushViewController:messengerView animated:YES];
        });
    }
}

#pragma mark - message methods


//Hot fix for the bug in the Parse SDK
- (NSIndexPath *)_indexPathForPaginationCell {
    return [NSIndexPath indexPathForRow:0 inSection:[self.objects count]];
}


-(void) changeProfilePicture {
    
    BOOL cameraDeviceAvailable = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    BOOL photoLibraryAvailable = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary];
    
    if (cameraDeviceAvailable && photoLibraryAvailable) {
        
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Change header picture", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Take Photo", nil), NSLocalizedString(@"Choose Photo", nil), nil];
            //actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
            actionSheet.tag = ChangeHeaderPictureTag;
            [actionSheet showInView:self.view];

    } else {
        // if we don't have at least two options, we automatically show whichever is available (camera or roll)
        [self shouldPresentPhotoCaptureController];
    }
    
}

- (BOOL)shouldPresentPhotoCaptureController {
    BOOL presentedPhotoCaptureController = [self shouldStartCameraController];
    
    if (!presentedPhotoCaptureController) {
        presentedPhotoCaptureController = [self shouldStartPhotoLibraryPickerController];
    }
    
    return presentedPhotoCaptureController;
}

- (BOOL)shouldStartPhotoLibraryPickerController {
    if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] == NO
         && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)) {
        return NO;
    }
    
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]
        && [[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary] containsObject:(NSString *)kUTTypeImage]) {
        
        cameraUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        cameraUI.mediaTypes = [NSArray arrayWithObject:(NSString *) kUTTypeImage];
        
    } else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]
               && [[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum] containsObject:(NSString *)kUTTypeImage]) {
        
        cameraUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        cameraUI.mediaTypes = [NSArray arrayWithObject:(NSString *) kUTTypeImage];
        
    } else {
        return NO;
    }
    
    cameraUI.allowsEditing = YES;
    cameraUI.delegate = self;
    cameraUI.modalPresentationStyle = UIModalPresentationFullScreen;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:cameraUI animated:YES completion:nil];
    });
    
    return YES;
}
- (BOOL)shouldStartCameraController {
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO) {
        return NO;
    }
    
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]
        && [[UIImagePickerController availableMediaTypesForSourceType:
             UIImagePickerControllerSourceTypeCamera] containsObject:(NSString *)kUTTypeImage]) {
        
        cameraUI.mediaTypes = [NSArray arrayWithObject:(NSString *) kUTTypeImage];
        cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
        cameraUI.allowsEditing = false;

        if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]) {
            cameraUI.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        } else if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
            cameraUI.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        }
        
    } else {
        return NO;
    }
    
    cameraUI.allowsEditing = YES;
    cameraUI.showsCameraControls = YES;
    cameraUI.delegate = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:cameraUI animated:YES completion:nil];
    });
    
    return YES;
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self dismissViewControllerAnimated:NO completion:nil];
    
    UIImage *_image = [info objectForKey:UIImagePickerControllerEditedImage];
    self.imageView.image = _image;
    
    [self shouldUploadImage: _image];
    
}

- (BOOL)shouldUploadImage:(UIImage *)anImage {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    UIImage *resizedImage = [anImage resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(640.0f, 640.0f) interpolationQuality:kCGInterpolationHigh];
    UIImage *thumbnailImage = [anImage thumbnailImage:86.0f transparentBorder:0.0f cornerRadius:10.0f interpolationQuality:kCGInterpolationDefault];
    
    // JPEG to decrease file size and enable faster uploads & downloads
    NSData *imageData = UIImageJPEGRepresentation(resizedImage, 0.8f);
    NSData *thumbnailImageData = UIImagePNGRepresentation(thumbnailImage);
    
    if (!imageData || !thumbnailImageData) {
        return NO;
    }
    
    PFFile* photoFile = [PFFile fileWithData:imageData];
    PFFile* thumbnailFile = [PFFile fileWithData:thumbnailImageData];
    
    // Request a background execution task to allow us to finish uploading the photo even if the app is backgrounded
    self.fileUploadBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler: ^{
        [[UIApplication sharedApplication] endBackgroundTask: self.fileUploadBackgroundTaskId];
    }];
    
    [ photoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        // Do something...
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
        if (succeeded) {
          
            [thumbnailFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                NSData *imageData = UIImageJPEGRepresentation(anImage, 0.7);
                
                [ESUtility processHeaderPhotoWithData:imageData];
                    
                
                          [self.imageView setFile:photoFile];
                          
                          [self.imageView loadInBackground:^(UIImage *image, NSError *error)
                          {
                              if (!image)
                              {
                                  [self.imageView setImage:[UIImage imageNamed:@"bg_logo.jpg"]];
                              }
                          }];
                          
                [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
            }];
        } else {
            [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
        }
    }];
    
    return YES;
}
@end
