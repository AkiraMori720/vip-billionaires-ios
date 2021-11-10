//
//  ESEditPhotoViewController.m
//  D'Netzwierk
//
//  Created by Eric Schanet on 6/05/2014.
//  Copyright (c) 2014 Eric Schanet. All rights reserved.
//

#import "ESEditPhotoViewController.h"
#import "ESPhotoDetailsFooterView.h"
#import "UIImage+ResizeAdditions.h"
#import "MBProgressHUD.h"
#import <QuartzCore/QuartzCore.h>
#import "PXAlertView.h"
#import <CoreLocation/CoreLocation.h>


@implementation ESEditPhotoViewController
@synthesize scrollView;
@synthesize image;
@synthesize commentTextField;
@synthesize photoFile;
@synthesize thumbnailFile;
@synthesize fileUploadBackgroundTaskId;
@synthesize photoPostBackgroundTaskId;
@synthesize photoImageView;

#pragma mark - NSObject
- (id)initWithImage:(UIImage *)aImage isEditView:(BOOL)isEditView {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        
        if (isEditView == FALSE) {
            
            if (!aImage) {
                return nil;
            }
        }
        
        self.image = aImage;
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

    self.scrollView = [[UIScrollView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.scrollView.delegate = self;
    self.view = self.scrollView;
    if ([UIScreen mainScreen].bounds.size.height > 500) {
        photoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 80.0f, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width)];
    }
    else {
        photoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 65.0f, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width)];
    }
    [photoImageView setBackgroundColor:[UIColor clearColor]];
    [photoImageView setContentMode:UIViewContentModeScaleAspectFit];
    
   

//    CALayer *layer = photoImageView.layer;
//    layer.masksToBounds = NO;
//    layer.shadowRadius = 3.0f;
//    layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
//    layer.shadowOpacity = 0.5f;
//    layer.shouldRasterize = YES;
    
    [self.scrollView addSubview:photoImageView];
    
    CGRect footerRect = [ESPhotoDetailsFooterView rectForView];
    footerRect.origin.y =  20; //photoImageView.frame.origin.y + photoImageView.frame.size.height;

    footerRect.size.height = footerRect.size.height + 50;
    
    ESPhotoDetailsFooterView *footerView = [[ESPhotoDetailsFooterView alloc] initWithFrame:footerRect];
    footerView.hideDropShadow = YES;
    self.commentTextField = footerView.commentField;
//    self.commentTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 30, SCR_W - 40, 25)];
    self.commentTextField.delegate = self;
    [self.scrollView addSubview:footerView];
