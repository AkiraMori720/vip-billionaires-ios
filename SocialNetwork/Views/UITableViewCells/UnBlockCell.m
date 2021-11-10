//
//  ESFindFriendsCell.m
//  D'Netzwierk
//
//  Created by Eric Schanet on 6/05/2014.
//  Copyright (c) 2014 Eric Schanet. All rights reserved.
//

#import "UnBlockCell.h"
#import "ESProfileImageView.h"
#import "ESConstants.h"

@interface UnBlockCell()
/**
 *  Button containing the display name of a user
 */
@property (nonatomic, strong) UIButton *nameButton;
/**
 *  Button that is floating above the actual profile picture to catch taps
 */
@property (nonatomic, strong) UIButton *avatarImageButton;
/**
 *  Actual profile picture of a user, not sensitive to taps
 */
@property (nonatomic, strong) ESProfileImageView *avatarImageView;

@end


@implementation UnBlockCell
@synthesize delegate;
@synthesize user;
@synthesize avatarImageView;
@synthesize avatarImageButton;
@synthesize nameButton;
@synthesize photoLabel;
@synthesize unBlockButton;
@synthesize app;
@synthesize flag;


#pragma mark - NSObject

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.avatarImageView = [[ESProfileImageView alloc] init];
        self.avatarImageView.frame = CGRectMake( 10.0f, 14.0f, 40.0f, 40.0f);
        avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
        avatarImageView.layer.cornerRadius = 20;
        avatarImageView.layer.masksToBounds = YES;
        [self.contentView addSubview:self.avatarImageView];
        
        self.avatarImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.avatarImageButton.backgroundColor = [UIColor clearColor];
        self.avatarImageButton.frame = CGRectMake( 10.0f, 14.0f, 40.0f, 40.0f);
        [self.avatarImageButton addTarget:self action:@selector(didTapUserButtonAction:)
                         forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.avatarImageButton];
        
        self.nameButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.nameButton.backgroundColor = [UIColor clearColor];
        self.nameButton.titleLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:16.0f];
        self.nameButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.nameButton setTitleColor:def_Golden_Color
                              forState:UIControlStateNormal];
        [self.nameButton setTitleColor:def_Golden_Color
                              forState:UIControlStateHighlighted];
        [self.nameButton.titleLabel setShadowOffset:CGSizeMake( 0.0f, 1.0f)];
        [self.nameButton addTarget:self action:@selector(didTapUserButtonAction:)
                  forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.nameButton];
        
        self.photoLabel = [[UILabel alloc] init];
        self.photoLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:11.0f];
        self.photoLabel.textColor = def_Golden_Color8;
        self.photoLabel.backgroundColor = [UIColor clearColor];
        self.photoLabel.shadowOffset = CGSizeMake( 0.0f, 1.0f);
        [self.contentView addSubview:self.photoLabel];
        
        self.unBlockButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.unBlockButton.titleLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:15.0f];
        self.unBlockButton.titleEdgeInsets = UIEdgeInsetsMake( 0.0f, 10.0f, 0.0f, 0.0f);
        [self.unBlockButton setBackgroundImage:[UIImage imageNamed:@"ButtonFollowing.png"]
                                     forState:UIControlStateNormal];
        [self.unBlockButton setBackgroundImage:[UIImage imageNamed:@"ButtonFollow.png"]
                                     forState:UIControlStateSelected];
        
        [self.unBlockButton setImage:[UIImage imageNamed:@"IconTick"]
                           forState:UIControlStateSelected];
        
        [self.unBlockButton setTitle:NSLocalizedString(@"Block  ", @"Follow string, with spaces added for centering")
                           forState:UIControlStateNormal];
        [self.unBlockButton setTitle:NSLocalizedString(@"UnBlock", nil)
                           forState:UIControlStateSelected];
        
        [self.unBlockButton setTitleColor:[UIColor blackColor]
                                forState:UIControlStateNormal];
        
        [self.unBlockButton setTitleColor:def_Golden_Color
                                forState:UIControlStateSelected];
        
        [self.unBlockButton setTitleShadowColor:[UIColor clearColor]
                                      forState:UIControlStateNormal];
        [self.unBlockButton setTitleShadowColor:[UIColor clearColor]
                                      forState:UIControlStateSelected];
        self.unBlockButton.titleLabel.shadowOffset = CGSizeMake( 0.0f, -1.0f);
        
       // [self.unBlockButton addTarget:self action:@selector(didTapFollowButtonAction:) forControlEvents:UIControlEventTouchUpInside]; shweta
        
        [self.contentView addSubview:self.unBlockButton];
        
        app=[UIApplication sharedApplication].delegate;
        flag=false;
        
    }
    return self;
}


