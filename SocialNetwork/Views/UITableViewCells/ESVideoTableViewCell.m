//
//  ESVideoTableViewCell.m
//  d'Netzwierk
//
//  Created by Eric Schanet on 07.12.14.
//
//

#import "ESVideoTableViewCell.h"

@implementation ESVideoTableViewCell
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
        
       /* self.imageView.frame = CGRectMake( 20.0f, 20.0f, [UIScreen mainScreen].bounds.size.width-40, [UIScreen mainScreen].bounds.size.width-40);
        self.imageView.backgroundColor = [UIColor blackColor];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;*/
        
        self.lblDescription = [[UILabel alloc] init];
        self.lblDescription.frame = CGRectMake( 20.0f, 20.0f, [UIScreen mainScreen].bounds.size.width-40, 30);
        self.lblDescription.backgroundColor = [UIColor clearColor];
        self.lblDescription.textColor = [UIColor blackColor];
        self.lblDescription.numberOfLines = 0;
        [self.lblDescription setFont:[UIFont fontWithName:@"Montserrat-Regular" size:15]];
        // self.lblDescription.text = @"Testing app";
        [self.lblDescription setBackgroundColor:[UIColor clearColor]];
        self.lblDescription.lineBreakMode = NSLineBreakByWordWrapping;
        
        self.imageView.frame = CGRectMake( 20.0f, 20.0f, [UIScreen mainScreen].bounds.size.width-40, [UIScreen mainScreen].bounds.size.width-40);
        self.imageView.backgroundColor = [UIColor blackColor];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        self.movie = [[AVPlayerViewController alloc] init];
        self.movie.videoGravity = AVLayerVideoGravityResizeAspect;
        self.movie.view.frame = self.imageView.frame;
        self.movie.view.hidden = true;
        [self.contentView addSubview:self.movie.view];
        [self.contentView bringSubviewToFront:self.imageView];
        
        self.mediaItemButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.mediaItemButton.frame = CGRectMake( 20.0f, 20.0f, [UIScreen mainScreen].bounds.size.width-40, [UIScreen mainScreen].bounds.size.width-40);
        self.mediaItemButton.backgroundColor = [UIColor clearColor];
        [self.mediaItemButton setImage:[UIImage imageNamed:@"play_alt-512"] forState:UIControlStateNormal];
        [self.contentView addSubview:self.mediaItemButton];
        [self.mediaItemButton addTarget:self action:@selector(tapPlay) forControlEvents:UIControlEventTouchUpInside];
        
        [self.contentView addSubview:self.lblDescription];
        [self.contentView bringSubviewToFront:self.imageView];
        [self.contentView bringSubviewToFront:self.mediaItemButton];


//        self.imageView.backgroundColor = UIColor.redColor;
//        self.mediaItemButton.backgroundColor = UIColor.blueColor;
//        self.imageView.backgroundColor = UIColor.grayColor;
//        self.movie.view.backgroundColor = UIColor.greenColor;

    }
    
    return self;
}
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
        [self.imageView setFrame:CGRectMake(20, labelHeight + 40, SCR_W - 40, (SCR_W - 40) * 1)];
//                                            height / width)];
    }
        
    else {
        [self.lblDescription setFrame:CGRectMake(20, 20, SCR_W - 40, labelHeight)];
        [self.imageView setFrame:CGRectMake(20, 20, SCR_W - 40, (SCR_W - 40) * 1)];
    }
    self.mediaItemButton.frame = self.imageView.frame;
 
}
- (void) tapPlay {
    if (self.movie.player.timeControlStatus != AVPlayerTimeControlStatusPlaying) {
//        [self.videoImageView setHidden:YES];
        CGRect rt = self.movie.view.frame;
        rt.size.width = SCR_W - 40;
        rt.size.height = SCR_W - 40;
        self.movie.view.frame = rt;
//        [self.mediaItemButton setHidden:YES];
        self.movie.view.hidden = false;
        [self.contentView bringSubviewToFront:self.movie.view];
        [self.movie.player play];
              
    }
    
}

@end
