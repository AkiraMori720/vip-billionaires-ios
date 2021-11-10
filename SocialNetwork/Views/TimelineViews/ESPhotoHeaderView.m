//
//  ESPhotoHeaderView.m
//  D'Netzwierk
//
//  Created by Eric Schanet on 6/05/2014.
//  Copyright (c) 2014 Eric Schanet. All rights reserved.
//

#import "ESPhotoHeaderView.h"
#import "ESProfileImageView.h"
#import "TTTTimeIntervalFormatter.h"
#import "ESUtility.h"

@interface ESPhotoHeaderView ()
/**
 *  Containing all the subviews of the header
 */
@property (nonatomic, strong) UIView *containerView;
/**
 *  Imageview of the profile picture
 */
@property (nonatomic, strong) ESProfileImageView *avatarImageView;
/**
 *  Button with the user's name as title. If a user taps on it, he is taken to the user's profile page
 */
@property (nonatomic, strong) UIButton *userButton;

@property (nonatomic, strong) UIView* graySeparatorView;
/**
 *  Used to report a photo
 */
@property (nonatomic, strong) UIButton *reportButton;
/**
 *  Indicating when the photo has been taken
 */
@property (nonatomic, strong) UILabel *timestampLabel;
/**
 *  Indicating where the photo has been taken
 */
@property (nonatomic, strong) UILabel *geostampLabel;
/**
 *  Helping us to create the timeStampLabel
 */
@property (nonatomic, strong) TTTTimeIntervalFormatter *timeIntervalFormatter;
@end


@implementation ESPhotoHeaderView
@synthesize containerView;
@synthesize avatarImageView;
@synthesize userButton;
@synthesize reportButton;
@synthesize timestampLabel, geostampLabel;
@synthesize timeIntervalFormatter;
@synthesize photo;
@synthesize buttons;
@synthesize likeButton;
@synthesize commentButton;
@synthesize delegate;
@synthesize clockView, locationView;

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame buttons:(ESPhotoHeaderButtons)otherButtons {
    self = [super initWithFrame:frame];
    if (self) {
        [ESPhotoHeaderView validateButtons:otherButtons];
        buttons = otherButtons;
        
        self.clipsToBounds = NO;
        self.containerView.clipsToBounds = NO;
        self.superview.clipsToBounds = NO;
        [self setBackgroundColor:[UIColor clearColor]];
        
        // translucent portion
        self.containerView = [[UIView alloc] initWithFrame:CGRectMake( 0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, self.bounds.size.height)];
        [self addSubview:self.containerView];
        
        [self.containerView setOpaque:NO];
        self.opaque = NO;
        [self.containerView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0]];
        [self setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0]];
        self.superview.opaque = NO;
        
//        UIImageView *containerImage = [[UIImageView alloc]initWithImage:nil];
//        containerImage.backgroundColor = [UIColor whiteColor];
//        [containerImage setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44)];
//        [self.containerView addSubview:containerImage];
        self.graySeparatorView = [[UIView alloc] init];
        [self.containerView addSubview:self.graySeparatorView];
        
        
        self.avatarImageView = [[ESProfileImageView alloc] init];
        self.avatarImageView.frame = CGRectMake( 20.0f, 0.0f, 42.0f, 42.0f);
        avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
        avatarImageView.layer.cornerRadius = 21;
        avatarImageView.layer.masksToBounds = YES;
        [self.avatarImageView.profileButton addTarget:self action:@selector(didTapUserButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.containerView addSubview:self.avatarImageView];
        clockView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"clockIcon"]];
        locationView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"locationIcon"]];
