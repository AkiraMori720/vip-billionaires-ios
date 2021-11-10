//
//  AppDelegate.m
//  D'Netzwierk
//
//  Created by Eric Schanet on 6/05/2014.
//  Copyright (c) 2014 Eric Schanet. All rights reserved.
//


#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "ESPrivacyPolicyViewController.h"
#import <Bolts/Bolts.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <Firebase/Firebase.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "PFFacebookUtils.h"
#import <UserNotifications/UserNotifications.h>
#import "IQKeyboardManager.h"
#import "Flurry.h"

@interface AppDelegate() {
    
}
@property (nonatomic, strong) ESHomeViewController *homeViewController;
@property (nonatomic, strong) ESActivityFeedViewController *activityViewController;
@property (nonatomic, strong) ESWelcomeViewController *welcomeViewController;
@property (nonatomic, strong) ESAccountViewController *accountViewController;
@property (nonatomic, strong) ESConversationViewController *messengerViewController;


@end


@implementation AppDelegate
@synthesize cameraButton;
@synthesize unblockUserArray;
#pragma mark - UIApplicationDelegate
- (void)crash {
    [NSException raise:NSGenericException format:@"Everything is ok. This is just a test crash."];
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [Flurry startSession:@"3P7H3GH7BNBSGN8TN76F"
    withSessionBuilder:[[[FlurrySessionBuilder new]
                         withCrashReporting:YES]
                         withLogLevel:FlurryLogLevelDebug]];
    
    sleep(3);
    
    [IQKeyboardManager sharedManager].enable = true;
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // ****************************************************************************
    // Parse initialization
   // [Parse setApplicationId:@"93goSK8wGoacU3bxAogpbrvr4wJp10vs0pY2fK3q" clientKey:@"UaTqdWHndjRdbrYTh5aIs65SsdqvTSuukCyGG4pF"];
    
    [Parse initializeWithConfiguration:[ParseClientConfiguration configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {
        configuration.applicationId = @"93goSK8wGoacU3bxAogpbrvr4wJp10vs0pY2fK3q";
        configuration.clientKey = @"UaTqdWHndjRdbrYTh5aIs65SsdqvTSuukCyGG4pF";
        configuration.server = @"https://parseapi.back4app.com";
    }]];

   
    // ****************************************************************************
    [Firebase setOption:@"persistence" to:@YES];
    
    unblockUserArray=[[NSMutableArray alloc] initWithCapacity:1000];
    // Track app open.
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];

    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    currentInstallation.badge = 0;
    [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            [currentInstallation saveEventually];
        }
    }];
    
    PFACL *defaultACL = [PFACL ACL];
    // Enable public read access by default, with any newly created PFObjects belonging to the current user
    [defaultACL setPublicReadAccess:YES];
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
    
    // Set up our app's global UIAppearance
    [self setupAppearance];
#/*ifdef __IPHONE_8_0
    
    if(IS_OS_8_OR_LATER) {
        //Right, that is the point
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIRemoteNotificationTypeBadge
                                                                                             |UIRemoteNotificationTypeSound
                                                                                             |UIRemoteNotificationTypeAlert) categories:nil];
        NSUserDefaults *defaults= [NSUserDefaults standardUserDefaults];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];

        if([[[defaults dictionaryRepresentation] allKeys] containsObject:@"pushnotifications"]){
            if ([defaults boolForKey:@"pushnotifications"] == NO ) {
                [[UIApplication sharedApplication] unregisterForRemoteNotifications];
            }
        }
    }