//    [self.scrollView addSubview:self.commentTextField];
    UIView* underline = [[UIView alloc] initWithFrame:CGRectMake(20, 55, SCR_W - 40, 1)];
    [underline setBackgroundColor:[UIColor colorWithWhite:0.5 alpha:1]];
    [self.scrollView addSubview:underline];
    self.commentTextField.placeholder = NSLocalizedString(@"Say something about this photo", nil);
    [footerView setHideCommentIcon:YES];
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
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.view.backgroundColor = [UIColor colorWithWhite:0.90 alpha:1];
    [self.navigationItem setHidesBackButton:YES];
    
    self.navigationItem.title = NSLocalizedString(@"CREATE POST", nil);
    self.navigationController.navigationBar.titleTextAttributes = @{
        NSForegroundColorAttributeName: [UIColor whiteColor]
    };//[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LogoNavigationBar"]];
    
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
    
    UIBarButtonItem* saveInfoBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Save", nil) style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonAction:)];
    [saveInfoBtn setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:def_Golden_Color,  UITextAttributeTextColor,nil] forState:UIControlStateNormal];
    UIButton *saveBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 5, 80, 30)];
    
    [saveBtn setTitle:NSLocalizedString(@"Save", nil) forState:UIControlStateNormal];
    saveBtn.titleLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:14];
    [saveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    saveBtn.backgroundColor = def_Golden_Color;
    [saveBtn addTarget:self action:@selector(doneButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    saveBtn.layer.cornerRadius = 15;
    saveInfoBtn.customView = saveBtn;
    saveInfoBtn.customView.backgroundColor = def_Golden_Color;
    self.navigationItem.rightBarButtonItem = saveInfoBtn;
    
    
    
    saveInfoBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil) style:UIBarButtonItemStyleDone target:self action:@selector(cancelButtonAction:)];
    [saveInfoBtn setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:def_Golden_Color,  UITextAttributeTextColor,nil] forState:UIControlStateNormal];
    saveBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 5, 80, 30)];
    
    [saveBtn setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
    saveBtn.titleLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:14];
    [saveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    saveBtn.backgroundColor = def_Golden_Color;
    [saveBtn addTarget:self action:@selector(cancelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    saveBtn.layer.cornerRadius = 15;
    saveInfoBtn.customView = saveBtn;
    saveInfoBtn.customView.backgroundColor = def_Golden_Color;
    self.navigationItem.leftBarButtonItem = saveInfoBtn;
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    self.view.backgroundColor = [UIColor whiteColor];
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
    UIImage *resizedImage = [anImage resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(560.0f, 560.0f) interpolationQuality:kCGInterpolationHigh];
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
    
    // both files have finished uploading
    
    // create a photo object
    
    PFObject *photo;
    
     if (self.isEdit == TRUE) {
        
         [self.editPhotoObject setObject:trimmedComment forKey:kESEditPhotoViewControllerDescriptionKey];
         photo = self.editPhotoObject;
     }
    else
    {
        photo = [PFObject objectWithClassName:kESPhotoClassKey];
        [photo setObject:[PFUser currentUser] forKey:kESPhotoUserKey];
        [photo setObject:self.photoFile forKey:kESPhotoPictureKey];
        [photo setObject:self.thumbnailFile forKey:kESPhotoThumbnailKey];
        [photo setObject:trimmedComment forKey:kESEditPhotoViewControllerDescriptionKey];
    }
    
    
   
    
    if (localityString && [[[PFUser currentUser] objectForKey:@"locationServices"] isEqualToString:@"YES"]) {
        [photo setObject:localityString forKey:kESPhotoLocationKey];
    }
    
    // photos are public, but may only be modified by the user who uploaded them
    PFACL *photoACL = [PFACL ACLWithUser:[PFUser currentUser]];
    [photoACL setPublicReadAccess:YES];
    [photoACL setPublicWriteAccess:YES]; // forUser:[PFUser currentUser]];
    photo.ACL = photoACL;
    
    // Request a background execution task to allow us to finish uploading the photo even if the app is backgrounded
    self.photoPostBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.photoPostBackgroundTaskId];
    }];

    // Save the Photo PFObject
    
    
    [photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [[ESCache sharedCache] setAttributesForPhoto:photo likers:[NSArray array] commenters:[NSArray array] likedByCurrentUser:NO];
            
            // userInfo might contain any caption which might have been posted by the uploader
            if (userInfo) {
                
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:ESTabBarControllerDidFinishEditingPhotoNotification object:photo];
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
    
  /*  if (self.isEdit == TRUE) {

    [photo deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        
        if (error == nil) {
            
            [photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    [[ESCache sharedCache] setAttributesForPhoto:photo likers:[NSArray array] commenters:[NSArray array] likedByCurrentUser:NO];
                    
                    // userInfo might contain any caption which might have been posted by the uploader
                    if (userInfo) {
                        
                    }
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:ESTabBarControllerDidFinishEditingPhotoNotification object:photo];
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
        }
    }];
    }*/
    
   
    
    // Dismiss this screen
    
    if (self.isEdit == TRUE) {
        
        [self.navigationController popToRootViewControllerAnimated:TRUE];
    }
    else
    {
        [self.parentViewController dismissViewControllerAnimated:YES completion:nil];

    }
}

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
