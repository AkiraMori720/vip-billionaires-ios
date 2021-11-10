//
//  ESWelcomeViewController.m
//  D'Netzwierk
//
//  Created by Eric Schanet on 6/05/2014.
//  Copyright (c) 2014 Eric Schanet. All rights reserved.
//

#import "AFNetworking.h"
#import <Parse/Parse.h>
#import "AppDelegate.h"
#import "ProgressHUD.h"
#import "ESPageViewController.h"

#import "ESWelcomeViewController.h"
#import "ESLoginViewController.h"
#import "ESSignUpViewController.h"

@implementation ESWelcomeViewController
@synthesize loginButton,signupButton, pageController,arrPageImages,arrPageTitles;
- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([PFUser currentUser]) {
        [[PFUser currentUser] fetchInBackground];
        // Present Netzwierk UI
        [(AppDelegate*)[[UIApplication sharedApplication] delegate] presentTabBarController];
    }
    
    
    arrPageTitles = @[NSLocalizedString(@"Welcome to VIP Billionaires",nil)];
    arrPageImages =@[@"logo"];
    
    UIImageView * background = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    background.image = [UIImage imageNamed:@"background_splash"];
    background.contentMode = UIViewContentModeScaleToFill;
    [self.view addSubview:background];
    
//    // Create page view controller
//    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
//    
//    self.pageController.dataSource = self;
//    ESPageViewController *startingViewController = [self viewControllerAtIndex:0];
//    NSArray *viewControllers = [NSArray arrayWithObject:startingViewController];
//    [self.pageController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
//    // Change the size of page view controller
//    self.pageController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 80);
//    [self addChildViewController:self.pageController];
//    [self.view addSubview:self.pageController.view];
//    [self.pageController didMoveToParentViewController:self];
//    for (UIView *subview in self.pageController.view.subviews) {
//        if ([subview isKindOfClass:[UIPageControl class]]) {
//            UIPageControl *pageControl = (UIPageControl *)subview;
//            pageControl.pageIndicatorTintColor = [UIColor colorWithWhite:0.9 alpha:0.6];
//            pageControl.currentPageIndicatorTintColor = def_Golden_Color;// [UIColor whiteColor];
//            pageControl.backgroundColor = [UIColor clearColor];
//        }
//    }
    
    UILabel * lblScreenLabel = [[UILabel alloc]init];
    UIImageView * screenImage = [[UIImageView alloc]init];
    screenImage.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:screenImage];
    [self.view addSubview:lblScreenLabel];
    lblScreenLabel.textColor = [UIColor blackColor];
    
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.alignment = NSTextAlignmentCenter;
    
    NSString * strWelcom = NSLocalizedString(@"Welcome to VIP Billionaires",nil);
    NSDictionary *attributes = @{ NSParagraphStyleAttributeName : paragraph,
                                  NSFontAttributeName : lblScreenLabel.font,
                                  NSBaselineOffsetAttributeName : [NSNumber numberWithFloat:0] };
    
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:strWelcom
                                                              attributes:attributes];
    
    lblScreenLabel.attributedText = str;
    
    lblScreenLabel.numberOfLines = 5;
    lblScreenLabel.font = [UIFont fontWithName:@"Montserrat-Light" size:18];
    if (IS_IPHONE6P) {
        lblScreenLabel.font = [UIFont fontWithName:@"Montserrat-Light" size:22];
    }else if (IS_IPHONE6){
        lblScreenLabel.font = [UIFont fontWithName:@"Montserrat-Light" size:20];
    }
    lblScreenLabel.frame = CGRectMake(30, [UIScreen mainScreen].bounds.size.height / 6, [UIScreen mainScreen].bounds.size.width - 60, 120);
    screenImage.image = [UIImage imageNamed:@"logo"];
    screenImage.frame = CGRectMake(0, 0, SCR_W / 3 * 2, SCR_W / 3 * 2 / 741 * 564);
    screenImage.center = CGPointMake(SCR_W/2, SCR_H/2 - 20);
    
    UIImageView* imageViewLogoText = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo_text"]];
    imageViewLogoText.frame = CGRectMake(screenImage.frame.origin.x, screenImage.frame.origin.y + screenImage.frame.size.height, SCR_W / 3 * 2, SCR_W / 3 * 2 / 708 * 64);
    [self.view addSubview:imageViewLogoText];
    
    self.title = @"Welcome";
    self.navigationController.navigationBar.hidden = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];//[UIColor colorWithRed:0.3412 green:0.6902 blue:0.9294 alpha:1];
    self.loginButton = [[UIButton alloc]init];
    [self.view addSubview:self.loginButton];
    
    self.signupButton = [[UIButton alloc]init];
    [self.view addSubview:self.signupButton];
    [self.signupButton setTitle:NSLocalizedString(@"SIGN UP", nil) forState:UIControlStateNormal];
    [self.loginButton setTitle:NSLocalizedString(@"LOGIN", nil) forState:UIControlStateNormal];
    self.loginButton.titleLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:18];
    self.signupButton.titleLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:18];
    [self.loginButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.signupButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    [self.loginButton addTarget:self action:@selector(actionLogin:) forControlEvents:UIControlEventTouchDown];
    [self.signupButton addTarget:self action:@selector(actionRegister:) forControlEvents:UIControlEventTouchDown];
    
    self.loginButton.frame = CGRectMake(20, [UIScreen mainScreen].bounds.size.height / 2700 * 2050, [UIScreen mainScreen].bounds.size.width - 40, [UIScreen mainScreen].bounds.size.height / 2700 * 160);
    self.loginButton.layer.cornerRadius = 25;
    self.signupButton.frame = CGRectMake(20, [UIScreen mainScreen].bounds.size.height / 2700 * 2260, [UIScreen mainScreen].bounds.size.width - 40, [UIScreen mainScreen].bounds.size.height / 2700 * 160);
    self.signupButton.layer.cornerRadius = 25;
    self.signupButton.backgroundColor = [UIColor clearColor]; //def_Golden_Color; //[UIColor colorWithRed:3.0f/255.0f green:201.0f/255.0f blue:169.0f/255.0f alpha:1.0f];
    self.loginButton.backgroundColor = [UIColor clearColor];//[UIColor colorWithRed:189.0f/255.0f green:195.0f/255.0f blue:199.0f/255.0f alpha:1.0f];
    self.loginButton.layer.borderColor = [UIColor blackColor].CGColor; // def_Golden_Color.CGColor;
    self.loginButton.layer.borderWidth = 2.0f;
    self.signupButton.layer.borderColor = [UIColor blackColor].CGColor; // def_Golden_Color.CGColor;
    self.signupButton.layer.borderWidth = 2.0f;
    
}
- (void) viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBar.hidden = YES;
}