#endif*/
    
   /* if(IS_OS_8_OR_LATER) {
        //Right, that is the point, no need to do anything here
        
    }
    else {
        //register to receive notifications
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|
         UIRemoteNotificationTypeAlert|
         UIRemoteNotificationTypeSound];
    }*/
    
    [self registerForRemoteNotifications];

    UILocalNotification *locationNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (locationNotification) {
        // Set icon badge number to zero
        application.applicationIconBadgeNumber = 0;
    }
    // Use Reachability to monitor connectivity
    [self monitorReachability];
    
    self.welcomeViewController = [[ESWelcomeViewController alloc] init];
    
    self.navController = [[UINavigationController alloc] initWithRootViewController:self.welcomeViewController];
    self.navController.navigationBarHidden = YES;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    
    self.window.rootViewController = self.navController;
    [self.window makeKeyAndVisible];
    
    [self handlePush:launchOptions];
    
    NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
    [[PFUser currentUser] setObject:language forKey:@"language"];
    [[PFUser currentUser] saveEventually];
    
    [self.window makeKeyAndVisible];
    
    //
   /* if (launchOptions[UIApplicationLaunchOptionsURLKey] == nil) {
        [FBSDKAppLinkUtility fetchDeferredAppLink:^(NSURL *url, NSError *error) {
            if (error) {
                NSLog(@"Received error while fetching deferred app link %@", error);
            }
            if (url) {
                [[UIApplication sharedApplication]openURL:url];
            }
        }];
    }*/
    

    
    [FBSDKLoginButton class];

    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];

    [PFFacebookUtils initializeFacebookWithApplicationLaunchOptions:launchOptions];

    return YES;
}
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                          options:options];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    BOOL handled = [[FBSDKApplicationDelegate sharedInstance] application:application
                                                                  openURL:url
                                                        sourceApplication:sourceApplication
                                                               annotation:annotation
                    ];
    // Add any custom logic here.
    return handled;
}

- (void)registerForRemoteNotifications {
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge |     UNAuthorizationOptionCarPlay) completionHandler:^(BOOL granted, NSError * _Nullable error){
        if(!error){
            dispatch_async(dispatch_get_main_queue(), ^{
                [[UIApplication sharedApplication] registerForRemoteNotifications];
            });
        }else{
            NSLog(@"%@",error.description);
        }
    }];
    
    
}
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current Installation and save it to Parse
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];;
    [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            NSLog(@"installation saved!!!");
        }else{
            NSLog(@"installation save failed %@",error.debugDescription);
        }
    }];
}
/*- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    if (application.applicationIconBadgeNumber != 0) {
        application.applicationIconBadgeNumber = 0;
    }
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            [currentInstallation saveEventually];
        }
    }];
}*/

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    if (error.code != 3010) { // 3010 is for the iPhone Simulator
        NSLog(@"Application failed to register for push notifications: %@", error);
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ESAppDelegateApplicationDidReceiveRemoteNotification object:nil userInfo:userInfo];
    
    //AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
    
   // AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        // Track app opens due to a push notification being acknowledged while the app wasn't active.
        [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
    }
    
    NSString *remoteNotificationPayload = [userInfo objectForKey:kESPushPayloadPayloadTypeKey];
    if ([PFUser currentUser]) {
        
        /*if (application.applicationState == UIApplicationStateActive ) {
            
            if (self.tabBarController.selectedIndex != ESChatTabBarItemIndex) {
                
                /*UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                 message:[[userInfo objectForKey:@"aps"]objectForKey:@"alert"]
                 delegate:self
                 cancelButtonTitle:@"OK"
                 otherButtonTitles:nil];
                 [alert show];
                
                UILocalNotification *localNotification = [[UILocalNotification alloc] init];
                localNotification.userInfo = userInfo;
                localNotification.soundName = UILocalNotificationDefaultSoundName;
                localNotification.alertBody = [[userInfo objectForKey:@"aps"]objectForKey:@"alert"];
                localNotification.fireDate = [NSDate date];
                [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
                
            }
            
        }*/
        if ([remoteNotificationPayload isEqualToString:@"m"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"receivedMessage" object:nil userInfo:nil];
            
            UITabBarItem *tabBarItem = [[self.tabBarController.viewControllers objectAtIndex:ESChatTabBarItemIndex] tabBarItem];
            
            NSString *currentBadgeValue = tabBarItem.badgeValue;
            
            if (currentBadgeValue && currentBadgeValue.length > 0) {
                NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
                NSNumber *badgeValue = [numberFormatter numberFromString:currentBadgeValue];
                NSNumber *newBadgeValue = [NSNumber numberWithInt:[badgeValue intValue] + 1];
                tabBarItem.badgeValue = [numberFormatter stringFromNumber:newBadgeValue];
            } else {
                tabBarItem.badgeValue = @"1";
            }
            
        }
        else if ([self.tabBarController viewControllers].count > ESActivityTabBarItemIndex) {
            UITabBarItem *tabBarItem = [[self.tabBarController.viewControllers objectAtIndex:ESActivityTabBarItemIndex] tabBarItem];
            
            NSString *currentBadgeValue = tabBarItem.badgeValue;
            
            if (currentBadgeValue && currentBadgeValue.length > 0) {
                NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
                NSNumber *badgeValue = [numberFormatter numberFromString:currentBadgeValue];
                NSNumber *newBadgeValue = [NSNumber numberWithInt:[badgeValue intValue] + 1];
                tabBarItem.badgeValue = [numberFormatter stringFromNumber:newBadgeValue];
            } else {
                tabBarItem.badgeValue = @"1";
            }
            
            
        }
    }
}
- (void)application:(UIApplication *)application
didReceiveLocalNotification:(UILocalNotification *)notification
{
    
}
-(void)applicationDidEnterBackground:(UIApplication *)application
{
    application.applicationIconBadgeNumber = 0;
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}
- (void)applicationDidBecomeActive:(UIApplication *)application {
   // [FBSDKAppEvents activateApp];

    // Clears out all notifications from Notification Center.
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    application.applicationIconBadgeNumber = 0;
    application.applicationIconBadgeNumber = 0;
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    currentInstallation.badge = 0;
    [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            [currentInstallation saveEventually];
        }
    }];
    
   // [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
    if ([PFUser currentUser]) {
        if (![[[PFUser currentUser] objectForKey:@"acceptedTerms"] isEqualToString:@"Yes"]) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Terms of Use", nil) message:NSLocalizedString(@"Please accept the terms of use before using this app",nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"I accept", nil), NSLocalizedString(@"Show terms", nil), nil];
            [alert show];
            alert.tag = 99;
            
        }
    }
}


