//
//  ESPhotoCell.m
//  D'Netzwierk
//
//  Created by Eric Schanet on 6/05/2014.
//  Copyright (c) 2014 Eric Schanet. All rights reserved.
//

#import "ESPhotoCell.h"
#import "ESUtility.h"

@implementation ESPhotoCell
@synthesize mediaItemButton, singleTap, doubleTap, lblDescription;

#pragma mark - NSObject

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier object:(PFObject*)object{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
 
    if (self) {
        // Initialization code
        
        self.object = object;
        self.opaque = NO;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryNone;
        self.clipsToBounds = NO;
        
        self.backgroundColor = [UIColor clearColor];
        
        self.lblDescription = [[UILabel alloc] init];
        self.lblDescription.frame = CGRectMake( 20.0f, 20.0f, [UIScreen mainScreen].bounds.size.width-40, 0);
        self.lblDescription.backgroundColor = [UIColor clearColor];
        self.lblDescription.textColor = [UIColor blackColor];
        self.lblDescription.numberOfLines = 0;
        [self.lblDescription setFont:[UIFont fontWithName:@"Montserrat-Regular" size:15]];

       // self.lblDescription.text = @"Testing app";

        self.lblDescription.lineBreakMode = NSLineBreakByWordWrapping;

        self.imageView.frame = CGRectMake( 20.0f, 0.0f, SCR_W - 40, SCR_W - 40);
        self.imageView.backgroundColor = [UIColor clearColor];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
            
        //self.imageView.contentMode = UIViewContentModeScaleToFill; shweta

        self.mediaItemButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.mediaItemButton.frame = CGRectMake( 20.0f, 0.0f, SCR_W - 40, SCR_W - 40);
        self.mediaItemButton.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.mediaItemButton];
        
        [self.contentView addSubview:self.lblDescription];

        [self.contentView bringSubviewToFront:self.imageView];
        [self.contentView bringSubviewToFront:self.lblDescription];

        singleTap = [[UITapGestureRecognizer alloc] init];
        singleTap.numberOfTapsRequired = 1;
        [self.contentView addGestureRecognizer:singleTap];
        
        doubleTap = [[UITapGestureRecognizer alloc] init];
        doubleTap.numberOfTapsRequired = 2;
        [self.contentView addGestureRecognizer:doubleTap];
        
        [singleTap requireGestureRecognizerToFail:doubleTap];
        
      

    }

    return self;
}


#pragma mark - UIView

- (void)layoutSubviews {
    [super layoutSubviews];
    
    UIImage* cellImage = self.imageView.image;
    CGFloat labelHeight = 0;
    
    NSString *strDsc = [self.object objectForKey:kESEditPhotoViewControllerDescriptionKey];
    strDsc = [strDsc stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (strDsc.length > 0) {
        CGSize labelSize = [strDsc sizeWithFont:[UIFont fontWithName:@"Montserrat-Regular" size:15] constrainedToSize:CGSizeMake(SCR_W - 40, 9999999) lineBreakMode:NSLineBreakByWordWrapping];
        labelHeight = labelSize.height;
    }
    
    CGFloat width, height;
    width = cellImage == nil ? SCR_W - 40 : cellImage.size.width;
    height = cellImage == nil ? SCR_W - 40 : cellImage.size.height;
    
    if (strDsc.length > 0) {
        [self.lblDescription setFrame:CGRectMake(20, 20, SCR_W - 40, labelHeight)];
        [self.imageView setFrame:CGRectMake(20, labelHeight + 40, SCR_W - 40, (SCR_W - 40) * height / width)];
    }
        
    else {
        [self.lblDescription setFrame:CGRectMake(20, 20, SCR_W - 40, labelHeight)];
        [self.imageView setFrame:CGRectMake(20, 20, SCR_W - 40, (SCR_W - 40) * height / width)];
    }
    self.mediaItemButton.frame = self.imageView.frame;
}

@end