//        [self.containerView addSubview:clockView];
        [self.containerView addSubview:locationView];
        
        if (self.buttons & ESPhotoHeaderButtonsUser) {
            // This is the user's display name, on a button so that we can tap on it
            self.userButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [containerView addSubview:self.userButton];
            [self.userButton setBackgroundColor:[UIColor clearColor]];
            [[self.userButton titleLabel] setFont:[UIFont fontWithName:@"Montserrat-Regular" size:15]];
            [self.userButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//            [self.userButton setTitleColor:def_Golden_Color8 forState:UIControlStateHighlighted];
            [[self.userButton titleLabel] setLineBreakMode:NSLineBreakByTruncatingTail];
            [[self.userButton titleLabel] setShadowOffset:CGSizeMake( 0.0f, .5f)];
            [self.userButton setTitleShadowColor:[UIColor colorWithWhite:1.0f alpha:0.750f] forState:UIControlStateNormal];
            
        }
        
        self.timeIntervalFormatter = [[TTTTimeIntervalFormatter alloc] init];
        self.timeIntervalFormatter.usesAbbreviatedCalendarUnits = YES;
        
        // timestamp
        self.timestampLabel = [[UILabel alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 108, 25.0f, 50, 18.0f)];
        self.timestampLabel.textAlignment = NSTextAlignmentRight;
        [containerView addSubview:self.timestampLabel];
        [self.timestampLabel setTextColor:[UIColor blackColor]];
        [self.timestampLabel setShadowColor:[UIColor colorWithWhite:1.0f alpha:0.750f]];
        [self.timestampLabel setShadowOffset:CGSizeMake( 0.0f, .5f)];
        [self.timestampLabel setFont:[UIFont fontWithName:@"Montserrat-Regular" size:12]];
        [self.timestampLabel setBackgroundColor:[UIColor clearColor]];
        [clockView setFrame:CGRectMake(self.timestampLabel.frame.origin.x + self.timestampLabel.frame.size.width + 1, self.timestampLabel.frame.origin.y + 3, 12, 12)];
        
        // geostamp
        self.geostampLabel = [[UILabel alloc] init];
//        [containerView addSubview:self.geostampLabel];
        [self.geostampLabel setTextColor:def_Golden_Color];
        [self.geostampLabel setShadowColor:[UIColor colorWithWhite:1.0f alpha:0.750f]];
        [self.geostampLabel setShadowOffset:CGSizeMake( 0.0f, .5f)];
        [self.geostampLabel setFont:[UIFont fontWithName:@"Montserrat-Light" size:11]];
        [self.geostampLabel setBackgroundColor:[UIColor clearColor]];
        
        self.editButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.editButton setFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 40, 7.0f, 30 , 26.0f)];
        [self.editButton setImage:[UIImage imageNamed:@"more"] forState:UIControlStateNormal];
        self.editButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.containerView addSubview:self.editButton];
    }
    
    return self;
}


#pragma mark - ESPhotoHeaderView