#pragma mark - UITabBarControllerDelegate

- (BOOL)tabBarController:(UITabBarController *)aTabBarController shouldSelectViewController:(UIViewController *)viewController {
    // The empty UITabBarItem behind our Camera button should not load a view controller
    return ![viewController isEqual:aTabBarController.viewControllers[ESEmptyTabBarItemIndex]];
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    _data = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    if (![[PFUser currentUser] objectForKey:@"uploadedProfilePicture"]) {
        [ESUtility processProfilePictureData:_data];
    }
    else {
        //nothing to do here, actually
    }
}


#pragma mark - AppDelegate

- (BOOL)isParseReachable {
    return self.networkStatus != NotReachable;
}

-(UIImage *)scaleToWidth: (CGFloat)width image:(UIImage*) image
{
    UIImage *scaledImage = image;
    if (image.size.width != width) {
        CGFloat height = floorf(image.size.height * (width / image.size.width));
        CGSize size = CGSizeMake(width, height);
        
        // Create an image context
        UIGraphicsBeginImageContext(size);
        
        // Draw the scaled image
        [image drawInRect:CGRectMake(0.0f, 0.0f, size.width, size.height)];
        
        // Create a new image from context
        scaledImage = UIGraphicsGetImageFromCurrentImageContext();
        
        // Pop the current context from the stack
        UIGraphicsEndImageContext();
    }
    // Return the new scaled image
    return scaledImage;
}


