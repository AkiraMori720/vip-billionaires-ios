//
//  ESPhotoFooterView.m
//  d'Netzwierk
//
//  Created by Eric Schanet on 17.06.14.
//
//

#import "ESPhotoFooterView.h"
#import "ESProfileImageView.h"
#import "TTTTimeIntervalFormatter.h"
#import "ESUtility.h"
#import "ESConstants.h"

@interface ESPhotoFooterView (){
    
}
/**
 *  Containerview of the footer
 */
@property (nonatomic, strong) UIView *containerView2;
/**
 *  ImageView of the user's profile picture
 */
@property (nonatomic, strong) ESProfileImageView *avatarImageView;
/**
 *  Button with the username as title
 */
@property (nonatomic, strong) UIButton *userButton;
/**
 *  A timestamp indicating when the photo has been uploaded
 */
@property (nonatomic, strong) UILabel *timestampLabel;
/**
 *  Formatter used to create standardized time stamps
 */
@property (nonatomic, strong) TTTTimeIntervalFormatter *timeIntervalFormatter;
@end


@implementation ESPhotoFooterView
@synthesize containerView2;
@synthesize avatarImageView;
@synthesize userButton;
@synthesize timestampLabel;
@synthesize timeIntervalFormatter;
@synthesize photo;
@synthesize buttons;
@synthesize likeButton;
@synthesize commentButton;
@synthesize delegate;
@synthesize labelButton;
@synthesize labelComment;
@synthesize likeImage;
@synthesize shareButton;
@synthesize commentLikeButton;

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame buttons:(ESPhotoFooterButtons)otherButtons {
    self = [super initWithFrame:frame];
    if (self) {
        [ESPhotoFooterView validateButtons:otherButtons];
        buttons = otherButtons;
        UIView *grayLine = [[UIView alloc] initWithFrame:CGRectMake(40, 26, [UIScreen mainScreen].bounds.size.width - 80, 0.5)];
        grayLine.backgroundColor = [UIColor colorWithWhite:221.0/256 alpha:1];
        UIView *grayBackgroundView = [[UIView alloc]initWithFrame: CGRectMake(20, 0, [UIScreen mainScreen].bounds.size.width - 40, self.bounds.size.height)];
        grayBackgroundView.backgroundColor = [UIColor colorWithWhite:245.0 / 255 alpha:1];
        CGRect rt =grayBackgroundView.frame;
        rt.size.height =59;
        grayBackgroundView.frame = rt;
        [self addSubview:grayBackgroundView];
        [self addSubview:grayLine];
        self.clipsToBounds = NO;
        self.containerView2.clipsToBounds = NO;
        self.superview.clipsToBounds = NO;
        [self setBackgroundColor:[UIColor clearColor]];
        
        // translucent portion
        self.containerView2 = [[UIView alloc] initWithFrame:CGRectMake( 0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, self.bounds.size.height)];
        [self addSubview:self.containerView2];

        [self.containerView2 setOpaque:NO];
        self.opaque = NO;
        [self.containerView2 setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0]];
        [self setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0]];
        self.superview.opaque = NO;
        
        UIImageView *straightLine = [[UIImageView alloc]initWithImage:nil];
        straightLine.backgroundColor = [UIColor colorWithRed:50.0f/255.0f green:80.0f/255.0f blue:114.0f/255 alpha:1.0f];
        [straightLine setFrame:CGRectMake(5, 70, 310, 1)];
        straightLine.layer.cornerRadius = 3;
        straightLine.alpha = 0.0;
        [self.containerView2 addSubview:straightLine];
        
    
        shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [containerView2 addSubview:self.shareButton];
        [self.shareButton setFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 110.0f, 35.0f, 69.0f, 20.0f)];
        self.shareButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [self.shareButton setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.0f]];
        [self.shareButton setImageEdgeInsets:UIEdgeInsetsMake(0.0f,0.0f, 0.0f, 0.0f)];
        [self.shareButton setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
        [self.shareButton setSelected:NO];
        [self.shareButton addTarget:nil action:@selector(shareButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        self.shareButton.layer.cornerRadius = 3;
        [self.shareButton setHidden:YES];
        if (self.buttons & ESPhotoFooterButtonsComment) {
            // comments button
            commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [containerView2 addSubview:self.commentButton];
            [self.commentButton setFrame:
             CGRectMake([UIScreen mainScreen].bounds.size.width - 130.0f, 35.0f, 90.0f, 20.0f)
             /*CGRectMake( [UIScreen mainScreen].bounds.size.width / 2 - 45, 36.0f, 90.0f, 20.0f)*/];
            [self.commentButton setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.0f]];
            self.commentButton.layer.cornerRadius = 3;
            [self.commentButton setTitle:@"" forState:UIControlStateNormal];
            [self.commentButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
            [self.commentButton setTitleShadowColor:[UIColor clearColor] forState:UIControlStateNormal];
            [self.commentButton setTitleEdgeInsets:UIEdgeInsetsMake( 0.0f, 0.0f, 0.0f, 0.0f)];
            [self.commentButton setImageEdgeInsets:UIEdgeInsetsMake(0.0f,0.0f, 0.0f, 0.0f)];
            [[self.commentButton titleLabel] setShadowOffset:CGSizeMake( 0.0f, 1.0f)];
            [[self.commentButton titleLabel] setFont:[UIFont fontWithName:@"Montserrat-Regular" size:12.0f]];
            [[self.commentButton titleLabel] setMinimumScaleFactor:0.8f];
            [[self.commentButton titleLabel] setAdjustsFontSizeToFitWidth:YES];
            [self.commentButton setImage:[UIImage imageNamed:@"comment"] forState:UIControlStateNormal];
            [self.commentButton setSelected:NO];
            
            labelComment = [UIButton buttonWithType:UIButtonTypeCustom];
            [containerView2 addSubview:self.labelComment];
            self.labelComment.titleLabel.textAlignment = NSTextAlignmentRight;
            [self.labelComment setFrame:CGRectMake( [[UIScreen mainScreen] bounds].size.width / 2, 0.0f, [[UIScreen mainScreen] bounds].size.width / 2 - 40, 29.0f)];
            [self.labelComment setBackgroundColor:[UIColor clearColor]];
            [self.labelComment setTitle:[NSString stringWithFormat:@"0 %@", NSLocalizedString(@"comments", nil)] forState:UIControlStateNormal];
            [self.labelComment setTitleColor:[UIColor colorWithWhite:0.5 alpha:1] forState:UIControlStateNormal];
            [self.labelComment setTitleEdgeInsets:UIEdgeInsetsMake( 0.0f, 0.0f, 0.0f, 0.0f)];
            [[self.labelComment titleLabel] setFont:[UIFont fontWithName:@"Montserrat-Light" size:12]];
            [[self.labelComment titleLabel] setMinimumScaleFactor:0.8f];
            [[self.labelComment titleLabel] setAdjustsFontSizeToFitWidth:NO];
            self.labelComment.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
            
        }
        
        if (self.buttons & ESPhotoFooterButtonsLike) {
            // like button
            UIImage *image = [UIImage imageNamed:@"like"];
            UIImage *image2 = [UIImage imageNamed:@"like_selected"];
            
            likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
            labelButton = [UIButton buttonWithType:UIButtonTypeCustom];
            likeImage = [UIButton buttonWithType:UIButtonTypeCustom];
            [containerView2 addSubview:self.labelButton];
            [containerView2 addSubview:self.likeImage];
            [containerView2 addSubview:self.likeButton];
            
            [self.likeButton setFrame:CGRectMake(40.0f, 35.0f, 56.0f, 20.0f)];
            
            [self.labelButton setFrame:CGRectMake(48.0f, 0.0f, 60.0f, 29.0f)];
//            [self.labelButton setHidden:YES];
            [self.likeImage setFrame:CGRectMake(40, 0.0f, 44, 29.0f)];

            [self.labelButton setBackgroundColor:[UIColor clearColor]];
            [self.likeImage setBackgroundColor:[UIColor clearColor]];
            [self.likeButton setTitle:@"" forState:UIControlStateNormal];
            [self.labelButton setTitle:NSLocalizedString(@"likes", nil) forState:UIControlStateNormal];
            [self.likeImage setTitle:@"0" forState:UIControlStateNormal];
            [self.likeButton setTitleColor:[UIColor colorWithWhite:0.5 alpha:1] forState:UIControlStateNormal];
            [self.labelButton setTitleColor:[UIColor colorWithWhite:0.5 alpha:1] forState:UIControlStateNormal];
            [self.likeImage setTitleColor:[UIColor colorWithWhite:0.5 alpha:1] forState:UIControlStateNormal];
            [self.likeButton setTitleShadowColor:[UIColor clearColor] forState:UIControlStateNormal];
            [self.labelButton setTitleShadowColor:[UIColor clearColor] forState:UIControlStateNormal];
            [self.likeImage setTitleShadowColor:[UIColor clearColor] forState:UIControlStateNormal];
            [self.likeButton setTitleShadowColor:[UIColor clearColor] forState:UIControlStateSelected];
            [self.labelButton setTitleShadowColor:[UIColor clearColor] forState:UIControlStateSelected];
            [self.likeImage setTitleShadowColor:[UIColor clearColor] forState:UIControlStateSelected];
            [self.likeButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
            [self.likeButton setImageEdgeInsets:UIEdgeInsetsMake(0.0f,0.0f, 0.0f, 0.0f)];
            [self.likeImage setImageEdgeInsets:UIEdgeInsetsMake(0.0f,0.0f, 0.0f, 0.0f)];
            self.labelButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            self.likeImage.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            self.likeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
            [self.labelButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0f,0.0f, 0.0f, 0.0f)];
            [self.likeImage setTitleEdgeInsets:UIEdgeInsetsMake(0.0f,0.0f, 0.0f, 0.0f)];
            [[self.likeButton titleLabel] setShadowOffset:CGSizeMake(0.0f, 0.0f)];
            [[self.labelButton titleLabel] setShadowOffset:CGSizeMake(0.0f, 0.0f)];
            [[self.likeImage titleLabel] setShadowOffset:CGSizeMake(0.0f, 0.0f)];
            [[self.likeButton titleLabel] setFont:[UIFont fontWithName:@"Montserrat-Light" size:12]];
            [[self.labelButton titleLabel] setFont:[UIFont fontWithName:@"Montserrat-Light" size:12]];
            [[self.likeImage titleLabel] setFont:[UIFont fontWithName:@"Montserrat-Light" size:12]];
            [[self.likeButton titleLabel] setMinimumScaleFactor:0.8f];
            [[self.labelButton titleLabel] setMinimumScaleFactor:0.8f];
            [[self.likeImage titleLabel] setMinimumScaleFactor:0.8f];
            [[self.likeButton titleLabel] setAdjustsFontSizeToFitWidth:YES];
            [[self.labelButton titleLabel] setAdjustsFontSizeToFitWidth:YES];
            [[self.likeImage titleLabel] setAdjustsFontSizeToFitWidth:YES];
            [self.likeButton setAdjustsImageWhenHighlighted:NO];
            [self.labelButton setAdjustsImageWhenHighlighted:NO];
            [self.likeImage setAdjustsImageWhenHighlighted:NO];
            [self.likeButton setAdjustsImageWhenDisabled:NO];
            [self.labelButton setAdjustsImageWhenDisabled:NO];
            [self.likeImage setAdjustsImageWhenDisabled:NO];
            [self.likeButton setImage:image forState:UIControlStateNormal];
            [self.likeButton setImage:image2 forState:UIControlStateSelected];
            [self.likeButton setSelected:NO];
            [self.labelButton setSelected:NO];
        }
    
        commentLikeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [containerView2 addSubview:self.commentLikeButton];
        [self.commentLikeButton setFrame:CGRectMake(10, 3, 140, 20)];
        [self.commentLikeButton setBackgroundColor:[UIColor clearColor]];
        [self.commentLikeButton addTarget:self action:@selector(didTapCommentOnPhotoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        UIView * footerLine = [[UIView alloc]initWithFrame:CGRectMake(20, self.frame.size.height - 1, SCR_W - 40, 0.5)];
        footerLine.backgroundColor = def_Golden_Color;
//        [self addSubview:footerLine];
        
        self.likeButton.layer.borderWidth = 0.0f;
        self.likeButton.backgroundColor = [UIColor clearColor];// def_GoldenDark_Color;
        self.likeButton.layer.cornerRadius = 3;
        
        shareButton.backgroundColor = [UIColor clearColor];// def_GoldenDark_Color;
        shareButton.layer.borderWidth = 0.0f;
        
        commentButton.backgroundColor = [UIColor clearColor];// def_GoldenDark_Color;
        commentButton.layer.borderWidth = 0.0f;
    }
    
    return self;
}


#pragma mark - ESPhotoFooterView

- (void)setPhoto:(PFObject *)aPhoto {
    
    photo = aPhoto;
    
    [self.shareButton addTarget:self action:@selector(didTapSharePhotoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    CGFloat constrainWidth = containerView2.bounds.size.width;
    
    if (self.buttons & ESPhotoFooterButtonsComment) {
        constrainWidth = self.commentButton.frame.origin.x;
        [self.commentButton addTarget:self action:@selector(didTapCommentOnPhotoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (self.buttons & ESPhotoFooterButtonsLike) {
        constrainWidth = self.likeButton.frame.origin.x;
        [self.likeButton addTarget:self action:@selector(didTapLikePhotoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [self setNeedsDisplay];
}

- (void)setLikeStatus:(BOOL)liked {
    [self.likeButton setSelected:liked];
    
    if (liked) {
        //        [self.likeButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
        [[self.likeButton titleLabel] setShadowOffset:CGSizeMake(0.0f, -1.0f)];
    } else {
        //        [self.likeButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
        [[self.likeButton titleLabel] setShadowOffset:CGSizeMake(0.0f, 1.0f)];
    }
}

- (void)shouldEnableLikeButton:(BOOL)enable {

    if (enable) {
        [self.likeButton removeTarget:self action:@selector(didTapLikePhotoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [self.likeButton addTarget:self action:@selector(didTapLikePhotoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
}
- (void)shouldReEnableLikeButton:(NSNumber*)enable {

    if (enable == [NSNumber numberWithInt:1]) {
        self.likeButton.userInteractionEnabled = YES;
    } else {
        self.likeButton.userInteractionEnabled = NO;
    }
}
- (void)shareButtonTapped {

}

#pragma mark - ()

+ (void)validateButtons:(ESPhotoFooterButtons)buttons {
    if (buttons == ESPhotoFooterButtonsNone) {
        [NSException raise:NSInvalidArgumentException format:@"Buttons must be set before initializing ESPhotoFooterView."];
    }
}

- (void)didTapLikePhotoButtonAction:(UIButton *)button {
    if (delegate && [delegate respondsToSelector:@selector(photoFooterView:didTapLikePhotoButton:photo:)]) {
        [delegate photoFooterView:self didTapLikePhotoButton:button photo:self.photo];
    }
}

- (void)didTapCommentOnPhotoButtonAction:(UIButton *)sender {
    if (delegate && [delegate respondsToSelector:@selector(photoFooterView:didTapCommentOnPhotoButton:photo:)]) {
        [delegate photoFooterView:self didTapCommentOnPhotoButton:sender photo:self.photo];
    }
}
- (void)didTapSharePhotoButtonAction:(UIButton *)sender {
    if (delegate && [delegate respondsToSelector:@selector(photoFooterView:didTapSharePhotoButton:photo:)]) {
        [delegate photoFooterView:self didTapSharePhotoButton:sender photo:self.photo];
    }
}

-(void)layoutSubviews {
    [super layoutSubviews];
    NSString* likeText =[self.likeImage titleForState:UIControlStateNormal];
    CGSize size = [likeText sizeWithAttributes:@{NSFontAttributeName: self.likeImage.titleLabel.font}];
    [self.labelButton setFrame:CGRectMake(44.0f + size.width, 0.0f, 60.0f, 29.0f)];
    //            [self.labelButton setHidden:YES];
}
@end