#pragma mark - User actions
- (IBAction)actionRegister:(id)sender
{
    
    ESLoginViewController *loginView = [[ESLoginViewController alloc] init];
    loginView.signupView = YES;
    
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:loginView];
    
    navigation.navigationBar.backgroundColor = [UIColor whiteColor];
    navigation.modalPresentationStyle = UIModalPresentationFullScreen;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:navigation animated:YES completion:nil];
    });
}

- (IBAction)actionLogin:(id)sender
{
    ESLoginViewController *loginView = [[ESLoginViewController alloc] init];
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:loginView];
    navigation.navigationBar.backgroundColor = [UIColor whiteColor];
    navigation.modalPresentationStyle = UIModalPresentationFullScreen;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:navigation animated:YES completion:nil];
    });
}
#pragma mark - PageViewController data source and delegate

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSUInteger index = ((ESPageViewController*) viewController).pageIndex;
    if ((index == 0) || (index == NSNotFound))
    {
        return nil;
    }
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSUInteger index = ((ESPageViewController*) viewController).pageIndex;
    if (index == NSNotFound)
    {
        return nil;
    }
    index++;
    if (index == [self.arrPageTitles count])
    {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}
- (ESPageViewController *)viewControllerAtIndex:(NSUInteger)index {
    
    if (([self.arrPageTitles count] == 0) || (index >= [self.arrPageTitles count])) {
        return nil;
    }
    ESPageViewController *pageContentViewController = [[ESPageViewController alloc] initWithNibName:@"ESPageViewController" bundle:nil];
    pageContentViewController.imgFile = self.arrPageImages[index];
    pageContentViewController.txtTitle = self.arrPageTitles[index];
    pageContentViewController.pageIndex = index;
    return pageContentViewController;
}

-(NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [self.arrPageTitles count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}
@end
