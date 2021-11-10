//
//  ESEditVedioViewController.m
//  VIP Billionaires
//
//  Created by jts on 26/06/18.
//  Copyright © 2018 Eric Schanet. All rights reserved.
//

#import "ESEditVedioViewController.h"
#import "ESPhotoDetailsFooterView.h"
#import "UIImage+ResizeAdditions.h"
#import "MBProgressHUD.h"
#import <QuartzCore/QuartzCore.h>
#import "PXAlertView.h"
#import <CoreLocation/CoreLocation.h>
#import "SCLAlertView.h"

@interface ESEditVedioViewController ()

@end

@implementation ESEditVedioViewController

@synthesize scrollView;
@synthesize image;
@synthesize commentTextField;
@synthesize photoFile;
@synthesize thumbnailFile;
@synthesize fileUploadBackgroundTaskId;
@synthesize photoPostBackgroundTaskId;
@synthesize photoImageView;
@synthesize vedioUrl;

#pragma mark - NSObject
- (id)initWithImage:(UIImage *)aImage url:(NSURL*)url isEditView:(BOOL)isEditView{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        
        if (isEditView == FALSE) {

        if (!aImage) {
            return nil;
        }
        
        }
        self.image = aImage;
        self.vedioUrl = url;
        
        NSData *data = [[NSData alloc] initWithContentsOfURL:self.vedioUrl];
        
        NSLog(@"%lu",(unsigned long)data.length);

        self.vedioData = data;
        NSLog(@"%lu",(unsigned long)self.vedioData.length);

        
        self.fileUploadBackgroundTaskId = UIBackgroundTaskInvalid;
        self.photoPostBackgroundTaskId = UIBackgroundTaskInvalid;
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UIViewController

- (void)initUI {
    self.navigationController.navigationBar.translucent = YES;
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
   
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    self.scrollView.backgroundColor = [UIColor whiteColor];
    self.scrollView.delegate = self;
    self.view = self.scrollView;
    if ([UIScreen mainScreen].bounds.size.height > 500) {
        photoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20.0f, 20.0f, [UIScreen mainScreen].bounds.size.width - 40, [UIScreen mainScreen].bounds.size.width - 40)];
    }
    else {
        photoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20.0f, 20.0f, [UIScreen mainScreen].bounds.size.width - 40, [UIScreen mainScreen].bounds.size.width - 40)];
    }
    [photoImageView setBackgroundColor:[UIColor clearColor]];
   // [photoImageView setImage:self.image];
    
    
    [photoImageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.scrollView addSubview:photoImageView];
    
    self.movie = [[AVPlayerViewController alloc] init];
    self.movie.videoGravity = AVLayerVideoGravityResizeAspect;
    
    [self.scrollView addSubview:self.movie.view];
    [self.scrollView bringSubviewToFront:self.movie.view];
    
    