- (void)presentTabBarController {
    
    self.tabBarController = [[ESTabBarController alloc] init];
    self.tabBarController.delegate = self;
    self.tabBarController.tabBar.backgroundColor = [UIColor whiteColor];
    self.homeViewController = [[ESHomeViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [self.homeViewController setFirstLaunch:firstLaunch];
    self.activityViewController = [[ESActivityFeedViewController alloc] initWithStyle:UITableViewStylePlain];
    self.accountViewController = [[ESAccountViewController alloc] initWithStyle:UITableViewStyleGrouped];
    self.accountViewController.user = [PFUser currentUser];
    self.messengerViewController = [[ESConversationViewController alloc] initWithStyle:UITableViewStylePlain];
    
    UINavigationController *homeNavigationController = [[UINavigationController alloc] initWithRootViewController:self.homeViewController];
    UINavigationController *emptyNavigationController = [[UINavigationController alloc] init];
    UINavigationController *activityFeedNavigationController = [[UINavigationController alloc] initWithRootViewController:self.activityViewController];
    UINavigationController *accountNavigationController = [[UINavigationController alloc] initWithRootViewController:self.accountViewController];
    UINavigationController *chatNavigationController = [[UINavigationController alloc] initWithRootViewController:self.messengerViewController];
    
    chatNavigationController.navigationItem.backBarButtonItem =  [[UIBarButtonItem alloc] initWithTitle:@""style:UIBarButtonItemStylePlain target:nil action:nil];
    /*
    UIImage *image1 = [[UIImage alloc]init];
    image1 = [self imageNamed:@"IconHome" withColor:[UIColor colorWithHue:204.0f/360.0f saturation:76.0f/100.0f brightness:86.0f/100.0f alpha:1]];
    UIGraphicsBeginImageContext(self.window.frame.size);
    UIGraphicsEndImageContext();*/
    
    UIImage *homeImage1 = [self scaleToWidth: 25 image:[UIImage imageNamed:@"home_disabled"]];
    UIImage *homeImage2 = [self scaleToWidth: 25 image: [UIImage imageNamed:@"home_enabled"]];
    UITabBarItem *homeTabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Home", nil) image:[homeImage1 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[homeImage2 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [homeTabBarItem setTitleTextAttributes: @{ NSForegroundColorAttributeName: [UIColor grayColor] } forState:UIControlStateNormal];
    [homeTabBarItem setTitleTextAttributes: @{ NSForegroundColorAttributeName: def_Golden_Color } forState:UIControlStateSelected];
    
    UIImage *activityImage1 = [self scaleToWidth: 25 image:[UIImage imageNamed:@"activity_disabled"]];
    UIImage *activityImage2 = [self scaleToWidth: 25 image:[UIImage imageNamed:@"activity_enabled"]];
    UITabBarItem *activityFeedTabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Activity", nil) image:[activityImage1 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[activityImage2 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [activityFeedTabBarItem setTitleTextAttributes:@{ NSForegroundColorAttributeName: [UIColor grayColor] } forState:UIControlStateNormal];
    [activityFeedTabBarItem setTitleTextAttributes:@{ NSForegroundColorAttributeName: def_Golden_Color } forState:UIControlStateSelected];
    
    UIImage *profileImage1 = [self scaleToWidth: 25 image:[UIImage imageNamed:@"profile_disabled"]];
    UIImage *profileImage2 = [self scaleToWidth: 25 image:[UIImage imageNamed:@"profile_enabled"]];
    UITabBarItem *profileTabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Profile", nil) image:[profileImage1 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[profileImage2 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [profileTabBarItem setTitleTextAttributes:@{ NSForegroundColorAttributeName: [UIColor grayColor] } forState:UIControlStateNormal];
    [profileTabBarItem setTitleTextAttributes:@{ NSForegroundColorAttributeName: def_Golden_Color } forState:UIControlStateSelected];
    
    UIImage *chatImage1 = [self scaleToWidth: 25 image:[UIImage imageNamed:@"message_disabled"]];
    UIImage *chatImage2 = [self scaleToWidth: 25 image:[UIImage imageNamed:@"message_enabled"]];
    UITabBarItem *chatTabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Message", nil) image:[chatImage1 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[chatImage2 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [chatTabBarItem setTitleTextAttributes:@{ NSForegroundColorAttributeName: [UIColor grayColor] } forState:UIControlStateNormal];
    [chatTabBarItem setTitleTextAttributes:@{ NSForegroundColorAttributeName: def_Golden_Color } forState:UIControlStateSelected];
    
    [homeNavigationController setTabBarItem:homeTabBarItem];
    [activityFeedNavigationController setTabBarItem:activityFeedTabBarItem];
    [accountNavigationController setTabBarItem:profileTabBarItem];
    [chatNavigationController setTabBarItem:chatTabBarItem];
    [[UITabBar appearance] setBarTintColor: [UIColor colorWithWhite:0.95 alpha:1]];
    [[UITabBar appearance] setTranslucent:NO];
    UIViewController * leftDrawer = [[SideViewController alloc] init];
    
    NSLog(@"%f, %f --------------XXXX", self.tabBarController.tabBar.frame.size.height + self.tabBarController.tabBar.frame.origin.y, [UIScreen mainScreen].bounds.size.height);
    CGFloat vipButonSize = 80;
    self.vipButton = [[UIButton alloc] init];
    
    [self.vipButton setBackgroundImage:[UIImage imageNamed:@"vip_button"] forState:UIControlStateNormal];
//    [self.tabBarController.tabBar addSubview: self.vipButton];
//    self.vipButton.frame = CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - vipButonSize / 2, -vipButonSize / 3, vipButonSize, vipButonSize);
    self.tabBarController.tabBar.clipsToBounds = NO;
    self.tabBarController.delegate = self;
    
    
    self.tabBarController.viewControllers = @[ homeNavigationController, accountNavigationController, emptyNavigationController, chatNavigationController, activityFeedNavigationController];
    
    self.container = [MFSideMenuContainerViewController
                      containerWithCenterViewController:self.tabBarController
                      leftMenuViewController:leftDrawer
                      rightMenuViewController:nil];
    
    [self.navController setViewControllers:@[ self.welcomeViewController, self.container ] animated:NO];
//    [self.tabBarController.tabBar bringSubviewToFront:self.vipButton];
    [self.tabBarController.tabBar setTranslucent:NO];
    [[self.tabBarController.tabBar.items objectAtIndex:2] setTitle:nil];
//    NSTimer* timer = [NSTimer scheduledTimerWithTimeInterval:0.1 repeats:YES block:^(NSTimer * _Nonnull timer) {
//        if (!self.tabBarController.tabBar.hidden) {
//            self.vipButton.hidden = NO;
//           [self.tabBarController.view bringSubviewToFront:self.vipButton];
//        } else {
//            self.vipButton.hidden = YES;
//        }
//    }];
}

- (void)logOut {
    // clear cache
    [[ESCache sharedCache] clear];
    
    // clear NSUserDefaults
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kESUserDefaultsCacheFacebookFriendsKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kESUserDefaultsActivityFeedViewControllerLastRefreshKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // Unsubscribe from push notifications by removing the user association from the current installation.
    [[PFInstallation currentInstallation] removeObjectForKey:kESInstallationUserKey];
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            [currentInstallation saveEventually];
        }
    }];
    
    // Clear all caches
    [PFQuery clearAllCachedResults];
    
    // Log out
    [PFUser logOut];
    
    // clear out cached data, view controllers, etc
    [self.navController popToRootViewControllerAnimated:NO];
    
    [ProgressHUD dismiss];
    self.homeViewController = nil;
    self.activityViewController = nil;
}