#pragma mark - ESFindFriendsCell

- (void)setUser:(PFUser *)aUser {
    user = aUser;
    
    
    if (![self.user objectForKey:kESUserProfilePicMediumKey] && ![self.user objectForKey:kESUserProfilePicSmallKey]) {
        NSData* data = UIImageJPEGRepresentation([UIImage imageNamed:@"AvatarPlaceholder.png"], 0.5f);
        PFFile *imageFile = [PFFile fileWithName:@"AvatarPlaceholder.png" data:data];
        [self.avatarImageView setFile:imageFile];
    }
    else {
        // [self.avatarImageView setFile:[self.user objectForKey:kESUserProfilePicSmallKey]];
        
        if([self.user objectForKey:kESUserProfilePicSmallKey])
        {
            [self.avatarImageView setFile:[self.user objectForKey:kESUserProfilePicSmallKey]];
            
        }
        else
        {
            [self.avatarImageView setFile:[self.user objectForKey:kESUserProfilePicMediumKey]];
            
        }
        
    }
    
    // Configure the cell
    /*if (![self.user objectForKey:kESUserProfilePicSmallKey]) {
        NSData* data = UIImageJPEGRepresentation([UIImage imageNamed:@"AvatarPlaceholder.png"], 0.5f);
        PFFile *imageFile = [PFFile fileWithName:@"AvatarPlaceholder.png" data:data];
        [self.avatarImageView setFile:imageFile];
    }
    else {
        //[self.avatarImageView setFile:[self.user objectForKey:kESUserProfilePicSmallKey]];
        
        if([self.user objectForKey:kESUserProfilePicSmallKey])
        {
            [self.avatarImageView setFile:[self.user objectForKey:kESUserProfilePicSmallKey]];
            
        }
        else
        {
            [self.avatarImageView setFile:[self.user objectForKey:kESUserProfilePicMediumKey]];
            
        }
        
    }*/
    
    // Set name
    NSString *nameString = [self.user objectForKey:kESUserDisplayNameKey];
    
    CGSize nameSize = [nameString boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width/2, CGFLOAT_MAX)
                                               options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin
                                            attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Montserrat-Bold" size:16.0f]}
                                               context:nil].size;
    [nameButton setTitle:[self.user objectForKey:kESUserDisplayNameKey] forState:UIControlStateNormal];
    [nameButton setTitle:[self.user objectForKey:kESUserDisplayNameKey] forState:UIControlStateHighlighted];
    
    [nameButton setFrame:CGRectMake( 60.0f, 20.0f, nameSize.width, nameSize.height)];
    
    // Set photo number label
    CGSize photoLabelSize = [@"photos" boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width/2, CGFLOAT_MAX)
                                                    options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin
                                                 attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Montserrat-Regular" size:11.0f]}
                                                    context:nil].size;
    [photoLabel setFrame:CGRectMake( 60.0f, 17.0f + nameSize.height, 140.0f, photoLabelSize.height)];
    
    // Set follow button
    [unBlockButton setFrame:CGRectMake( [UIScreen mainScreen].bounds.size.width - 120, 20.0f, 103.0f, 32.0f)];
}

#pragma mark - ()

+ (CGFloat)heightForCell {
    return 67.0f;
}

/* Inform delegate that a user image or name was tapped */
//- (void)didTapUserButtonAction:(id)sender {
//    if (self.delegate && [self.delegate respondsToSelector:@selector(cell:didTapUserButton:)]) {
//        [self.delegate cell:self didTapUserButton:self.user];
//    }
//}

/* Inform delegate that the follow button was tapped */
- (void)didTapFollowButtonAction:(id)sender {
    
    NSString * us= [self.user objectId];
    
    if (!flag) {
        [sender setTitle:NSLocalizedString(@"UnBlock", nil)
                forState:UIControlStateNormal];
        [sender setTintColor:[UIColor blackColor]];
        [sender setBackgroundImage:[UIImage imageNamed:@"ButtonFollow.png"]
                                      forState:UIControlStateNormal];
        [sender setTitleColor:def_Golden_Color
                     forState:UIControlStateNormal];
        
        [app.unblockUserArray addObject:us];
    }
    else
    {
        [sender setTitle:NSLocalizedString(@"Block", nil)
                forState:UIControlStateNormal];
        [sender setBackgroundImage:[UIImage imageNamed:@"ButtonFollowing.png"]
                                      forState:UIControlStateNormal];
        [sender setTitleColor:[UIColor blackColor]
                     forState:UIControlStateNormal];
        [app.unblockUserArray removeObject:us];
    }
    flag=!flag;

}

@end