//    self.movie = [[AVPlayerViewController alloc] init];
//    self.movie.controlStyle = MPMovieControlStyleEmbedded;
//    self.movie.scalingMode = MPMovieScalingModeAspectFit;
//    [self.scrollView addSubview:self.movie.view];
//    [self.scrollView bringSubviewToFront:self.movie.view];
    self.movie.view.frame = CGRectMake( 20.0f, 20.0f, [UIScreen mainScreen].bounds.size.width-40, [UIScreen mainScreen].bounds.size.width-40);
    self.movie.view.hidden = YES;
    self.mediaItemButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.mediaItemButton.frame = CGRectMake( 20.0f, 20.0f, [UIScreen mainScreen].bounds.size.width-40, [UIScreen mainScreen].bounds.size.width-40);
    self.mediaItemButton.backgroundColor = [UIColor clearColor];
    [self.mediaItemButton setImage:[UIImage imageNamed:@"play_alt-512"] forState:UIControlStateNormal];
    [self.mediaItemButton addTarget:self action:@selector(btnMediaPlayPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:self.mediaItemButton];
    
    
    [self.scrollView bringSubviewToFront:self.movie.view];

    [self.scrollView bringSubviewToFront:self.photoImageView];

    [self.scrollView bringSubviewToFront:self.mediaItemButton];
    
    CALayer *layer = photoImageView.layer;
    layer.masksToBounds = NO;
    layer.shadowRadius = 3.0f;
    layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
    layer.shadowOpacity = 0.5f;
    layer.shouldRasterize = YES;
    
    
    CGRect footerRect = [ESPhotoDetailsFooterView rectForView];
    footerRect.origin.y = photoImageView.frame.origin.y + photoImageView.frame.size.height;
    
    footerRect.size.height = footerRect.size.height + 50;
    
    ESPhotoDetailsFooterView *footerView = [[ESPhotoDetailsFooterView alloc] initWithFrame:footerRect];
    self.commentTextField = footerView.commentField;
    self.commentTextField.delegate = self;
    [self.scrollView addSubview:footerView];
    
    self.commentTextField.placeholder = NSLocalizedString(@"Add a caption", nil);
    
    if (self.isEdit == TRUE) {
        
        self.commentTextField.text = self.descriptionPhoto;
        
        if (self.photoFile != nil) {
            
            [self.photoFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                if (!data) {
                    return NSLog(@"%@", error);
                }
                
                [photoImageView setImage:[UIImage imageWithData:data]];
                
            }];
        }
        
    }
    else
    {
        [photoImageView setImage:self.image];
        
    }
    
    footerView.backgroundColor = [UIColor clearColor];
    
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.bounds.size.width, photoImageView.frame.origin.y + photoImageView.frame.size.height + footerView.frame.size.height)];
    
    NSData *videoData = [[NSData alloc] initWithContentsOfURL:self.vedioUrl];
    
    NSLog(@"%lu",(unsigned long)videoData.length);

}
-(IBAction)btnMediaPlayPressed:(id)sender
{
    if (self.isEdit == FALSE) {
   
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"myMove.mp4"];
    
    [[NSFileManager defaultManager] createFileAtPath:path contents:self.vedioData attributes:nil];
    
    NSURL *moveUrl = [NSURL fileURLWithPath:path];
    
        
//        NSURL *movieUrl = [NSURL fileURLWithPath:moveUrl];
        AVPlayer *player = [AVPlayer playerWithURL:moveUrl];
        self.movie.player = player;
        self.movie.view.frame = CGRectMake(20,20, SCR_W - 40, SCR_W - 40);
        self.movie.view.hidden = NO;
//
//
//    [self.movie setContentURL:moveUrl];
//
    
        
    }
    else
    {
        PFFile *_video =[self.editVideoObject objectForKey:kESVideoFileKey];
        if (_video) {
            [_video getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                if (!error) {
                    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                    NSString *documentsDirectory = [paths objectAtIndex:0];
                    NSString *appFile = [documentsDirectory stringByAppendingPathComponent:@"MyFile.m4v"];
                    [data writeToFile:appFile atomically:YES];
                    NSURL *movieUrl = [NSURL fileURLWithPath:appFile];
//                    [self.movie setContentURL:movieUrl];
                    AVPlayer *player = [AVPlayer playerWithURL:movieUrl];
                    self.movie.view.frame = CGRectMake(20,20, SCR_W - 40, SCR_W - 40);
                    self.movie.player = player;
                }
            }];
        }
    }
    
//    if (self.movie.st != MPMoviePlaybackStatePlaying) {
    {
        self.mediaItemButton.hidden = YES;
        self.photoImageView.hidden = YES;
        self.movie.view.frame = CGRectMake(20,20, SCR_W - 40, SCR_W - 40);
//        [self.movie prepareToPlay];
        [self.movie.player play];
        self.movie.view.hidden = NO;
        
    }

}
- (void)viewDidLoad {
    [super viewDidLoad];
    //    self.view.backgroundColor = [UIColor colorWithWhite:0.90 alpha:1];
    [self.navigationItem setHidesBackButton:YES];
    
    self.navigationItem.titleView = nil;//[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LogoNavigationBar"]];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(cancelButtonAction:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Publish", nil) style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonAction:)];
    
    [self.navigationItem.leftBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:def_Golden_Color,  UITextAttributeTextColor,nil] forState:UIControlStateNormal];
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:def_Golden_Color,  UITextAttributeTextColor,nil] forState:UIControlStateNormal];
    
    self.navigationItem.leftBarButtonItem.tintColor = def_Golden_Color;
    self.navigationItem.rightBarButtonItem.tintColor = def_Golden_Color;
    
    if (self.isEdit == FALSE) {
        
        [self shouldUploadImage:self.image];
        
    }
    UIImageView * imgBG = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SCR_W, SCR_H)];
    imgBG.image = [UIImage imageNamed:@"background_splash"];
    [self.view addSubview:imgBG];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
#ifdef __IPHONE_8_0
    if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [locationManager requestWhenInUseAuthorization];
    }