#pragma mark - manager methods

- (void)refreshESConversationViewController {
    [self.messengerViewController loadChatRooms];
}
#pragma mark - ()

// Set up appearance parameters to achieve Netzwierk's custom look and feel
- (void)setupAppearance {
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    
        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    [[UIButton appearanceWhenContainedIn:[UINavigationBar class], nil]
     setTitleColor:def_Golden_Color3
     forState:UIControlStateNormal];
    
    [[UISearchBar appearance] setTintColor:[UIColor colorWithRed:32.0f/255.0f green:19.0f/255.0f blue:16.0f/255.0f alpha:1.0f]];
    
    [[UINavigationBar appearance] setBarTintColor:def_TopBar_Color];
    UIColor *color = [UIColor clearColor];
    if (IS_IPHONE6) {
        cameraButton = [[UIImageView alloc]initWithImage:[self imageFromColor:color forSize:CGSizeMake(75, 49) withCornerRadius:0]];
        cameraButton.frame = CGRectMake(150.0f, 1.0f, 75.0f, 48);
    }
    else {
        cameraButton = [[UIImageView alloc]initWithImage:[self imageFromColor:color forSize:CGSizeMake(64, 49) withCornerRadius:0]];
        cameraButton.frame = CGRectMake( [UIScreen mainScreen].bounds.size.width/2 - 64/2, 1.0f, 64.0f, 48);
    }
    cameraButton.tag = 1;
    cameraButton.layer.borderColor = def_Golden_Color8.CGColor;
    cameraButton.layer.borderWidth = 0.f;
    [[UITabBar appearance] insertSubview:cameraButton atIndex:1];
    
    NSShadow * shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor clearColor];
    shadow.shadowOffset = CGSizeMake(0, 0);
    
    NSDictionary * navBarTitleTextAttributes =
    @{ NSForegroundColorAttributeName : def_Golden_Color,
       NSShadowAttributeName          : shadow,
       NSFontAttributeName            : def_Title_Font };
    
    [[UINavigationBar appearance] setTitleTextAttributes:navBarTitleTextAttributes];
    
    
}