- (void)setPhoto:(PFObject *)aPhoto {
    
    photo = aPhoto;
    
    // user's avatar
    PFUser *user = [self.photo objectForKey:kESPhotoUserKey];
    PFFile *profilePictureSmall;// = [user objectForKey:kESUserProfilePicSmallKey];
    
    if([user objectForKey:kESUserProfilePicSmallKey])
    {
        profilePictureSmall = [user objectForKey:kESUserProfilePicSmallKey];
        
    }
    else
    {
        profilePictureSmall = [user objectForKey:kESUserProfilePicMediumKey];
        
    }
    [self.avatarImageView setFile:profilePictureSmall];
    CGPoint userButtonPoint = CGPointMake(59.0f, 0.0f);
    NSString *authorName = [user objectForKey:kESUserDisplayNameKey];
    [self.userButton setTitle:authorName forState:UIControlStateNormal];
    
    //check for timestamp
    if ([self.photo objectForKey:kESPhotoLocationKey]) {
        NSString *locality = [NSString stringWithFormat:@"%@", [self.photo objectForKey:kESPhotoLocationKey]];
        [self.geostampLabel setText:locality];
        locationView.hidden = NO;
        
    }
    else {
        [self.geostampLabel setText:@""];
        userButtonPoint = CGPointMake(50.0f, 3.0f);
        locationView.hidden = YES;
        
    }
    CGFloat constrainWidth = containerView.bounds.size.width;
    
    //associate the methods to the buttons
    if (self.buttons & ESPhotoHeaderButtonsUser) {
        [self.userButton addTarget:self action:@selector(didTapUserButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    // we resize the button to fit the user's name to avoid having a huge touch area
    constrainWidth -= userButtonPoint.x;
    CGSize constrainSize = CGSizeMake(constrainWidth, containerView.bounds.size.height - userButtonPoint.y*2.0f);
    
    CGSize userButtonSize = [self.userButton.titleLabel.text boundingRectWithSize:constrainSize
                                                                          options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin
                                                                       attributes:@{NSFontAttributeName:self.userButton.titleLabel.font}
                                                                          context:nil].size;
    
    CGRect userButtonFrame = CGRectMake(userButtonPoint.x + 26, userButtonPoint.y + self.topMargin, userButtonSize.width, userButtonSize.height);
    CGRect usernameButtonFrame = CGRectMake(userButtonPoint.x + 26, userButtonPoint.y + self.topMargin, [UIScreen mainScreen].bounds.size.width / 2, userButtonSize.height);
    CGRect geostampLabelFrame = CGRectMake(userButtonPoint.x + 26, userButtonPoint.y + userButtonFrame.size.height + self.topMargin, containerView.bounds.size.width - 50.0f - 72.0f, 18);
    [self.userButton setFrame:userButtonFrame];
    self.userButton.titleLabel.textAlignment = NSTextAlignmentLeft;
    [self.geostampLabel setFrame:geostampLabelFrame];
    self.timestampLabel.textAlignment = NSTextAlignmentLeft;
    [locationView setFrame:CGRectMake(userButtonPoint.x, self.geostampLabel.frame.origin.y+2, 12, 12)];
    
    NSTimeInterval timeInterval = [[self.photo createdAt] timeIntervalSinceNow];
    NSString *timestamp = [self.timeIntervalFormatter stringForTimeInterval:timeInterval];
    [self.timestampLabel setText: [NSString stringWithFormat:NSLocalizedString(@"%@ ago", nil), timestamp]];
    usernameButtonFrame.origin.y += 20;
    timestampLabel.textAlignment = NSTextAlignmentLeft;
    timestampLabel.frame = usernameButtonFrame;
    timestampLabel.textColor = [UIColor colorWithWhite:0 alpha:0.3];
    
    CGRect avatarRect = self.avatarImageView.frame;
    avatarRect.origin.y = self.topMargin;
    self.avatarImageView.frame = avatarRect;
    avatarRect = self.editButton.frame;
    avatarRect.origin.y = self.topMargin + 7;
    avatarImageView.layer.cornerRadius = avatarRect.size.width / 2;
    self.editButton.frame = avatarRect;
    
    if (self.topMargin == 21) {
        self.graySeparatorView.frame = CGRectMake(-1, 0, SCR_W + 2, 8);
        self.graySeparatorView.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1];
    } else
        self.graySeparatorView.frame = CGRectMake(-1, 0, SCR_W + 2, 0);
    
    [self setNeedsDisplay];
    
    
}


#pragma mark - ()

+ (void)validateButtons:(ESPhotoHeaderButtons)buttons {
    if (buttons == ESPhotoHeaderButtonsNone) {
        [NSException raise:NSInvalidArgumentException format:@"Buttons must be set before initializing ESPhotoHeaderView."];
    }
}

- (void)didTapUserButtonAction:(UIButton *)sender {
    if (delegate && [delegate respondsToSelector:@selector(photoHeaderView:didTapUserButton:user:)]) {
        [delegate photoHeaderView:self didTapUserButton:sender user:[self.photo objectForKey:kESPhotoUserKey]];
    }
}


@end