#endif
    [locationManager startUpdatingLocation];
    
    [self initUI];
    
    
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self doneButtonAction:textField];
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.commentTextField resignFirstResponder];
}


#pragma mark - ()

- (BOOL)shouldUploadImage:(UIImage *)anImage {
    
    UIImage *resizedImage = [anImage resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(560.0f, 560.0f * anImage.size.height / anImage.size.width) interpolationQuality:kCGInterpolationHigh];
    UIImage *thumbnailImage = [anImage thumbnailImage:86.0f transparentBorder:0.0f cornerRadius:42.0f interpolationQuality:kCGInterpolationDefault];
    
    // JPEG to decrease file size and enable faster uploads & downloads
    NSData *imageData = UIImageJPEGRepresentation(resizedImage, 0.8f);
    NSData *thumbnailImageData = UIImagePNGRepresentation(thumbnailImage);
    
    if (!imageData || !thumbnailImageData) {
        return NO;
    }
    
    self.photoFile = [PFFile fileWithData:imageData];
    self.thumbnailFile = [PFFile fileWithData:thumbnailImageData];
    
    // Request a background execution task to allow us to finish uploading the photo even if the app is backgrounded
    self.fileUploadBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
    }];
    
    [self.photoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [self.thumbnailFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
            }];
        } else {
            [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
        }
    }];
    
    return YES;
}