- (void)monitorReachability {
    //Reachability *hostReach = [Reachability reachabilityWithHostname:@"api.parse.com"];
    Reachability *hostReach = [Reachability reachabilityWithHostname:@"https://parseapi.back4app.com"];

    hostReach.reachableBlock = ^(Reachability*reach) {
        _networkStatus = [reach currentReachabilityStatus];
        
        if ([self isParseReachable] && [PFUser currentUser] && self.homeViewController.objects.count == 0) {
            // Refresh home timeline on network restoration. Takes care of a freshly installed app that failed to load the main timeline under bad network conditions.
            // In this case, they'd see the empty timeline placeholder and have no way of refreshing the timeline unless they followed someone.
            [self.homeViewController loadObjects];
        }
    };
    
    hostReach.unreachableBlock = ^(Reachability*reach) {
        _networkStatus = [reach currentReachabilityStatus];
    };
    
    [hostReach startNotifier];
}

- (void)handlePush:(NSDictionary *)launchOptions
{
    // If the app was launched in response to a push notification, we'll handle the payload here
    NSDictionary *remoteNotificationPayload = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    
    if (remoteNotificationPayload)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:ESAppDelegateApplicationDidReceiveRemoteNotification object:nil userInfo:remoteNotificationPayload];
        
        if (![PFUser currentUser])
        {
            return;
        }
        
        // If the push notification payload references a photo, we will attempt to push this view controller into view
        NSString *photoObjectId = [remoteNotificationPayload objectForKey:kESPushPayloadPhotoObjectIdKey];
        
        if (photoObjectId && photoObjectId.length > 0)
        {
            [self shouldNavigateToPhoto:[PFObject objectWithoutDataWithClassName:kESPhotoClassKey objectId:photoObjectId]];
            return;
        }
        
        // If the push notification payload references a user, we will attempt to push their profile into view
        NSString *fromObjectId = [remoteNotificationPayload objectForKey:kESPushPayloadFromUserObjectIdKey];
        
        if (fromObjectId && fromObjectId.length > 0)
        {
            PFQuery *query = [PFUser query];
            query.cachePolicy = kPFCachePolicyCacheElseNetwork;
            
            [query getObjectInBackgroundWithId:fromObjectId block:^(PFObject *user, NSError *error)
            {
                if (!error)
                {
                    UINavigationController *homeNavigationController = self.tabBarController.viewControllers[ESHomeTabBarItemIndex];
                    self.tabBarController.selectedViewController = homeNavigationController;
                    
                    if (user != nil && ![[user objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
                        ESAccountViewController *accountViewController = [[ESAccountViewController alloc] initWithStyle:UITableViewStyleGrouped];
                        accountViewController.user = (PFUser *)user;
                        accountViewController.hidesBottomBarWhenPushed = true;
                        [homeNavigationController pushViewController:accountViewController animated:YES];
                    }
                }
            }];
        }
    }
}

- (BOOL)handleActionURL:(NSURL *)url {
    if ([[url host] isEqualToString:kESLaunchURLHostTakePicture]) {
        if ([PFUser currentUser]) {
            return [self.tabBarController shouldPresentPhotoCaptureController];
        }
    } else {
        if ([[url fragment] rangeOfString:@"^pic/[A-Za-z0-9]{10}$" options:NSRegularExpressionSearch].location != NSNotFound) {
            NSString *photoObjectId = [[url fragment] substringWithRange:NSMakeRange(4, 10)];
            if (photoObjectId && photoObjectId.length > 0) {
                [self shouldNavigateToPhoto:[PFObject objectWithoutDataWithClassName:kESPhotoClassKey objectId:photoObjectId]];
                return YES;
            }
        }
    }
    
    return NO;
}

- (void)shouldNavigateToPhoto:(PFObject *)targetPhoto
{
    for (PFObject *photo in self.homeViewController.objects)
    {
        if ([photo.objectId isEqualToString:targetPhoto.objectId])
        {
            targetPhoto = photo;
            break;
        }
    }
    
    // if we have a local copy of this photo, this won't result in a network fetch
    [targetPhoto fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error)
    {
        if (!error)
        {
            UINavigationController *homeNavigationController = [[self.tabBarController viewControllers] objectAtIndex:ESHomeTabBarItemIndex];
            [self.tabBarController setSelectedViewController:homeNavigationController];
            
            ESPhotoDetailsViewController *detailViewController = [[ESPhotoDetailsViewController alloc] initWithPhoto:object];
            detailViewController.hidesBottomBarWhenPushed = true;
            [homeNavigationController pushViewController:detailViewController animated:YES];
        }
    }];
}

#ifdef __IPHONE_8_0
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    //handle the actions
    if ([identifier isEqualToString:@"declineAction"]){
    }
    else if ([identifier isEqualToString:@"answerAction"]){
    }
}
#endif


- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    if ([tabBarController.viewControllers indexOfObject:viewController] == 0) {
        if (tabBarController.selectedIndex == 0) {
            [self.homeViewController.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
        }
    } else if ([tabBarController.viewControllers indexOfObject:viewController] == 1) {
        if (tabBarController.selectedIndex == 1) {
            [self.accountViewController.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
        }
    }
}
- (UIImage *)imageFromColor:(UIColor *)color forSize:(CGSize)size withCornerRadius:(CGFloat)radius
{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Begin a new image that will be the new image with the rounded corners
    // (here with the size of an UIImageView)
    UIGraphicsBeginImageContext(size);
    
    // Add a clip before drawing anything, in the shape of an rounded rect
    [[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:radius] addClip];
    // Draw your image
    [image drawInRect:rect];
    
    // Get the image, here setting the UIImageView image
    image = UIGraphicsGetImageFromCurrentImageContext();
    
    // Lets forget about that we were drawing
    UIGraphicsEndImageContext();
    
    return image;
}
- (UIColor *)darkerColorForColor:(UIColor *)c
{
    CGFloat r, g, b, a;
    if ([c getRed:&r green:&g blue:&b alpha:&a])
        return [UIColor colorWithRed:MAX(r - 0.02, 0.0)
                               green:MAX(g - 0.02, 0.0)
                                blue:MAX(b - 0.02, 0.0)
                               alpha:a];
    return nil;
}

- (void) wouldYouPleaseChangeTheDesign: (UIColor *)color
{
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    NSString *colorAsString = [NSString stringWithFormat:@"%f,%f,%f,%f", components[0], components[1], components[2], components[3]];
    [[PFUser currentUser] setObject:colorAsString forKey:@"profileColor"];
    [[PFUser currentUser] saveEventually];
    
}


- (void) ChangeBlock: (PFUser *)usr
{
    PFObject* pobject = [[PFObject alloc] initWithClassName:@"block_table"];
    
    [pobject setObject:usr.objectId forKey:@"UserID"];
    [pobject setObject:[PFUser currentUser].objectId forKey:@"block_userId"];
    [pobject saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        
//        Firebase *_firebase = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@/Conversations/%@", kESChatFirebaseCredentialKey, conversation[@"recentId"]]];
//        [_firebase removeValueWithCompletionBlock:^(NSError *error, Firebase *ref)
//         {
//             if (error != nil) NSLog(@"delete error.");
//         }];}
    }];
    
}
- (UIImage *)imageNamed:(NSString *)name withColor:(UIColor *)color {
    // load the image
    UIImage *img = [UIImage imageNamed:name];
    
    // begin a new image context, to draw our colored image onto
    UIGraphicsBeginImageContext(img.size);
    
    // get a reference to that context we created
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // set the fill color
    [color setFill];
    
    // translate/flip the graphics context (for transforming from CG* coords to UI* coords
    CGContextTranslateCTM(context, 0, img.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    // set the blend mode to color burn, and the original image
    CGContextSetBlendMode(context, kCGBlendModeColorBurn);
    CGRect rect = CGRectMake(0, 0, img.size.width, img.size.height);
    CGContextDrawImage(context, rect, img.CGImage);
    
    // set a mask that matches the shape of the image, then draw (color burn) a colored rectangle
    CGContextClipToMask(context, rect, img.CGImage);
    CGContextAddRect(context, rect);
    CGContextDrawPath(context,kCGPathFill);
    
    // generate a new UIImage from the graphics context we drew onto
    UIImage *coloredImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //return the color-burned image
    return coloredImg;
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 99) {
        if (buttonIndex == 0) {
            PFUser *user= [PFUser currentUser];
            [user setObject:@"Yes" forKey:@"acceptedTerms"];
            [user saveInBackground];
            [alertView dismissWithClickedButtonIndex:0 animated:YES];
        }
        else {
            ESPrivacyPolicyViewController * vc = [[ESPrivacyPolicyViewController alloc]init];
            vc.showDoneButton = YES;
            
            [self.navController presentViewController:vc animated:NO completion: nil];
        }
    }
    
}

@end