- (void)keyboardWillShow:(NSNotification *)note {
    CGRect keyboardFrameEnd = [[note.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGSize scrollViewContentSize = self.scrollView.bounds.size;
    scrollViewContentSize.height += keyboardFrameEnd.size.height;
    [self.scrollView setContentSize:scrollViewContentSize];
    
    CGPoint scrollViewContentOffset = self.scrollView.contentOffset;
    // Align the bottom edge of the photo with the keyboard
    scrollViewContentOffset.y = scrollViewContentOffset.y + keyboardFrameEnd.size.height*3.0f - [UIScreen mainScreen].bounds.size.height;
    
    [self.scrollView setContentOffset:scrollViewContentOffset animated:YES];
}

- (void)keyboardWillHide:(NSNotification *)note {
    CGRect keyboardFrameEnd = [[note.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGSize scrollViewContentSize = self.scrollView.bounds.size;
    scrollViewContentSize.height -= keyboardFrameEnd.size.height;
    [UIView animateWithDuration:0.200f animations:^{
        [self.scrollView setContentSize:scrollViewContentSize];
    }];
}

- (void)doneButtonAction:(id)sender {
    
    NSDictionary *userInfo = [NSDictionary dictionary];
    NSString *trimmedComment = [self.commentTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (trimmedComment.length != 0) {
        //   userInfo = [NSDictionary dictionaryWithObjectsAndKeys:trimmedComment,kESEditPhotoViewControllerUserInfoCommentKey, nil];
        
        userInfo = [NSDictionary dictionaryWithObjectsAndKeys:trimmedComment,kESEditPhotoViewControllerDescriptionKey, nil];
        
    }
    PFACL *ACL = [PFACL ACLWithUser:[PFUser currentUser]];
    [ACL setPublicReadAccess:YES];
    [ACL setWriteAccess:YES forUser:[PFUser currentUser]];
    
    PFObject *videoObject;
    
    if (self.isEdit == TRUE) {
        
        [self.editVideoObject setObject:trimmedComment forKey:kESEditPhotoViewControllerDescriptionKey];
        videoObject = self.editVideoObject;
    }
    else
    {
        UIImage *thumbnailImage = [image thumbnailImage:86.0f transparentBorder:0.0f cornerRadius:42.0f interpolationQuality:kCGInterpolationDefault];
        
        NSData *imageData = UIImageJPEGRepresentation(image, 0.8f);
        PFFile *thumbnail = [PFFile fileWithData:imageData];
        NSData *_imageData = UIImageJPEGRepresentation(thumbnailImage, 0.8f);
        PFFile *_thumbnail = [PFFile fileWithData:_imageData];
        
        //NSData *videoData = [[NSData alloc] initWithContentsOfURL:self.vedioUrl];
        
        NSLog(@"%lu",(unsigned long)self.vedioData.length);
        
        
        
        NSLog(@"File size is : %.2f MB",(float)self.vedioData.length/1024.0f/1024.0f);
        
        double vedioSize = (float)self.vedioData.length/1024.0f/1024.0f;
        
        if (vedioSize > 10) {
            
            [ProgressHUD showError:@"Video should not be larger than 10 MB"];
            return;
        }
        
       
        
        // Make sure there were no errors creating the image files
        if (!self.photoFile || !self.thumbnailFile) {
            [PXAlertView showAlertWithTitle:nil
                                    message:NSLocalizedString(@"Couldn't post your photo, a network error occurred.", nil)
                                cancelTitle:@"OK"
                                 completion:^(BOOL cancelled, NSInteger buttonIndex) {
                                     if (cancelled) {
                                         NSLog(@"Simple Alert View cancelled");
                                     } else {
                                         NSLog(@"Simple Alert View dismissed, but not cancelled");
                                     }
                                 }];
            return;
        }
        [ProgressHUD show:NSLocalizedString(@"Uploading", nil)];
        
        // both files have finished uploading
        
        // create a photo object
        
        PFFile *videoFile = [PFFile fileWithData:self.vedioData];
        NSLog(@"%@",[NSByteCountFormatter stringFromByteCount:self.vedioData.length countStyle:NSByteCountFormatterCountStyleFile]);
        
        videoObject = [PFObject objectWithClassName:kESPhotoClassKey];
        [videoObject setObject:videoFile forKey:kESVideoFileKey];
        [videoObject setObject:thumbnail forKey:kESVideoFileThumbnailKey];
        [videoObject setObject:_thumbnail forKey:kESVideoFileThumbnailRoundedKey];
        [videoObject setObject:kESVideoTypeKey forKey:kESVideoOrPhotoTypeKey];
        [videoObject setACL:ACL];
        [videoObject setObject:[PFUser currentUser] forKey:@"user"];
        [videoObject setObject:trimmedComment forKey:kESEditPhotoViewControllerDescriptionKey];
    }
    
    
   /* PFObject *videoObject = [PFObject objectWithClassName:kESPhotoClassKey];
    [videoObject setObject:videoFile forKey:kESVideoFileKey];
    [videoObject setObject:thumbnail forKey:kESVideoFileThumbnailKey];
    [videoObject setObject:_thumbnail forKey:kESVideoFileThumbnailRoundedKey];
    [videoObject setObject:kESVideoTypeKey forKey:kESVideoOrPhotoTypeKey];
    [videoObject setACL:ACL];
    [videoObject setObject:[PFUser currentUser] forKey:@"user"];
    [videoObject setObject:trimmedComment forKey:kESEditPhotoViewControllerDescriptionKey];*/
    
    
    if (localityString && [[[PFUser currentUser] objectForKey:@"locationServices"] isEqualToString:@"YES"]) {
        [videoObject setObject:localityString forKey:kESPhotoLocationKey];
    }
    
        self.photoPostBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.photoPostBackgroundTaskId];
    }];
    
    // Save the Photo PFObject
    [videoObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"videoUploadEnds" object:nil];

        if (succeeded) {
            
            [ProgressHUD dismiss];
                        
            [[NSNotificationCenter defaultCenter] postNotificationName:@"videoUploadSucceeds" object:nil];
            
            
        } else {
            [PXAlertView showAlertWithTitle:nil
                                    message:NSLocalizedString(@"Couldn't post your photo, a network error occurred.", nil)
                                cancelTitle:@"OK"
                                 completion:^(BOOL cancelled, NSInteger buttonIndex) {
                                     if (cancelled) {
                                         NSLog(@"Simple Alert View cancelled");
                                     } else {
                                         NSLog(@"Simple Alert View dismissed, but not cancelled");
                                     }
                                 }];
        }
        [[UIApplication sharedApplication] endBackgroundTask:self.photoPostBackgroundTaskId];
    }];
    
    // Dismiss this screen
    if (self.isEdit == TRUE) {
        
        [self.navigationController popToRootViewControllerAnimated:TRUE];
    }
    else
    {
        [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
        
    }}

- (void)cancelButtonAction:(id)sender {
    if (self.isEdit == TRUE) {
        
        [self.navigationController popViewControllerAnimated:TRUE];
    }
    else
    {
        [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
        
    }}

#pragma mark - CLLocationManager delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    
    CLGeocoder * geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        for (CLPlacemark * placemark in placemarks) {
            localityString = [placemark locality];
            NSLog(@"%@", [placemark locality]);
            [locationManager stopUpdatingLocation];
        }
    }];
    
}
// this delegate method is called if an error occurs in locating your current location
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"locationManager:%@ didFailWithError:%@", manager, error);
}
@end

